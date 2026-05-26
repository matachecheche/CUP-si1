<?php
use App\Http\Controllers\Auth\{ForgotPasswordController,ResetPasswordController};
use App\Http\Controllers\{BitacoraController,CarreraController,DocenteController,GestionController,HomeController,LoginController,LogoutController,MateriaController,PostulanteController,RoleController,UsuarioController};
use Illuminate\Support\Facades\{Auth,DB,Route};

// Recuperación de contraseña
Route::get('password/reset',         [ForgotPasswordController::class,'showLinkRequestForm'])->name('password.request');
Route::post('password/email',        [ForgotPasswordController::class,'sendResetLinkEmail'])->name('password.email');
Route::get('password/reset/{token}', [ResetPasswordController::class, 'showResetForm'])->name('password.reset');
Route::post('password/reset',        [ResetPasswordController::class, 'reset'])->name('password.update');

// Autenticación
Route::get('/login',  [LoginController::class, 'index'])->name('login');
Route::post('/login', [LoginController::class, 'login']);
Route::get('/logout', [LogoutController::class,'logout'])->name('logout');

Route::middleware('auth')->group(function () {
    Route::get('/',      [HomeController::class,'index'])->name('panel');
    Route::get('/panel', [HomeController::class,'index']);
    Route::get('/perfil',[UsuarioController::class,'miPerfil'])->name('users.perfil');

    // Módulo 1: Autenticación y Seguridad
    Route::resource('users',    UsuarioController::class);
    Route::resource('roles',    RoleController::class);
    Route::resource('bitacora', BitacoraController::class)->only(['index']);

    // Módulo 2: Registro de Postulantes (CU-05 a CU-09)
    Route::resource('postulantes', PostulanteController::class);

    // Módulo 3: Gestión Académica (CU-10 a CU-13)
    Route::resource('gestiones', GestionController::class);
    Route::resource('carreras',  CarreraController::class);
    Route::post('carreras/{carrera}/cupos',[CarreraController::class,'storeCupo'])->name('carreras.cupos');
    Route::resource('materias',  MateriaController::class);

    // Módulo 4: Asignación de Grupos y Docentes (CU-14 a CU-16)
    Route::resource('docentes', DocenteController::class);

    // Módulo 5: Exámenes y Control Académico (Ciclo 2)
    // Route::resource('notas', NotaController::class);

    // Módulo 6: Panel Administrativo y Reportes (Ciclo 2)
    // Route::get('admision', ...)->name('admision.index');
    // Route::get('reportes', ...)->name('reportes.index');
});

// Bitácora: cierre de pestaña
Route::post('/bitacora/page-close', function () {
    if (Auth::check()) {
        DB::table('bitacoras')->insert([
            'user_id'=>Auth::id(),'usuario'=>Auth::user()->name,
            'accion'=>'Cerró o abandonó la página del sistema',
            'modulo'=>'Seguridad','metodo_http'=>'POST','ruta'=>'bitacora/page-close',
            'fecha_hora'=>now(),'ip'=>request()->ip(),
            'created_at'=>now(),'updated_at'=>now(),
        ]);
    }
    return response()->noContent();
})->middleware('web')->name('bitacora.page-close');

Route::get('/401',fn()=>view('pages.401'));
Route::get('/404',fn()=>view('pages.404'));
Route::get('/500',fn()=>view('pages.500'));
