<?php

namespace App\Services;

use App\Models\Admision;
use App\Models\Carrera;
use App\Models\CupoCarrera;
use App\Models\Docente;
use App\Models\Gestion;
use App\Models\Grupo;
use App\Models\Pago;
use App\Models\Postulante;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;

/**
 * Asistente de consulta por voz/texto. Dos niveles:
 *  1) Comandos predefinidos (regex sobre el texto normalizado) → consulta Eloquent.
 *  2) Interpretación con IA: GPT solo CLASIFICA hacia un id de comando existente
 *     (nunca genera SQL). Toda ejecución pasa por consultas validadas y de solo lectura.
 */
class ConsultaVozService
{
    private const APROBADO_EN = ['aprobado', 'admitido', 'admitido_segunda_opcion'];

    /** Punto de entrada. Recibe texto (de Whisper o tecleado) y devuelve la respuesta. */
    public function responder(string $texto): array
    {
        $texto = trim($texto);
        if ($texto === '') {
            return $this->salida(false, 'vacio', null, '', 'No entendí nada. ¿Puedes repetir la consulta?');
        }
        $norm = $this->norm($texto);

        // NIVEL 1 — comandos predefinidos
        foreach ($this->catalogo() as $cmd) {
            foreach ($cmd['patrones'] as $patron) {
                if (str_contains($norm, $patron)) {
                    return $this->salida(true, 'comando', $cmd['id'], $texto, ($cmd['handler'])($norm, $texto));
                }
            }
        }

        // NIVEL 2 — interpretación con IA (opcional)
        if ($ia = $this->interpretarConIA($texto)) {
            return $ia;
        }

        return $this->salida(
            false, 'sin_coincidencia', null, $texto,
            'No reconocí esa consulta. Prueba con una frase sugerida, por ejemplo: «¿Cuántos postulantes aprobaron?».'
        );
    }

