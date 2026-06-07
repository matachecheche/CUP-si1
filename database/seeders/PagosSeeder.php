<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * CU-20: datos de prueba para la pasarela de pagos. IDEMPOTENTE: puede
 * ejecutarse sobre la BD ya sembrada sin duplicar registros.
 *  1. Pagos CONFIRMADOS retroactivos para los postulantes históricos
 *     (todo el que avanzó más allá de 'preinscrito' pagó en su momento).
 *  2. 8 postulantes nuevos en 'preinscrito' con su pago 'pendiente',
 *     para demostrar el flujo Stripe de punta a punta.
 *  3. 1 intento 'fallido' (variedad de estados/badges en el panel CU-20).
 *  4. Vincula el usuario demo postulante@cup.edu.bo al primer preinscrito.
 */
class PagosSeeder extends Seeder
{
    public function run(): void
    {
        $gestion = DB::table('gestiones')->where('estado', 'en_curso')->first()
                ?? DB::table('gestiones')->orderBy('id')->first();
        if (! $gestion) {
            $this->command?->warn('PagosSeeder: no hay gestiones; ejecuta CupDataSeeder primero.');
            return;
        }
        $costo = $gestion->costo_inscripcion ?? 850.00;
        $anio  = now()->year;

        // ── 1. Pagos confirmados retroactivos ───────────────────────────────
        $conPago    = DB::table('pagos')->pluck('postulante_id')->all();
        $historicos = DB::table('postulantes')
            ->where('gestion_id', $gestion->id)
            ->where('estado', '!=', 'preinscrito')
            ->whereNotIn('id', $conPago ?: [0])
            ->get(['id', 'created_at']);

        $filas = [];
        foreach ($historicos as $p) {
            $f = \Carbon\Carbon::parse($p->created_at)->addHours(rand(1, 72));
            $filas[] = [
                'postulante_id' => $p->id, 'gestion_id' => $gestion->id,
                'monto' => $costo, 'moneda' => 'BOB', 'metodo' => 'stripe',
                'estado' => 'pagado', 'fecha_pago' => $f,
                'created_at' => $f, 'updated_at' => $f,
            ];
        }
        foreach (array_chunk($filas, 100) as $chunk) {
            DB::table('pagos')->insert($chunk);
        }

        // Comprobante con el MISMO formato que PagoController::confirmar()
        DB::statement("UPDATE pagos SET comprobante = 'CUP-{$anio}-' || LPAD(id::text, 5, '0')
                       WHERE comprobante IS NULL AND estado = 'pagado'");

        // ── 2. Postulantes demo 'preinscrito' + pago pendiente ──────────────
        $carreras = DB::table('carreras')->pluck('id')->all();
        $demo = [
            ['Lucía', 'Suárez Roca'], ['Marcelo', 'Justiniano Paz'],
            ['Valeria', 'Camacho Ortiz'], ['Diego', 'Saucedo Flores'],
            ['Camila', 'Terceros Vaca'], ['Rodrigo', 'Peña Aguilera'],
            ['Fernanda', 'Salvatierra Gil'], ['Andrés', 'Cuéllar Ribera'],
        ];
        $primerPreinscritoId = null;

        foreach ($demo as $i => [$nom, $ape]) {
            $ci  = (string) (90000001 + $i);
            $pid = DB::table('postulantes')->where('ci', $ci)->value('id');
            if (! $pid) {
                shuffle($carreras);
                $pid = DB::table('postulantes')->insertGetId([
                    'gestion_id'          => $gestion->id,
                    'primera_opcion_id'   => $carreras[0],
                    'segunda_opcion_id'   => $carreras[1],
                    'ci'                  => $ci,
                    'nombres'             => $nom,
                    'apellidos'           => $ape,
                    'fecha_nacimiento'    => now()->subYears(rand(17, 20))->subDays(rand(0, 365))->toDateString(),
                    'sexo'                => $i % 2 === 0 ? 'F' : 'M',
                    'direccion'           => 'B/ Equipetrol, calle '.($i + 2),
                    'telefono'            => '7'.rand(1000000, 9999999),
                    'email'               => 'demo.pago'.($i + 1).'@cup.edu.bo',
                    'colegio_procedencia' => 'Colegio Nacional Florida',
                    'ciudad'              => 'Santa Cruz',
                    'doc_ci' => true, 'doc_libreta_colegio' => true, 'doc_titulo_bachiller' => true,
                    'estado'              => 'preinscrito',
                    'created_at' => now(), 'updated_at' => now(),
                ]);
            }
            $primerPreinscritoId ??= $pid;

            $tienePendiente = DB::table('pagos')
                ->where('postulante_id', $pid)->where('estado', 'pendiente')->exists();
            if (! $tienePendiente) {
                DB::table('pagos')->insert([
                    'postulante_id' => $pid, 'gestion_id' => $gestion->id,
                    'monto' => $costo, 'moneda' => 'BOB', 'metodo' => 'stripe',
                    'estado' => 'pendiente', 'created_at' => now(), 'updated_at' => now(),
                ]);
            }
        }

        // ── 3. Un intento fallido (badge rojo en el panel) ──────────────────
        if ($primerPreinscritoId && ! DB::table('pagos')->where('estado', 'fallido')->exists()) {
            DB::table('pagos')->insert([
                'postulante_id' => $primerPreinscritoId, 'gestion_id' => $gestion->id,
                'monto' => $costo, 'moneda' => 'BOB', 'metodo' => 'stripe',
                'estado' => 'fallido',
                'created_at' => now()->subDay(), 'updated_at' => now()->subDay(),
            ]);
        }

        // ── 4. Adoptar al usuario demo huérfano ─────────────────────────────
        if ($primerPreinscritoId) {
            User::where('email', 'postulante@cup.edu.bo')
                ->whereNull('postulante_id')
                ->update(['postulante_id' => $primerPreinscritoId]);
        }

        $this->command?->info('PagosSeeder: pagos históricos + 8 preinscritos demo listos.');
    }
}
