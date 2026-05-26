<?php
namespace App\Http\Controllers;

use App\Models\Carrera;
use App\Models\CupoCarrera;
use App\Models\Gestion;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;

class CarreraController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver carreras')->only('index','show');
        $this->middleware('permission:crear carreras')->only('create','store');
        $this->middleware('permission:editar carreras')->only('edit','update');
        $this->middleware('permission:eliminar carreras')->only('destroy');
    }

    public function index()
    {
        $carreras = Carrera::orderBy('nombre')->get();
        return view('carreras.index', compact('carreras'));
    }

    public function create()
    {
        return view('carreras.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nombre'      => 'required|string|max:100|unique:carreras,nombre',
            'sigla'       => 'nullable|string|max:10',
            'descripcion' => 'nullable|string',
            'estado'      => 'boolean',
        ]);
        $data['estado'] = $request->boolean('estado', true);
        $c = Carrera::create($data);
        $this->registrarEnBitacora("Registró carrera: {$c->nombre}", $c->id, 'Carreras');
        return redirect()->route('carreras.index')
            ->with('success', "Carrera «{$c->nombre}» registrada correctamente.");
    }

    public function show(Carrera $carrera)
    {
        $gestiones = Gestion::orderByDesc('fecha_inicio')->get();
        $cupos     = CupoCarrera::where('carrera_id', $carrera->id)
                        ->with('gestion')->orderByDesc('id')->get();
        return view('carreras.show', compact('carrera', 'gestiones', 'cupos'));
    }

    public function edit(Carrera $carrera)
    {
        return view('carreras.edit', compact('carrera'));
    }

    public function update(Request $request, Carrera $carrera)
    {
        $data = $request->validate([
            'nombre'      => "required|string|max:100|unique:carreras,nombre,{$carrera->id}",
            'sigla'       => 'nullable|string|max:10',
            'descripcion' => 'nullable|string',
            'estado'      => 'boolean',
        ]);
        $data['estado'] = $request->boolean('estado', true);
        $carrera->update($data);
        $this->registrarEnBitacora("Actualizó carrera: {$carrera->nombre}", $carrera->id, 'Carreras');
        return redirect()->route('carreras.index')
            ->with('success', "Carrera «{$carrera->nombre}» actualizada.");
    }

    public function destroy(Carrera $carrera)
    {
        $nombre = $carrera->nombre;
        $carrera->delete();
        $this->registrarEnBitacora("Eliminó carrera: {$nombre}", null, 'Carreras');
        return redirect()->route('carreras.index')
            ->with('success', "Carrera «{$nombre}» eliminada.");
    }

    /** CU-11: Definir cupo para una carrera en una gestión */
    public function storeCupo(Request $request, Carrera $carrera)
    {
        $data = $request->validate([
            'gestion_id'      => 'required|exists:gestiones,id',
            'cantidad_maxima' => 'required|integer|min:1|max:9999',
        ]);
        $cupo = CupoCarrera::updateOrCreate(
            ['carrera_id' => $carrera->id, 'gestion_id' => $data['gestion_id']],
            ['cantidad_maxima' => $data['cantidad_maxima']]
        );
        $this->registrarEnBitacora(
            "Definió cupo {$cupo->cantidad_maxima} para {$carrera->nombre}",
            $carrera->id, 'Carreras'
        );
        return redirect()->route('carreras.show', $carrera)
            ->with('success', 'Cupo definido correctamente.');
    }
}
