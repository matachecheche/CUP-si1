<?php
namespace App\Http\Controllers;
use App\Models\Comunicado;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;

/** CU-21: gestión de comunicados institucionales por audiencia. */
class ComunicadoController extends Controller {
    use BitacoraTrait;

    public function __construct() {
        $this->middleware('auth');
        $this->middleware('permission:ver comunicados')->only('index');
        $this->middleware('permission:crear comunicados')->only('create','store');
        $this->middleware('permission:editar comunicados')->only('edit','update');
        $this->middleware('permission:eliminar comunicados')->only('destroy');
    }

    public function index() {
        return view('comunicados.index', ['comunicados' => Comunicado::with('autor')->orderByDesc('created_at')->get()]);
    }

    public function create() { return view('comunicados.create'); }

    public function store(Request $r) {
        $d = $this->validar($r);
        $d['user_id'] = auth()->id();
        $c = Comunicado::create($d);
        $this->registrarEnBitacora("Creó comunicado: «{$c->titulo}» ({$c->audiencia})", $c->id, 'Comunicados');
        return redirect()->route('comunicados.index')->with('success', "Comunicado «{$c->titulo}» creado.");
    }

    public function edit(Comunicado $comunicado) { return view('comunicados.edit', compact('comunicado')); }

    public function update(Request $r, Comunicado $comunicado) {
        $comunicado->update($this->validar($r));
        $this->registrarEnBitacora("Editó comunicado: «{$comunicado->titulo}»", $comunicado->id, 'Comunicados');
        return redirect()->route('comunicados.index')->with('success', "Comunicado «{$comunicado->titulo}» actualizado.");
    }

    public function destroy(Comunicado $comunicado) {
        $titulo = $comunicado->titulo;
        $comunicado->delete();
        $this->registrarEnBitacora("Eliminó comunicado: «{$titulo}»", null, 'Comunicados');
        return redirect()->route('comunicados.index')->with('success', "Comunicado «{$titulo}» eliminado.");
    }

    private function validar(Request $r): array {
        $d = $r->validate([
            'titulo'        => 'required|string|max:150',
            'contenido'     => 'required|string|max:5000',
            'audiencia'     => 'required|in:todos,postulantes,docentes',
            'publicado'     => 'boolean',
            'vigente_hasta' => 'nullable|date',
        ], [
            'titulo.required' => 'El título es obligatorio.',
            'contenido.required' => 'El contenido es obligatorio.',
            'audiencia.in' => 'Audiencia inválida.',
        ]);
        $d['publicado'] = $r->boolean('publicado');
        return $d;
    }
}
