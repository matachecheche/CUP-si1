#!/usr/bin/env bash
# =============================================================================
#  adaptar_a_cup_v2.sh
#  Adapta el proyecto condominio-SA (rama academia) al Sistema de Admisión CUP
#  según el documento nuevo.odt (Proceso Unificado y UML — Ing. CUP)
#
#  CAMBIOS RESPECTO A v1:
#    - Roles reducidos a 3: Administrador, Docente, Postulante
#    - Se elimina "Responsable de Admisiones" y "Autoridad de la Facultad"
#    - El Administrador absorbe TODAS las funciones de gestión y reportes
#    - Permisos rediseñados según los 33 casos de uso del documento
#    - Migraciones del dominio CUP completas (gestiones → postulantes)
#    - Usuarios semilla alineados a los 3 roles
#
#  USO:
#    1. git clone --branch academia https://github.com/matachecheche/condominio-SA.git admision-cup
#    2. cd admision-cup
#    3. chmod +x adaptar_a_cup_v2.sh
#    4. bash adaptar_a_cup_v2.sh
# =============================================================================

set -e
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

info()    { echo -e "${CYAN}[INFO]${NC}  $1"; }
success() { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ── 0. Verificar raíz del proyecto Laravel ────────────────────────────────────
[ -f "artisan" ] || error "No se encontró artisan. Ejecuta desde la raíz del proyecto Laravel."

# =============================================================================
#  1. NOMBRE Y MARCA DEL SISTEMA
# =============================================================================
info "Actualizando nombre del sistema..."

[ -f ".env" ]         && sed -i 's/^APP_NAME=.*/APP_NAME="Sistema de Admision CUP"/' .env         && success ".env → APP_NAME"
[ -f ".env.example" ] && sed -i 's/^APP_NAME=.*/APP_NAME="Sistema de Admision CUP"/' .env.example

sed -i "s/'title' => '.*'/'title' => 'Admisión CUP'/"          config/adminlte.php 2>/dev/null || true
sed -i "s|'logo' => '.*'|'logo' => '<b>Admisión<\/b>CUP'|"    config/adminlte.php 2>/dev/null || true
success "config/adminlte.php → título y logo"

# =============================================================================
#  2. MIGRACIÓN: TABLA USERS
#     FK opcionales: docente_id, postulante_id (según el actor que usa el sistema)
# =============================================================================
info "Reescribiendo migración de users..."

TARGET_USERS="database/migrations/0001_01_01_000013_create_users_table.php"
cat > "$TARGET_USERS" << 'MIGRATION'
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Tabla de usuarios — Sistema de Admisión CUP
 *
 * Roles (nuevo.odt § 4 — Actores del sistema):
 *   - Administrador del Sistema  → gestión general, configuración, reportes
 *   - Docente                    → registro de notas de sus grupos
 *   - Postulante                 → consulta de notas y resultado de admisión
 *
 * Un usuario tiene exactamente uno de estos roles (Spatie/Permission).
 * Las FK docente_id / postulante_id vinculan el usuario con su entidad de dominio.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');

            // Vínculo a entidad de dominio (solo uno puede estar presente)
            $table->foreignId('docente_id')
                  ->nullable()
                  ->constrained('docentes')
                  ->nullOnDelete();
            $table->foreignId('postulante_id')
                  ->nullable()
                  ->constrained('postulantes')
                  ->nullOnDelete();

            $table->boolean('activo')->default(true);
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
MIGRATION
success "$TARGET_USERS"

# =============================================================================
#  3. MODELO User
# =============================================================================
info "Actualizando app/Models/User.php..."

cat > app/Models/User.php << 'MODEL'
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable
{
    use HasFactory, Notifiable, HasRoles;

    protected $fillable = [
        'name',
        'email',
        'email_verified_at',
        'password',
        'docente_id',
        'postulante_id',
        'activo',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password'          => 'hashed',
        ];
    }

    // ── Relaciones ────────────────────────────────────────────────────────────

    /** Usuario vinculado a un docente del CUP */
    public function docente()
    {
        return $this->belongsTo(Docente::class);
    }

    /** Usuario vinculado a un postulante */
    public function postulante()
    {
        return $this->belongsTo(Postulante::class);
    }

    /** Registro de acciones en bitácora */
    public function bitacoras()
    {
        return $this->hasMany(Bitacora::class);
    }
}
MODEL
success "app/Models/User.php"

# =============================================================================
#  4. SEEDER: Permisos
#     Mapeo 1-a-1 con los 33 casos de uso del documento (§ 6)
# =============================================================================
info "Creando PermissionSeeder (33 CU → nuevo.odt)..."

mkdir -p database/seeders
cat > database/seeders/PermissionSeeder.php << 'SEEDER'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;

/**
 * Permisos del Sistema de Admisión CUP
 * Derivados de los 33 casos de uso identificados en nuevo.odt § 6
 *
 * Roles que los consumen (§ 4):
 *   Administrador   → gestión total del sistema
 *   Docente         → registrar notas, consultar grupos y nóminas
 *   Postulante      → consultar sus propias notas y resultado
 */
class PermissionSeeder extends Seeder
{
    public function run(): void
    {
        $permisos = [

            // ── SEGURIDAD (CU-01 a CU-04) ─────────────────────────────────────
            // CU-01/02/03: login, logout y recuperar contraseña son rutas abiertas,
            // no requieren permiso explícito. Solo se protege la gestión de usuarios.
            'ver usuarios',       // CU-04 parcial
            'crear usuarios',
            'editar usuarios',
            'eliminar usuarios',
            'ver roles',
            'crear roles',
            'editar roles',
            'eliminar roles',
            'ver bitacora',

            // ── GESTIÓN DE POSTULANTES (CU-05 a CU-09) ───────────────────────
            'ver postulantes',           // CU-05, CU-09
            'crear postulantes',         // CU-05
            'editar postulantes',        // (modificar antes del cierre)
            'eliminar postulantes',
            'cargar documentos postulante',   // CU-06
            'validar requisitos postulante',  // CU-07
            'seleccionar opciones carrera',   // CU-08 — el postulante elige carreras
            'consultar estado propio',        // CU-09 — solo para el postulante

            // ── GESTIÓN ACADÉMICA (CU-10 a CU-13) ────────────────────────────
            'ver carreras',
            'crear carreras',     // CU-10
            'editar carreras',
            'eliminar carreras',
            'definir cupos',      // CU-11
            'ver cupos',
            'ver materias',
            'crear materias',     // CU-12
            'editar materias',
            'eliminar materias',
            'ver gestiones',
            'crear gestiones',    // CU-13
            'editar gestiones',
            'eliminar gestiones',

            // ── GESTIÓN DE DOCENTES (CU-14 a CU-16) ──────────────────────────
            'ver docentes',
            'crear docentes',     // CU-14
            'editar docentes',
            'eliminar docentes',
            'ver carga horaria docente',  // CU-16

            // ── CONFORMACIÓN DE GRUPOS (CU-17 a CU-21) ───────────────────────
            'generar grupos automaticos', // CU-17
            'ver grupos',
            'crear grupos',
            'editar grupos',
            'eliminar grupos',
            'asignar docente grupo',      // CU-18
            'ver horarios',
            'crear horarios',             // CU-20
            'editar horarios',
            'eliminar horarios',
            'inscribir postulantes grupos', // CU-21

            // ── EVALUACIÓN Y NOTAS (CU-22 a CU-26) ───────────────────────────
            'registrar notas',       // CU-22 — exclusivo del Docente
            'ver notas',             // CU-26 (admin/docente)
            'ver notas propias',     // CU-26 — solo el Postulante ve las suyas

            // ── ADMISIÓN (CU-27 a CU-29) ─────────────────────────────────────
            'procesar admision',          // CU-27
            'reasignar segunda opcion',   // CU-28
            'publicar resultado admision',// CU-29
            'ver resultados admision',    // Administrador
            'ver resultado propio',       // CU — Postulante consulta su resultado

            // ── REPORTES (CU-30 a CU-33) ─────────────────────────────────────
            'ver reportes',              // CU-30, CU-31, CU-32, CU-33
        ];

        foreach ($permisos as $permiso) {
            Permission::firstOrCreate(['name' => $permiso, 'guard_name' => 'web']);
        }
    }
}
SEEDER
success "database/seeders/PermissionSeeder.php"