    /**
     * Catálogo de comandos. Cada uno: id, etiqueta (lo que el usuario dice),
     * patrones (ya normalizados: minúsculas y SIN acentos) y handler que devuelve texto.
     * Ordena de lo más específico a lo más genérico.
     */
    public function catalogo(): array
    {
        return [
            [
                'id' => 'aprobados',
                'etiqueta' => '¿Cuántos postulantes aprobaron?',
                'patrones' => ['cuantos aprobaron', 'cuantos aprobados', 'postulantes aprobados', 'postulantes aprobaron', 'quienes aprobaron', 'aprobaron'],
                'handler' => function () {
                    $g = $this->gestion();
                    $n = Postulante::where('gestion_id', $g?->id)->whereIn('estado', self::APROBADO_EN)->count();

                    return "Aprobaron {$n} postulantes en la gestión {$this->nombreGestion($g)}.";
                },
            ],
            [
                'id' => 'reprobados',
                'etiqueta' => '¿Cuántos postulantes reprobaron?',
                'patrones' => ['cuantos reprobaron', 'cuantos reprobados', 'postulantes reprobados', 'postulantes reprobaron', 'reprobaron'],
                'handler' => function () {
                    $g = $this->gestion();
                    $n = Postulante::where('gestion_id', $g?->id)->where('estado', 'no_aprobado')->count();

                    return "Reprobaron {$n} postulantes en la gestión {$this->nombreGestion($g)}.";
                },
            ],
            [
                'id' => 'admitidos',
                'etiqueta' => '¿Cuántos postulantes fueron admitidos?',
                'patrones' => ['cuantos admitidos', 'cuantos fueron admitidos', 'fueron admitidos', 'cuantos ingresaron', 'postulantes admitidos'],
                'handler' => function () {
                    $g = $this->gestion();
                    $primera = Postulante::where('gestion_id', $g?->id)->where('estado', 'admitido')->count();
                    $segunda = Postulante::where('gestion_id', $g?->id)->where('estado', 'admitido_segunda_opcion')->count();
                    $total = $primera + $segunda;

                    return "Fueron admitidos {$total} postulantes: {$primera} por primera opción y {$segunda} por segunda opción.";
                },
            ],
            [
                'id' => 'promedio_general',
                'etiqueta' => '¿Cuál es el promedio general del curso?',
                'patrones' => ['promedio general', 'promedio del curso', 'cual es el promedio', 'promedio de los postulantes'],
                'handler' => function () {
                    $g = $this->gestion();
                    $avg = Postulante::where('gestion_id', $g?->id)->whereNotNull('promedio_general')->avg('promedio_general');

                    return $avg === null
                        ? 'Todavía no hay promedios registrados en la gestión actual.'
                        : 'El promedio general del curso es '.number_format((float) $avg, 2).' puntos.';
                },
            ],
            [
                'id' => 'ranking',
                'etiqueta' => '¿Quiénes tienen los mejores promedios?',
                'patrones' => ['mejor promedio', 'mejores promedios', 'ranking', 'quien va primero', 'top de postulantes'],
                'handler' => function () {
                    $g = $this->gestion();
                    $top = Postulante::where('gestion_id', $g?->id)
                        ->whereNotNull('promedio_general')
                        ->orderByDesc('promedio_general')->limit(5)->get();
                    if ($top->isEmpty()) {
                        return 'Todavía no hay promedios para armar un ranking.';
                    }
                    $lineas = $top->values()->map(
                        fn ($p, $i) => ($i + 1).'. '.$p->nombres.' '.$p->apellidos.' ('.number_format((float) $p->promedio_general, 2).')'
                    )->implode('; ');

                    return 'Los mejores promedios son: '.$lineas.'.';
                },
            ],
            [
                'id' => 'carreras_total',
                'etiqueta' => '¿Cuántas carreras hay?',
                'patrones' => ['cuantas carreras', 'numero de carreras', 'que carreras hay'],
                'handler' => function () {
                    $n = Carrera::where('estado', true)->count();

                    return "Hay {$n} carreras activas en el sistema.";
                },
            ],
            [
                'id' => 'grupos_total',
                'etiqueta' => '¿Cuántos grupos hay habilitados?',
                'patrones' => ['cuantos grupos', 'numero de grupos', 'grupos habilitados'],
                'handler' => function () {
                    $g = $this->gestion();
                    $n = Grupo::where('gestion_id', $g?->id)->count();

                    return "Hay {$n} grupos en la gestión {$this->nombreGestion($g)}.";
                },
            ],
            [
                'id' => 'docentes_total',
                'etiqueta' => '¿Cuántos docentes hay?',
                'patrones' => ['cuantos docentes', 'numero de docentes', 'cuantos profesores'],
                'handler' => function () {
                    $n = Docente::where('estado', true)->count();

                    return "Hay {$n} docentes registrados.";
                },
            ],
            [
                'id' => 'cupos_carrera',
                'etiqueta' => '¿Cuántos cupos hay en ingeniería de sistemas?',
                'patrones' => ['cuantos cupos', 'cupos de', 'cupos en', 'cupos para'],
                'handler' => function (string $norm) {
                    $g = $this->gestion();
                    if ($carrera = $this->carreraEnTexto($norm)) {
                        $cupo = CupoCarrera::where('carrera_id', $carrera->id)->where('gestion_id', $g?->id)->value('cantidad_maxima');

                        return $cupo === null
                            ? "La carrera {$carrera->nombre} no tiene cupos configurados en la gestión actual."
                            : "La carrera {$carrera->nombre} tiene {$cupo} cupos en la gestión {$this->nombreGestion($g)}.";
                    }
                    $total = (int) CupoCarrera::where('gestion_id', $g?->id)->sum('cantidad_maxima');

                    return "En total hay {$total} cupos entre todas las carreras. Puedes preguntar por una carrera específica.";
                },
            ],
            [
                'id' => 'postulantes_por_carrera',
                'etiqueta' => '¿Cuántos postulantes hay por carrera?',
                'patrones' => ['postulantes por carrera', 'postulantes hay por carrera', 'cuantos por carrera', 'inscritos por carrera'],
                'handler' => function () {
                    $g = $this->gestion();
                    $filas = Carrera::where('estado', true)
                        ->withCount(['primerasOpciones as inscritos' => fn ($q) => $q->where('gestion_id', $g?->id)])
                        ->orderByDesc('inscritos')->get();
                    if ($filas->isEmpty()) {
                        return 'No hay carreras registradas.';
                    }
                    $lineas = $filas->map(fn ($c) => "{$c->nombre}: {$c->inscritos}")->implode('; ');

                    return 'Postulantes por carrera (primera opción): '.$lineas.'.';
                },
            ],
            [
                // Catch-all genérico: va DESPUÉS de los comandos específicos de postulantes
                // para no eclipsar «aprobaron», «reprobaron», «por carrera», etc.
                'id' => 'postulantes_total',
                'etiqueta' => '¿Cuántos postulantes hay registrados?',
                'patrones' => ['cuantos postulantes', 'total de postulantes', 'numero de postulantes', 'cuantos inscritos'],
                'handler' => function () {
                    $g = $this->gestion();
                    $n = Postulante::where('gestion_id', $g?->id)->count();

                    return "En la gestión {$this->nombreGestion($g)} hay {$n} postulantes registrados.";
                },
            ],
            [
                'id' => 'pagos_recaudado',
                'etiqueta' => '¿Cuánto se ha recaudado en pagos?',
                'patrones' => ['cuanto se ha recaudado', 'total recaudado', 'cuanto recaudamos', 'recaudacion'],
                'handler' => function () {
                    $total = (float) Pago::where('estado', 'pagado')->sum('monto');
                    $n = Pago::where('estado', 'pagado')->count();

                    return 'Se han recaudado '.number_format($total, 2).' bolivianos en '.$n.' pagos confirmados.';
                },
            ],
            [
                'id' => 'pagos_pendientes',
                'etiqueta' => '¿Cuántos pagos están pendientes?',
                'patrones' => ['pagos pendientes', 'pagos estan pendientes', 'cuantos deben pagar', 'cuantos pagos faltan'],
                'handler' => function () {
                    $n = Pago::where('estado', 'pendiente')->count();

                    return "Hay {$n} pagos pendientes.";
                },
            ],
            [
                'id' => 'gestion_actual',
                'etiqueta' => '¿Cuál es la gestión actual?',
                'patrones' => ['gestion actual', 'que gestion', 'gestion en curso', 'cual es la gestion'],
                'handler' => function () {
                    $g = $this->gestion();
                    if (! $g) {
                        return 'No hay ninguna gestión marcada como en curso.';
                    }

                    return "La gestión en curso es {$this->nombreGestion($g)}, con costo de inscripción de "
                        .number_format((float) ($g->costo_inscripcion ?? 0), 2).' bolivianos.';
                },
            ],
            [
                'id' => 'resultado_ci',
                'etiqueta' => 'Resultado del postulante con carnet 12345678',
                'patrones' => ['carnet', 'carne ', 'resultado del postulante', 'resultado de la postulante', 'admision de'],
                'handler' => function (string $norm) {
                    if (! preg_match('/(\d{5,10})/', $norm, $m)) {
                        return 'Dime el número de carnet; por ejemplo: «resultado del carnet 12345678».';
                    }
                    $ci = $m[1];
                    $p = Postulante::with(['primeraOpcion', 'segundaOpcion'])->where('ci', 'like', $ci.'%')->first();
                    if (! $p) {
                        return "No encontré ningún postulante con el carnet {$ci}.";
                    }
                    $admision = Admision::with('carreraAsignada')->where('postulante_id', $p->id)->first();
                    $nombre = $p->nombres.' '.$p->apellidos;
                    if ($admision && $admision->publicado) {
                        $carrera = $admision->carreraAsignada?->nombre ?? 'sin carrera';

                        return "{$nombre} (CI {$p->ci}) — resultado: {$admision->resultado}; carrera asignada: {$carrera}.";
                    }

                    return "{$nombre} (CI {$p->ci}) está en estado «{$p->estado}». El resultado de admisión aún no ha sido publicado.";
                },
            ],
        ];
    }

