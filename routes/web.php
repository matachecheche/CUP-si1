<?php

use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;
use App\Http\Controllers\BitacoraController;
use App\Http\Controllers\CarreraController;
use App\Http\Controllers\DocenteController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\LogoutController;
use App\Http\Controllers\MateriaController;
use App\Http\Controllers\PostulanteController;
use App\Http\Controllers\RoleController;
use App\Http\Controllers\UsuarioController;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use App\Models\Bitacora;

// ── Recuperación de contraseña (CU-03) ────────────────────────────────────────
Route::get('password/reset',         [ForgotPasswordController::class,'showLinkRequestForm'])->name('password.request');
Route::post('password/email',        [ForgotPasswordController::class,'sendResetLinkEmail'])->name('password.email');
Route::get('password/reset/{token}', [ResetPasswordController::class, 'showResetForm'])->name('password.reset');
Route::post('password/reset',        [ResetPasswordController::class, 'reset'])->name('password.update');

// ── Autenticación (CU-01, CU-02) ─────────────────────────────────────────────
Route::get('/login',  [LoginController::class, 'index'])->name('login');
Route::post('/login', [LoginController::class, 'login']);
Route::get('/logout', [LogoutController::class,'logout'])->name('logout');

// ── Rutas protegidas ─────────────────────────────────────────────────────────
Route::middleware('auth')->group(function () {

    Route::get('/',      [HomeController::class,'index'])->name('panel');
    Route::get('/panel', [HomeController::class,'index']);
    Route::get('/perfil',[UsuarioController::class,'miPerfil'])->name('users.perfil');

    // ── Módulo Autenticación y Seguridad (CU-01 a CU-04) ─────────────────────
    Route::resource('users',    UsuarioController::class);
    Route::resource('roles',    RoleController::class);
    Route::resource('bitacora', BitacoraController::class)->only(['index']);

    // ── Módulo Registro de Postulantes (CU-05 a CU-09) ───────────────────────
    Route::resource('postulantes', PostulanteController::class);

    // ── Módulo Gestión Académica (CU-10 a CU-13) ─────────────────────────────
    Route::resource('carreras', CarreraController::class);
    Route::post('carreras/{carrera}/cupos', [CarreraController::class,'storeCupo'])->name('carreras.cupos');
    Route::resource('materias', MateriaController::class);
    // Route::resource('gestiones', GestionController::class);     // próximo ciclo

    // ── Módulo Asignación de Grupos y Docentes (CU-14 a CU-21) ───────────────
    Route::resource('docentes', DocenteController::class);
    // Route::resource('grupos', GrupoController::class);          // próximo ciclo
    // Route::post('grupos/generar', ...)->name('grupos.generar');  // próximo ciclo

    // ── Módulo Exámenes y Control Académico (CU-22 a CU-26) ──────────────────
    // Route::resource('notas', NotaController::class);             // próximo ciclo

    // ── Módulo Panel Administrativo y Reportes (CU-27 a CU-33) ──────────────
    // Route::get('admision',           ...)->name('admision.index');  // próximo ciclo
    // Route::get('reportes',           ...)->name('reportes.index');  // próximo ciclo
});

// ── Bitácora: cierre de pestaña ───────────────────────────────────────────────
Route::post('/bitacora/page-close', function () {
    if (Auth::check()) {
        \Illuminate\Support\Facades\DB::table('bitacoras')->insert([
            'user_id'    => Auth::id(),
            'usuario'    => Auth::user()->name,
            'accion'     => 'Cerró o abandonó la página del sistema',
            'modulo'     => 'Seguridad',
            'metodo_http'=> 'POST',
            'ruta'       => 'bitacora/page-close',
            'fecha_hora' => now(),
            'ip'         => request()->ip(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
    return response()->noContent();
})->middleware('web')->name('bitacora.page-close');

Route::get('/401', fn() => view('pages.401'));
Route::get('/404', fn() => view('pages.404'));
Route::get('/500', fn() => view('pages.500'));