# =============================================================================
#  5. SEEDER: Roles
#     Solo 3 roles según nuevo.odt § 4 (Actores del sistema)
# =============================================================================
info "Creando RolesSeeder (3 roles: Administrador, Docente, Postulante)..."

cat > database/seeders/RolesSeeder.php << 'SEEDER'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

/**
 * Roles del Sistema de Admisión CUP — nuevo.odt § 4
 *
 * ┌─────────────────────────────┬──────────────────────────────────────────────┐
 * │ Rol                         │ Descripción (nuevo.odt)                      │
 * ├─────────────────────────────┼──────────────────────────────────────────────┤
 * │ Administrador del Sistema   │ Personal de la facultad. Configuración,      │
 * │                             │ gestión de usuarios, supervisión general,    │
 * │                             │ registro de postulantes, asignación de       │
 * │                             │ docentes, proceso de admisión, reportes.     │
 * ├─────────────────────────────┼──────────────────────────────────────────────┤
 * │ Docente                     │ Registra notas de sus grupos. Consulta       │
 * │                             │ nómina de alumnos a su cargo.                │
 * ├─────────────────────────────┼──────────────────────────────────────────────┤
 * │ Postulante                  │ Consulta sus notas y resultado de admisión.  │
 * │                             │ Carga documentos y elige opciones de carrera.│
 * └─────────────────────────────┴──────────────────────────────────────────────┘
 */
class RolesSeeder extends Seeder
{
    public function run(): void
    {
        // ── 1. Administrador del Sistema ──────────────────────────────────────
        // Tiene acceso total (todos los permisos del sistema)
        $admin = Role::firstOrCreate(['name' => 'Administrador del Sistema', 'guard_name' => 'web']);
        $admin->syncPermissions(Permission::all());

        // ── 2. Docente ────────────────────────────────────────────────────────
        // Solo opera sobre los grupos que le fueron asignados (CU-16, CU-22)
        $docente = Role::firstOrCreate(['name' => 'Docente', 'guard_name' => 'web']);
        $docente->syncPermissions([
            'ver grupos',
            'ver postulantes',
            'ver notas',
            'registrar notas',         // CU-22: registrar notas de sus grupos
            'ver carga horaria docente', // CU-16: consultar su propia carga
        ]);

        // ── 3. Postulante ─────────────────────────────────────────────────────
        // Acceso de solo lectura a sus propios datos (CU-06, CU-08, CU-09, CU-26)
        $postulante = Role::firstOrCreate(['name' => 'Postulante', 'guard_name' => 'web']);
        $postulante->syncPermissions([
            'cargar documentos postulante',  // CU-06
            'seleccionar opciones carrera',  // CU-08
            'consultar estado propio',       // CU-09
            'ver notas propias',             // CU-26
            'ver resultado propio',          // post CU-29
        ]);
    }
}
SEEDER
success "database/seeders/RolesSeeder.php"

# =============================================================================
#  6. SEEDER: Usuarios iniciales (uno por cada rol)
# =============================================================================
info "Creando UsuariosSeeder..."

cat > database/seeders/UsuariosSeeder.php << 'SEEDER'
<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UsuariosSeeder extends Seeder
{
    public function run(): void
    {
        $pwd = Hash::make('12345678');

        // Un usuario de prueba por rol
        $usuarios = [
            [
                'name'  => 'Administrador CUP',
                'email' => 'admin@cup.edu.bo',
                'rol'   => 'Administrador del Sistema',
            ],
            [
                'name'  => 'Docente Demo',
                'email' => 'docente@cup.edu.bo',
                'rol'   => 'Docente',
            ],
            [
                'name'  => 'Postulante Demo',
                'email' => 'postulante@cup.edu.bo',
                'rol'   => 'Postulante',
            ],
        ];

        foreach ($usuarios as $data) {
            $user = User::firstOrCreate(
                ['email' => $data['email']],
                [
                    'name'              => $data['name'],
                    'activo'            => true,
                    'email_verified_at' => now(),
                    'password'          => $pwd,
                ]
            );
            $user->syncRoles([$data['rol']]);
        }
    }
}
SEEDER
success "database/seeders/UsuariosSeeder.php"

# =============================================================================
#  7. DatabaseSeeder
# =============================================================================
info "Actualizando DatabaseSeeder..."

cat > database/seeders/DatabaseSeeder.php << 'SEEDER'
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            // Orden estricto: permisos → roles → usuarios
            PermissionSeeder::class,
            RolesSeeder::class,
            UsuariosSeeder::class,

            // Datos de referencia del dominio (descomenta a medida que implementes)
            // GestionSeeder::class,
            // CarreraSeeder::class,
            // MateriaSeeder::class,
            // DocenteSeeder::class,
        ]);
    }
}
SEEDER
success "database/seeders/DatabaseSeeder.php"

# =============================================================================
#  8. CONTROLADOR: UsuarioController (adaptado a 3 roles)
# =============================================================================
info "Actualizando UsuarioController..."

cat > app/Http/Controllers/UsuarioController.php << 'CONTROLLER'
<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;
use Exception;

