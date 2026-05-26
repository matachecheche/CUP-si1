<?php
namespace App\Traits;

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

trait BitacoraTrait
{
    public function registrarEnBitacora(string $accion, $id = null, string $modulo = ''): void
    {
        try {
            $u = Auth::user();
            DB::table('bitacoras')->insert([
                'user_id'     => $u?->id,
                'usuario'     => $u?->name ?? 'Sistema',
                'accion'      => substr($accion, 0, 250),
                'modulo'      => substr($modulo, 0, 60),
                'metodo_http' => request()->method(),
                'ruta'        => substr(request()->path(), 0, 255),
                'ip'          => request()->ip(),
                'user_agent'  => substr(request()->userAgent() ?? '', 0, 255),
                'fecha_hora'  => now(),
                'id_operacion'=> $id,
                'created_at'  => now(),
                'updated_at'  => now(),
            ]);
        } catch (\Throwable $e) {
            Log::error('BitacoraTrait: ' . $e->getMessage());
        }
    }
}
