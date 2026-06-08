<?php

namespace App\Services;

use App\Models\Gestion;
use App\Models\Grupo;
use App\Models\Postulante;
use Illuminate\Support\Facades\DB;

/**
 * CU-11 · Lógica de negocio de la gestión de grupos (entidad grupo).
 * No contiene nada de asignación de docentes (eso es CU-12 / AsignacionService).
 */
class GrupoService
{
    /** Capacidad por defecto. Configurable; única fuente del divisor (ver §7 del enunciado). */
    public const CAPACIDAD_DEFAULT = 70;

    /**
     * CantidadGrupos = ceil(TotalInscritos / capacidad). Cálculo ESTRICTO con
     * división flotante: 11/10 → 2 (NUNCA intdiv/(int), que truncan a 1).
     */
    public function calcularCantidadGrupos(int $totalInscritos, int $capacidad = self::CAPACIDAD_DEFAULT): int
    {
        if ($capacidad < 1 || $totalInscritos < 1) {
            return 0;
        }

        return (int) ceil($totalInscritos / $capacidad);
    }

    /** Query de inscritos de la gestión que aún NO tienen grupo (excluye preinscritos). */
    public function inscritosSinGrupo(Gestion $gestion)
    {
        $yaConGrupo = DB::table('grupo_postulante')->pluck('postulante_id')->all();

        return Postulante::where('gestion_id', $gestion->id)
            ->where('estado', '!=', 'preinscrito')
            ->whereNotIn('id', $yaConGrupo ?: [0])
            ->orderBy('id');
    }

    /** Total de inscritos de la gestión que cuentan para grupos (excluye preinscritos). */
    public function totalInscritos(Gestion $gestion): int
    {
        return Postulante::where('gestion_id', $gestion->id)->where('estado', '!=', 'preinscrito')->count();
    }

    /**
     * Crea ⌈inscritosSinGrupo / capacidad⌉ grupos del turno y modalidad indicados,
     * y distribuye a los inscritos en bloques estrictos de `capacidad`
     * (intdiv solo para INDEXAR el bloque). Transaccional.
     *
     * @return array{grupos_creados:int,total_distribuido:int}
     */
    public function generarGruposAutomaticos(Gestion $gestion, int $capacidad, string $turno, string $modalidad = 'presencial'): array
    {
        return DB::transaction(function () use ($gestion, $capacidad, $turno, $modalidad) {
            $inscritos = $this->inscritosSinGrupo($gestion)->get();
            $total = $inscritos->count();
            $cantidad = $this->calcularCantidadGrupos($total, $capacidad);

            if ($cantidad === 0) {
                return ['grupos_creados' => 0, 'total_distribuido' => 0];
            }

            // Crea los grupos del turno con código único correlativo G-<T>-NN.
            $ini = $this->inicialTurno($turno);
            $n = Grupo::where('gestion_id', $gestion->id)->where('turno', $turno)->count();
            $grupos = [];
            for ($i = 1; $i <= $cantidad; $i++) {
                do {
                    $n++;
                    $codigo = sprintf('G-%s-%02d', $ini, $n);
                } while (Grupo::where('codigo', $codigo)->exists());

                $grupos[] = Grupo::create([
                    'gestion_id' => $gestion->id,
                    'codigo' => $codigo,
                    'turno' => $turno,
                    'modalidad' => $modalidad,
                    'capacidad_maxima' => $capacidad,
                    'estado' => true,
                ]);
            }

            // Distribución estricta: el inscrito #index cae en el bloque intdiv(index, capacidad).
            $now = now();
            foreach ($inscritos as $index => $inscrito) {
                $grupo = $grupos[intdiv($index, $capacidad)];
                DB::table('grupo_postulante')->insert([
                    'grupo_id' => $grupo->id, 'postulante_id' => $inscrito->id,
                    'created_at' => $now, 'updated_at' => $now,
                ]);
                if ($inscrito->estado === 'inscrito') {
                    $inscrito->update(['estado' => 'en_curso']);
                }
            }

            return ['grupos_creados' => $cantidad, 'total_distribuido' => $total];
        });
    }

    /** Inicial del turno para el código del grupo (M/T/N). */
    private function inicialTurno(string $turno): string
    {
        return match ($turno) {
            'mañana' => 'M',
            'tarde' => 'T',
            'noche' => 'N',
            default => strtoupper(substr($turno, 0, 1)),
        };
    }
}