class UsuarioController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver usuarios')->only('index');
        $this->middleware('permission:crear usuarios')->only(['create', 'store']);
        $this->middleware('permission:editar usuarios')->only(['edit', 'update']);
        $this->middleware('permission:eliminar usuarios')->only('destroy');
    }

    public function index()
    {
        $users = User::with('roles')->get();
        return view('users.index', compact('users'));
    }

    public function miPerfil()
    {
        $user = auth()->user();
        return view('users.perfil', compact('user'));
    }

    public function create()
    {
        $roles      = Role::all();
        $docentes   = class_exists(\App\Models\Docente::class)   ? \App\Models\Docente::all()   : collect();
        $postulantes = class_exists(\App\Models\Postulante::class) ? \App\Models\Postulante::all() : collect();
        return view('users.create', compact('roles', 'docentes', 'postulantes'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:100',
            'email'    => 'required|email|unique:users,email',
            'password' => 'required|string|min:8|confirmed',
            'role'     => 'required|exists:roles,name',
        ]);

        // Validar que no se vinculen ambos tipos a la vez
        if ($request->filled('docente_id') && $request->filled('postulante_id')) {
            return back()
                ->withErrors(['vínculo' => 'Un usuario solo puede vincularse a un Docente O a un Postulante, no ambos.'])
                ->withInput();
        }

        try {
            DB::beginTransaction();
            $user = User::create([
                'name'              => $request->name,
                'email'             => $request->email,
                'password'          => Hash::make($request->password),
                'docente_id'        => $request->docente_id   ?: null,
                'postulante_id'     => $request->postulante_id ?: null,
                'email_verified_at' => now(),
                'activo'            => true,
            ]);
            $user->assignRole($request->role);
            $this->registrarEnBitacora('Usuario creado: ' . $user->name, $user->id);
            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $this->registrarEnBitacora('Error al crear usuario: ' . $e->getMessage());
            return back()->withErrors(['error' => 'Error al crear el usuario: ' . $e->getMessage()])->withInput();
        }

        return redirect()->route('users.index')->with('success', 'Usuario creado correctamente.');
    }

    public function show(User $user)
    {
        return view('users.show', compact('user'));
    }

    public function edit(User $user)
    {
        $roles       = Role::all();
        $docentes    = class_exists(\App\Models\Docente::class)   ? \App\Models\Docente::all()   : collect();
        $postulantes = class_exists(\App\Models\Postulante::class) ? \App\Models\Postulante::all() : collect();
        return view('users.edit', compact('user', 'roles', 'docentes', 'postulantes'));
    }

    public function update(Request $request, User $user)
    {
        $request->validate([
            'name'  => 'required|string|max:100',
            'email' => 'required|email|unique:users,email,' . $user->id,
            'role'  => 'required|exists:roles,name',
        ]);

        if ($request->filled('docente_id') && $request->filled('postulante_id')) {
            return back()
                ->withErrors(['vínculo' => 'Un usuario solo puede vincularse a un Docente O a un Postulante, no ambos.'])
                ->withInput();
        }

        try {
            DB::beginTransaction();
            $user->update([
                'name'          => $request->name,
                'email'         => $request->email,
                'docente_id'    => $request->docente_id   ?: null,
                'postulante_id' => $request->postulante_id ?: null,
            ]);
            if ($request->filled('password')) {
                $request->validate(['password' => 'string|min:8|confirmed']);
                $user->update(['password' => Hash::make($request->password)]);
            }
            $user->syncRoles([$request->role]);
            $this->registrarEnBitacora('Usuario actualizado: ' . $user->name, $user->id);
            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            return back()->withErrors(['error' => 'Error al actualizar: ' . $e->getMessage()]);
        }

        return redirect()->route('users.index')->with('success', 'Usuario actualizado correctamente.');
    }

    public function destroy(string $id)
    {
        $user   = User::findOrFail($id);
        $user->update(['activo' => !$user->activo]);
        $estado = $user->activo ? 'activado' : 'desactivado';
        $this->registrarEnBitacora("Usuario {$estado}: {$user->name}", $user->id);
        return redirect()->route('users.index')->with('success', "Usuario {$estado} correctamente.");
    }
}
CONTROLLER
success "app/Http/Controllers/UsuarioController.php"

# =============================================================================
#  9. CONTROLADOR: RoleController (sin cambios de lógica, actualiza texto de protección)
# =============================================================================
info "Actualizando RoleController..."

cat > app/Http/Controllers/RoleController.php << 'CONTROLLER'
<?php

namespace App\Http\Controllers;

use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;

class RoleController extends Controller
{
    use BitacoraTrait;

    // Roles del sistema que NO pueden eliminarse
    const ROLES_PROTEGIDOS = ['Administrador del Sistema', 'Docente', 'Postulante'];

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver roles')->only('index');
        $this->middleware('permission:crear roles')->only(['create', 'store']);
        $this->middleware('permission:editar roles')->only(['edit', 'update']);
        $this->middleware('permission:eliminar roles')->only('destroy');
    }

    public function index()
    {
        $roles = Role::with('permissions')->get();
        return view('roles.index', compact('roles'));
    }

    public function create()
    {
        $permisos = Permission::all()->groupBy(function ($p) {
            // Agrupa por la última palabra del nombre del permiso (módulo)
            $parts = explode(' ', $p->name);
            return ucfirst(end($parts));
        });
        return view('roles.create', compact('permisos'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name'         => 'required|string|unique:roles,name',
            'permission'   => 'required|array|min:1',
            'permission.*' => 'exists:permissions,id',
        ]);

        DB::beginTransaction();
        try {
            $role = Role::create(['name' => $request->name, 'guard_name' => 'web']);
            $permissions = Permission::whereIn('id', $request->permission)->pluck('name');
            $role->syncPermissions($permissions);
            $this->registrarEnBitacora('Rol creado: ' . $role->name, $role->id);
            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->withErrors(['error' => 'Error al crear el rol: ' . $e->getMessage()])->withInput();
        }

        return redirect()->route('roles.index')->with('success', 'Rol creado correctamente.');
    }

    public function edit(Role $role)
    {
        $permisos = Permission::all()->groupBy(function ($p) {
            $parts = explode(' ', $p->name);
            return ucfirst(end($parts));
        });
        $permisosRol = $role->permissions->pluck('name')->toArray();
        return view('roles.edit', compact('role', 'permisos', 'permisosRol'));
    }

    public function update(Request $request, Role $role)
    {
        $request->validate([
            'name'         => 'required|string|unique:roles,name,' . $role->id,
            'permission'   => 'required|array|min:1',
            'permission.*' => 'exists:permissions,id',
        ]);

        DB::beginTransaction();
        try {
            $role->update(['name' => $request->name]);
            $permissions = Permission::whereIn('id', $request->permission)->pluck('name');
            $role->syncPermissions($permissions);
            $this->registrarEnBitacora('Rol actualizado: ' . $role->name, $role->id);
            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->withErrors(['error' => 'Error al actualizar el rol: ' . $e->getMessage()]);
        }

        return redirect()->route('roles.index')->with('success', 'Rol actualizado correctamente.');
    }

    public function destroy(Role $role)
    {
        if (in_array($role->name, self::ROLES_PROTEGIDOS)) {
            return back()->withErrors(['No se puede eliminar el rol "' . $role->name . '" porque es un rol base del sistema.']);
        }
        $this->registrarEnBitacora('Rol eliminado: ' . $role->name, $role->id);
        $role->delete();
        return redirect()->route('roles.index')->with('success', 'Rol eliminado correctamente.');
    }
}
CONTROLLER
success "app/Http/Controllers/RoleController.php"

# =============================================================================
#  10. RUTAS web.php — limpias con comentarios para los módulos futuros
# =============================================================================
info "Actualizando routes/web.php..."

cat > routes/web.php << 'ROUTES'
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
ROUTES
success "routes/web.php"

# =============================================================================
#  11. VISTA: users/index.blade.php
# =============================================================================
info "Actualizando vistas de usuarios..."
mkdir -p resources/views/users

cat > resources/views/users/index.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title', 'Usuarios — Admisión CUP')

@push('css')
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
@endpush

@section('content')
@include('layouts.partials.alert')

@if(session('success'))
<script>
    Swal.mixin({ toast:true, position:'top-end', showConfirmButton:false, timer:2500, timerProgressBar:true })
        .fire({ icon:'success', title:"{{ session('success') }}" });
