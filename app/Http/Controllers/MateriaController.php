<?php
namespace App\Http\Controllers;

use App\Models\Materia;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;

class MateriaController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver materias')->only('index','show');
        $this->middleware('permission:crear materias')->only('create','store');
        $this->middleware('permission:editar materias')->only('edit','update');
        $this->middleware('permission:eliminar materias')->only('destroy');
    }

    public function index()
    {
        $materias = Materia::orderBy('orden')->orderBy('nombre')->get();
        return view('materias.index', compact('materias'));
    }

    public function create()
    {
        return view('materias.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nombre'                 => 'required|string|max:100|unique:materias,nombre',
            'area_formacion'         => 'nullable|string|max:80',
            'descripcion'            => 'nullable|string',
            'pond_examen1'           => 'required|integer|min:1|max:98',
            'pond_examen2'           => 'required|integer|min:1|max:98',
            'pond_examen3'           => 'required|integer|min:1|max:98',
            'nota_minima_aprobacion' => 'required|integer|min:1|max:100',
            'orden'                  => 'nullable|integer|min:0',
            'estado'                 => 'boolean',
        ]);
        // Validar que las ponderaciones sumen 100
        if (($data['pond_examen1'] + $data['pond_examen2'] + $data['pond_examen3']) !== 100) {
            return back()->withErrors(['pond_examen1' => 'Las ponderaciones deben sumar exactamente 100%'])->withInput();
        }
        $data['estado'] = $request->boolean('estado', true);
        $data['orden']  = $data['orden'] ?? 0;
        $m = Materia::create($data);
        $this->registrarEnBitacora("Registró materia: {$m->nombre}", $m->id, 'Materias');
        return redirect()->route('materias.index')
            ->with('success', "Materia «{$m->nombre}» registrada correctamente.");
    }

    public function show(Materia $materia)
    {
        return view('materias.show', compact('materia'));
    }

    public function edit(Materia $materia)
    {
        return view('materias.edit', compact('materia'));
    }

    public function update(Request $request, Materia $materia)
    {
        $data = $request->validate([
            'nombre'                 => "required|string|max:100|unique:materias,nombre,{$materia->id}",
            'area_formacion'         => 'nullable|string|max:80',
            'descripcion'            => 'nullable|string',
            'pond_examen1'           => 'required|integer|min:1|max:98',
            'pond_examen2'           => 'required|integer|min:1|max:98',
            'pond_examen3'           => 'required|integer|min:1|max:98',
            'nota_minima_aprobacion' => 'required|integer|min:1|max:100',
            'orden'                  => 'nullable|integer|min:0',
            'estado'                 => 'boolean',
        ]);
        if (($data['pond_examen1'] + $data['pond_examen2'] + $data['pond_examen3']) !== 100) {
            return back()->withErrors(['pond_examen1' => 'Las ponderaciones deben sumar exactamente 100%'])->withInput();
        }
        $data['estado'] = $request->boolean('estado', true);
        $materia->update($data);
        $this->registrarEnBitacora("Actualizó materia: {$materia->nombre}", $materia->id, 'Materias');
        return redirect()->route('materias.index')
            ->with('success', "Materia «{$materia->nombre}» actualizada.");
    }

    public function destroy(Materia $materia)
    {
        $nombre = $materia->nombre;
        $materia->delete();
        $this->registrarEnBitacora("Eliminó materia: {$nombre}", null, 'Materias');
        return redirect()->route('materias.index')
            ->with('success', "Materia «{$nombre}» eliminada.");
    }
}