    // ── Nivel 2: IA solo clasifica hacia un id de comando (no genera SQL) ──────
    private function interpretarConIA(string $texto): ?array
    {
        $apiKey = config('services.openai.key');
        if (! $apiKey) {
            return null;
        }
        $lista = collect($this->catalogo())->map(fn ($c) => "{$c['id']}: {$c['etiqueta']}")->implode("\n");
        $system = 'Eres un clasificador de intenciones para el sistema de admisión CUP/FICCT. '
            .'Responde SOLO un JSON {"comando": <id|null>}. Elige el id que mejor corresponda '
            ."a la pregunta del usuario de esta lista:\n{$lista}\nSi ninguno aplica, usa null. No inventes ids.";
        try {
            $resp = Http::withToken($apiKey)->timeout(20)->post('https://api.openai.com/v1/chat/completions', [
                'model' => config('services.openai.chat_model', 'gpt-4o-mini'),
                'temperature' => 0,
                'response_format' => ['type' => 'json_object'],
                'messages' => [
                    ['role' => 'system', 'content' => $system],
                    ['role' => 'user', 'content' => $texto],
                ],
            ]);
            if (! $resp->successful()) {
                return null;
            }
            $json = json_decode((string) $resp->json('choices.0.message.content'), true);
            $cmd = collect($this->catalogo())->firstWhere('id', $json['comando'] ?? null);
            if (! $cmd) {
                return null;
            }

            return $this->salida(true, 'ia', $cmd['id'], $texto, ($cmd['handler'])($this->norm($texto), $texto));
        } catch (\Throwable $e) {
            Log::warning('ConsultaVozService IA: '.$e->getMessage());

            return null;
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private function gestion(): ?Gestion
    {
        return Gestion::where('estado', 'en_curso')->first();
    }

    private function nombreGestion(?Gestion $g): string
    {
        return $g ? ($g->descripcion ?: ('#'.$g->id)) : 'actual';
    }

    /** Detecta una carrera mencionada en el texto por nombre o sigla. */
    private function carreraEnTexto(string $norm): ?Carrera
    {
        foreach (Carrera::where('estado', true)->get() as $c) {
            $nombre = $this->norm((string) $c->nombre);
            $sigla = $this->norm((string) ($c->sigla ?? ''));
            if ($nombre !== '' && str_contains($norm, $nombre)) {
                return $c;
            }
            if (strlen($sigla) >= 2 && str_contains($norm, $sigla)) {
                return $c;
            }
        }

        return null;
    }

    /** minúsculas + sin acentos (á→a, ñ→n) + espacios colapsados. */
    private function norm(string $t): string
    {
        return preg_replace('/\s+/', ' ', Str::ascii(mb_strtolower(trim($t))));
    }

    private function salida(bool $ok, string $origen, ?string $comando, string $pregunta, string $respuesta): array
    {
        return compact('ok', 'origen', 'comando', 'pregunta', 'respuesta');
    }
}
