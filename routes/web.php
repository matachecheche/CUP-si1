<?php

use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;
use App\Http\Controllers\BitacoraController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\LoginController;
use App\Http\Controllers\LogoutController;
use App\Http\Controllers\RoleController;
use App\Http\Controllers\UsuarioController;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;
use App\Models\Bitacora;

// ── Recuperación de contraseña (CU-03) ────────────────────────────────────────
Route::get('password/reset',          [ForgotPasswordController::class, 'showLinkRequestForm'])->name('password.request');
Route::post('password/email',         [ForgotPasswordController::class, 'sendResetLinkEmail'])->name('password.email');
Route::get('password/reset/{token}',  [ResetPasswordController::class,  'showResetForm'])->name('password.reset');
Route::post('password/reset',         [ResetPasswordController::class,  'reset'])->name('password.update');

// ── Autenticación (CU-01, CU-02) ─────────────────────────────────────────────
Route::get('/login',  [LoginController::class,  'index'])->name('login');
Route::post('/login', [LoginController::class,  'login']);
Route::get('/logout', [LogoutController::class, 'logout'])->name('logout');

// ── Rutas protegidas ─────────────────────────────────────────────────────────
Route::middleware('auth')->group(function () {

    // Panel principal (redirige según rol)
    Route::get('/',      [HomeController::class, 'index'])->name('panel');
    Route::get('/panel', [HomeController::class, 'index']);

    // Perfil propio
    Route::get('/perfil', [UsuarioController::class, 'miPerfil'])->name('users.perfil');

    // ── MÓDULO SEGURIDAD — Implementado ──────────────────────────────────────
    Route::resource('users',    UsuarioController::class);
    Route::resource('roles',    RoleController::class);
    Route::resource('bitacora', BitacoraController::class)->only(['index']);

    // ── MÓDULO GESTIÓN ACADÉMICA (CU-10 a CU-13) ─────────────────────────────
    // Route::resource('gestiones', GestionController::class);
    // Route::resource('carreras',  CarreraController::class);
    // Route::resource('materias',  MateriaController::class);
    // Route::post('carreras/{carrera}/cupos', [CarreraController::class, 'definirCupo'])->name('carreras.cupos');

    // ── MÓDULO DOCENTES (CU-14 a CU-16) ──────────────────────────────────────
    // Route::resource('docentes', DocenteController::class);

    // ── MÓDULO POSTULANTES (CU-05 a CU-09) ───────────────────────────────────
    // Route::resource('postulantes', PostulanteController::class);
    // Route::post('postulantes/{postulante}/validar', [PostulanteController::class, 'validarRequisitos'])->name('postulantes.validar');

    // ── MÓDULO GRUPOS / AULAS (CU-17 a CU-21) ────────────────────────────────
    // Route::resource('grupos', GrupoController::class);
    // Route::post('/grupos/generar', [GrupoController::class, 'generarAutomatico'])->name('grupos.generar');
    // Route::post('/grupos/{grupo}/asignar-docente', [GrupoController::class, 'asignarDocente'])->name('grupos.asignarDocente');
    // Route::post('/grupos/{grupo}/inscribir', [GrupoController::class, 'inscribirPostulantes'])->name('grupos.inscribir');

    // ── MÓDULO HORARIOS (CU-19, CU-20) ───────────────────────────────────────
    // Route::resource('horarios', HorarioController::class);

    // ── MÓDULO EVALUACIÓN / NOTAS (CU-22 a CU-26) ────────────────────────────
    // Route::resource('notas', NotaController::class);
    // Route::get('mis-notas', [NotaController::class, 'misNotas'])->name('notas.propias');

    // ── MÓDULO ADMISIÓN (CU-27 a CU-29) ──────────────────────────────────────
    // Route::get('admision',                  [AdmisionController::class, 'index'])->name('admision.index');
    // Route::post('admision/procesar',        [AdmisionController::class, 'procesar'])->name('admision.procesar');
    // Route::post('admision/reasignar',       [AdmisionController::class, 'reasignar'])->name('admision.reasignar');
    // Route::post('admision/publicar',        [AdmisionController::class, 'publicar'])->name('admision.publicar');
    // Route::get('mi-resultado',              [AdmisionController::class, 'miResultado'])->name('admision.resultado-propio');

    // ── MÓDULO REPORTES (CU-30 a CU-33) ──────────────────────────────────────
    // Route::get('reportes',                  [ReporteController::class, 'index'])->name('reportes.index');
    // Route::get('reportes/grupos',           [ReporteController::class, 'porGrupo'])->name('reportes.grupos');
    // Route::get('reportes/admitidos',        [ReporteController::class, 'admitidos'])->name('reportes.admitidos');
    // Route::get('reportes/historico',        [ReporteController::class, 'historico'])->name('reportes.historico');
    // Route::get('reportes/estadisticas',     [ReporteController::class, 'estadisticas'])->name('reportes.estadisticas');
});

// ── Bitácora: cierre de página (sendBeacon) ───────────────────────────────────
Route::post('/bitacora/page-close', function () {
    if (Auth::check()) {
        Bitacora::create([
            'user_id'    => Auth::id(),
            'usuario'    => Auth::user()->name,
            'accion'     => 'Cerró o abandonó la página del sistema',
            'fecha_hora' => now(),
            'ip'         => request()->ip(),
        ]);
    }
    return response()->noContent();
})->middleware('web')->name('bitacora.page-close');

// ── Páginas de error ──────────────────────────────────────────────────────────
Route::get('/401', fn() => view('pages.401'));
Route::get('/404', fn() => view('pages.404'));
Route::get('/500', fn() => view('pages.500'));
