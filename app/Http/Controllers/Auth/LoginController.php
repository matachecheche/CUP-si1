<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    use AuthenticatesUsers;

    protected $redirectTo = '/home';

    public function __construct()
    {
        $this->middleware('guest')->except('logout');
    }

    public function index()
    {
        return view('auth.login');
    }

    public function login(Request $request)
    {
        // Validación
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // 🔒 Si ya está bloqueado
        if ($this->hasTooManyLoginAttempts($request)) {
            return back()->withErrors([
                'email' => 'Demasiados intentos. Intenta nuevamente en 1 minuto.'
            ]);
        }

        // Intento de login
        if (Auth::attempt($request->only('email', 'password'))) {

            // ✅ éxito → limpiar intentos
            $this->clearLoginAttempts($request);

            return redirect()->intended($this->redirectTo);
        }

        // ❌ fallo → sumar intento
        $this->incrementLoginAttempts($request);

        return back()->withErrors([
            'email' => 'Credenciales incorrectas.'
        ]);
    }

    // 🔥 AQUÍ ESTÁ LA CLAVE
    protected function maxAttempts()
    {
        return 3; // solo 3 intentos
    }

    protected function decayMinutes()
    {
        return 1; // bloqueo 1 minuto
    }
}