</script>
@endif

<div class="container-fluid px-4">
    <h1 class="mt-4">Usuarios del Sistema</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="{{ route('panel') }}">Inicio</a></li>
        <li class="breadcrumb-item active">Usuarios</li>
    </ol>

    @can('crear usuarios')
    <div class="mb-3">
        <a href="{{ route('users.create') }}" class="btn btn-primary btn-sm">
            <i class="fas fa-user-plus me-1"></i> Nuevo Usuario
        </a>
    </div>
    @endcan

    <div class="card mb-4">
        <div class="card-header"><i class="fas fa-users me-1"></i> Listado de Usuarios</div>
        <div class="card-body">
            <table id="datatablesSimple" class="table table-striped table-sm">
                <thead>
                    <tr>
                        <th>#</th><th>Nombre</th><th>Email</th>
                        <th>Rol</th><th>Estado</th><th>Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach($users as $user)
                    <tr>
                        <td>{{ $loop->iteration }}</td>
                        <td>{{ $user->name }}</td>
                        <td>{{ $user->email }}</td>
                        <td>
                            @foreach($user->getRoleNames() as $rol)
                                @php
                                    $color = match($rol) {
                                        'Administrador del Sistema' => 'danger',
                                        'Docente'                   => 'primary',
                                        'Postulante'                => 'success',
                                        default                     => 'secondary',
                                    };
                                @endphp
                                <span class="badge bg-{{ $color }}">{{ $rol }}</span>
                            @endforeach
                        </td>
                        <td>
                            <span class="badge {{ $user->activo ? 'bg-success' : 'bg-secondary' }}">
                                {{ $user->activo ? 'Activo' : 'Inactivo' }}
                            </span>
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                @can('editar usuarios')
                                <a href="{{ route('users.edit', $user) }}" class="btn btn-warning btn-sm" title="Editar">
                                    <i class="fas fa-edit"></i>
                                </a>
                                @endcan
                                @can('eliminar usuarios')
                                <form action="{{ route('users.destroy', $user) }}" method="POST" class="d-inline">
                                    @csrf @method('DELETE')
                                    <button class="btn btn-sm {{ $user->activo ? 'btn-danger' : 'btn-success' }}"
                                            title="{{ $user->activo ? 'Desactivar' : 'Activar' }}"
                                            onclick="return confirm('¿Confirmar cambio de estado?')">
                                        <i class="fas fa-{{ $user->activo ? 'ban' : 'check' }}"></i>
                                    </button>
                                </form>
                                @endcan
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection
BLADE

# =============================================================================
#  12. VISTA: users/create.blade.php
# =============================================================================
cat > resources/views/users/create.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title', 'Crear Usuario')

