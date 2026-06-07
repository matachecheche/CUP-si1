<?php
namespace App\Http\Controllers;

use App\Models\{Nota, Postulante, Materia, Grupo, Gestion};
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotaController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver notas')->only('index', 'planilla', 'calcular', 'consultar');
        $this->middleware('permission:crear notas')->only('create', 'store', 'guardarPlanilla');
        $this->middleware('permission:editar notas')->only('edit', 'update', 'procesarCalculo');
    }

    /** CU-13/CU-15: Lista notas del grupo (docente ve solo sus grupos) */
    public function index(Request $r)
    {
        $gestion = Gestion::where('estado','en_curso')->first();
        $grupos  = Grupo::when($gestion, fn($q)=>$q->where('gestion_id',$gestion->id))
            ->with('asignaciones.docente')
            ->get();
        $grupoSel = $r->grupo_id ? Grupo::find($r->grupo_id) : $grupos->first();
        $materias = $grupoSel ? Materia::where('estado',true)->orderBy('orden')->get() : collect();
        $matSel   = $r->materia_id ? Materia::find($r->materia_id) : $materias->first();

        $notas = ($grupoSel && $matSel)
            ? Nota::where('grupo_id',$grupoSel->id)->where('materia_id',$matSel->id)
                ->with('postulante')->orderBy('created_at')->get()
            : collect();

        // Postulantes del grupo sin nota aún
        $inscritos = $grupoSel
            ? DB::table('grupo_postulante')->where('grupo_id',$grupoSel->id)->pluck('postulante_id')
            : collect();
        $sinNota = $matSel
            ? Postulante::whereIn('id',$inscritos)
                ->whereNotIn('id', Nota::where('grupo_id',$grupoSel->id)->where('materia_id',$matSel->id)->pluck('postulante_id'))
                ->get()
            : collect();

        return view('notas.index', compact('grupos','grupoSel','materias','matSel','notas','sinNota','gestion'));
    }

    /** CU-13: Formulario para registrar nota de un postulante */
    public function create(Request $r)
    {
        $r->validate(['postulante_id'=>'required|exists:postulantes,id','grupo_id'=>'required|exists:grupos,id','materia_id'=>'required|exists:materias,id']);
        $postulante = Postulante::findOrFail($r->postulante_id);
        $grupo      = Grupo::findOrFail($r->grupo_id);
        $materia    = Materia::findOrFail($r->materia_id);
        return view('notas.create', compact('postulante','grupo','materia'));
    }

    /** CU-13/CU-14: Guarda nota y recalcula estado del postulante */
    public function store(Request $r)
    {
        $d = $r->validate([
            'postulante_id' => 'required|exists:postulantes,id',
            'materia_id'    => 'required|exists:materias,id',
            'grupo_id'      => 'required|exists:grupos,id',
            'examen1'       => 'required|numeric|min:0|max:100',
            'examen2'       => 'required|numeric|min:0|max:100',
            'examen3'       => 'required|numeric|min:0|max:100',
        ], [
            'examen1.max' => 'La nota del examen 1 debe estar entre 0 y 100.',
            'examen2.max' => 'La nota del examen 2 debe estar entre 0 y 100.',
            'examen3.max' => 'La nota del examen 3 debe estar entre 0 y 100.',
            'examen1.min' => 'La nota del examen 1 debe estar entre 0 y 100.',
            'examen2.min' => 'La nota del examen 2 debe estar entre 0 y 100.',
            'examen3.min' => 'La nota del examen 3 debe estar entre 0 y 100.',
        ]);

        // Validar que el postulante esté inscrito en el grupo
        $inscrito = DB::table('grupo_postulante')
            ->where(['grupo_id'=>$d['grupo_id'],'postulante_id'=>$d['postulante_id']])->exists();
        if (!$inscrito) {
            return back()->withErrors(['postulante_id'=>'El postulante no está inscrito en este grupo.'])->withInput();
        }

        $nota = Nota::updateOrCreate(
            ['postulante_id'=>$d['postulante_id'],'materia_id'=>$d['materia_id'],'grupo_id'=>$d['grupo_id']],
            ['examen1'=>$d['examen1'],'examen2'=>$d['examen2'],'examen3'=>$d['examen3']]
        );
        $nota->calcularYGuardar();   // CU-14

        $this->_actualizarEstadoPostulante($d['postulante_id']); // CU-14
        $this->registrarEnBitacora("Registró nota para postulante ID:{$d['postulante_id']}", $nota->id, 'Notas');

        return redirect()->route('notas.index', ['grupo_id'=>$d['grupo_id'],'materia_id'=>$d['materia_id']])
            ->with('success','Nota registrada y promedio actualizado.');
    }

    public function edit(Nota $nota)
    {
        $nota->load('postulante','materia','grupo');
        return view('notas.edit', compact('nota'));
    }

    public function update(Request $r, Nota $nota)
    {
        $d = $r->validate([
            'examen1'=>'required|numeric|min:0|max:100',
            'examen2'=>'required|numeric|min:0|max:100',
            'examen3'=>'required|numeric|min:0|max:100',
        ], [
            'examen1.max' => 'La nota del examen 1 debe estar entre 0 y 100.',
            'examen2.max' => 'La nota del examen 2 debe estar entre 0 y 100.',
            'examen3.max' => 'La nota del examen 3 debe estar entre 0 y 100.',
        ]);
        $nota->update($d);
        $nota->calcularYGuardar();
        $this->_actualizarEstadoPostulante($nota->postulante_id);
        $this->registrarEnBitacora("Editó nota ID:{$nota->id}", $nota->id, 'Notas');
        return redirect()->route('notas.index',['grupo_id'=>$nota->grupo_id,'materia_id'=>$nota->materia_id])
            ->with('success','Nota actualizada.');
    }

    /** CU-14: Recalcula promedio general y estado aprobado/no_aprobado */
    private function _actualizarEstadoPostulante(int $postulanteId): void
    {
        $notas = Nota::where('postulante_id', $postulanteId)->get();
        if ($notas->count() < 4) return; // esperar a tener las 4 materias

        $promedio = round($notas->avg('nota_final'), 2);
        $aprobado = $notas->every(fn($n) => $n->nota_final >= 60);

        Postulante::find($postulanteId)?->update([
            'promedio_general' => $promedio,
            'estado'           => $aprobado ? 'aprobado' : 'no_aprobado',
        ]);
    }

    /** CU-13: planilla de captura masiva por grupo + materia. */
    public function planilla(Request $r)
    {
        $gestion = Gestion::where('estado', 'en_curso')->first();
        $grupos  = Grupo::when($gestion, fn ($q) => $q->where('gestion_id', $gestion->id))->orderBy('codigo')->get();
        $grupoSel = $r->grupo_id ? Grupo::find($r->grupo_id) : $grupos->first();
        $materias = Materia::where('estado', true)->orderBy('orden')->get();
        $matSel   = $r->materia_id ? Materia::find($r->materia_id) : $materias->first();

        $filas = collect();
        if ($grupoSel && $matSel) {
            $ids = DB::table('grupo_postulante')->where('grupo_id', $grupoSel->id)->pluck('postulante_id');
            $notas = Nota::where('grupo_id', $grupoSel->id)->where('materia_id', $matSel->id)
                ->get()->keyBy('postulante_id');
            $filas = Postulante::whereIn('id', $ids)->orderBy('apellidos')->get()
                ->map(fn ($p) => ['p' => $p, 'n' => $notas->get($p->id)]);
        }

        return view('notas.planilla', compact('gestion', 'grupos', 'grupoSel', 'materias', 'matSel', 'filas'));
    }

    /** CU-13: guarda la planilla completa (upsert por postulante) y recalcula. */
    public function guardarPlanilla(Request $r)
    {
        $r->validate([
            'grupo_id'   => 'required|exists:grupos,id',
            'materia_id' => 'required|exists:materias,id',
            'filas'      => 'required|array',
            'filas.*.examen1' => 'nullable|numeric|min:0|max:100',
            'filas.*.examen2' => 'nullable|numeric|min:0|max:100',
            'filas.*.examen3' => 'nullable|numeric|min:0|max:100',
        ], ['filas.*.examen1.max' => 'Las notas deben estar entre 0 y 100.',
            'filas.*.examen2.max' => 'Las notas deben estar entre 0 y 100.',
            'filas.*.examen3.max' => 'Las notas deben estar entre 0 y 100.']);

        $inscritos = DB::table('grupo_postulante')->where('grupo_id', $r->grupo_id)->pluck('postulante_id')->all();
        $guardadas = 0; $incompletas = 0;

        DB::transaction(function () use ($r, $inscritos, &$guardadas, &$incompletas) {
            foreach ($r->input('filas', []) as $postulanteId => $f) {
                $e = [$f['examen1'] ?? null, $f['examen2'] ?? null, $f['examen3'] ?? null];
                if ($e === [null, null, null]) continue;                    // fila vacía: se ignora
                if (in_array(null, $e, true)) { $incompletas++; continue; } // faltan exámenes: no se guarda
                if (! in_array((int) $postulanteId, $inscritos)) continue;  // no pertenece al grupo

                $nota = Nota::updateOrCreate(
                    ['postulante_id' => $postulanteId, 'materia_id' => $r->materia_id, 'grupo_id' => $r->grupo_id],
                    ['examen1' => $e[0], 'examen2' => $e[1], 'examen3' => $e[2]]
                );
                $nota->calcularYGuardar();                       // CU-14 (por nota)
                $this->_actualizarEstadoPostulante((int) $postulanteId); // CU-14 (por postulante)
                $guardadas++;
            }
        });

        $this->registrarEnBitacora("CU-13: planilla grupo ID:{$r->grupo_id} materia ID:{$r->materia_id} — {$guardadas} notas", null, 'Notas');
        $msg = "Planilla guardada: {$guardadas} nota(s).".($incompletas ? " {$incompletas} fila(s) incompletas no se guardaron (se requieren los 3 exámenes)." : '');
        return redirect()->route('notas.planilla', ['grupo_id' => $r->grupo_id, 'materia_id' => $r->materia_id])
            ->with($incompletas ? 'error' : 'success', $msg);
    }

    /** CU-14: pantalla de cálculo (ponderaciones, fórmula y pendientes). */
    public function calcular()
    {
        $gestion  = Gestion::where('estado', 'en_curso')->first();
        $materias = Materia::where('estado', true)->orderBy('orden')->get();
        $grupoIds = $gestion ? Grupo::where('gestion_id', $gestion->id)->pluck('id') : collect();

        $resumen = [
            'notas'      => Nota::whereIn('grupo_id', $grupoIds)->count(),
            'sin_final'  => Nota::whereIn('grupo_id', $grupoIds)->whereNull('nota_final')->count(),
            'aprobados'  => $gestion ? Postulante::where('gestion_id', $gestion->id)->where('estado', 'aprobado')->count() : 0,
            'reprobados' => $gestion ? Postulante::where('gestion_id', $gestion->id)->where('estado', 'no_aprobado')->count() : 0,
            'en_curso'   => $gestion ? Postulante::where('gestion_id', $gestion->id)->whereIn('estado', ['inscrito', 'en_curso'])->count() : 0,
        ];

        return view('notas.calcular', compact('gestion', 'materias', 'resumen'));
    }

    /** CU-14: recalcula nota_final/aprobado de todas las notas y promedio/estado de postulantes. */
    public function procesarCalculo()
    {
        $gestion = Gestion::where('estado', 'en_curso')->firstOrFail();
        $grupoIds = Grupo::where('gestion_id', $gestion->id)->pluck('id');
        $totalMaterias = Materia::where('estado', true)->count();

        [$nCalc, $ap, $rep] = DB::transaction(function () use ($grupoIds, $gestion, $totalMaterias) {
            $notas = Nota::whereIn('grupo_id', $grupoIds)
                ->whereNotNull('examen1')->whereNotNull('examen2')->whereNotNull('examen3')
                ->with('materia')->get();
            foreach ($notas as $n) $n->calcularYGuardar();

            $a = 0; $r = 0;
            // Solo estados previos a la admisión: los admitidos/no admitidos NO se tocan
            $postulantes = Postulante::where('gestion_id', $gestion->id)
                ->whereIn('estado', ['inscrito', 'en_curso', 'aprobado', 'no_aprobado'])
                ->whereIn('id', $notas->pluck('postulante_id')->unique())->get();

            foreach ($postulantes as $p) {
                $sus = $notas->where('postulante_id', $p->id);
                if ($sus->count() < $totalMaterias) continue; // faltan materias
                $aproboTodo = $sus->every(fn ($n) => $n->aprobado);
                $p->update([
                    'promedio_general' => round($sus->avg('nota_final'), 2),
                    'estado'           => $aproboTodo ? 'aprobado' : 'no_aprobado',
                ]);
                $aproboTodo ? $a++ : $r++;
            }
            return [$notas->count(), $a, $r];
        });

        $this->registrarEnBitacora("CU-14: recalculó {$nCalc} notas — {$ap} aprobados, {$rep} reprobados", null, 'Notas');
        return redirect()->route('notas.calcular')
            ->with('success', "Cálculo completado: {$nCalc} notas procesadas; {$ap} aprobados y {$rep} reprobados (los ya admitidos no se modifican).");
    }

    /** CU-15: consulta de notas del postulante (boleta). */
    public function consultar(Request $r)
    {
        $matches = collect(); $sel = null; $boleta = collect();

        if ($r->filled('postulante_id')) {
            $sel = Postulante::with(['primeraOpcion', 'segundaOpcion', 'gestion'])->find($r->postulante_id);
        } elseif ($r->filled('q')) {
            $q = trim($r->q);
            $matches = Postulante::with('primeraOpcion')
                ->where(fn ($w) => $w->where('ci', 'ILIKE', "%{$q}%")
                    ->orWhere('apellidos', 'ILIKE', "%{$q}%")->orWhere('nombres', 'ILIKE', "%{$q}%"))
                ->orderBy('apellidos')->limit(15)->get();
            if ($matches->count() === 1) { $sel = $matches->first(); $matches = collect(); }
        }

        if ($sel) {
            $boleta = Nota::with(['materia', 'grupo'])->where('postulante_id', $sel->id)->get()
                ->sortBy(fn ($n) => $n->materia->orden ?? 0)->values();
            $this->registrarEnBitacora("CU-15: consultó notas de {$sel->nombre_completo} (CI {$sel->ci})", $sel->id, 'Notas');
        }

        return view('notas.consultar', ['q' => $r->q, 'matches' => $matches, 'sel' => $sel, 'boleta' => $boleta]);
    }
}
