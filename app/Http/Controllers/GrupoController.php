<?php
namespace App\Http\Controllers;

use App\Models\{Grupo, Asignacion, Docente, Materia, Gestion, Postulante};
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class GrupoController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver grupos')->only('index','show');
        $this->middleware('permission:crear grupos')->only('create','store','generar');
        $this->middleware('permission:editar grupos')->only('edit','update','asignarDocente','inscribirPostulantes');
        $this->middleware('permission:eliminar grupos')->only('destroy');
    }

    /** CU-17: Lista grupos de la gestión activa y muestra botón de generación automática */
    public function index()
    {
        $gestion  = Gestion::where('estado','en_curso')->first();
        $grupos   = $gestion
            ? Grupo::where('gestion_id', $gestion->id)
                ->withCount('postulantes')
                ->with(['asignaciones.docente','asignaciones.materia'])
                ->get()
            : collect();

        $totalInscritos  = $gestion ? Postulante::where('gestion_id',$gestion->id)->count() : 0;
        $gruposNecesarios = $totalInscritos > 0 ? (int) ceil($totalInscritos / 60) : 0;

        return view('grupos.index', compact('gestion','grupos','totalInscritos','gruposNecesarios'));
    }

    /** CU-17: Genera automáticamente los grupos necesarios (CEIL(inscritos/60)) */
    public function generar(Request $r)
    {
        $gestion = Gestion::where('estado','en_curso')->firstOrFail();
        $total   = Postulante::where('gestion_id', $gestion->id)->count();
        $necesarios = (int) ceil($total / 60);
        $existentes = Grupo::where('gestion_id', $gestion->id)->count();

        $turnos    = ['mañana','tarde','noche'];
        $modalidad = ['presencial','presencial','virtual'];
        $creados   = 0;

        for ($i = $existentes; $i < $necesarios; $i++) {
            $letra = chr(65 + $i); // A, B, C, D …
            Grupo::create([
                'gestion_id'      => $gestion->id,
                'codigo'          => "GRP-{$letra}",
                'turno'           => $turnos[$i % 3],
                'modalidad'       => $modalidad[$i % 3],
                'capacidad_maxima'=> 60,
                'estado'          => true,
            ]);
            $creados++;
        }

        $this->registrarEnBitacora("Generó {$creados} grupo(s) automáticamente para {$gestion->descripcion}", null, 'Grupos');
        return redirect()->route('grupos.index')
            ->with('success', $creados > 0
                ? "Se generaron {$creados} grupo(s) automáticamente (total inscritos: {$total})."
                : "Ya existen los {$existentes} grupo(s) necesarios para {$total} inscritos.");
    }

    public function show(Grupo $grupo)
    {
        $grupo->load(['asignaciones.docente','asignaciones.materia','postulantes']);
        $docentes = Docente::where('estado',true)->orderBy('apellidos')->get();
        $materias = Materia::where('estado',true)->orderBy('orden')->get();
        return view('grupos.show', compact('grupo','docentes','materias'));
    }

    public function edit(Grupo $grupo)
    {
        return view('grupos.edit', compact('grupo'));
    }

    public function update(Request $r, Grupo $grupo)
    {
        $d = $r->validate([
            'turno'            => 'required|in:mañana,tarde,noche',
            'modalidad'        => 'required|in:presencial,virtual',
            'capacidad_maxima' => 'required|integer|min:1|max:100',
            'estado'           => 'boolean',
        ]);
        $d['estado'] = $r->boolean('estado', true);
        $grupo->update($d);
        $this->registrarEnBitacora("Editó grupo {$grupo->codigo}", $grupo->id, 'Grupos');
        return redirect()->route('grupos.show', $grupo)->with('success', 'Grupo actualizado.');
    }

    /** CU-18/CU-19: Asignar docente a grupo-materia con validación de cruces */
    public function asignarDocente(Request $r, Grupo $grupo)
    {
        $d = $r->validate([
            'docente_id' => 'required|exists:docentes,id',
            'materia_id' => 'required|exists:materias,id',
            'dia'        => 'required|in:lunes,martes,miercoles,jueves,viernes,sabado',
            'hora_inicio'=> 'required|date_format:H:i',
            'hora_fin'   => 'required|date_format:H:i|after:hora_inicio',
        ]);

        // CU-19: Validar cruce de horario del docente
        $cruce = Asignacion::where('docente_id', $d['docente_id'])
            ->where('dia', $d['dia'])
            ->where(function($q) use ($d) {
                $q->whereBetween('hora_inicio', [$d['hora_inicio'], $d['hora_fin']])
                  ->orWhereBetween('hora_fin',   [$d['hora_inicio'], $d['hora_fin']])
                  ->orWhere(function($q2) use ($d) {
                      $q2->where('hora_inicio','<=',$d['hora_inicio'])->where('hora_fin','>=',$d['hora_fin']);
                  });
            })
            ->whereHas('grupo', fn($q) => $q->where('id','!=',$grupo->id))
            ->first();

        if ($cruce) {
            return back()->withErrors([
                'docente_id' => "⚠ Cruce de horario: el docente ya tiene asignado el día {$d['dia']} de {$cruce->hora_inicio} a {$cruce->hora_fin} en el grupo {$cruce->grupo->codigo}."
            ])->withInput();
        }

        // CU-16: Máx 4 grupos por docente
        $gruposDocente = Asignacion::where('docente_id',$d['docente_id'])
            ->distinct('grupo_id')->count('grupo_id');
        if ($gruposDocente >= 4 && !Asignacion::where('docente_id',$d['docente_id'])->where('grupo_id',$grupo->id)->exists()) {
            return back()->withErrors(['docente_id'=>'El docente ya tiene asignados 4 grupos (máximo permitido).'])->withInput();
        }

        Asignacion::updateOrCreate(
            ['grupo_id'=>$grupo->id,'materia_id'=>$d['materia_id']],
            ['docente_id'=>$d['docente_id'],'dia'=>$d['dia'],'hora_inicio'=>$d['hora_inicio'],'hora_fin'=>$d['hora_fin']]
        );
        $this->registrarEnBitacora("Asignó docente al grupo {$grupo->codigo}", $grupo->id, 'Grupos');
        return redirect()->route('grupos.show',$grupo)->with('success','Asignación guardada correctamente.');
    }

    /** CU-21: Inscribir postulantes al grupo */
    public function inscribirPostulantes(Request $r, Grupo $grupo)
    {
        $r->validate(['postulante_ids'=>'required|array','postulante_ids.*'=>'exists:postulantes,id']);

        $yaInscritos = DB::table('grupo_postulante')->where('grupo_id',$grupo->id)->count();
        $disponible  = $grupo->capacidad_maxima - $yaInscritos;
        $nuevos      = array_slice($r->postulante_ids, 0, $disponible);

        foreach ($nuevos as $pid) {
            DB::table('grupo_postulante')->updateOrInsert(
                ['grupo_id'=>$grupo->id,'postulante_id'=>$pid],
                ['created_at'=>now(),'updated_at'=>now()]
            );
        }
        $this->registrarEnBitacora('Inscribió '.count($nuevos).' postulante(s) al grupo '.$grupo->codigo, $grupo->id,'Grupos');
        return redirect()->route('grupos.show',$grupo)->with('success','Postulantes inscritos: '.count($nuevos).'.');
    }

    public function destroy(Grupo $grupo)
    {
        $cod = $grupo->codigo;
        $grupo->delete();
        $this->registrarEnBitacora("Eliminó grupo {$cod}", null, 'Grupos');
        return redirect()->route('grupos.index')->with('success',"Grupo «{$cod}» eliminado.");
    }
}