@section('content')
<div class="container-fluid px-4">
    <h1 class="mt-4">Crear Usuario</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="{{ route('panel') }}">Inicio</a></li>
        <li class="breadcrumb-item"><a href="{{ route('users.index') }}">Usuarios</a></li>
        <li class="breadcrumb-item active">Crear</li>
    </ol>

    <div class="card">
        <div class="card-header"><i class="fas fa-user-plus me-1"></i> Nuevo Usuario</div>
        <div class="card-body">
            @if($errors->any())
                <div class="alert alert-danger">
                    <ul class="mb-0">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul>
                </div>
            @endif

            <form action="{{ route('users.store') }}" method="POST">
                @csrf
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Nombre completo *</label>
                        <input type="text" name="name" class="form-control" value="{{ old('name') }}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Email *</label>
                        <input type="email" name="email" class="form-control" value="{{ old('email') }}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Contraseña *</label>
                        <input type="password" name="password" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Confirmar contraseña *</label>
                        <input type="password" name="password_confirmation" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Rol *</label>
                        <select name="role" class="form-select" required>
                            <option value="">— Seleccionar rol —</option>
                            @foreach($roles as $rol)
                                <option value="{{ $rol->name }}" {{ old('role') == $rol->name ? 'selected' : '' }}>
                                    {{ $rol->name }}
                                </option>
                            @endforeach
                        </select>
                        <div class="form-text">
                            Roles disponibles: <strong>Administrador del Sistema</strong>,
                            <strong>Docente</strong>, <strong>Postulante</strong>
                        </div>
                    </div>

                    {{-- Vínculo a Docente (solo si ya existen docentes registrados) --}}
                    @if($docentes->count())
                    <div class="col-md-6">
                        <label class="form-label">Vincular a Docente <small class="text-muted">(opcional)</small></label>
                        <select name="docente_id" class="form-select">
                            <option value="">— Ninguno —</option>
                            @foreach($docentes as $d)
                                <option value="{{ $d->id }}" {{ old('docente_id') == $d->id ? 'selected' : '' }}>
                                    {{ $d->nombres }} {{ $d->apellidos }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    @endif

                    {{-- Vínculo a Postulante (solo si ya existen postulantes registrados) --}}
                    @if($postulantes->count())
                    <div class="col-md-6">
                        <label class="form-label">Vincular a Postulante <small class="text-muted">(opcional)</small></label>
                        <select name="postulante_id" class="form-select">
                            <option value="">— Ninguno —</option>
                            @foreach($postulantes as $p)
                                <option value="{{ $p->id }}" {{ old('postulante_id') == $p->id ? 'selected' : '' }}>
                                    {{ $p->nombres }} {{ $p->apellidos }} — CI: {{ $p->ci }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    @endif
                </div>

                <div class="mt-4">
                    <button type="submit" class="btn btn-primary">Guardar</button>
                    <a href="{{ route('users.index') }}" class="btn btn-secondary ms-2">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
BLADE

# =============================================================================
#  13. VISTA: users/edit.blade.php
# =============================================================================
cat > resources/views/users/edit.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title', 'Editar Usuario')

@section('content')
<div class="container-fluid px-4">
    <h1 class="mt-4">Editar Usuario</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="{{ route('panel') }}">Inicio</a></li>
        <li class="breadcrumb-item"><a href="{{ route('users.index') }}">Usuarios</a></li>
        <li class="breadcrumb-item active">Editar</li>
    </ol>

    <div class="card">
        <div class="card-header"><i class="fas fa-user-edit me-1"></i> Editar: {{ $user->name }}</div>
        <div class="card-body">
            @if($errors->any())
                <div class="alert alert-danger">
                    <ul class="mb-0">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul>
                </div>
            @endif

            <form action="{{ route('users.update', $user) }}" method="POST">
                @csrf @method('PUT')
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Nombre *</label>
                        <input type="text" name="name" class="form-control" value="{{ old('name', $user->name) }}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Email *</label>
                        <input type="email" name="email" class="form-control" value="{{ old('email', $user->email) }}" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Nueva contraseña <small class="text-muted">(vacío = no cambiar)</small></label>
                        <input type="password" name="password" class="form-control">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Confirmar contraseña</label>
                        <input type="password" name="password_confirmation" class="form-control">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Rol *</label>
                        <select name="role" class="form-select" required>
                            <option value="">— Seleccionar —</option>
                            @foreach($roles as $rol)
                                <option value="{{ $rol->name }}" {{ $user->hasRole($rol->name) ? 'selected' : '' }}>
                                    {{ $rol->name }}
                                </option>
                            @endforeach
                        </select>
                    </div>

                    @if($docentes->count())
                    <div class="col-md-6">
                        <label class="form-label">Docente vinculado</label>
                        <select name="docente_id" class="form-select">
                            <option value="">— Ninguno —</option>
                            @foreach($docentes as $d)
                                <option value="{{ $d->id }}" {{ $user->docente_id == $d->id ? 'selected' : '' }}>
                                    {{ $d->nombres }} {{ $d->apellidos }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    @endif

                    @if($postulantes->count())
                    <div class="col-md-6">
                        <label class="form-label">Postulante vinculado</label>
                        <select name="postulante_id" class="form-select">
                            <option value="">— Ninguno —</option>
                            @foreach($postulantes as $p)
                                <option value="{{ $p->id }}" {{ $user->postulante_id == $p->id ? 'selected' : '' }}>
                                    {{ $p->nombres }} {{ $p->apellidos }} — CI: {{ $p->ci }}
                                </option>
                            @endforeach
                        </select>
                    </div>
                    @endif
                </div>

                <div class="mt-4">
                    <button type="submit" class="btn btn-primary">Actualizar</button>
                    <a href="{{ route('users.index') }}" class="btn btn-secondary ms-2">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection
BLADE
success "Vistas de usuarios creadas/actualizadas"

# =============================================================================
#  14. VISTAS: roles (index, create, edit)
# =============================================================================
info "Actualizando vistas de roles..."
mkdir -p resources/views/roles

cat > resources/views/roles/index.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title', 'Roles')

@section('content')
@include('layouts.partials.alert')

<div class="container-fluid px-4">
    <h1 class="mt-4">Roles y Permisos</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="{{ route('panel') }}">Inicio</a></li>
        <li class="breadcrumb-item active">Roles</li>
    </ol>

    @can('crear roles')
    <div class="mb-3">
        <a href="{{ route('roles.create') }}" class="btn btn-primary btn-sm">
            <i class="fas fa-plus me-1"></i> Nuevo Rol
        </a>
    </div>
    @endcan

    <div class="card">
        <div class="card-header"><i class="fas fa-shield-alt me-1"></i> Roles del Sistema</div>
        <div class="card-body">
            <table id="datatablesSimple" class="table table-striped table-sm">
                <thead>
                    <tr><th>Rol</th><th>Nº Permisos</th><th>Permisos (muestra)</th><th>Acciones</th></tr>
                </thead>
                <tbody>
                    @php
                        $protegidos = ['Administrador del Sistema', 'Docente', 'Postulante'];
                    @endphp
                    @foreach($roles as $rol)
                    <tr>
                        <td>
                            <strong>{{ $rol->name }}</strong>
                            @if(in_array($rol->name, $protegidos))
                                <span class="badge bg-warning text-dark ms-1" title="Rol base del sistema">base</span>
                            @endif
                        </td>
                        <td><span class="badge bg-info text-dark">{{ $rol->permissions->count() }}</span></td>
                        <td>
                            @foreach($rol->permissions->take(4) as $p)
                                <span class="badge bg-light text-dark border">{{ $p->name }}</span>
                            @endforeach
                            @if($rol->permissions->count() > 4)
                                <span class="text-muted small">+{{ $rol->permissions->count() - 4 }} más</span>
                            @endif
                        </td>
                        <td>
                            <div class="btn-group btn-group-sm">
                                @can('editar roles')
                                <a href="{{ route('roles.edit', $rol) }}" class="btn btn-warning btn-sm">
                                    <i class="fas fa-edit"></i>
                                </a>
                                @endcan
                                @can('eliminar roles')
                                @if(!in_array($rol->name, $protegidos))
                                <form action="{{ route('roles.destroy', $rol) }}" method="POST" class="d-inline">
                                    @csrf @method('DELETE')
                                    <button class="btn btn-danger btn-sm"
                                            onclick="return confirm('¿Eliminar el rol {{ $rol->name }}?')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                                @endif
                                @endcan
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection
BLADE

cat > resources/views/roles/create.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title', 'Crear Rol')

@section('content')
<div class="container-fluid px-4">
    <h1 class="mt-4">Crear Rol</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="{{ route('panel') }}">Inicio</a></li>
        <li class="breadcrumb-item"><a href="{{ route('roles.index') }}">Roles</a></li>
        <li class="breadcrumb-item active">Crear</li>
    </ol>

    <div class="card">
        <div class="card-header"><i class="fas fa-shield-alt me-1"></i> Nuevo Rol</div>
        <div class="card-body">
            @if($errors->any())
                <div class="alert alert-danger"><ul class="mb-0">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>
            @endif

            <form action="{{ route('roles.store') }}" method="POST">
                @csrf
                <div class="mb-3">
                    <label class="form-label">Nombre del rol *</label>
                    <input type="text" name="name" class="form-control w-50" value="{{ old('name') }}" required>
                </div>

                <label class="form-label fw-bold">Permisos * <small class="text-muted fw-normal">(selecciona al menos uno)</small></label>
                @foreach($permisos as $modulo => $lista)
                <div class="card mb-2">
                    <div class="card-header py-1 bg-light fw-semibold small d-flex justify-content-between align-items-center">
                        <span>{{ $modulo }}</span>
                        <button type="button" class="btn btn-xs btn-outline-secondary btn-sm py-0 px-1"
                                onclick="toggleModulo('{{ Str::slug($modulo) }}')">Sel/Des todo</button>
                    </div>
                    <div class="card-body py-2">
                        <div class="row" id="mod-{{ Str::slug($modulo) }}">
                            @foreach($lista as $permiso)
                            <div class="col-md-3 col-sm-4 col-6">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox"
                                           name="permission[]" value="{{ $permiso->id }}"
                                           id="p{{ $permiso->id }}"
                                           {{ in_array($permiso->id, old('permission', [])) ? 'checked' : '' }}>
                                    <label class="form-check-label small" for="p{{ $permiso->id }}">
                                        {{ $permiso->name }}
                                    </label>
                                </div>
                            </div>
                            @endforeach
                        </div>
                    </div>
                </div>
                @endforeach

                <div class="mt-3">
                    <button type="submit" class="btn btn-primary">Guardar</button>
                    <a href="{{ route('roles.index') }}" class="btn btn-secondary ms-2">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function toggleModulo(id) {
    const mod = document.getElementById('mod-' + id);
    const checks = mod.querySelectorAll('input[type="checkbox"]');
    const allChecked = Array.from(checks).every(c => c.checked);
    checks.forEach(c => c.checked = !allChecked);
}
</script>
@endsection
BLADE

cat > resources/views/roles/edit.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title', 'Editar Rol')

@section('content')
<div class="container-fluid px-4">
    <h1 class="mt-4">Editar Rol: {{ $role->name }}</h1>
    <ol class="breadcrumb mb-4">
        <li class="breadcrumb-item"><a href="{{ route('panel') }}">Inicio</a></li>
        <li class="breadcrumb-item"><a href="{{ route('roles.index') }}">Roles</a></li>
        <li class="breadcrumb-item active">Editar</li>
    </ol>

    <div class="card">
        <div class="card-header"><i class="fas fa-edit me-1"></i> Editar: {{ $role->name }}</div>
        <div class="card-body">
            @if($errors->any())
                <div class="alert alert-danger"><ul class="mb-0">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>
            @endif

            <form action="{{ route('roles.update', $role) }}" method="POST">
                @csrf @method('PUT')
                <div class="mb-3">
                    <label class="form-label">Nombre del rol *</label>
                    <input type="text" name="name" class="form-control w-50"
                           value="{{ old('name', $role->name) }}" required>
                </div>

                <label class="form-label fw-bold">Permisos *</label>
                @foreach($permisos as $modulo => $lista)
                <div class="card mb-2">
                    <div class="card-header py-1 bg-light fw-semibold small d-flex justify-content-between align-items-center">
                        <span>{{ $modulo }}</span>
                        <button type="button" class="btn btn-outline-secondary btn-sm py-0 px-1"
                                onclick="toggleModulo('{{ Str::slug($modulo) }}')">Sel/Des todo</button>
                    </div>
                    <div class="card-body py-2">
                        <div class="row" id="mod-{{ Str::slug($modulo) }}">
                            @foreach($lista as $permiso)
                            <div class="col-md-3 col-sm-4 col-6">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox"
                                           name="permission[]" value="{{ $permiso->id }}"
                                           id="p{{ $permiso->id }}"
                                           {{ in_array($permiso->name, $permisosRol) ? 'checked' : '' }}>
                                    <label class="form-check-label small" for="p{{ $permiso->id }}">
                                        {{ $permiso->name }}
                                    </label>
                                </div>
                            </div>
                            @endforeach
                        </div>
                    </div>
                </div>
                @endforeach

                <div class="mt-3">
                    <button type="submit" class="btn btn-primary">Actualizar</button>
                    <a href="{{ route('roles.index') }}" class="btn btn-secondary ms-2">Cancelar</a>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function toggleModulo(id) {
    const mod = document.getElementById('mod-' + id);
    const checks = mod.querySelectorAll('input[type="checkbox"]');
    const allChecked = Array.from(checks).every(c => c.checked);
    checks.forEach(c => c.checked = !allChecked);
}
</script>
@endsection
BLADE
success "Vistas de roles creadas/actualizadas"

# =============================================================================
#  15. ELIMINAR archivos del dominio condominio que no aplican al CUP
# =============================================================================
info "Eliminando archivos de dominio exclusivo de condominio..."

OBSOLETOS=(
    # Modelos de condominio
    app/Models/Residente.php
    app/Models/Empleado.php
    app/Models/CargoEmpleado.php
    app/Models/AreaComun.php
    app/Models/Reserva.php
    app/Models/Cuota.php
    app/Models/TipoCuota.php
    app/Models/Pago.php
    app/Models/Multa.php
    app/Models/Visita.php
    app/Models/Comunicado.php
    app/Models/EmpresaExterna.php
    app/Models/Mantenimiento.php
    app/Models/Notificacion.php
    app/Models/Inventario.php
    app/Models/CategoriaInventario.php
    app/Models/VerificacionInventario.php
    app/Models/Unidad.php
    # Controladores de condominio
    app/Http/Controllers/ResidenteController.php
    app/Http/Controllers/EmpleadoController.php
    app/Http/Controllers/CargoEmpleadoController.php
    app/Http/Controllers/AreaComunController.php
    app/Http/Controllers/ReservaController.php
    app/Http/Controllers/CuotaController.php
    app/Http/Controllers/TipoCuotaController.php
    app/Http/Controllers/PagoController.php
    app/Http/Controllers/MultaController.php
    app/Http/Controllers/VisitaController.php
    app/Http/Controllers/ComunicadoController.php
    app/Http/Controllers/EmpresaExternaController.php
    app/Http/Controllers/MantenimientoController.php
    # Factories
    database/factories/ResidenteFactory.php
    database/factories/EmpleadoFactory.php
    database/factories/EmpresaExternaFactory.php
    database/factories/MantenimientoFactory.php
    database/factories/ComunicadoFactory.php
    database/factories/CuotaFactory.php
    database/factories/PagoFactory.php
    database/factories/RegistroSeguridadFactory.php
    database/factories/TipoCuotaFactory.php
    database/factories/UnidadFactory.php
    database/factories/VisitaFactory.php
    # Seeders de condominio
    database/seeders/ResidentesSeeder.php
    database/seeders/EmpleadosSeeder.php
    database/seeders/CargoEmpleadosSeeder.php
    database/seeders/AreaComunSeeder.php
    database/seeders/ReservaSeeder.php
    database/seeders/CuotaSeeder.php
    database/seeders/TipoCuotaSeeder.php
    database/seeders/PagoSeeder.php
    database/seeders/MultaSeeder.php
    database/seeders/VisitasSeeder.php
    database/seeders/ComunicadoSeeder.php
    database/seeders/EmpresaExternaSeeder.php
    database/seeders/MantenimientoSeeder.php
    database/seeders/ClasificadoresSeeder.php
)

for f in "${OBSOLETOS[@]}"; do
    [ -f "$f" ] && rm "$f" && warn "Eliminado: $f"
done

# Vistas de módulos de condominio
DIRS_OBSOLETOS=(
    resources/views/residentes
    resources/views/empleados
    resources/views/areas_comunes
    resources/views/reservas
    resources/views/cuotas
    resources/views/pagos
    resources/views/multas
    resources/views/visitas
    resources/views/comunicados
    resources/views/empresas
    resources/views/mantenimientos
    resources/views/Usuarios
)
for d in "${DIRS_OBSOLETOS[@]}"; do
    [ -d "$d" ] && rm -rf "$d" && warn "Directorio eliminado: $d"
done

success "Limpieza de archivos de condominio completada"

# =============================================================================
#  16. MIGRACIONES DEL DOMINIO CUP (orden correcto de FK)
#
#  Laravel ejecuta las migraciones en orden ALFABÉTICO por nombre de archivo.
#  La tabla `users` (0001_01_01_000013) tiene FK → docentes y postulantes.
#  Docentes y postulantes tienen FK → gestiones y carreras.
#  Por lo tanto el orden de ejecución debe ser:
#
#    000003 gestiones
#    000004 carreras
#    000005 cupos_carrera  (FK → gestiones, carreras)
#    000006 materias
#    000007 docentes       (FK: ninguna en dominio)
#    000008 postulantes    (FK → gestiones, carreras)
#    000009 create_jobs (ya existente)  ← no tocar
#    000013 users           (FK → docentes, postulantes)
#    ... resto de migraciones de bitacora, permisos, etc.
#
#  Renombramos las 8 migraciones del dominio CUP a prefijo 0001_01_01_000XXX
#  usando números menores a 0013 (users) y mayores a 0002 (jobs).
# =============================================================================
info "Corrigiendo orden de migraciones del dominio CUP..."

# Limpiar CUALQUIER versión previa de migraciones CUP (de ejecuciones anteriores del script)
# para evitar tablas duplicadas al correr migrate:fresh --seed
CUP_TABLES=(gestiones carreras materias docentes postulantes cupos_carrera grupos asignaciones notas admisiones)
for tabla in "${CUP_TABLES[@]}"; do
    for f in database/migrations/*_create_${tabla}_table.php database/migrations/*_create_${tabla}s_table.php; do
        [ -f "$f" ] && rm "$f" && warn "Eliminada migración previa: $(basename $f)"
    done
done
# También eliminar cualquier 2026_ genérico que pudiera quedar
for f in database/migrations/2026_01_01_000*; do
    [ -f "$f" ] && rm "$f" && warn "Eliminado 2026_ residual: $(basename $f)"
done

# Reescribir las migraciones en el orden correcto con prefijo 0001_01_01_000XXX

# --- gestiones (sin dependencias externas) ---
cat > database/migrations/0001_01_01_000003_create_gestiones_table.php << 'MIG'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CU-13: Gestionar gestiones / periodos académicos
return new class extends Migration {
    public function up(): void {
        Schema::create('gestiones', function (Blueprint $table) {
            $table->id();
            $table->string('descripcion', 50)->unique(); // "Semestre 1-2026"
            $table->date('fecha_inicio');
            $table->date('fecha_fin');
            $table->enum('estado', ['planificacion', 'inscripcion', 'en_curso', 'finalizado'])
                  ->default('planificacion');
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('gestiones'); }
};
MIG

# --- carreras (sin dependencias externas) ---
cat > database/migrations/0001_01_01_000004_create_carreras_table.php << 'MIG'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CU-10: Carreras → Informática, Sistemas, Redes y Telecomunicaciones, Robótica
return new class extends Migration {
    public function up(): void {
        Schema::create('carreras', function (Blueprint $table) {
            $table->id();
            $table->string('nombre', 100)->unique();
            $table->text('descripcion')->nullable();
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('carreras'); }
};
MIG

# --- materias (sin dependencias externas) ---
cat > database/migrations/0001_01_01_000006_create_materias_table.php << 'MIG'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CU-12: Materias del CUP → Computación, Matemáticas, Física, Inglés
return new class extends Migration {
    public function up(): void {
        Schema::create('materias', function (Blueprint $table) {
            $table->id();
            $table->string('nombre', 100)->unique();
            $table->string('area_formacion', 50)->nullable();
            $table->text('descripcion')->nullable();
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('materias'); }
};
MIG

# --- docentes (sin FK a otras tablas del dominio) ---
cat > database/migrations/0001_01_01_000007_create_docentes_table.php << 'MIG'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CU-14: Docentes con perfil profesional
return new class extends Migration {
    public function up(): void {
        Schema::create('docentes', function (Blueprint $table) {
            $table->id();
            $table->string('ci', 20)->unique();
            $table->string('nombres', 100);
            $table->string('apellidos', 100);
            $table->string('telefono', 20)->nullable();
            $table->string('email', 100)->nullable()->unique();
            $table->string('profesion', 100)->nullable();
            $table->string('maestria', 150)->nullable();
            $table->string('diplomado_educacion_superior', 150)->nullable();
            $table->string('area_formacion', 50)->nullable();
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('docentes'); }
};
MIG

# --- postulantes (FK → gestiones, carreras) ---
cat > database/migrations/0001_01_01_000008_create_postulantes_table.php << 'MIG'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CU-05: Registro de postulantes
return new class extends Migration {
    public function up(): void {
        Schema::create('postulantes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gestion_id')->constrained('gestiones');
            $table->foreignId('primera_opcion_id')->constrained('carreras');
            $table->foreignId('segunda_opcion_id')->constrained('carreras');
            $table->string('ci', 20)->unique();
            $table->string('nombres', 100);
            $table->string('apellidos', 100);
            $table->date('fecha_nacimiento')->nullable();
            $table->string('telefono', 20)->nullable();
            $table->string('email', 100)->nullable();
            $table->boolean('doc_ci')->default(false);
            $table->boolean('doc_libreta_colegio')->default(false);
            $table->boolean('doc_titulo_bachiller')->default(false);
            $table->enum('estado', [
                'inscrito', 'en_curso', 'aprobado', 'no_aprobado',
                'admitido', 'admitido_segunda_opcion', 'no_admitido',
            ])->default('inscrito');
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('postulantes'); }
};
MIG

success "Migraciones 0001_01_01_000003..000008 escritas en orden correcto"

# Eliminar archivos de migraciones del dominio condominio que quedan
# (tablas con FK cruzadas que rompían el migrate:fresh)
MIGS_CONDOMINIO=(
    "database/migrations/0001_01_01_000009_create_cargo_empleados_table.php.php"
    "database/migrations/0001_01_01_000010_create_empleados_table.php"
    "database/migrations/0001_01_01_000011_create_residentes_table.php"
    "database/migrations/2025_04_30_021953_create_clasificadores_table.php"
    "database/migrations/2025_04_30_033906_add_usuario_to_bitacoras_table.php"
    "database/migrations/2025_05_18_161430_create_tipos_cuotas_table.php"
    "database/migrations/2025_05_18_161436_create_cuotas_table.php"
    "database/migrations/2025_05_18_161444_create_multas_table.php"
    "database/migrations/2025_05_18_161444_create_pagos_table.php"
    "database/migrations/2025_05_18_185233_create_empresas_externas_table.php"
    "database/migrations/2025_05_22_104346_create_mantenimiento_table.php"
    "database/migrations/2025_05_26_161747_create_area_comuns_table.php"
    "database/migrations/2025_05_26_205720_create_reservas_table.php"
    "database/migrations/2025_06_08_115035_create_notificacion_table.php"
    "database/migrations/2025_06_09_163540_create_visitas_table.php"
    "database/migrations/2025_06_18_120504_create_categoria_inventarios_table.php"
    "database/migrations/2025_06_18_120509_create_inventarios_table.php"
    "database/migrations/2025_06_18_125553_create_verificacion_inventarios_table.php"
    "database/migrations/2025_06_24_075952_create_comunicados_table.php"
)
for f in "${MIGS_CONDOMINIO[@]}"; do
    [ -f "$f" ] && rm "$f" && warn "Migración condominio eliminada: $(basename $f)"
done

# Las migraciones CUP post-users (cupos, grupos, asignaciones, notas, admisiones)
# sí pueden vivir con prefijo fecha posterior (2026_...) porque no tienen
# FK desde users hacia ellas, sino al revés.
# Las reescribimos con fechas ordenadas:

cat > database/migrations/2026_01_01_000001_create_cupos_carrera_table.php << 'MIG'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CU-11: Cupos por carrera y gestión
return new class extends Migration {
    public function up(): void {
        Schema::create('cupos_carrera', function (Blueprint $table) {
            $table->id();
            $table->foreignId('carrera_id')->constrained()->cascadeOnDelete();
            $table->foreignId('gestion_id')->constrained('gestiones')->cascadeOnDelete();
            $table->unsignedInteger('cantidad_maxima');
            $table->unique(['carrera_id', 'gestion_id']);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('cupos_carrera'); }
};
MIG

cat > database/migrations/2026_01_01_000002_create_grupos_table.php << 'MIG'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CU-17: Grupos (máx. 60 alumnos) + tabla pivote grupo_postulante (CU-21)
return new class extends Migration {
    public function up(): void {
        Schema::create('grupos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gestion_id')->constrained('gestiones');
            $table->string('codigo', 20)->unique();
            $table->enum('turno', ['mañana', 'tarde', 'noche']);
            $table->enum('modalidad', ['presencial', 'virtual'])->default('presencial');
            $table->unsignedInteger('capacidad_maxima')->default(60);
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });

        Schema::create('grupo_postulante', function (Blueprint $table) {
            $table->id();
            $table->foreignId('grupo_id')->constrained()->cascadeOnDelete();
            $table->foreignId('postulante_id')->constrained()->cascadeOnDelete();
            $table->unique(['grupo_id', 'postulante_id']);
            $table->timestamps();
        });
    }
    public function down(): void {
        Schema::dropIfExists('grupo_postulante');
        Schema::dropIfExists('grupos');
    }
};
MIG

cat > database/migrations/2026_01_01_000003_create_asignaciones_table.php << 'MIG'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CU-18: Asignación docente-grupo-materia + horario (CU-19, CU-20)
return new class extends Migration {
    public function up(): void {
        Schema::create('asignaciones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('grupo_id')->constrained()->cascadeOnDelete();
            $table->foreignId('docente_id')->constrained()->cascadeOnDelete();
            $table->foreignId('materia_id')->constrained()->cascadeOnDelete();
            $table->enum('dia', ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado']);
            $table->time('hora_inicio');
            $table->time('hora_fin');
            $table->unique(['grupo_id', 'materia_id']);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('asignaciones'); }
};
MIG

cat > database/migrations/2026_01_01_000004_create_notas_table.php << 'MIG'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CU-22 a CU-26: Notas (3 exámenes 30%+30%+40%, nota_final calculada)
return new class extends Migration {
    public function up(): void {
        Schema::create('notas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('postulante_id')->constrained()->cascadeOnDelete();
            $table->foreignId('materia_id')->constrained()->cascadeOnDelete();
            $table->foreignId('grupo_id')->constrained()->cascadeOnDelete();
            $table->decimal('examen1', 5, 2)->nullable();
            $table->decimal('examen2', 5, 2)->nullable();
            $table->decimal('examen3', 5, 2)->nullable();
            $table->decimal('nota_final', 5, 2)->nullable();
            $table->boolean('aprobado')->nullable();
            $table->unique(['postulante_id', 'materia_id', 'grupo_id']);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('notas'); }
};
MIG

cat > database/migrations/2026_01_01_000005_create_admisiones_table.php << 'MIG'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

// CU-27 a CU-29: Resultado final de admisión
return new class extends Migration {
    public function up(): void {
        Schema::create('admisiones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('postulante_id')->unique()->constrained()->cascadeOnDelete();
            $table->foreignId('gestion_id')->constrained('gestiones');
            $table->decimal('promedio_general', 5, 2)->nullable();
            $table->foreignId('carrera_asignada_id')->nullable()->constrained('carreras');
            $table->enum('resultado', [
                'pendiente', 'admitido_primera', 'admitido_segunda', 'no_admitido',
            ])->default('pendiente');
            $table->boolean('publicado')->default(false);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('admisiones'); }
};
MIG

success "Migraciones post-users (cupos → admisiones) escritas con prefijo 2026_01_01_000001..000005"

# =============================================================================
#  17. Limpiar caché de Laravel
# =============================================================================
info "Limpiando caché de Laravel..."
php artisan config:clear 2>/dev/null || true
php artisan route:clear  2>/dev/null || true
php artisan view:clear   2>/dev/null || true
php artisan cache:clear  2>/dev/null || true
success "Caché limpiada"

# =============================================================================
#  RESUMEN FINAL
# =============================================================================
echo ""
echo -e "${GREEN}══════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ADAPTACIÓN COMPLETADA — Sistema de Admisión CUP  (v2)${NC}"
echo -e "${GREEN}  Alineado con nuevo.odt (Proceso Unificado y UML)${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${CYAN}CAMBIO PRINCIPAL respecto a v1:${NC}"
echo "   5 roles  →  3 roles (según nuevo.odt § 4 — Actores del sistema)"
echo ""
echo -e "  ${CYAN}ROLES DEL SISTEMA:${NC}"
echo "   ┌──────────────────────────────┬────────────────────────────────────────┐"
echo "   │ Administrador del Sistema    │ Gestión total: usuarios, académico,    │"
echo "   │                              │ grupos, admisión, reportes             │"
echo "   ├──────────────────────────────┼────────────────────────────────────────┤"
echo "   │ Docente                      │ Registra notas de sus grupos (CU-22)  │"
echo "   ├──────────────────────────────┼────────────────────────────────────────┤"
echo "   │ Postulante                   │ Consulta notas y resultado (CU-26/29) │"
echo "   └──────────────────────────────┴────────────────────────────────────────┘"
echo ""
echo -e "  ${CYAN}ARCHIVOS MODIFICADOS:${NC}"
echo "   ✓ .env / config/adminlte.php"
echo "   ✓ app/Models/User.php"
echo "   ✓ app/Http/Controllers/UsuarioController.php"
echo "   ✓ app/Http/Controllers/RoleController.php"
echo "   ✓ database/seeders/PermissionSeeder.php   (permisos por módulo/CU)"
echo "   ✓ database/seeders/RolesSeeder.php         (3 roles)"
echo "   ✓ database/seeders/UsuariosSeeder.php      (3 usuarios de prueba)"
echo "   ✓ database/seeders/DatabaseSeeder.php"
echo "   ✓ routes/web.php                           (rutas comentadas por módulo)"
echo "   ✓ resources/views/users/{index,create,edit}.blade.php"
echo "   ✓ resources/views/roles/{index,create,edit}.blade.php"
echo ""
echo -e "  ${CYAN}MIGRACIONES CREADAS (dominio CUP) — orden de ejecución:${NC}"
echo "   0001_01_01_000003  gestiones        (sin FK externas)"
echo "   0001_01_01_000004  carreras         (sin FK externas)"
echo "   0001_01_01_000006  materias         (sin FK externas)"
echo "   0001_01_01_000007  docentes         (sin FK externas)"
echo "   0001_01_01_000008  postulantes      (FK → gestiones, carreras)"
echo "   0001_01_01_000013  users            (FK → docentes, postulantes)"
echo "   2026_01_01_000001  cupos_carrera    (FK → gestiones, carreras)"
echo "   2026_01_01_000002  grupos           (FK → gestiones, postulantes)"
echo "   2026_01_01_000003  asignaciones     (FK → grupos, docentes, materias)"
echo "   2026_01_01_000004  notas            (FK → postulantes, materias, grupos)"
echo "   2026_01_01_000005  admisiones       (FK → postulantes, gestiones, carreras)"
echo ""
echo -e "  ${YELLOW}PRÓXIMOS PASOS:${NC}"
echo "   1. Revisar .env: DB_DATABASE, DB_USERNAME, DB_PASSWORD"
echo "   2. php artisan migrate:fresh --seed"
echo "   3. Implementar CRUDs en este orden (descomenta rutas en web.php):"
echo "      Gestiones → Carreras → Cupos → Materias → Docentes → Postulantes"
echo "      → Grupos (con generación automática) → Horarios → Notas → Admisión → Reportes"
echo ""
echo -e "  ${CYAN}Credenciales de prueba (password: 12345678):${NC}"
echo "   admin@cup.edu.bo        →  Administrador del Sistema"
echo "   docente@cup.edu.bo      →  Docente"
echo "   postulante@cup.edu.bo   →  Postulante"
echo ""
