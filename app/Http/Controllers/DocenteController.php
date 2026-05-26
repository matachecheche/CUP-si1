<?php
namespace App\Http\Controllers;

use App\Models\Docente;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;

class DocenteController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver docentes')->only('index','show');
        $this->middleware('permission:crear docentes')->only('create','store');
        $this->middleware('permission:editar docentes')->only('edit','update');
        $this->middleware('permission:eliminar docentes')->only('destroy');
    }

    public function index()
    {
        $docentes = Docente::orderBy('apellidos')->get();
        return view('docentes.index', compact('docentes'));
    }

    public function create()
    {
        return view('docentes.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'ci'                            => 'required|string|max:20|unique:docentes,ci',
            'nombres'                       => 'required|string|max:100',
            'apellidos'                     => 'required|string|max:100',
            'telefono'                      => 'nullable|string|max:20',
            'email'                         => 'nullable|email|max:100|unique:docentes,email',
            'titulo_profesional'            => 'required|string|max:150',
            'maestria'                      => 'required|string|max:150',
            'diplomado_educacion_superior'  => 'required|string|max:150',
            'certificacion_ingles'          => 'nullable|string|max:100',
            'otras_certificaciones'         => 'nullable|string',
            'area_formacion'                => 'required|string|max:80',
            'estado'                        => 'boolean',
        ]);
        $data['estado'] = $request->boolean('estado', true);
        $d = Docente::create($data);
        $this->registrarEnBitacora("Registró docente: {$d->nombre_completo}", $d->id, 'Docentes');
        return redirect()->route('docentes.index')
            ->with('success', "Docente «{$d->nombre_completo}» registrado correctamente.");
    }

    public function show(Docente $docente)
    {
        return view('docentes.show', compact('docente'));
    }

    public function edit(Docente $docente)
    {
        return view('docentes.edit', compact('docente'));
    }

    public function update(Request $request, Docente $docente)
    {
        $data = $request->validate([
            'ci'                            => "required|string|max:20|unique:docentes,ci,{$docente->id}",
            'nombres'                       => 'required|string|max:100',
            'apellidos'                     => 'required|string|max:100',
            'telefono'                      => 'nullable|string|max:20',
            'email'                         => "nullable|email|max:100|unique:docentes,email,{$docente->id}",
            'titulo_profesional'            => 'required|string|max:150',
            'maestria'                      => 'required|string|max:150',
            'diplomado_educacion_superior'  => 'required|string|max:150',
            'certificacion_ingles'          => 'nullable|string|max:100',
            'otras_certificaciones'         => 'nullable|string',
            'area_formacion'                => 'required|string|max:80',
            'estado'                        => 'boolean',
        ]);
        $data['estado'] = $request->boolean('estado', true);
        $docente->update($data);
        $this->registrarEnBitacora("Actualizó docente: {$docente->nombre_completo}", $docente->id, 'Docentes');
        return redirect()->route('docentes.index')
            ->with('success', "Docente «{$docente->nombre_completo}» actualizado.");
    }

    public function destroy(Docente $docente)
    {
        $nombre = $docente->nombre_completo;
        $docente->update(['estado' => false]);
        $this->registrarEnBitacora("Desactivó docente: {$nombre}", $docente->id, 'Docentes');
        return redirect()->route('docentes.index')
            ->with('success', "Docente «{$nombre}» desactivado.");
    }
}
