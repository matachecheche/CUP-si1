<?php
namespace App\Http\Controllers;

use App\Models\Postulante;
use App\Models\Carrera;
use App\Models\Gestion;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;

class PostulanteController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver postulantes')->only('index','show');
        $this->middleware('permission:crear postulantes')->only('create','store');
        $this->middleware('permission:editar postulantes')->only('edit','update');
        $this->middleware('permission:eliminar postulantes')->only('destroy');
    }

    public function index()
    {
        $postulantes = Postulante::with('primeraOpcion', 'segundaOpcion', 'gestion')
                        ->orderBy('apellidos')->get();
        return view('postulantes.index', compact('postulantes'));
    }

    public function create()
    {
        $carreras  = Carrera::where('estado', true)->orderBy('nombre')->get();
        $gestiones = Gestion::orderByDesc('fecha_inicio')->get();
        return view('postulantes.create', compact('carreras', 'gestiones'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'gestion_id'          => 'required|exists:gestiones,id',
            'primera_opcion_id'   => 'required|exists:carreras,id',
            'segunda_opcion_id'   => 'required|exists:carreras,id|different:primera_opcion_id',
            'ci'                  => 'required|string|max:20|unique:postulantes,ci',
            'nombres'             => 'required|string|max:100',
            'apellidos'           => 'required|string|max:100',
            'fecha_nacimiento'    => 'nullable|date|before:today',
            'sexo'                => 'nullable|in:M,F,Otro',
            'direccion'           => 'nullable|string|max:200',
            'telefono'            => 'nullable|string|max:20',
            'email'               => 'nullable|email|max:100',
            'colegio_procedencia' => 'nullable|string|max:150',
            'ciudad'              => 'nullable|string|max:80',
            'doc_ci'              => 'boolean',
            'doc_libreta_colegio' => 'boolean',
            'doc_titulo_bachiller'=> 'boolean',
        ]);

        // Validar: la 2ª opción debe ser diferente a la 1ª
        if ($data['primera_opcion_id'] === $data['segunda_opcion_id']) {
            return back()->withErrors(['segunda_opcion_id' => 'La segunda opción debe ser diferente a la primera.'])->withInput();
        }

        $data['doc_ci']               = $request->boolean('doc_ci');
        $data['doc_libreta_colegio']  = $request->boolean('doc_libreta_colegio');
        $data['doc_titulo_bachiller'] = $request->boolean('doc_titulo_bachiller');

        $p = Postulante::create($data);
        $this->registrarEnBitacora("Registró postulante: {$p->nombre_completo} CI:{$p->ci}", $p->id, 'Postulantes');
        return redirect()->route('postulantes.index')
            ->with('success', "Postulante «{$p->nombre_completo}» registrado correctamente.");
    }

    public function show(Postulante $postulante)
    {
        $postulante->load('primeraOpcion', 'segundaOpcion', 'gestion');
        return view('postulantes.show', compact('postulante'));
    }

    public function edit(Postulante $postulante)
    {
        $carreras  = Carrera::where('estado', true)->orderBy('nombre')->get();
        $gestiones = Gestion::orderByDesc('fecha_inicio')->get();
        return view('postulantes.edit', compact('postulante', 'carreras', 'gestiones'));
    }

    public function update(Request $request, Postulante $postulante)
    {
        $data = $request->validate([
            'gestion_id'          => 'required|exists:gestiones,id',
            'primera_opcion_id'   => 'required|exists:carreras,id',
            'segunda_opcion_id'   => "required|exists:carreras,id|different:primera_opcion_id",
            'ci'                  => "required|string|max:20|unique:postulantes,ci,{$postulante->id}",
            'nombres'             => 'required|string|max:100',
            'apellidos'           => 'required|string|max:100',
            'fecha_nacimiento'    => 'nullable|date|before:today',
            'sexo'                => 'nullable|in:M,F,Otro',
            'direccion'           => 'nullable|string|max:200',
            'telefono'            => 'nullable|string|max:20',
            'email'               => 'nullable|email|max:100',
            'colegio_procedencia' => 'nullable|string|max:150',
            'ciudad'              => 'nullable|string|max:80',
            'doc_ci'              => 'boolean',
            'doc_libreta_colegio' => 'boolean',
            'doc_titulo_bachiller'=> 'boolean',
        ]);
        $data['doc_ci']               = $request->boolean('doc_ci');
        $data['doc_libreta_colegio']  = $request->boolean('doc_libreta_colegio');
        $data['doc_titulo_bachiller'] = $request->boolean('doc_titulo_bachiller');
        $postulante->update($data);
        $this->registrarEnBitacora("Actualizó postulante: {$postulante->nombre_completo}", $postulante->id, 'Postulantes');
        return redirect()->route('postulantes.index')
            ->with('success', "Postulante «{$postulante->nombre_completo}» actualizado.");
    }

    public function destroy(Postulante $postulante)
    {
        $nombre = $postulante->nombre_completo;
        $postulante->delete();
        $this->registrarEnBitacora("Eliminó postulante: {$nombre}", null, 'Postulantes');
        return redirect()->route('postulantes.index')
            ->with('success', "Postulante «{$nombre}» eliminado.");
    }
}
