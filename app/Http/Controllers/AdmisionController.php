<?php
namespace App\Http\Controllers;

use App\Models\{Admision, CupoCarrera, Gestion, Postulante};
use App\Traits\BitacoraTrait;
use Illuminate\Support\Facades\DB;

/**
 * Proceso de admisión en 3 pasos, cada uno con interfaz y lógica propia:
 *  CU-16 asigna la 1ª opción por ranking de promedio hasta llenar cupos;
 *  CU-17 reasigna los aprobados sin cupo a su 2ª opción (o no admitido);
 *  CU-18 publica los resultados y materializa el acta de los reprobados,
 *  habilitando la consulta pública (CU-22). Incluye reinicio del proceso.
 */
class AdmisionController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver admision')->only('index', 'primera', 'segunda', 'publicacion');
        $this->middleware('permission:procesar admision')->only('procesarPrimera', 'procesarSegunda', 'reiniciar');
        $this->middleware('permission:publicar admision')->only('publicar');
    }

    /** Tablero del proceso (wizard de 3 pasos). */
    public function index()
    {
        $gestion = $this->gestionActiva();
        $e = $gestion ? $this->estadoProceso($gestion) : null;
        return view('admision.index', compact('gestion', 'e'));
    }

    /** CU-16: pantalla de procesamiento por primera opción. */
    public function primera()
    {
        $gestion = $this->gestionActiva();
        abort_unless($gestion, 404);
        $e = $this->estadoProceso($gestion);

        // Proyección: simula el ranking contra los cupos libres de la 1ª opción
        $libres = collect($e['cupos'])->pluck('libres', 'id')->toArray();
        $candidatos = $e['pendientes']->map(function ($p) use (&$libres) {
            $entra = ($libres[$p->primera_opcion_id] ?? 0) > 0;
            if ($entra) $libres[$p->primera_opcion_id]--;
            $p->proyeccion = $entra ? 'entra' : 'segunda';
            return $p;
        });

        $admitidos = Admision::with(['postulante', 'carreraAsignada'])
            ->where('gestion_id', $gestion->id)->where('resultado', 'admitido_primera')
            ->orderByDesc('promedio_general')->get();

        return view('admision.primera', compact('gestion', 'e', 'candidatos', 'admitidos'));
    }

    /** CU-16: ejecuta la asignación por 1ª opción. */
    public function procesarPrimera()
    {
        $gestion = $this->gestionActiva();
        abort_unless($gestion, 404);

        [$ok, $sinCupo] = DB::transaction(function () use ($gestion) {
            $e = $this->estadoProceso($gestion);
            $libres = collect($e['cupos'])->pluck('libres', 'id')->toArray();
            $a = 0; $s = 0;
            foreach ($e['pendientes'] as $p) {
                $c1 = $p->primera_opcion_id;
                if (($libres[$c1] ?? 0) > 0) {
                    Admision::updateOrCreate(['postulante_id' => $p->id], [
                        'gestion_id' => $gestion->id, 'promedio_general' => $p->promedio_general,
                        'carrera_asignada_id' => $c1, 'resultado' => 'admitido_primera', 'publicado' => false,
                    ]);
                    $p->update(['estado' => 'admitido']);
                    $libres[$c1]--; $a++;
                } else {
                    $s++; // queda 'aprobado': lo resuelve CU-17
                }
            }
            return [$a, $s];
        });

        $this->registrarEnBitacora("CU-16: {$ok} admitidos en 1ª opción; {$sinCupo} pasan a 2ª opción", null, 'Admisión');
        return redirect()->route('admision.primera')
            ->with('success', "1ª opción procesada: {$ok} admitidos, {$sinCupo} pendientes para CU-17.");
    }

    /** CU-17: pantalla de reasignación a segunda opción. */
    public function segunda()
    {
        $gestion = $this->gestionActiva();
        abort_unless($gestion, 404);
        $e = $this->estadoProceso($gestion);

        $libres = collect($e['cupos'])->pluck('libres', 'id')->toArray();
        $candidatos = $e['pendientes']->map(function ($p) use (&$libres) {
            $entra = ($libres[$p->segunda_opcion_id] ?? 0) > 0;
            if ($entra) $libres[$p->segunda_opcion_id]--;
            $p->proyeccion = $entra ? 'entra' : 'sin_cupo';
            return $p;
        });

        $reasignados = Admision::with(['postulante', 'carreraAsignada'])
            ->where('gestion_id', $gestion->id)->whereIn('resultado', ['admitido_segunda', 'no_admitido'])
            ->whereHas('postulante', fn ($q) => $q->where('estado', '!=', 'no_aprobado'))
            ->orderByDesc('promedio_general')->get();

        return view('admision.segunda', compact('gestion', 'e', 'candidatos', 'reasignados'));
    }

    /** CU-17: ejecuta la reasignación (2ª opción o no admitido). */
    public function procesarSegunda()
    {
        $gestion = $this->gestionActiva();
        abort_unless($gestion, 404);

        [$dos, $sin] = DB::transaction(function () use ($gestion) {
            $e = $this->estadoProceso($gestion);
            $libres = collect($e['cupos'])->pluck('libres', 'id')->toArray();
            $d = 0; $n = 0;
            foreach ($e['pendientes'] as $p) {
                $c2 = $p->segunda_opcion_id;
                if (($libres[$c2] ?? 0) > 0) {
                    Admision::updateOrCreate(['postulante_id' => $p->id], [
                        'gestion_id' => $gestion->id, 'promedio_general' => $p->promedio_general,
                        'carrera_asignada_id' => $c2, 'resultado' => 'admitido_segunda', 'publicado' => false,
                    ]);
                    $p->update(['estado' => 'admitido_segunda_opcion']);
                    $libres[$c2]--; $d++;
                } else {
                    Admision::updateOrCreate(['postulante_id' => $p->id], [
                        'gestion_id' => $gestion->id, 'promedio_general' => $p->promedio_general,
                        'carrera_asignada_id' => null, 'resultado' => 'no_admitido', 'publicado' => false,
                    ]);
                    $p->update(['estado' => 'no_admitido']);
                    $n++;
                }
            }
            return [$d, $n];
        });

        $this->registrarEnBitacora("CU-17: {$dos} admitidos en 2ª opción; {$sin} sin cupo (no admitidos)", null, 'Admisión');
        return redirect()->route('admision.segunda')
            ->with('success', "2ª opción procesada: {$dos} reasignados, {$sin} sin cupo.");
    }

    /** CU-18: pantalla de publicación de resultados. */
    public function publicacion()
    {
        $gestion = $this->gestionActiva();
        abort_unless($gestion, 404);
        $e = $this->estadoProceso($gestion);
        return view('admision.publicacion', compact('gestion', 'e'));
    }

    /** CU-18: publica resultados; materializa el acta de los reprobados (habilita CU-22). */
    public function publicar()
    {
        $gestion = $this->gestionActiva();
        abort_unless($gestion, 404);

        $e = $this->estadoProceso($gestion);
        if ($e['pendientes']->isNotEmpty()) {
            return redirect()->route('admision.publicacion')
                ->with('error', 'No se puede publicar: quedan '.$e['pendientes']->count().' aprobados sin asignar. Ejecuta CU-16 y CU-17 primero.');
        }

        $n = DB::transaction(function () use ($gestion) {
            // Sin acta, la consulta pública (CU-22) no podría mostrar nada a los reprobados
            Postulante::where('gestion_id', $gestion->id)->where('estado', 'no_aprobado')
                ->whereDoesntHave('admision')->get()
                ->each(fn ($p) => Admision::create([
                    'postulante_id' => $p->id, 'gestion_id' => $gestion->id,
                    'promedio_general' => $p->promedio_general, 'carrera_asignada_id' => null,
                    'resultado' => 'no_admitido', 'publicado' => false,
                ]));

            return Admision::where('gestion_id', $gestion->id)->update(['publicado' => true]);
        });

        $this->registrarEnBitacora("CU-18: publicó {$n} resultados de la gestión {$gestion->descripcion}", null, 'Admisión');
        return redirect()->route('admision.publicacion')
            ->with('success', "{$n} resultado(s) publicados. Ya son visibles en la consulta pública (CU-22).");
    }

    /** Reinicia el proceso para poder re-ejecutar CU-16 → CU-17 → CU-18 (demo/correcciones). */
    public function reiniciar()
    {
        $gestion = $this->gestionActiva();
        abort_unless($gestion, 404);

        DB::transaction(function () use ($gestion) {
            Admision::where('gestion_id', $gestion->id)->delete();
            Postulante::where('gestion_id', $gestion->id)
                ->whereIn('estado', ['admitido', 'admitido_segunda_opcion', 'no_admitido'])
                ->update(['estado' => 'aprobado']);
        });

        $this->registrarEnBitacora("Reinició el proceso de admisión de la gestión {$gestion->descripcion}", null, 'Admisión');
        return redirect()->route('admision.index')
            ->with('success', 'Proceso reiniciado: los aprobados quedaron listos para CU-16.');
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private function gestionActiva(): ?Gestion
    {
        return Gestion::where('estado', 'en_curso')->first();
    }

    /** Estado del proceso: cupos y ocupación por carrera, pendientes y contadores. */
    private function estadoProceso(Gestion $gestion): array
    {
        $asignados = Admision::where('gestion_id', $gestion->id)->whereNotNull('carrera_asignada_id')
            ->selectRaw('carrera_asignada_id, COUNT(*) n')->groupBy('carrera_asignada_id')
            ->pluck('n', 'carrera_asignada_id');

        $demanda1 = Postulante::where('gestion_id', $gestion->id)->whereIn('estado', ['aprobado', 'admitido'])
            ->selectRaw('primera_opcion_id, COUNT(*) n')->groupBy('primera_opcion_id')
            ->pluck('n', 'primera_opcion_id');

        $cupos = CupoCarrera::with('carrera')->where('gestion_id', $gestion->id)->get()
            ->map(fn ($c) => [
                'id' => $c->carrera_id,
                'carrera' => $c->carrera->nombre,
                'cupo' => $c->cantidad_maxima,
                'ocupados' => (int) ($asignados[$c->carrera_id] ?? 0),
                'libres' => max(0, $c->cantidad_maxima - (int) ($asignados[$c->carrera_id] ?? 0)),
                'demanda1' => (int) ($demanda1[$c->carrera_id] ?? 0),
            ])->sortBy('carrera')->values()->all();

        $pendientes = Postulante::with(['primeraOpcion', 'segundaOpcion'])
            ->where('gestion_id', $gestion->id)->where('estado', 'aprobado')
            ->orderByDesc('promedio_general')->orderBy('apellidos')->get();

        $adm = Admision::where('gestion_id', $gestion->id);
        return [
            'cupos'       => $cupos,
            'pendientes'  => $pendientes,
            'admitidos1'  => (clone $adm)->where('resultado', 'admitido_primera')->count(),
            'admitidos2'  => (clone $adm)->where('resultado', 'admitido_segunda')->count(),
            'noAdmitidos' => Postulante::where('gestion_id', $gestion->id)->where('estado', 'no_admitido')->count(),
            'noAprobados' => Postulante::where('gestion_id', $gestion->id)->where('estado', 'no_aprobado')->count(),
            'publicados'  => (clone $adm)->where('publicado', true)->count(),
            'totalActas'  => (clone $adm)->count(),
        ];
    }
}
