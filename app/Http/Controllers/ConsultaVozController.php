<?php

namespace App\Http\Controllers;

use App\Services\ConsultaVozService;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

/**
 * Asistente de consulta por voz/texto con IA.
 *  - transcribir(): audio → texto (OpenAI Whisper).
 *  - responder():   texto → respuesta (ConsultaVozService, solo lectura).
 *  - comandos():    catálogo de frases para mostrar como chips de ayuda.
 */
class ConsultaVozController extends Controller
{
    use BitacoraTrait;

    public function __construct(private ConsultaVozService $servicio)
    {
        $this->middleware('auth');
        // Para restringir por permiso: crea 'usar asistente' en RolesSeeder y descomenta:
        // $this->middleware('permission:usar asistente');
    }

    /** Paso 1 (voz): audio → texto vía Whisper. */
    public function transcribir(Request $r)
    {
        $r->validate(
            ['audio' => 'required|file|max:25600'], // 25 MB
            ['audio.required' => 'No se recibió audio.', 'audio.max' => 'El audio supera el límite de 25 MB.']
        );
        $apiKey = config('services.openai.key');
        if (! $apiKey) {
            return response()->json(['ok' => false, 'error' => 'Falta configurar OPENAI_API_KEY en el .env.'], 422);
        }
        $archivo = $r->file('audio');
        $ext = $archivo->getClientOriginalExtension() ?: 'webm';
        $resp = Http::withToken($apiKey)->timeout(60)
            ->attach('file', file_get_contents($archivo->getRealPath()), "consulta.$ext")
            ->post('https://api.openai.com/v1/audio/transcriptions', [
                'model' => config('services.openai.whisper_model', 'whisper-1'),
                'language' => 'es',
            ]);
        if (! $resp->successful()) {
            return response()->json(['ok' => false, 'error' => 'No se pudo transcribir el audio.'], 502);
        }

        return response()->json(['ok' => true, 'texto' => trim((string) $resp->json('text'))]);
    }

    /** Paso 2 (voz o texto): texto → respuesta consultando la base de datos. */
    public function responder(Request $r)
    {
        $r->validate(['texto' => 'required|string|max:300']);
        $resultado = $this->servicio->responder($r->input('texto'));
        $this->registrarEnBitacora('Consulta IA por voz: '.$r->input('texto'), null, 'Asistente IA');

        return response()->json($resultado);
    }

    /** Catálogo de comandos para los chips de ayuda del widget. */
    public function comandos()
    {
        $lista = collect($this->servicio->catalogo())
            ->map(fn ($c) => ['id' => $c['id'], 'etiqueta' => $c['etiqueta']])->values();

        return response()->json(['comandos' => $lista]);
    }
}
