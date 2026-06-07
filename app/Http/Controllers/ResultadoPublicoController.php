<?php
namespace App\Http\Controllers;
use App\Models\{Admision, Postulante};
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;

/**
 * CU-22: consulta pública de resultados de admisión por CI (sin autenticación).
 * Seguridad: throttle en la ruta POST, CI validado por regex, y solo se revela
 * el resultado cuando la admisión fue PUBLICADA (CU-18). Datos mínimos.
 */
class ResultadoPublicoController extends Controller
{
    use BitacoraTrait;

    public function index()
    {
        return view('publico.resultados');
    }

    public function consultar(Request $r)
    {
        $r->validate(
            ['ci' => 'required|string|max:20|regex:/^[0-9]{5,10}(-[A-Z]{1,2})?$/'],
            ['ci.required' => 'Ingresa tu número de carnet.', 'ci.regex' => 'Formato de CI inválido.']
        );

        $postulante = Postulante::with(['gestion', 'primeraOpcion', 'segundaOpcion'])
            ->where('ci', $r->ci)->first();

        $admision = $postulante
            ? Admision::with('carreraAsignada')->where('postulante_id', $postulante->id)->first()
            : null;

        $publicado = (bool) ($admision?->publicado);

        // La bitácora funciona sin sesión: BitacoraTrait registra usuario 'Sistema'
        $this->registrarEnBitacora('Consulta pública de resultados CI: '.$r->ci, $postulante?->id, 'Resultados');

        return view('publico.resultados', [
            'consultado' => true,
            'ci'         => $r->ci,
            'postulante' => $postulante,
            'admision'   => $publicado ? $admision : null,   // sin publicar, no se revela nada
            'publicado'  => $publicado,
        ]);
    }
}
