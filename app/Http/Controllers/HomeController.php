<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Traits\BitacoraTrait;

class HomeController extends Controller
{
    use BitacoraTrait;

    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        // Registrar acción en la bitácora
        $this->registrarEnBitacora('Usuario accedió al panel de control');

        $comunicados = \App\Models\Comunicado::vigentes()
            ->paraUsuario(auth()->user())
            ->orderByDesc('created_at')->limit(5)->get();

        return view('panel.index', compact('comunicados'));
    }

    public function login()
    {
        // Registrar acción en la bitácora
        $this->registrarEnBitacora('Usuario inició sesión');

        // Lógica de inicio de sesión aquí
    }
}
