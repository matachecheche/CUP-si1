<?php

namespace App\Http\Controllers;

use App\Http\Requests\LoginRequest;
use Illuminate\Support\Facades\Auth;
use App\Traits\BitacoraTrait;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class LoginController extends Controller
{
    use BitacoraTrait;

    public function index()
    {
        if (Auth::check()) {
            return redirect()->route('panel');
        }
        return view('auth.login');
    }

    public function login(LoginRequest $request)
    {
        // 1. Crear llave única basada SOLO en el email para máxima persistencia
        $throttleKey = 'login_lock_' . Str::lower($request->input('email'));

        // 2. VERIFICACIÓN RADICAL: Si ya está bloqueado, no procesamos NADA más.
        if (RateLimiter::tooManyAttempts($throttleKey, 3)) {
            $seconds = RateLimiter::availableIn($throttleKey);
            
            throw ValidationException::withMessages([
                'email' => "BLOQUEADO. Demasiados intentos. Intenta en $seconds segundos.",
            ]);
        }

        // 3. Intentar validar las credenciales en la base de datos
        $credentials = $request->only('email', 'password');

        if (!Auth::validate($credentials)) {
            
            // ❌ FALLO: Registramos el golpe y forzamos la persistencia
            RateLimiter::hit($throttleKey, 60);
            
            $remaining = RateLimiter::remaining($throttleKey, 3);

            throw ValidationException::withMessages([
                'email' => "Credenciales incorrectas. Intentos restantes: $remaining",
            ]);
        }

        // 4. ÉXITO: Los datos son correctos
        $user = Auth::getProvider()->retrieveByCredentials($credentials);
        
        // Antes de loguear, verificamos una última vez por si acaso entró una petición paralela
        if (RateLimiter::tooManyAttempts($throttleKey, 3)) {
             throw ValidationException::withMessages([
                'email' => "Acceso denegado temporalmente por seguridad.",
            ]);
        }

        Auth::login($user);

        // ✅ Limpiamos el contador
        RateLimiter::clear($throttleKey);

        $this->registrarEnBitacora('Usuario inició sesión', $user->id);

        return redirect()->route('panel');
    }
}