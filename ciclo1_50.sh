#!/usr/bin/env bash
# =============================================================================
#  ciclo1_50.sh — Sistema de Admisión CUP
#  Implementa el 50% del Ciclo 1 completo desde la raíz del proyecto
#
#  Qué entrega este script:
#   ✓ bootstrap/app.php     — BitacoraMiddleware registrado (Laravel 11)
#   ✓ public/css/cup.css    — Diseño Institucional Andino completo
#   ✓ Layout ap.blade.php   — Sidebar + topbar propio, sin SB Admin
#   ✓ Login                 — Diseño nuevo, funcional
#   ✓ Panel de Control      — Dashboard con stats + mapa de módulos y CUs
#   ✓ BitacoraMiddleware    — Registra TODAS las rutas con DB::table()
#   ✓ CRUD Gestiones        — CU-13
#   ✓ CRUD Carreras + Cupos — CU-10, CU-11
#   ✓ CRUD Materias         — CU-12 (ponderación configurable)
#   ✓ CRUD Docentes         — CU-14 (perfil profesional completo)
#   ✓ CRUD Postulantes      — CU-05 a CU-09 (todos los campos del PDF)
#   ✓ Migraciones           — tablas completas con todos los campos
#   ✓ Modelos               — Eloquent con relaciones y accessors
#   ✓ Seeders               — 4 carreras, 4 materias, 1 gestión, 3 usuarios
#   ✓ Rutas web.php         — todos los recursos registrados
#   ✓ Permisos/Roles        — actualizados con permisos de los 5 CRUDs
#
#  USO: bash ciclo1_50.sh   (desde la raíz del proyecto Laravel)
# =============================================================================
set -e
C='\033[0;36m'; G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; N='\033[0m'
nfo() { echo -e "${C}[INFO]${N}  $1"; }
ok()  { echo -e "${G}[OK]${N}    $1"; }
wrn() { echo -e "${Y}[WARN]${N}  $1"; }
die() { echo -e "${R}[ERROR]${N} $1"; exit 1; }

[ -f "artisan" ] || die "Ejecuta desde la raíz del proyecto Laravel."

mkdir -p public/css \
  app/Models app/Http/Controllers app/Http/Middleware app/Traits \
  resources/views/{layouts,layouts/partials,auth,panel,bitacora} \
  resources/views/{gestiones,carreras,materias,docentes,postulantes,users,roles,pages} \
  database/migrations database/seeders

# ─────────────────────────────────────────────────────────────────────────────
#  1. CSS — Diseño Institucional Andino
# ─────────────────────────────────────────────────────────────────────────────
nfo "CSS..."
cat > public/css/cup.css << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Crimson+Pro:wght@400;600;700&family=DM+Sans:wght@300;400;500;600;700&display=swap');
:root{
  --v:#1a3a2a;--v2:#254d38;--v3:#2e6347;--vl:#d4e8dc;
  --o:#b8973e;--ol:#f0e2b6;--cr:#f5f0e8;--cr2:#ede7d9;
  --t:#1c1c1c;--t2:#4a4a4a;--t3:#7a7a7a;--b:#d6cfc2;
  --w:#ffffff;--d:#a3290c;--dl:#fde8e3;--wn:#7a5c00;--wl:#fff8e1;
  --sw:260px;--th:60px;--r:8px;
  --ss:0 1px 3px rgba(0,0,0,.08);--s:0 4px 16px rgba(26,58,42,.12);--sl:0 8px 32px rgba(26,58,42,.18);
  --fd:'Crimson Pro',Georgia,serif;--fb:'DM Sans','Helvetica Neue',sans-serif;
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
html{font-size:15px;-webkit-font-smoothing:antialiased}
body{font-family:var(--fb);background:var(--cr);color:var(--t);line-height:1.6;min-height:100vh}
a{color:var(--v3);text-decoration:none}a:hover{color:var(--o)}

/* topbar */
.cup-top{position:fixed;top:0;left:0;right:0;height:var(--th);background:var(--v);
  display:flex;align-items:center;padding:0 1.25rem;gap:1rem;z-index:1000;border-bottom:3px solid var(--o)}
.cup-top .brand{font-family:var(--fd);font-size:1.2rem;font-weight:700;color:var(--w);
  display:flex;align-items:center;gap:.6rem;text-decoration:none}
.bico{width:34px;height:34px;border-radius:6px;background:var(--o);display:flex;align-items:center;
  justify-content:center;font-size:1rem;color:var(--v);font-weight:700}
.tgl{background:none;border:none;color:rgba(255,255,255,.7);font-size:1.1rem;cursor:pointer;
  padding:6px 8px;border-radius:6px;transition:.2s}
.tgl:hover{background:rgba(255,255,255,.1);color:#fff}
.top-r{margin-left:auto;display:flex;align-items:center;gap:.75rem}
.top-usr{display:flex;align-items:center;gap:.5rem;color:rgba(255,255,255,.85);font-size:.87rem;
  font-weight:500;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.14);
  border-radius:30px;padding:.3rem .85rem;cursor:pointer;position:relative}
.top-usr .av{width:28px;height:28px;background:var(--o);border-radius:50%;display:flex;
  align-items:center;justify-content:center;font-size:.78rem;font-weight:700;color:var(--v)}
.umenu{position:absolute;right:0;top:calc(100% + 8px);background:var(--w);border:1px solid var(--b);
  border-radius:var(--r);box-shadow:var(--sl);min-width:180px;padding:.4rem 0;display:none;z-index:9999}
.top-usr.open .umenu{display:block}
.umenu a{display:flex;align-items:center;gap:.6rem;padding:.5rem 1rem;font-size:.87rem;
  color:var(--t2);transition:.15s}
.umenu a:hover{background:var(--cr);color:var(--v)}
.umenu .sep{border-top:1px solid var(--b);margin:.3rem 0}
.umenu a.dng{color:var(--d)}
.umenu a.dng:hover{background:var(--dl)}

/* sidebar */
.cup-sb{position:fixed;top:var(--th);left:0;bottom:0;width:var(--sw);
  background:var(--w);border-right:1px solid var(--b);overflow-y:auto;
  overflow-x:hidden;z-index:900;transition:transform .28s ease}
.cup-sb.collapsed{transform:translateX(calc(-1 * var(--sw)))}
.cup-sb::-webkit-scrollbar{width:4px}
.cup-sb::-webkit-scrollbar-thumb{background:var(--b);border-radius:4px}
.sb-usr{padding:1.1rem 1.2rem;border-bottom:1px solid var(--cr2);background:var(--cr);
  display:flex;align-items:center;gap:.75rem}
.sb-usr .av{width:38px;height:38px;border-radius:50%;background:var(--v);display:flex;
  align-items:center;justify-content:center;font-size:.95rem;font-weight:700;color:var(--o);flex-shrink:0}
.sbn{font-size:.9rem;font-weight:600;color:var(--t);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.sbr{font-size:.73rem;color:var(--t3)}
.sb-sec{padding:.6rem 1rem .2rem}
.sb-ttl{font-size:.65rem;font-weight:700;letter-spacing:.08em;text-transform:uppercase;
  color:var(--t3);padding:.5rem .2rem .2rem}
.ni{display:flex;align-items:center;gap:.65rem;padding:.52rem .8rem;border-radius:6px;
  margin-bottom:2px;color:var(--t2);font-size:.88rem;transition:.15s;position:relative;cursor:pointer}
.ni:hover{background:var(--cr);color:var(--v)}
.ni.act{background:var(--vl);color:var(--v);font-weight:600}
.ni.act::before{content:'';position:absolute;left:-1px;top:20%;bottom:20%;width:3px;
  border-radius:0 3px 3px 0;background:var(--o)}
.ni .ico{width:20px;text-align:center;font-size:.88rem;flex-shrink:0;color:var(--t3)}
.ni.act .ico,.ni:hover .ico{color:var(--v3)}
.ni.pnd{color:var(--t3);pointer-events:none}
.nbg{margin-left:auto;font-size:.6rem;font-weight:700;background:var(--cr2);
  color:var(--t3);border-radius:10px;padding:1px 6px}
.ni.act .nbg{background:var(--vl);color:var(--v3)}
.sbdiv{border-top:1px solid var(--cr2);margin:.5rem 1rem}
.ni.lgt{color:var(--d)}
.ni.lgt:hover{background:var(--dl);color:var(--d)}
.ni.lgt .ico{color:var(--d)}

/* main */
.cup-mn{margin-top:var(--th);margin-left:var(--sw);min-height:calc(100vh - var(--th));
  transition:margin-left .28s ease;display:flex;flex-direction:column}
.cup-mn.exp{margin-left:0}
.cup-cnt{flex:1;padding:2rem 2rem 1rem}
.cup-ft{padding:.75rem 2rem;border-top:1px solid var(--b);background:var(--w);
  display:flex;align-items:center;justify-content:space-between;font-size:.78rem;color:var(--t3)}

/* page header */
.ph{margin-bottom:1.75rem;border-bottom:1px solid var(--b);padding-bottom:1rem}
.ph h1{font-family:var(--fd);font-size:1.9rem;font-weight:700;color:var(--v);line-height:1.2}
.ph .sub{font-size:.88rem;color:var(--t3);margin-top:.2rem}
.bc{display:flex;align-items:center;gap:.4rem;list-style:none;font-size:.8rem;color:var(--t3);margin-top:.5rem}
.bc li+li::before{content:'/';margin-right:.4rem}
.bc a{color:var(--v3)}

/* cards */
.card{background:var(--w);border:1px solid var(--b);border-radius:var(--r);box-shadow:var(--ss)}
.card-hd{padding:.9rem 1.25rem;border-bottom:1px solid var(--cr2);font-size:.93rem;
  font-weight:600;color:var(--v);background:var(--cr);
  border-radius:var(--r) var(--r) 0 0;display:flex;align-items:center;gap:.5rem}
.card-hd i{color:var(--o)}
.card-bd{padding:1.25rem}

/* stat grid */
.sg{display:grid;grid-template-columns:repeat(auto-fill,minmax(190px,1fr));gap:1rem;margin-bottom:1.75rem}
.sc{background:var(--w);border:1px solid var(--b);border-radius:var(--r);
  padding:1.1rem 1.25rem;display:flex;align-items:center;gap:1rem;box-shadow:var(--ss);
  text-decoration:none;transition:.18s}
.sc:hover{box-shadow:var(--s);transform:translateY(-1px)}
.si{width:44px;height:44px;border-radius:10px;display:flex;align-items:center;
  justify-content:center;font-size:1.2rem;flex-shrink:0}
.c1{background:var(--vl);color:var(--v3)}.c2{background:var(--ol);color:#7a5800}
.c3{background:var(--dl);color:var(--d)}.c4{background:var(--cr2);color:var(--t3)}
.c5{background:#dbeafe;color:#1d4f8f}.c6{background:#d8f0e6;color:#1a5c38}
.sv{font-size:.95rem;font-weight:700;color:var(--v);line-height:1}
.sl{font-size:.77rem;color:var(--t3);margin-top:.15rem}

/* modulo grid panel */
.mg{display:grid;grid-template-columns:repeat(auto-fill,minmax(310px,1fr));gap:1.25rem;margin-bottom:2rem}
.mc{background:var(--w);border:1px solid var(--b);border-radius:var(--r);overflow:hidden;box-shadow:var(--ss)}
.mh{display:flex;align-items:center;gap:.75rem;padding:.9rem 1.15rem;
  font-family:var(--fd);font-size:1.05rem;font-weight:700;border-bottom:1px solid var(--cr2)}
.mn2{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:.82rem;font-weight:800;flex-shrink:0}
.m1{border-top:3px solid #3b82f6}.m1 .mn2{background:#d4e2f7;color:#1d4f8f}
.m2{border-top:3px solid #22c55e}.m2 .mn2{background:#d8f0e6;color:#1a5c38}
.m3{border-top:3px solid #f97316}.m3 .mn2{background:#fde8cc;color:#8a4300}
.m4{border-top:3px solid #a855f7}.m4 .mn2{background:#ede0f7;color:#5b2a8a}
.m5{border-top:3px solid #ef4444}.m5 .mn2{background:#fce4e4;color:#8a1f1f}
.mb2{padding:.5rem .8rem}
.cr2x{display:flex;align-items:center;gap:.6rem;padding:.42rem .6rem;border-radius:5px;
  margin-bottom:1px;font-size:.86rem;color:var(--t2);transition:.15s}
.cr2x.lnk:hover{background:var(--cr);color:var(--v)}
.cr2x.lnk a{color:inherit;display:flex;align-items:center;gap:.6rem;width:100%;text-decoration:none}
.cr2x.lnk a:hover{color:var(--v)}
.cr2x.dis{color:var(--t3)}
.ctg{font-size:.63rem;font-weight:700;padding:1px 5px;border-radius:4px;flex-shrink:0;min-width:40px;text-align:center}
.ctg.dn{background:#d4edda;color:#1a5c38;border:1px solid #a3d9b5}
.ctg.pn{background:var(--cr2);color:var(--t3);border:1px solid var(--b)}
.ci2{width:16px;text-align:center;font-size:.82rem;color:var(--t3);flex-shrink:0}
.cr2x.lnk:hover .ci2{color:var(--v3)}
.cpl{margin-left:auto;font-size:.65rem;color:var(--t3);flex-shrink:0}

/* tabla */
.tw{overflow-x:auto}
table.ct{width:100%;border-collapse:collapse;font-size:.88rem}
.ct th{background:var(--cr);color:var(--v);font-weight:700;font-size:.78rem;
  text-transform:uppercase;letter-spacing:.05em;padding:.65rem 1rem;
  border-bottom:2px solid var(--b);white-space:nowrap}
.ct td{padding:.7rem 1rem;border-bottom:1px solid var(--cr2);color:var(--t2);vertical-align:middle}
.ct tbody tr:hover{background:#fafaf7}
.ct tbody tr:last-child td{border-bottom:none}

/* badges */
.bg{display:inline-flex;align-items:center;padding:2px 9px;border-radius:20px;font-size:.72rem;font-weight:700}
.bv{background:var(--vl);color:var(--v)}.bo{background:var(--ol);color:#5c4200}
.bd{background:var(--dl);color:var(--d)}.bg2{background:var(--cr2);color:var(--t3)}
.baz{background:#dbeafe;color:#1d4f8f}.bvi{background:#ede0f7;color:#5b2a8a}
.bna{background:#fde8cc;color:#8a4300}
.ra{background:#1a3a2a22;color:#1a3a2a;border:1px solid #1a3a2a44}
.rd{background:#1d4f8f22;color:#1d4f8f;border:1px solid #1d4f8f44}
.rp{background:#b8973e22;color:#7a5800;border:1px solid #b8973e44}

/* botones */
.btn{display:inline-flex;align-items:center;gap:.4rem;padding:.5rem 1.1rem;border-radius:6px;
  font-size:.87rem;font-weight:600;cursor:pointer;border:1px solid transparent;
  transition:.18s;white-space:nowrap;font-family:var(--fb);text-decoration:none}
.bp{background:var(--v);color:var(--w);border-color:var(--v)}
.bp:hover{background:var(--v2);color:var(--w);box-shadow:var(--ss)}
.bw{background:#c8860a;color:var(--w);border-color:#c8860a}
.bw:hover{background:var(--wn);color:var(--w)}
.bo2{background:transparent;color:var(--v);border-color:var(--v)}
.bo2:hover{background:var(--vl)}
.bdr{background:var(--d);color:var(--w);border-color:var(--d)}
.bdr:hover{background:#7c1e09;color:var(--w)}
.bsm{padding:.32rem .75rem;font-size:.8rem}
.bxs{padding:.2rem .55rem;font-size:.74rem}
.bg3{display:flex;gap:.35rem;flex-wrap:wrap}

/* forms */
.fl{display:block;font-size:.83rem;font-weight:600;color:var(--t);margin-bottom:.35rem}
.fl .rq{color:var(--d);margin-left:2px}
.fc,.fs{width:100%;padding:.52rem .85rem;background:var(--w);border:1px solid var(--b);
  border-radius:6px;font-family:var(--fb);font-size:.88rem;color:var(--t);
  transition:border-color .15s,box-shadow .15s;appearance:none;-webkit-appearance:none}
.fc:focus,.fs:focus{outline:none;border-color:var(--v3);box-shadow:0 0 0 3px rgba(46,99,71,.15)}
.fc::placeholder{color:var(--t3)}
.fs{background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14L2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z' fill='%234a4a4a'/%3E%3C/svg%3E");
  background-repeat:no-repeat;background-position:right .65rem center;background-size:12px;padding-right:2.2rem}
textarea.fc{resize:vertical;min-height:80px}
.fr{display:grid;gap:1rem}
.c2g{grid-template-columns:1fr 1fr}.c3g{grid-template-columns:1fr 1fr 1fr}
.fh{font-size:.76rem;color:var(--t3);margin-top:.25rem}
.fck{display:flex;align-items:center;gap:.5rem}
.fck input[type="checkbox"]{width:16px;height:16px;accent-color:var(--v);cursor:pointer}
.fs-t{font-family:var(--fd);font-size:1.1rem;font-weight:700;color:var(--v);
  border-bottom:2px solid var(--ol);padding-bottom:.4rem;margin-bottom:1rem}

/* permisos */
.pg{border:1px solid var(--b);border-radius:6px;overflow:hidden;margin-bottom:.75rem}
.pgh{background:var(--cr);padding:.55rem .9rem;font-size:.78rem;font-weight:700;
  color:var(--v);display:flex;align-items:center;justify-content:space-between}
.pgb{padding:.6rem .9rem;display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:.3rem}

/* alertas */
.al{display:flex;align-items:flex-start;gap:.6rem;padding:.75rem 1rem;
  border-radius:6px;font-size:.87rem;margin-bottom:1rem}
.al-s{background:#e8f5ee;color:#1a5c38;border:1px solid #a3d9b5}
.al-d{background:var(--dl);color:var(--d);border:1px solid #f5b8a8}
.al-w{background:var(--wl);color:var(--wn);border:1px solid #ffe082}
.al ul{margin:.3rem 0 0 1rem;padding:0}

/* bitacora */
.cmod{display:inline-block;font-size:.63rem;font-weight:700;padding:2px 7px;border-radius:3px;
  text-transform:uppercase;letter-spacing:.05em;white-space:nowrap}
.Seg{background:#dbeafe;color:#1d4f8f}.Usr{background:#d4e8dc;color:#1a5c38}
.Rol{background:#d8f0e6;color:#1a5c38}.Bit{background:#ede0f7;color:#5b2a8a}
.Pos{background:#fde8cc;color:#8a4300}.Doc{background:#fff8e1;color:#7a5c00}
.Ges{background:#fef9c3;color:#78350f}.Car{background:#e8f5e9;color:#2e7d32}
.Mat{background:#e0f7fa;color:#006064}.Grp{background:#fce4e4;color:#8a1f1f}
.Adm{background:#f3e5f5;color:#6a1b9a}.Rep{background:#e8f5e9;color:#1b5e20}
.chttp{font-size:.65rem;font-weight:800;padding:1px 5px;border-radius:3px;font-family:'Courier New',monospace}
.hGET{background:#e8f4fd;color:#0369a1}.hPOST{background:#d4edda;color:#155724}
.hPUT{background:#fff3cd;color:#856404}.hDELETE{background:#fde8e3;color:#a3290c}

/* paginacion */
.pag{display:flex;gap:.3rem;list-style:none;flex-wrap:wrap}
.pag .pl{padding:.38rem .7rem;border-radius:5px;border:1px solid var(--b);
  color:var(--v3);font-size:.84rem;transition:.15s;display:inline-block}
.pag .act .pl{background:var(--v);color:#fff;border-color:var(--v)}
.pag .pl:hover{background:var(--cr)}

/* responsive */
@media(max-width:768px){
  .cup-sb{transform:translateX(calc(-1 * var(--sw)))}
  .cup-sb.open{transform:translateX(0)}
  .cup-mn{margin-left:0}
  .c2g,.c3g{grid-template-columns:1fr}
  .cup-cnt{padding:1.25rem 1rem}
  .mg{grid-template-columns:1fr}
}
EOF
ok "public/css/cup.css"

# ─────────────────────────────────────────────────────────────────────────────
#  2. bootstrap/app.php — registra BitacoraMiddleware en Laravel 11
# ─────────────────────────────────────────────────────────────────────────────
nfo "bootstrap/app.php..."
cat > bootstrap/app.php << 'EOF'
<?php
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->trustProxies(at: '*');
        $middleware->alias([
            'role'               => \Spatie\Permission\Middleware\RoleMiddleware::class,
            'permission'         => \Spatie\Permission\Middleware\PermissionMiddleware::class,
            'role_or_permission' => \Spatie\Permission\Middleware\RoleOrPermissionMiddleware::class,
        ]);
        // Bitácora automática — corre DESPUÉS de StartSession y Auth
        $middleware->appendToGroup('web', \App\Http\Middleware\BitacoraMiddleware::class);
    })
    ->withExceptions(function (Exceptions $exceptions) {})
    ->create();
EOF
ok "bootstrap/app.php"

# ─────────────────────────────────────────────────────────────────────────────
#  3. BitacoraMiddleware — DB::table() directo, nunca rompe la petición
# ─────────────────────────────────────────────────────────────────────────────
nfo "BitacoraMiddleware..."
cat > app/Http/Middleware/BitacoraMiddleware.php << 'EOF'
<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class BitacoraMiddleware
{
    protected array $ignorar = ['bitacora.page-close','livewire.message','debugbar.openhandler'];

    protected array $mapa = [
        'panel'                         => ['Accedió al panel de control','Seguridad'],
        'login'                         => ['Visitó la página de inicio de sesión','Seguridad'],
        'logout'                        => ['Cerró sesión','Seguridad'],
        'password.request'              => ['Visitó recuperación de contraseña','Seguridad'],
        'password.email'                => ['Solicitó enlace de recuperación','Seguridad'],
        'password.reset'                => ['Visitó formulario nueva contraseña','Seguridad'],
        'password.update'               => ['Restableció su contraseña','Seguridad'],
        'users.index'                   => ['Listó usuarios del sistema','Usuarios'],
        'users.create'                  => ['Abrió formulario crear usuario','Usuarios'],
        'users.store'                   => ['Creó un nuevo usuario','Usuarios'],
        'users.show'                    => ['Vio detalle de usuario','Usuarios'],
        'users.edit'                    => ['Abrió formulario editar usuario','Usuarios'],
        'users.update'                  => ['Actualizó datos de usuario','Usuarios'],
        'users.destroy'                 => ['Cambió estado de usuario','Usuarios'],
        'users.perfil'                  => ['Consultó su perfil','Usuarios'],
        'roles.index'                   => ['Listó roles y permisos','Roles'],
        'roles.create'                  => ['Abrió formulario crear rol','Roles'],
        'roles.store'                   => ['Creó un nuevo rol','Roles'],
        'roles.edit'                    => ['Abrió formulario editar rol','Roles'],
        'roles.update'                  => ['Actualizó un rol','Roles'],
        'roles.destroy'                 => ['Eliminó un rol','Roles'],
        'bitacora.index'                => ['Consultó la bitácora del sistema','Bitácora'],
        'gestiones.index'               => ['Listó gestiones académicas','Gestiones'],
        'gestiones.create'              => ['Abrió formulario nueva gestión','Gestiones'],
        'gestiones.store'               => ['Creó una gestión académica (CU-13)','Gestiones'],
        'gestiones.show'                => ['Consultó detalle de gestión','Gestiones'],
        'gestiones.edit'                => ['Abrió formulario editar gestión','Gestiones'],
        'gestiones.update'              => ['Actualizó una gestión académica','Gestiones'],
        'gestiones.destroy'             => ['Eliminó una gestión académica','Gestiones'],
        'carreras.index'                => ['Listó carreras de la facultad','Carreras'],
        'carreras.create'               => ['Abrió formulario nueva carrera','Carreras'],
        'carreras.store'                => ['Creó una carrera (CU-10)','Carreras'],
        'carreras.show'                 => ['Consultó detalle de carrera','Carreras'],
        'carreras.edit'                 => ['Abrió formulario editar carrera','Carreras'],
        'carreras.update'               => ['Actualizó una carrera','Carreras'],
        'carreras.destroy'              => ['Eliminó una carrera','Carreras'],
        'carreras.cupos'                => ['Definió cupos por carrera y gestión (CU-11)','Carreras'],
        'materias.index'                => ['Listó materias del CUP','Materias'],
        'materias.create'               => ['Abrió formulario nueva materia','Materias'],
        'materias.store'                => ['Creó una materia (CU-12)','Materias'],
        'materias.show'                 => ['Consultó detalle de materia','Materias'],
        'materias.edit'                 => ['Abrió formulario editar materia','Materias'],
        'materias.update'               => ['Actualizó una materia','Materias'],
        'materias.destroy'              => ['Eliminó una materia','Materias'],
        'postulantes.index'             => ['Listó postulantes inscritos','Postulantes'],
        'postulantes.create'            => ['Abrió formulario registrar postulante','Postulantes'],
        'postulantes.store'             => ['Registró un postulante (CU-05)','Postulantes'],
        'postulantes.show'              => ['Consultó estado del postulante (CU-09)','Postulantes'],
        'postulantes.edit'              => ['Abrió formulario editar postulante','Postulantes'],
        'postulantes.update'            => ['Actualizó datos de postulante','Postulantes'],
        'postulantes.destroy'           => ['Eliminó un postulante','Postulantes'],
        'docentes.index'                => ['Listó docentes del CUP','Docentes'],
        'docentes.create'               => ['Abrió formulario registrar docente','Docentes'],
        'docentes.store'                => ['Registró un docente (CU-14)','Docentes'],
        'docentes.show'                 => ['Consultó perfil de docente','Docentes'],
        'docentes.edit'                 => ['Abrió formulario editar docente','Docentes'],
        'docentes.update'               => ['Actualizó datos de docente','Docentes'],
        'docentes.destroy'              => ['Desactivó un docente','Docentes'],
        'grupos.index'                  => ['Listó grupos del CUP','Grupos'],
        'grupos.create'                 => ['Abrió formulario nuevo grupo','Grupos'],
        'grupos.store'                  => ['Creó un grupo','Grupos'],
        'grupos.generar'                => ['Generó grupos automáticamente (CU-17)','Grupos'],
        'notas.index'                   => ['Listó notas del sistema','Evaluación'],
        'notas.store'                   => ['Registró notas de exámenes (CU-22)','Evaluación'],
        'notas.propias'                 => ['Postulante consultó sus notas (CU-26)','Evaluación'],
        'admision.index'                => ['Accedió al módulo de admisión','Admisión'],
        'admision.procesar'             => ['Procesó admisión primera opción (CU-27)','Admisión'],
        'admision.publicar'             => ['Publicó resultado de admisión (CU-29)','Admisión'],
        'reportes.index'                => ['Accedió al módulo de reportes','Reportes'],
    ];

    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);
        if (!Auth::check()) return $response;
        try {
            $rn = $request->route()?->getName() ?? '';
            if (empty($rn) || in_array($rn, $this->ignorar)) return $response;
            [$accion, $modulo] = $this->mapa[$rn]
                ?? ['Visitó ' . strtoupper($request->method()) . ' /' . $request->path(), 'Sistema'];
            $u = Auth::user();
            DB::table('bitacoras')->insert([
                'user_id'     => $u->id,
                'usuario'     => $u->name,
                'accion'      => substr($accion, 0, 250),
                'modulo'      => substr($modulo, 0, 60),
                'metodo_http' => $request->method(),
                'ruta'        => substr($request->path(), 0, 255),
                'ip'          => $request->ip(),
                'user_agent'  => substr($request->userAgent() ?? '', 0, 255),
                'fecha_hora'  => now(),
                'id_operacion'=> null,
                'created_at'  => now(),
                'updated_at'  => now(),
            ]);
        } catch (\Throwable $e) {
            Log::error('BitacoraMiddleware: ' . $e->getMessage());
        }
        return $response;
    }
}
EOF
ok "BitacoraMiddleware"

# ─────────────────────────────────────────────────────────────────────────────
#  4. BitacoraTrait
# ─────────────────────────────────────────────────────────────────────────────
cat > app/Traits/BitacoraTrait.php << 'EOF'
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
EOF
ok "BitacoraTrait"

# ─────────────────────────────────────────────────────────────────────────────
#  5. Layout principal
# ─────────────────────────────────────────────────────────────────────────────
nfo "Layout ap.blade.php..."
cat > resources/views/layouts/ap.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<meta name="csrf-token" content="{{ csrf_token() }}">
<title>@yield('title','CUP') — Admisión CUP</title>
<link href="{{ asset('css/cup.css') }}" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
@stack('css')
</head>
<body>
<header class="cup-top">
  <button class="tgl" id="sbTgl"><i class="fas fa-bars"></i></button>
  <a href="{{ route('panel') }}" class="brand">
    <div class="bico">C</div>
    <span>Admisión <span style="color:var(--o)">CUP</span></span>
  </a>
  <div class="top-r">
    <div class="top-usr" id="usrDd" onclick="this.classList.toggle('open')">
      <div class="av">{{ strtoupper(substr(Auth::user()->name??'U',0,1)) }}</div>
      <span style="display:none" class="d-sm">{{ Auth::user()->name??'Usuario' }}</span>
      <i class="fas fa-chevron-down" style="font-size:.6rem;opacity:.6;margin-left:.25rem"></i>
      <div class="umenu">
        <a href="{{ route('users.perfil') }}"><i class="fas fa-user-circle"></i> Mi perfil</a>
        <div class="sep"></div>
        <a href="{{ route('logout') }}" class="dng"><i class="fas fa-sign-out-alt"></i> Cerrar sesión</a>
      </div>
    </div>
  </div>
</header>

<nav class="cup-sb" id="cupSb">
  <div class="sb-usr">
    <div class="av">{{ strtoupper(substr(Auth::user()->name??'U',0,1)) }}</div>
    <div>
      <div class="sbn">{{ Auth::user()->name??'Usuario' }}</div>
      <div class="sbr">{{ Auth::user()->getRoleNames()->first()??'Sin rol' }}</div>
    </div>
  </div>

  {{-- Módulo 1: Autenticación y Seguridad --}}
  <div class="sb-sec">
    <div class="sb-ttl">🔐 Autenticación y Seguridad</div>
    <a class="ni {{ request()->routeIs('panel') ? 'act':'' }}" href="{{ route('panel') }}">
      <i class="ico fas fa-th-large"></i>Panel de Control</a>
    @can('ver usuarios')
    <a class="ni {{ request()->routeIs('users.*') ? 'act':'' }}" href="{{ route('users.index') }}">
      <i class="ico fas fa-users-cog"></i>Gestión de Usuarios</a>
    @endcan
    @can('ver roles')
    <a class="ni {{ request()->routeIs('roles.*') ? 'act':'' }}" href="{{ route('roles.index') }}">
      <i class="ico fas fa-user-shield"></i>Roles y Permisos</a>
    @endcan
    @can('ver bitacora')
    <a class="ni {{ request()->routeIs('bitacora.*') ? 'act':'' }}" href="{{ route('bitacora.index') }}">
      <i class="ico fas fa-journal-whills"></i>Bitácora</a>
    @endcan
  </div>
  <div class="sbdiv"></div>

  {{-- Módulo 2: Registro de Postulantes --}}
  <div class="sb-sec">
    <div class="sb-ttl">👤 Registro de Postulantes</div>
    @can('ver postulantes')
    <a class="ni {{ request()->routeIs('postulantes.*') ? 'act':'' }}" href="{{ route('postulantes.index') }}">
      <i class="ico fas fa-user-plus"></i>Postulantes</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-user-plus"></i>Postulantes<span class="nbg">Sin acceso</span></span>
    @endcan
  </div>
  <div class="sbdiv"></div>

  {{-- Módulo 3: Gestión Académica --}}
  <div class="sb-sec">
    <div class="sb-ttl">🎓 Gestión Académica</div>
    @can('ver gestiones')
    <a class="ni {{ request()->routeIs('gestiones.*') ? 'act':'' }}" href="{{ route('gestiones.index') }}">
      <i class="ico fas fa-calendar-alt"></i>Gestiones Académicas</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-calendar-alt"></i>Gestiones<span class="nbg">Sin acceso</span></span>
    @endcan
    @can('ver carreras')
    <a class="ni {{ request()->routeIs('carreras.*') ? 'act':'' }}" href="{{ route('carreras.index') }}">
      <i class="ico fas fa-graduation-cap"></i>Carreras y Cupos</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-graduation-cap"></i>Carreras y Cupos<span class="nbg">Sin acceso</span></span>
    @endcan
    @can('ver materias')
    <a class="ni {{ request()->routeIs('materias.*') ? 'act':'' }}" href="{{ route('materias.index') }}">
      <i class="ico fas fa-book-open"></i>Materias del CUP</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-book-open"></i>Materias del CUP<span class="nbg">Sin acceso</span></span>
    @endcan
  </div>
  <div class="sbdiv"></div>

  {{-- Módulo 4: Asignación de Grupos y Docentes --}}
  <div class="sb-sec">
    <div class="sb-ttl">🏫 Grupos y Docentes</div>
    @can('ver docentes')
    <a class="ni {{ request()->routeIs('docentes.*') ? 'act':'' }}" href="{{ route('docentes.index') }}">
      <i class="ico fas fa-chalkboard-teacher"></i>Docentes</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-chalkboard-teacher"></i>Docentes<span class="nbg">Sin acceso</span></span>
    @endcan
    <span class="ni pnd"><i class="ico fas fa-layer-group"></i>Grupos y Horarios<span class="nbg">Ciclo 2</span></span>
  </div>
  <div class="sbdiv"></div>

  {{-- Módulo 5: Exámenes --}}
  <div class="sb-sec">
    <div class="sb-ttl">📝 Exámenes y Control Académico</div>
    <span class="ni pnd"><i class="ico fas fa-pen-nib"></i>Registro de Notas<span class="nbg">Ciclo 2</span></span>
  </div>
  <div class="sbdiv"></div>

  {{-- Módulo 6: Panel Administrativo --}}
  <div class="sb-sec">
    <div class="sb-ttl">📊 Panel Administrativo</div>
    <span class="ni pnd"><i class="ico fas fa-trophy"></i>Proceso de Admisión<span class="nbg">Ciclo 2</span></span>
    <span class="ni pnd"><i class="ico fas fa-chart-bar"></i>Reportes y Estadísticas<span class="nbg">Ciclo 2</span></span>
  </div>
  <div class="sbdiv"></div>

  <div class="sb-sec">
    <a class="ni lgt" href="{{ route('logout') }}"><i class="ico fas fa-sign-out-alt"></i>Cerrar sesión</a>
  </div>
</nav>

<div class="cup-mn" id="cupMn">
  <div class="cup-cnt">
    @include('layouts.partials.alert')
    @yield('content')
  </div>
  <footer class="cup-ft">
    <span>© {{ date('Y') }} Sistema de Admisión CUP — FICCT</span>
    <span>Facultad de Ingeniería en Ciencias de la Computación y Telecomunicaciones</span>
  </footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>
<script>
const sb=document.getElementById('cupSb'),mn=document.getElementById('cupMn'),tg=document.getElementById('sbTgl');
let col=window.innerWidth<769;
function apl(){if(col){sb.classList.remove('open');if(window.innerWidth>=769){sb.classList.add('collapsed');mn.classList.add('exp')}else{sb.classList.remove('collapsed');mn.classList.remove('exp')}}else{sb.classList.add('open');sb.classList.remove('collapsed');mn.classList.remove('exp')}}
apl();tg.addEventListener('click',()=>{col=!col;apl()});
window.addEventListener('resize',()=>{col=window.innerWidth<769;apl()});
document.addEventListener('click',e=>{const d=document.getElementById('usrDd');if(d&&!d.contains(e.target))d.classList.remove('open')});
window.addEventListener('beforeunload',()=>navigator.sendBeacon('{{ route("bitacora.page-close") }}',new URLSearchParams({_token:'{{ csrf_token() }}'})));
</script>
@stack('js')
</body>
</html>
EOF
ok "layouts/ap.blade.php"

# ─────────────────────────────────────────────────────────────────────────────
#  6. Partials alert
# ─────────────────────────────────────────────────────────────────────────────
cat > resources/views/layouts/partials/alert.blade.php << 'EOF'
@if(session('success'))
<script>document.addEventListener('DOMContentLoaded',()=>{if(typeof Swal!=='undefined')Swal.mixin({toast:true,position:'top-end',showConfirmButton:false,timer:2800,timerProgressBar:true}).fire({icon:'success',title:@json(session('success'))});});</script>
@endif
@if(session('error'))
<div class="al al-d"><i class="fas fa-exclamation-triangle"></i> {{ session('error') }}</div>
@endif
@if($errors->any())
<div class="al al-d"><i class="fas fa-times-circle"></i><div><ul>@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div></div>
@endif
EOF
ok "partials/alert.blade.php"

# ─────────────────────────────────────────────────────────────────────────────
#  7. Login
# ─────────────────────────────────────────────────────────────────────────────
nfo "Login..."
cat > resources/views/auth/login.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Iniciar Sesión — CUP</title>
<link href="{{ asset('css/cup.css') }}" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
<style>
body{min-height:100vh;display:grid;place-items:center;background:var(--cr);
  background-image:repeating-linear-gradient(0deg,transparent,transparent 38px,rgba(26,58,42,.04) 38px,rgba(26,58,42,.04) 39px),
    repeating-linear-gradient(90deg,transparent,transparent 38px,rgba(26,58,42,.04) 38px,rgba(26,58,42,.04) 39px)}
.lw{width:100%;max-width:420px;padding:1.5rem}
.lc{background:var(--w);border:1px solid var(--b);border-radius:12px;box-shadow:var(--sl);overflow:hidden}
.lh{background:var(--v);padding:2rem 2rem 1.5rem;text-align:center;border-bottom:4px solid var(--o)}
.esc{width:64px;height:64px;border-radius:50%;background:var(--o);display:flex;align-items:center;
  justify-content:center;margin:0 auto .9rem;font-size:1.6rem;color:var(--v);font-weight:900}
.lh h1{font-family:var(--fd);font-size:1.5rem;font-weight:700;color:var(--w);margin:0}
.lh p{font-size:.8rem;color:rgba(255,255,255,.6);margin-top:.25rem}
.lb{padding:1.75rem 2rem 2rem}
.iw{position:relative}
.iw .ii{position:absolute;left:.8rem;top:50%;transform:translateY(-50%);color:var(--t3);font-size:.88rem}
.iw .fc{padding-left:2.4rem}
.btn-lg{width:100%;background:var(--v);color:var(--w);border:none;border-radius:7px;
  padding:.75rem;font-family:var(--fb);font-size:.95rem;font-weight:700;cursor:pointer;
  transition:.2s;display:flex;align-items:center;justify-content:center;gap:.5rem}
.btn-lg:hover{background:var(--v2);transform:translateY(-1px);box-shadow:var(--s)}
.fld{margin-bottom:1rem}
.fgt{text-align:center;margin-top:1rem;font-size:.82rem}
.fgt a{color:var(--t3)}
.fgt a:hover{color:var(--v)}
.lf{background:var(--cr);border-top:1px solid var(--b);text-align:center;padding:.6rem;font-size:.7rem;color:var(--t3)}
</style>
</head>
<body>
<div class="lw">
  <div class="lc">
    <div class="lh">
      <div class="esc">C</div>
      <h1>Sistema de Admisión CUP</h1>
      <p>Curso Preuniversitario — FICCT</p>
    </div>
    <div class="lb">
      @if($errors->any())
      @foreach($errors->all() as $err)
      <div class="al al-d" style="margin-bottom:.75rem"><i class="fas fa-exclamation-circle"></i> {{ $err }}</div>
      @endforeach
      @endif
      <form action="/login" method="POST">
        @csrf
        <div class="fld">
          <label class="fl" for="email">Correo institucional</label>
          <div class="iw">
            <i class="ii fas fa-envelope"></i>
            <input id="email" type="email" name="email" class="fc" value="{{ old('email') }}" placeholder="usuario@cup.edu.bo" autocomplete="email" autofocus>
          </div>
        </div>
        <div class="fld">
          <label class="fl" for="password">Contraseña</label>
          <div class="iw">
            <i class="ii fas fa-lock"></i>
            <input id="password" type="password" name="password" class="fc" placeholder="••••••••" autocomplete="current-password">
          </div>
        </div>
        <button type="submit" class="btn-lg"><i class="fas fa-sign-in-alt"></i> Ingresar al Sistema</button>
        <div class="fgt"><a href="{{ route('password.request') }}"><i class="fas fa-key"></i> ¿Olvidaste tu contraseña?</a></div>
      </form>
    </div>
    <div class="lf">© {{ date('Y') }} CUP — Todos los derechos reservados</div>
  </div>
</div>
</body>
</html>
EOF
ok "auth/login.blade.php"

# ─────────────────────────────────────────────────────────────────────────────
#  8. Panel
# ─────────────────────────────────────────────────────────────────────────────
nfo "Panel de control..."
cat > resources/views/panel/index.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Panel de Control')
@push('css')
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css">
@endpush
@section('content')
<div class="ph">
  <h1>Panel de Control</h1>
  <p class="sub">Sistema de Admisión — Curso Preuniversitario (CUP) · FICCT</p>
  <ol class="bc"><li>Inicio</li></ol>
</div>

<div class="sg">
  @can('ver postulantes')
  <a class="sc" href="{{ route('postulantes.index') }}">
    <div class="si c1"><i class="fas fa-users"></i></div>
    <div><div class="sv">{{ \App\Models\Postulante::count() }}</div><div class="sl">Postulantes inscritos</div></div>
  </a>
  @endcan
  @can('ver carreras')
  <a class="sc" href="{{ route('carreras.index') }}">
    <div class="si c2"><i class="fas fa-graduation-cap"></i></div>
    <div><div class="sv">{{ \App\Models\Carrera::count() }}</div><div class="sl">Carreras</div></div>
  </a>
  @endcan
  @can('ver docentes')
  <a class="sc" href="{{ route('docentes.index') }}">
    <div class="si c5"><i class="fas fa-chalkboard-teacher"></i></div>
    <div><div class="sv">{{ \App\Models\Docente::count() }}</div><div class="sl">Docentes</div></div>
  </a>
  @endcan
  @can('ver materias')
  <a class="sc" href="{{ route('materias.index') }}">
    <div class="si c6"><i class="fas fa-book-open"></i></div>
    <div><div class="sv">{{ \App\Models\Materia::count() }}</div><div class="sl">Materias</div></div>
  </a>
  @endcan
  @can('ver usuarios')
  <a class="sc" href="{{ route('users.index') }}">
    <div class="si c4"><i class="fas fa-users-cog"></i></div>
    <div><div class="sv">{{ \App\Models\User::count() }}</div><div class="sl">Usuarios del sistema</div></div>
  </a>
  @endcan
</div>

<div class="mg">
  {{-- M1: Autenticación --}}
  <div class="mc m1">
    <div class="mh"><div class="mn2">1</div>Módulo de Autenticación y Seguridad</div>
    <div class="mb2">
      <div class="cr2x lnk"><a href="{{ route('login') }}"><span class="ctg dn">CU-01</span><i class="ci2 fas fa-sign-in-alt"></i>Iniciar sesión</a></div>
      <div class="cr2x lnk"><a href="{{ route('logout') }}"><span class="ctg dn">CU-02</span><i class="ci2 fas fa-sign-out-alt"></i>Cerrar sesión</a></div>
      <div class="cr2x lnk"><a href="{{ route('password.request') }}"><span class="ctg dn">CU-03</span><i class="ci2 fas fa-key"></i>Recuperar contraseña</a></div>
      @can('ver usuarios')
      <div class="cr2x lnk"><a href="{{ route('users.index') }}"><span class="ctg dn">CU-04</span><i class="ci2 fas fa-users-cog"></i>Gestionar usuarios y roles</a></div>
      @endcan
      @can('ver bitacora')
      <div class="cr2x lnk"><a href="{{ route('bitacora.index') }}"><span class="ctg dn">AUD</span><i class="ci2 fas fa-journal-whills"></i>Bitácora del sistema</a></div>
      @endcan
    </div>
  </div>

  {{-- M2: Postulantes --}}
  <div class="mc m2">
    <div class="mh"><div class="mn2">2</div>Módulo de Registro de Postulantes</div>
    <div class="mb2">
      @can('ver postulantes')
      <div class="cr2x lnk"><a href="{{ route('postulantes.create') }}"><span class="ctg dn">CU-05</span><i class="ci2 fas fa-user-plus"></i>Registrar postulante</a></div>
      <div class="cr2x lnk"><a href="{{ route('postulantes.index') }}"><span class="ctg dn">CU-06</span><i class="ci2 fas fa-file-upload"></i>Cargar requisitos (CI, libreta, título)</a></div>
      <div class="cr2x lnk"><a href="{{ route('postulantes.index') }}"><span class="ctg dn">CU-07</span><i class="ci2 fas fa-check-circle"></i>Validar requisitos</a></div>
      <div class="cr2x lnk"><a href="{{ route('postulantes.create') }}"><span class="ctg dn">CU-08</span><i class="ci2 fas fa-list-ol"></i>Seleccionar 1ª y 2ª opción de carrera</a></div>
      <div class="cr2x lnk"><a href="{{ route('postulantes.index') }}"><span class="ctg dn">CU-09</span><i class="ci2 fas fa-search"></i>Consultar estado del postulante</a></div>
      @else
      @foreach(['CU-05'=>'Registrar postulante','CU-06'=>'Cargar requisitos','CU-07'=>'Validar requisitos','CU-08'=>'Opciones de carrera','CU-09'=>'Consultar estado'] as $c=>$d)
      <div class="cr2x dis"><span class="ctg pn">{{ $c }}</span><i class="ci2 fas fa-lock"></i>{{ $d }}<span class="cpl">Sin acceso</span></div>
      @endforeach
      @endcan
    </div>
  </div>

  {{-- M3: Gestión Académica --}}
  <div class="mc m3">
    <div class="mh"><div class="mn2">3</div>Módulo de Gestión Académica</div>
    <div class="mb2">
      @can('ver gestiones')
      <div class="cr2x lnk"><a href="{{ route('gestiones.index') }}"><span class="ctg dn">CU-13</span><i class="ci2 fas fa-calendar-alt"></i>Gestionar gestiones académicas</a></div>
      @endcan
      @can('ver carreras')
      <div class="cr2x lnk"><a href="{{ route('carreras.index') }}"><span class="ctg dn">CU-10</span><i class="ci2 fas fa-graduation-cap"></i>Gestionar carreras de la facultad</a></div>
      <div class="cr2x lnk"><a href="{{ route('carreras.index') }}"><span class="ctg dn">CU-11</span><i class="ci2 fas fa-sliders-h"></i>Definir cupos por carrera y gestión</a></div>
      @endcan
      @can('ver materias')
      <div class="cr2x lnk"><a href="{{ route('materias.index') }}"><span class="ctg dn">CU-12</span><i class="ci2 fas fa-book-open"></i>Gestionar materias del CUP</a></div>
      @endcan
    </div>
  </div>

  {{-- M4: Grupos y Docentes --}}
  <div class="mc m4">
    <div class="mh"><div class="mn2">4</div>Módulo de Asignación de Grupos y Docentes</div>
    <div class="mb2">
      @can('ver docentes')
      <div class="cr2x lnk"><a href="{{ route('docentes.index') }}"><span class="ctg dn">CU-14</span><i class="ci2 fas fa-chalkboard-teacher"></i>Registrar docente con perfil profesional</a></div>
      <div class="cr2x lnk"><a href="{{ route('docentes.index') }}"><span class="ctg dn">CU-15</span><i class="ci2 fas fa-user-check"></i>Validar perfil profesional del docente</a></div>
      <div class="cr2x lnk"><a href="{{ route('docentes.index') }}"><span class="ctg dn">CU-16</span><i class="ci2 fas fa-clock"></i>Consultar carga horaria del docente</a></div>
      @endcan
      @foreach(['CU-17'=>'Calcular y generar grupos automáticamente','CU-18'=>'Asignar docente a grupo y materia','CU-19'=>'Validar cruces de horario','CU-20'=>'Asignar horarios y modalidad','CU-21'=>'Inscribir postulantes a grupos'] as $c=>$d)
      <div class="cr2x dis"><span class="ctg pn">{{ $c }}</span><i class="ci2 fas fa-clock"></i>{{ $d }}<span class="cpl">Ciclo 2</span></div>
      @endforeach
    </div>
  </div>

  {{-- M5: Exámenes --}}
  <div class="mc m5">
    <div class="mh"><div class="mn2">5</div>Módulo de Exámenes y Control Académico</div>
    <div class="mb2">
      @foreach(['CU-22'=>'Registrar notas de exámenes (3 por materia)','CU-23'=>'Calcular nota final (30%+30%+40%)','CU-24'=>'Calcular promedio general','CU-25'=>'Determinar aprobado/reprobado ≥60','CU-26'=>'Consultar notas del postulante'] as $c=>$d)
      <div class="cr2x dis"><span class="ctg pn">{{ $c }}</span><i class="ci2 fas fa-clock"></i>{{ $d }}<span class="cpl">Ciclo 2</span></div>
      @endforeach
    </div>
  </div>

  {{-- M6: Admisión --}}
  <div class="mc m1" style="border-top-color:#10b981">
    <div class="mh"><div class="mn2" style="background:#d1fae5;color:#065f46">6</div>Módulo de Panel Administrativo y Reportes</div>
    <div class="mb2">
      @foreach(['CU-27'=>'Procesar admisión por primera opción','CU-28'=>'Reasignar a segunda opción','CU-29'=>'Publicar resultado final','CU-30'=>'Reporte aprobados/reprobados por grupo','CU-31'=>'Reporte admitidos por carrera','CU-32'=>'Comparativo histórico entre gestiones','CU-33'=>'Indicadores estadísticos del proceso'] as $c=>$d)
      <div class="cr2x dis"><span class="ctg pn">{{ $c }}</span><i class="ci2 fas fa-clock"></i>{{ $d }}<span class="cpl">Ciclo 2</span></div>
      @endforeach
    </div>
  </div>
</div>

@push('js')
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
@endpush
@endsection
EOF
ok "panel/index.blade.php"

# ─────────────────────────────────────────────────────────────────────────────
#  9. Bitácora vista
# ─────────────────────────────────────────────────────────────────────────────
nfo "Bitácora..."
cat > resources/views/bitacora/index.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Bitácora del Sistema')
@push('css')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css">
@endpush
@section('content')
<div class="ph">
  <h1>Bitácora del Sistema</h1>
  <p class="sub">Registro completo de todas las acciones de los usuarios</p>
  <ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Bitácora</li></ol>
</div>
<div class="card">
  <div class="card-hd"><i class="fas fa-journal-whills"></i>Bitácora
    <span style="margin-left:auto;font-size:.8rem;color:var(--t3);font-weight:400">{{ $bitacoras->count() }} registros</span>
  </div>
  <div class="card-bd" style="padding:.75rem">
    <div class="tw">
      <table id="tblBit" class="ct" style="width:100%;font-size:.83rem">
        <thead><tr><th>Fecha y Hora</th><th>Usuario</th><th>Módulo</th><th>Acción</th><th>Método</th><th>Ruta</th><th>IP</th></tr></thead>
        <tbody>
        @forelse($bitacoras as $log)
        @php
          $mc = substr(preg_replace('/[^A-Za-z]/','',$log->modulo??''),0,3);
        @endphp
        <tr>
          <td style="white-space:nowrap;color:var(--t3)">{{ \Carbon\Carbon::parse($log->fecha_hora)->format('d/m/Y H:i:s') }}</td>
          <td style="font-weight:600">{{ $log->usuario??'—' }}</td>
          <td>@if($log->modulo)<span class="cmod {{ $mc }}">{{ $log->modulo }}</span>@else<span style="color:var(--t3)">—</span>@endif</td>
          <td style="color:var(--t)">{{ $log->accion }}</td>
          <td>@if($log->metodo_http)<span class="chttp h{{ $log->metodo_http }}">{{ $log->metodo_http }}</span>@endif</td>
          <td style="font-family:'Courier New',monospace;font-size:.78rem;color:var(--t3)">{{ $log->ruta??'—' }}</td>
          <td style="font-family:'Courier New',monospace;font-size:.78rem;color:var(--t3)">{{ $log->ip??'—' }}</td>
        </tr>
        @empty
        <tr><td colspan="7" style="text-align:center;padding:2rem;color:var(--t3)">Sin registros aún.</td></tr>
        @endforelse
        </tbody>
      </table>
    </div>
  </div>
</div>
@push('js')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<script>$(()=>$('#tblBit').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},order:[[0,'desc']],pageLength:25}))</script>
@endpush
@endsection
EOF
ok "bitacora/index.blade.php"

# ─────────────────────────────────────────────────────────────────────────────
#  10. MIGRACIONES completas
# ─────────────────────────────────────────────────────────────────────────────
nfo "Migraciones..."

# bitacoras
cat > database/migrations/2024_04_23_030711_create_bitacoras_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('bitacoras', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('usuario',120)->nullable();
            $table->string('accion',250);
            $table->string('modulo',60)->nullable();
            $table->string('metodo_http',10)->nullable();
            $table->string('ruta',255)->nullable();
            $table->dateTime('fecha_hora');
            $table->bigInteger('id_operacion')->nullable();
            $table->string('ip',45)->nullable();
            $table->string('user_agent',255)->nullable();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('bitacoras'); }
};
EOF

# gestiones
cat > database/migrations/0001_01_01_000003_create_gestiones_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('gestiones', function (Blueprint $table) {
            $table->id();
            $table->string('descripcion',50)->unique();
            $table->date('fecha_inicio');
            $table->date('fecha_fin');
            $table->enum('estado',['planificacion','inscripcion','en_curso','finalizado'])->default('planificacion');
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('gestiones'); }
};
EOF

# carreras
cat > database/migrations/0001_01_01_000004_create_carreras_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('carreras', function (Blueprint $table) {
            $table->id();
            $table->string('nombre',100)->unique();
            $table->string('sigla',10)->nullable();
            $table->text('descripcion')->nullable();
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('carreras'); }
};
EOF

# materias
cat > database/migrations/0001_01_01_000006_create_materias_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('materias', function (Blueprint $table) {
            $table->id();
            $table->string('nombre',100)->unique();
            $table->string('area_formacion',80)->nullable();
            $table->text('descripcion')->nullable();
            $table->unsignedInteger('pond_examen1')->default(30);
            $table->unsignedInteger('pond_examen2')->default(30);
            $table->unsignedInteger('pond_examen3')->default(40);
            $table->unsignedInteger('nota_minima_aprobacion')->default(60);
            $table->unsignedInteger('orden')->default(0);
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('materias'); }
};
EOF

# docentes
cat > database/migrations/0001_01_01_000007_create_docentes_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('docentes', function (Blueprint $table) {
            $table->id();
            $table->string('ci',20)->unique();
            $table->string('nombres',100);
            $table->string('apellidos',100);
            $table->string('telefono',20)->nullable();
            $table->string('email',100)->nullable()->unique();
            $table->string('titulo_profesional',150)->nullable();
            $table->string('maestria',150)->nullable();
            $table->string('diplomado_educacion_superior',150)->nullable();
            $table->string('certificacion_ingles',100)->nullable();
            $table->text('otras_certificaciones')->nullable();
            $table->string('area_formacion',80)->nullable();
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('docentes'); }
};
EOF

# postulantes — campos completos del PDF
cat > database/migrations/0001_01_01_000008_create_postulantes_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('postulantes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gestion_id')->constrained('gestiones');
            $table->foreignId('primera_opcion_id')->constrained('carreras');
            $table->foreignId('segunda_opcion_id')->constrained('carreras');
            $table->string('ci',20)->unique();
            $table->string('nombres',100);
            $table->string('apellidos',100);
            $table->date('fecha_nacimiento')->nullable();
            $table->enum('sexo',['M','F','Otro'])->nullable();
            $table->string('direccion',200)->nullable();
            $table->string('telefono',20)->nullable();
            $table->string('email',100)->nullable();
            $table->string('colegio_procedencia',150)->nullable();
            $table->string('ciudad',80)->nullable();
            $table->boolean('doc_ci')->default(false);
            $table->boolean('doc_libreta_colegio')->default(false);
            $table->boolean('doc_titulo_bachiller')->default(false);
            $table->enum('estado',['inscrito','en_curso','aprobado','no_aprobado','admitido','admitido_segunda_opcion','no_admitido'])->default('inscrito');
            $table->decimal('promedio_general',5,2)->nullable();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('postulantes'); }
};
EOF

# cupos_carrera
cat > database/migrations/2026_01_01_000001_create_cupos_carrera_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('cupos_carrera', function (Blueprint $table) {
            $table->id();
            $table->foreignId('carrera_id')->constrained()->cascadeOnDelete();
            $table->foreignId('gestion_id')->constrained('gestiones')->cascadeOnDelete();
            $table->unsignedInteger('cantidad_maxima');
            $table->unique(['carrera_id','gestion_id']);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('cupos_carrera'); }
};
EOF

# usuarios (FK nullable hacia docentes y postulantes)
cat > database/migrations/0001_01_01_000013_create_users_table.php << 'EOF'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->foreignId('docente_id')->nullable()->constrained('docentes')->nullOnDelete();
            $table->foreignId('postulante_id')->nullable()->constrained('postulantes')->nullOnDelete();
            $table->boolean('activo')->default(true);
            $table->rememberToken();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('users'); }
};
EOF
ok "Migraciones"

# ─────────────────────────────────────────────────────────────────────────────
#  11. MODELOS
# ─────────────────────────────────────────────────────────────────────────────
nfo "Modelos..."

cat > app/Models/Gestion.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Gestion extends Model {
    protected $table = 'gestiones';
    protected $fillable = ['descripcion','fecha_inicio','fecha_fin','estado'];
    protected $casts = ['fecha_inicio'=>'date','fecha_fin'=>'date'];
    public function postulantes() { return $this->hasMany(Postulante::class); }
    public function cupos() { return $this->hasMany(CupoCarrera::class); }
}
EOF

cat > app/Models/Carrera.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Carrera extends Model {
    protected $table = 'carreras';
    protected $fillable = ['nombre','sigla','descripcion','estado'];
    public function cupos() { return $this->hasMany(CupoCarrera::class); }
    public function primerasOpciones() { return $this->hasMany(Postulante::class,'primera_opcion_id'); }
    public function segundasOpciones() { return $this->hasMany(Postulante::class,'segunda_opcion_id'); }
}
EOF

cat > app/Models/CupoCarrera.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class CupoCarrera extends Model {
    protected $table = 'cupos_carrera';
    protected $fillable = ['carrera_id','gestion_id','cantidad_maxima'];
    public function carrera() { return $this->belongsTo(Carrera::class); }
    public function gestion() { return $this->belongsTo(Gestion::class); }
}
EOF

cat > app/Models/Materia.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Materia extends Model {
    protected $table = 'materias';
    protected $fillable = ['nombre','area_formacion','descripcion','pond_examen1','pond_examen2','pond_examen3','nota_minima_aprobacion','orden','estado'];
    public function getPonderacionTotalAttribute(): int { return $this->pond_examen1+$this->pond_examen2+$this->pond_examen3; }
}
EOF

cat > app/Models/Docente.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Docente extends Model {
    protected $table = 'docentes';
    protected $fillable = ['ci','nombres','apellidos','telefono','email','titulo_profesional','maestria','diplomado_educacion_superior','certificacion_ingles','otras_certificaciones','area_formacion','estado'];
    public function getNombreCompletoAttribute(): string { return $this->nombres.' '.$this->apellidos; }
    public function user() { return $this->hasOne(User::class); }
}
EOF

cat > app/Models/Postulante.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Postulante extends Model {
    protected $table = 'postulantes';
    protected $fillable = ['gestion_id','primera_opcion_id','segunda_opcion_id','ci','nombres','apellidos','fecha_nacimiento','sexo','direccion','telefono','email','colegio_procedencia','ciudad','doc_ci','doc_libreta_colegio','doc_titulo_bachiller','estado','promedio_general'];
    protected $casts = ['fecha_nacimiento'=>'date'];
    public function gestion() { return $this->belongsTo(Gestion::class); }
    public function primeraOpcion() { return $this->belongsTo(Carrera::class,'primera_opcion_id'); }
    public function segundaOpcion() { return $this->belongsTo(Carrera::class,'segunda_opcion_id'); }
    public function getNombreCompletoAttribute(): string { return $this->nombres.' '.$this->apellidos; }
    public function tieneDocumentos(): bool { return $this->doc_ci && $this->doc_libreta_colegio && $this->doc_titulo_bachiller; }
    public function getEstadoBadgeAttribute(): string {
        return match($this->estado){
            'inscrito'=>'baz','en_curso'=>'bna','aprobado'=>'bv','no_aprobado'=>'bd',
            'admitido'=>'bv','admitido_segunda_opcion'=>'bo','no_admitido'=>'bd',default=>'bg2'};
    }
}
EOF

cat > app/Models/Bitacora.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Bitacora extends Model {
    protected $table = 'bitacoras';
    protected $fillable = ['user_id','usuario','accion','modulo','metodo_http','ruta','fecha_hora','id_operacion','ip','user_agent'];
    public function user() { return $this->belongsTo(User::class); }
}
EOF

cat > app/Models/User.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Spatie\Permission\Traits\HasRoles;
class User extends Authenticatable {
    use HasFactory, Notifiable, HasRoles;
    protected $fillable = ['name','email','email_verified_at','password','docente_id','postulante_id','activo'];
    protected $hidden = ['password','remember_token'];
    protected function casts(): array { return ['email_verified_at'=>'datetime','password'=>'hashed']; }
    public function docente() { return $this->belongsTo(Docente::class); }
    public function postulante() { return $this->belongsTo(Postulante::class); }
    public function bitacoras() { return $this->hasMany(Bitacora::class); }
}
EOF
ok "Modelos"

# ─────────────────────────────────────────────────────────────────────────────
#  12. CONTROLADORES
# ─────────────────────────────────────────────────────────────────────────────
nfo "Controladores..."

cat > app/Http/Controllers/BitacoraController.php << 'EOF'
<?php
namespace App\Http\Controllers;
use App\Models\Bitacora;
class BitacoraController extends Controller {
    public function __construct() { $this->middleware('auth'); $this->middleware('permission:ver bitacora'); }
    public function index() { $bitacoras = Bitacora::orderByDesc('fecha_hora')->limit(3000)->get(); return view('bitacora.index',compact('bitacoras')); }
}
EOF

cat > app/Http/Controllers/GestionController.php << 'EOF'
<?php
namespace App\Http\Controllers;
use App\Models\Gestion;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
class GestionController extends Controller {
    use BitacoraTrait;
    public function __construct() {
        $this->middleware('auth');
        $this->middleware('permission:ver gestiones')->only('index','show');
        $this->middleware('permission:crear gestiones')->only('create','store');
        $this->middleware('permission:editar gestiones')->only('edit','update');
        $this->middleware('permission:eliminar gestiones')->only('destroy');
    }
    public function index() { return view('gestiones.index',['gestiones'=>Gestion::orderByDesc('fecha_inicio')->get()]); }
    public function create() { return view('gestiones.create'); }
    public function store(Request $r) {
        $d = $r->validate(['descripcion'=>'required|string|max:50|unique:gestiones,descripcion','fecha_inicio'=>'required|date','fecha_fin'=>'required|date|after:fecha_inicio','estado'=>'in:planificacion,inscripcion,en_curso,finalizado']);
        $g = Gestion::create($d);
        $this->registrarEnBitacora("Creó gestión: {$g->descripcion}",$g->id,'Gestiones');
        return redirect()->route('gestiones.index')->with('success',"Gestión «{$g->descripcion}» creada.");
    }
    public function show(Gestion $gestion) { return view('gestiones.show',compact('gestion')); }
    public function edit(Gestion $gestion) { return view('gestiones.edit',compact('gestion')); }
    public function update(Request $r, Gestion $gestion) {
        $d = $r->validate(['descripcion'=>"required|string|max:50|unique:gestiones,descripcion,{$gestion->id}",'fecha_inicio'=>'required|date','fecha_fin'=>'required|date|after:fecha_inicio','estado'=>'in:planificacion,inscripcion,en_curso,finalizado']);
        $gestion->update($d);
        $this->registrarEnBitacora("Actualizó gestión: {$gestion->descripcion}",$gestion->id,'Gestiones');
        return redirect()->route('gestiones.index')->with('success',"Gestión actualizada.");
    }
    public function destroy(Gestion $gestion) {
        $n=$gestion->descripcion; $gestion->delete();
        $this->registrarEnBitacora("Eliminó gestión: {$n}",null,'Gestiones');
        return redirect()->route('gestiones.index')->with('success',"Gestión «{$n}» eliminada.");
    }
}
EOF

cat > app/Http/Controllers/CarreraController.php << 'EOF'
<?php
namespace App\Http\Controllers;
use App\Models\{Carrera,CupoCarrera,Gestion};
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
class CarreraController extends Controller {
    use BitacoraTrait;
    public function __construct() {
        $this->middleware('auth');
        $this->middleware('permission:ver carreras')->only('index','show');
        $this->middleware('permission:crear carreras')->only('create','store');
        $this->middleware('permission:editar carreras')->only('edit','update');
        $this->middleware('permission:eliminar carreras')->only('destroy');
    }
    public function index() { return view('carreras.index',['carreras'=>Carrera::orderBy('nombre')->get()]); }
    public function create() { return view('carreras.create'); }
    public function store(Request $r) {
        $d=$r->validate(['nombre'=>'required|string|max:100|unique:carreras,nombre','sigla'=>'nullable|string|max:10','descripcion'=>'nullable|string','estado'=>'boolean']);
        $d['estado']=$r->boolean('estado',true);
        $c=Carrera::create($d);
        $this->registrarEnBitacora("Creó carrera: {$c->nombre}",$c->id,'Carreras');
        return redirect()->route('carreras.index')->with('success',"Carrera «{$c->nombre}» creada.");
    }
    public function show(Carrera $carrera) {
        $gestiones=Gestion::orderByDesc('fecha_inicio')->get();
        $cupos=CupoCarrera::where('carrera_id',$carrera->id)->with('gestion')->orderByDesc('id')->get();
        return view('carreras.show',compact('carrera','gestiones','cupos'));
    }
    public function edit(Carrera $carrera) { return view('carreras.edit',compact('carrera')); }
    public function update(Request $r, Carrera $carrera) {
        $d=$r->validate(['nombre'=>"required|string|max:100|unique:carreras,nombre,{$carrera->id}",'sigla'=>'nullable|string|max:10','descripcion'=>'nullable|string','estado'=>'boolean']);
        $d['estado']=$r->boolean('estado',true); $carrera->update($d);
        $this->registrarEnBitacora("Actualizó carrera: {$carrera->nombre}",$carrera->id,'Carreras');
        return redirect()->route('carreras.index')->with('success',"Carrera actualizada.");
    }
    public function destroy(Carrera $carrera) {
        $n=$carrera->nombre; $carrera->delete();
        $this->registrarEnBitacora("Eliminó carrera: {$n}",null,'Carreras');
        return redirect()->route('carreras.index')->with('success',"Carrera «{$n}» eliminada.");
    }
    public function storeCupo(Request $r, Carrera $carrera) {
        $d=$r->validate(['gestion_id'=>'required|exists:gestiones,id','cantidad_maxima'=>'required|integer|min:1|max:9999']);
        $c=CupoCarrera::updateOrCreate(['carrera_id'=>$carrera->id,'gestion_id'=>$d['gestion_id']],['cantidad_maxima'=>$d['cantidad_maxima']]);
        $this->registrarEnBitacora("Definió cupo {$c->cantidad_maxima} para {$carrera->nombre}",$carrera->id,'Carreras');
        return redirect()->route('carreras.show',$carrera)->with('success','Cupo definido correctamente.');
    }
}
EOF

cat > app/Http/Controllers/MateriaController.php << 'EOF'
<?php
namespace App\Http\Controllers;
use App\Models\Materia;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
class MateriaController extends Controller {
    use BitacoraTrait;
    public function __construct() {
        $this->middleware('auth');
        $this->middleware('permission:ver materias')->only('index','show');
        $this->middleware('permission:crear materias')->only('create','store');
        $this->middleware('permission:editar materias')->only('edit','update');
        $this->middleware('permission:eliminar materias')->only('destroy');
    }
    public function index() { return view('materias.index',['materias'=>Materia::orderBy('orden')->orderBy('nombre')->get()]); }
    public function create() { return view('materias.create'); }
    public function store(Request $r) {
        $d=$r->validate(['nombre'=>'required|string|max:100|unique:materias,nombre','area_formacion'=>'nullable|string|max:80','descripcion'=>'nullable|string','pond_examen1'=>'required|integer|min:1|max:98','pond_examen2'=>'required|integer|min:1|max:98','pond_examen3'=>'required|integer|min:1|max:98','nota_minima_aprobacion'=>'required|integer|min:1|max:100','orden'=>'nullable|integer|min:0','estado'=>'boolean']);
        if(($d['pond_examen1']+$d['pond_examen2']+$d['pond_examen3'])!==100)
            return back()->withErrors(['pond_examen1'=>'Las ponderaciones deben sumar 100%'])->withInput();
        $d['estado']=$r->boolean('estado',true); $d['orden']=$d['orden']??0;
        $m=Materia::create($d);
        $this->registrarEnBitacora("Creó materia: {$m->nombre}",$m->id,'Materias');
        return redirect()->route('materias.index')->with('success',"Materia «{$m->nombre}» creada.");
    }
    public function show(Materia $materia) { return view('materias.show',compact('materia')); }
    public function edit(Materia $materia) { return view('materias.edit',compact('materia')); }
    public function update(Request $r, Materia $materia) {
        $d=$r->validate(['nombre'=>"required|string|max:100|unique:materias,nombre,{$materia->id}",'area_formacion'=>'nullable|string|max:80','descripcion'=>'nullable|string','pond_examen1'=>'required|integer|min:1|max:98','pond_examen2'=>'required|integer|min:1|max:98','pond_examen3'=>'required|integer|min:1|max:98','nota_minima_aprobacion'=>'required|integer|min:1|max:100','orden'=>'nullable|integer|min:0','estado'=>'boolean']);
        if(($d['pond_examen1']+$d['pond_examen2']+$d['pond_examen3'])!==100)
            return back()->withErrors(['pond_examen1'=>'Las ponderaciones deben sumar 100%'])->withInput();
        $d['estado']=$r->boolean('estado',true); $materia->update($d);
        $this->registrarEnBitacora("Actualizó materia: {$materia->nombre}",$materia->id,'Materias');
        return redirect()->route('materias.index')->with('success',"Materia actualizada.");
    }
    public function destroy(Materia $materia) {
        $n=$materia->nombre; $materia->delete();
        $this->registrarEnBitacora("Eliminó materia: {$n}",null,'Materias');
        return redirect()->route('materias.index')->with('success',"Materia «{$n}» eliminada.");
    }
}
EOF

cat > app/Http/Controllers/DocenteController.php << 'EOF'
<?php
namespace App\Http\Controllers;
use App\Models\Docente;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
class DocenteController extends Controller {
    use BitacoraTrait;
    public function __construct() {
        $this->middleware('auth');
        $this->middleware('permission:ver docentes')->only('index','show');
        $this->middleware('permission:crear docentes')->only('create','store');
        $this->middleware('permission:editar docentes')->only('edit','update');
        $this->middleware('permission:eliminar docentes')->only('destroy');
    }
    public function index() { return view('docentes.index',['docentes'=>Docente::orderBy('apellidos')->get()]); }
    public function create() { return view('docentes.create'); }
    public function store(Request $r) {
        $d=$r->validate(['ci'=>'required|string|max:20|unique:docentes,ci','nombres'=>'required|string|max:100','apellidos'=>'required|string|max:100','telefono'=>'nullable|string|max:20','email'=>'nullable|email|max:100|unique:docentes,email','titulo_profesional'=>'required|string|max:150','maestria'=>'required|string|max:150','diplomado_educacion_superior'=>'required|string|max:150','certificacion_ingles'=>'nullable|string|max:100','otras_certificaciones'=>'nullable|string','area_formacion'=>'required|string|max:80','estado'=>'boolean']);
        $d['estado']=$r->boolean('estado',true);
        $dc=Docente::create($d);
        $this->registrarEnBitacora("Registró docente: {$dc->nombre_completo}",$dc->id,'Docentes');
        return redirect()->route('docentes.index')->with('success',"Docente «{$dc->nombre_completo}» registrado.");
    }
    public function show(Docente $docente) { return view('docentes.show',compact('docente')); }
    public function edit(Docente $docente) { return view('docentes.edit',compact('docente')); }
    public function update(Request $r, Docente $docente) {
        $d=$r->validate(['ci'=>"required|string|max:20|unique:docentes,ci,{$docente->id}",'nombres'=>'required|string|max:100','apellidos'=>'required|string|max:100','telefono'=>'nullable|string|max:20','email'=>"nullable|email|max:100|unique:docentes,email,{$docente->id}",'titulo_profesional'=>'required|string|max:150','maestria'=>'required|string|max:150','diplomado_educacion_superior'=>'required|string|max:150','certificacion_ingles'=>'nullable|string|max:100','otras_certificaciones'=>'nullable|string','area_formacion'=>'required|string|max:80','estado'=>'boolean']);
        $d['estado']=$r->boolean('estado',true); $docente->update($d);
        $this->registrarEnBitacora("Actualizó docente: {$docente->nombre_completo}",$docente->id,'Docentes');
        return redirect()->route('docentes.index')->with('success',"Docente actualizado.");
    }
    public function destroy(Docente $docente) {
        $n=$docente->nombre_completo; $docente->update(['estado'=>false]);
        $this->registrarEnBitacora("Desactivó docente: {$n}",$docente->id,'Docentes');
        return redirect()->route('docentes.index')->with('success',"Docente «{$n}» desactivado.");
    }
}
EOF

cat > app/Http/Controllers/PostulanteController.php << 'EOF'
<?php
namespace App\Http\Controllers;
use App\Models\{Postulante,Carrera,Gestion};
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
class PostulanteController extends Controller {
    use BitacoraTrait;
    public function __construct() {
        $this->middleware('auth');
        $this->middleware('permission:ver postulantes')->only('index','show');
        $this->middleware('permission:crear postulantes')->only('create','store');
        $this->middleware('permission:editar postulantes')->only('edit','update');
        $this->middleware('permission:eliminar postulantes')->only('destroy');
    }
    public function index() { return view('postulantes.index',['postulantes'=>Postulante::with('primeraOpcion','segundaOpcion','gestion')->orderBy('apellidos')->get()]); }
    public function create() { return view('postulantes.create',['carreras'=>Carrera::where('estado',true)->orderBy('nombre')->get(),'gestiones'=>Gestion::orderByDesc('fecha_inicio')->get()]); }
    public function store(Request $r) {
        $d=$r->validate(['gestion_id'=>'required|exists:gestiones,id','primera_opcion_id'=>'required|exists:carreras,id','segunda_opcion_id'=>'required|exists:carreras,id|different:primera_opcion_id','ci'=>'required|string|max:20|unique:postulantes,ci','nombres'=>'required|string|max:100','apellidos'=>'required|string|max:100','fecha_nacimiento'=>'nullable|date|before:today','sexo'=>'nullable|in:M,F,Otro','direccion'=>'nullable|string|max:200','telefono'=>'nullable|string|max:20','email'=>'nullable|email|max:100','colegio_procedencia'=>'nullable|string|max:150','ciudad'=>'nullable|string|max:80','doc_ci'=>'boolean','doc_libreta_colegio'=>'boolean','doc_titulo_bachiller'=>'boolean']);
        $d['doc_ci']=$r->boolean('doc_ci'); $d['doc_libreta_colegio']=$r->boolean('doc_libreta_colegio'); $d['doc_titulo_bachiller']=$r->boolean('doc_titulo_bachiller');
        $p=Postulante::create($d);
        $this->registrarEnBitacora("Registró postulante: {$p->nombre_completo} CI:{$p->ci}",$p->id,'Postulantes');
        return redirect()->route('postulantes.index')->with('success',"Postulante «{$p->nombre_completo}» registrado.");
    }
    public function show(Postulante $postulante) { $postulante->load('primeraOpcion','segundaOpcion','gestion'); return view('postulantes.show',compact('postulante')); }
    public function edit(Postulante $postulante) { return view('postulantes.edit',['postulante'=>$postulante,'carreras'=>Carrera::where('estado',true)->orderBy('nombre')->get(),'gestiones'=>Gestion::orderByDesc('fecha_inicio')->get()]); }
    public function update(Request $r, Postulante $postulante) {
        $d=$r->validate(['gestion_id'=>'required|exists:gestiones,id','primera_opcion_id'=>'required|exists:carreras,id','segunda_opcion_id'=>"required|exists:carreras,id|different:primera_opcion_id",'ci'=>"required|string|max:20|unique:postulantes,ci,{$postulante->id}",'nombres'=>'required|string|max:100','apellidos'=>'required|string|max:100','fecha_nacimiento'=>'nullable|date|before:today','sexo'=>'nullable|in:M,F,Otro','direccion'=>'nullable|string|max:200','telefono'=>'nullable|string|max:20','email'=>'nullable|email|max:100','colegio_procedencia'=>'nullable|string|max:150','ciudad'=>'nullable|string|max:80','doc_ci'=>'boolean','doc_libreta_colegio'=>'boolean','doc_titulo_bachiller'=>'boolean']);
        $d['doc_ci']=$r->boolean('doc_ci'); $d['doc_libreta_colegio']=$r->boolean('doc_libreta_colegio'); $d['doc_titulo_bachiller']=$r->boolean('doc_titulo_bachiller');
        $postulante->update($d);
        $this->registrarEnBitacora("Actualizó postulante: {$postulante->nombre_completo}",$postulante->id,'Postulantes');
        return redirect()->route('postulantes.index')->with('success',"Postulante actualizado.");
    }
    public function destroy(Postulante $postulante) {
        $n=$postulante->nombre_completo; $postulante->delete();
        $this->registrarEnBitacora("Eliminó postulante: {$n}",null,'Postulantes');
        return redirect()->route('postulantes.index')->with('success',"Postulante «{$n}» eliminado.");
    }
}
EOF
ok "Controladores"

# ─────────────────────────────────────────────────────────────────────────────
#  13. VISTAS (macro helper para evitar repetición)
# ─────────────────────────────────────────────────────────────────────────────

# Función helper para crear vistas con encabezado/breadcrumb estándar
write_view() { cat > "$1" ; }

nfo "Vistas de gestiones..."

write_view resources/views/gestiones/index.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Gestiones Académicas')
@push('css')<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css">@endpush
@section('content')
<div class="ph"><h1>Gestiones Académicas</h1><p class="sub">CU-13 — Periodos del Curso Preuniversitario</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Gestiones</li></ol></div>
@can('crear gestiones')<div style="margin-bottom:1rem"><a href="{{ route('gestiones.create') }}" class="btn bp"><i class="fas fa-plus"></i> Nueva Gestión</a></div>@endcan
<div class="card"><div class="card-hd"><i class="fas fa-calendar-alt"></i>Gestiones registradas</div><div class="card-bd">
<div class="tw"><table id="tg" class="ct" style="width:100%">
<thead><tr><th>#</th><th>Descripción</th><th>Fecha Inicio</th><th>Fecha Fin</th><th>Estado</th><th>Acciones</th></tr></thead>
<tbody>@foreach($gestiones as $g)<tr>
<td style="color:var(--t3);font-size:.8rem">{{ $loop->iteration }}</td>
<td><strong>{{ $g->descripcion }}</strong></td>
<td>{{ $g->fecha_inicio->format('d/m/Y') }}</td>
<td>{{ $g->fecha_fin->format('d/m/Y') }}</td>
<td>@php $ec=['planificacion'=>'baz','inscripcion'=>'bna','en_curso'=>'bv','finalizado'=>'bg2']@endphp
<span class="bg {{ $ec[$g->estado]??'bg2' }}">{{ ucfirst(str_replace('_',' ',$g->estado)) }}</span></td>
<td><div class="bg3">
<a href="{{ route('gestiones.edit',$g) }}" class="btn bsm bw"><i class="fas fa-edit"></i></a>
@can('eliminar gestiones')<form action="{{ route('gestiones.destroy',$g) }}" method="POST" style="display:inline">@csrf @method('DELETE')
<button class="btn bsm bdr" onclick="return confirm('¿Eliminar?')"><i class="fas fa-trash"></i></button></form>@endcan
</div></td></tr>@endforeach</tbody></table></div></div></div>
@push('js')<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<script>$(()=>$('#tg').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},pageLength:10}))</script>@endpush
@endsection
EOF

write_view resources/views/gestiones/create.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Nueva Gestión')
@section('content')
<div class="ph"><h1>Nueva Gestión Académica</h1><ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('gestiones.index') }}">Gestiones</a></li><li>Nueva</li></ol></div>
<form action="{{ route('gestiones.store') }}" method="POST">@csrf
<div class="card" style="max-width:560px"><div class="card-hd"><i class="fas fa-calendar-plus"></i>Datos de la gestión</div><div class="card-bd">
<div style="margin-bottom:1rem"><label class="fl">Descripción <span class="rq">*</span></label>
<input type="text" name="descripcion" class="fc" value="{{ old('descripcion') }}" required placeholder="Ej: Semestre 1-2026">
<p class="fh">Formato sugerido: Semestre 1-2026, Semestre 2-2026, etc.</p></div>
<div class="fr c2g">
<div><label class="fl">Fecha de inicio <span class="rq">*</span></label><input type="date" name="fecha_inicio" class="fc" value="{{ old('fecha_inicio') }}" required></div>
<div><label class="fl">Fecha de fin <span class="rq">*</span></label><input type="date" name="fecha_fin" class="fc" value="{{ old('fecha_fin') }}" required></div>
</div>
<div style="margin-top:1rem"><label class="fl">Estado</label>
<select name="estado" class="fs"><option value="planificacion" {{ old('estado')=='planificacion'?'selected':'' }}>Planificación</option>
<option value="inscripcion" {{ old('estado')=='inscripcion'?'selected':'' }}>Inscripción</option>
<option value="en_curso" {{ old('estado')=='en_curso'?'selected':'' }}>En Curso</option>
<option value="finalizado" {{ old('estado')=='finalizado'?'selected':'' }}>Finalizado</option></select></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar</button>
<a href="{{ route('gestiones.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>
@endsection
EOF

write_view resources/views/gestiones/edit.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Editar Gestión')
@section('content')
<div class="ph"><h1>Editar Gestión</h1><ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('gestiones.index') }}">Gestiones</a></li><li>Editar</li></ol></div>
<form action="{{ route('gestiones.update',$gestion) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:560px"><div class="card-hd"><i class="fas fa-edit"></i>Editando: {{ $gestion->descripcion }}</div><div class="card-bd">
<div style="margin-bottom:1rem"><label class="fl">Descripción <span class="rq">*</span></label>
<input type="text" name="descripcion" class="fc" value="{{ old('descripcion',$gestion->descripcion) }}" required></div>
<div class="fr c2g">
<div><label class="fl">Fecha de inicio <span class="rq">*</span></label><input type="date" name="fecha_inicio" class="fc" value="{{ old('fecha_inicio',$gestion->fecha_inicio->format('Y-m-d')) }}" required></div>
<div><label class="fl">Fecha de fin <span class="rq">*</span></label><input type="date" name="fecha_fin" class="fc" value="{{ old('fecha_fin',$gestion->fecha_fin->format('Y-m-d')) }}" required></div>
</div>
<div style="margin-top:1rem"><label class="fl">Estado</label>
<select name="estado" class="fs">@foreach(['planificacion'=>'Planificación','inscripcion'=>'Inscripción','en_curso'=>'En Curso','finalizado'=>'Finalizado'] as $v=>$l)
<option value="{{ $v }}" {{ old('estado',$gestion->estado)==$v?'selected':'' }}>{{ $l }}</option>@endforeach</select></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Actualizar</button>
<a href="{{ route('gestiones.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>
@endsection
EOF

nfo "Vistas de carreras..."

write_view resources/views/carreras/index.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Carreras y Cupos')
@push('css')<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css">@endpush
@section('content')
<div class="ph"><h1>Carreras y Cupos</h1><p class="sub">CU-10, CU-11 — Las 4 carreras de la FICCT</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Carreras</li></ol></div>
@can('crear carreras')<div style="margin-bottom:1rem"><a href="{{ route('carreras.create') }}" class="btn bp"><i class="fas fa-plus"></i> Nueva Carrera</a></div>@endcan
<div class="card"><div class="card-hd"><i class="fas fa-graduation-cap"></i>Carreras de la Facultad FICCT</div><div class="card-bd">
<div class="tw"><table id="tc" class="ct" style="width:100%">
<thead><tr><th>#</th><th>Carrera</th><th>Sigla</th><th>Descripción</th><th>Estado</th><th>Acciones</th></tr></thead>
<tbody>@foreach($carreras as $c)<tr>
<td style="color:var(--t3);font-size:.8rem">{{ $loop->iteration }}</td>
<td><strong>{{ $c->nombre }}</strong></td>
<td><span class="bg baz">{{ $c->sigla??'—' }}</span></td>
<td style="font-size:.85rem;color:var(--t3)">{{ Str::limit($c->descripcion??'',55) }}</td>
<td><span class="bg {{ $c->estado?'bv':'bg2' }}">{{ $c->estado?'Activa':'Inactiva' }}</span></td>
<td><div class="bg3">
<a href="{{ route('carreras.show',$c) }}" class="btn bsm bo2" title="Ver / Cupos"><i class="fas fa-eye"></i></a>
@can('editar carreras')<a href="{{ route('carreras.edit',$c) }}" class="btn bsm bw"><i class="fas fa-edit"></i></a>@endcan
@can('eliminar carreras')<form action="{{ route('carreras.destroy',$c) }}" method="POST" style="display:inline">@csrf @method('DELETE')
<button class="btn bsm bdr" onclick="return confirm('¿Eliminar {{ $c->nombre }}?')"><i class="fas fa-trash"></i></button></form>@endcan
</div></td></tr>@endforeach</tbody></table></div></div></div>
@push('js')<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<script>$(()=>$('#tc').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},pageLength:10}))</script>@endpush
@endsection
EOF

write_view resources/views/carreras/create.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Nueva Carrera')
@section('content')
<div class="ph"><h1>Registrar Carrera</h1><ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>Nueva</li></ol></div>
<form action="{{ route('carreras.store') }}" method="POST">@csrf
<div class="card" style="max-width:600px"><div class="card-hd"><i class="fas fa-graduation-cap"></i>Datos de la carrera</div><div class="card-bd">
<div class="fr c2g">
<div><label class="fl">Nombre <span class="rq">*</span></label>
<input type="text" name="nombre" class="fc" value="{{ old('nombre') }}" required placeholder="Ej: Ingeniería Informática">
<p class="fh">Informática · Sistemas · Redes y Telecomunicaciones · Robótica</p></div>
<div><label class="fl">Sigla</label><input type="text" name="sigla" class="fc" value="{{ old('sigla') }}" placeholder="INF"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Descripción</label><textarea name="descripcion" class="fc">{{ old('descripcion') }}</textarea></div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',1)?'checked':'' }}><span>Carrera activa</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar</button>
<a href="{{ route('carreras.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
EOF

write_view resources/views/carreras/edit.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Editar Carrera')
@section('content')
<div class="ph"><h1>Editar Carrera</h1><ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>Editar</li></ol></div>
<form action="{{ route('carreras.update',$carrera) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:600px"><div class="card-hd"><i class="fas fa-edit"></i>Editando: {{ $carrera->nombre }}</div><div class="card-bd">
<div class="fr c2g">
<div><label class="fl">Nombre <span class="rq">*</span></label><input type="text" name="nombre" class="fc" value="{{ old('nombre',$carrera->nombre) }}" required></div>
<div><label class="fl">Sigla</label><input type="text" name="sigla" class="fc" value="{{ old('sigla',$carrera->sigla) }}"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Descripción</label><textarea name="descripcion" class="fc">{{ old('descripcion',$carrera->descripcion) }}</textarea></div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',$carrera->estado)?'checked':'' }}><span>Activa</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Actualizar</button>
<a href="{{ route('carreras.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
EOF

write_view resources/views/carreras/show.blade.php << 'EOF'
@extends('layouts.ap')
@section('title',$carrera->nombre)
@section('content')
<div class="ph"><h1>{{ $carrera->nombre }}</h1><p class="sub">CU-11 — Cupos por gestión académica</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>{{ $carrera->sigla }}</li></ol></div>
<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:780px;margin-bottom:1.5rem">
<div class="card"><div class="card-hd"><i class="fas fa-info-circle"></i>Información</div><div class="card-bd" style="font-size:.88rem">
<div style="margin-bottom:.6rem"><span style="color:var(--t3)">Nombre completo</span><div style="font-weight:600">{{ $carrera->nombre }}</div></div>
<div style="margin-bottom:.6rem"><span style="color:var(--t3)">Sigla</span><div><span class="bg baz">{{ $carrera->sigla??'—' }}</span></div></div>
<div><span style="color:var(--t3)">Estado</span><div><span class="bg {{ $carrera->estado?'bv':'bg2' }}">{{ $carrera->estado?'Activa':'Inactiva' }}</span></div></div>
</div></div>
<div class="card"><div class="card-hd"><i class="fas fa-sliders-h"></i>Definir cupo (CU-11)</div><div class="card-bd">
<form action="{{ route('carreras.cupos',$carrera) }}" method="POST">@csrf
<div style="margin-bottom:.75rem"><label class="fl">Gestión <span class="rq">*</span></label>
<select name="gestion_id" class="fs" required><option value="">— Seleccionar —</option>
@foreach($gestiones as $g)<option value="{{ $g->id }}">{{ $g->descripcion }}</option>@endforeach</select></div>
<div style="margin-bottom:.75rem"><label class="fl">Cupo máximo <span class="rq">*</span></label>
<input type="number" name="cantidad_maxima" class="fc" min="1" max="9999" required placeholder="Ej: 50"></div>
<button type="submit" class="btn bp bsm"><i class="fas fa-save"></i> Guardar cupo</button>
</form></div></div></div>
<div class="card" style="max-width:780px"><div class="card-hd"><i class="fas fa-table"></i>Cupos por gestión</div><div class="card-bd">
@if($cupos->isEmpty())<p style="color:var(--t3);font-size:.88rem;text-align:center;padding:1rem">Sin cupos definidos aún.</p>
@else<table class="ct"><thead><tr><th>Gestión</th><th>Cupo máximo</th><th>Registrado</th></tr></thead>
<tbody>@foreach($cupos as $q)<tr><td>{{ $q->gestion?->descripcion }}</td><td><strong style="color:var(--v)">{{ $q->cantidad_maxima }}</strong></td>
<td style="font-size:.8rem;color:var(--t3)">{{ $q->created_at->format('d/m/Y') }}</td></tr>@endforeach</tbody></table>@endif
</div></div>
<div style="margin-top:1rem;display:flex;gap:.75rem">
@can('editar carreras')<a href="{{ route('carreras.edit',$carrera) }}" class="btn bw"><i class="fas fa-edit"></i> Editar</a>@endcan
<a href="{{ route('carreras.index') }}" class="btn bo2"><i class="fas fa-arrow-left"></i> Volver</a></div>
@endsection
EOF

nfo "Vistas de materias..."

write_view resources/views/materias/index.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Materias del CUP')
@section('content')
<div class="ph"><h1>Materias del CUP</h1><p class="sub">CU-12 — Computación · Matemáticas · Física · Inglés — Ponderación 30%+30%+40%</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Materias</li></ol></div>
@can('crear materias')<div style="margin-bottom:1rem"><a href="{{ route('materias.create') }}" class="btn bp"><i class="fas fa-plus"></i> Nueva Materia</a></div>@endcan
<div class="card"><div class="card-hd"><i class="fas fa-book-open"></i>Materias del Curso Preuniversitario</div><div class="card-bd">
<div class="tw"><table class="ct">
<thead><tr><th>Ord</th><th>Materia</th><th>Área de Formación</th><th>Exam1</th><th>Exam2</th><th>Exam3</th><th>Nota Mín.</th><th>Estado</th><th>Acciones</th></tr></thead>
<tbody>@foreach($materias as $m)<tr>
<td style="color:var(--t3)">{{ $m->orden }}</td>
<td><strong>{{ $m->nombre }}</strong></td>
<td style="font-size:.84rem;color:var(--t3)">{{ $m->area_formacion??'—' }}</td>
<td style="text-align:center"><span class="bg baz">{{ $m->pond_examen1 }}%</span></td>
<td style="text-align:center"><span class="bg baz">{{ $m->pond_examen2 }}%</span></td>
<td style="text-align:center"><span class="bg bna">{{ $m->pond_examen3 }}%</span></td>
<td style="text-align:center;font-weight:600">{{ $m->nota_minima_aprobacion }}</td>
<td><span class="bg {{ $m->estado?'bv':'bg2' }}">{{ $m->estado?'Activa':'Inactiva' }}</span></td>
<td><div class="bg3">
@can('editar materias')<a href="{{ route('materias.edit',$m) }}" class="btn bsm bw"><i class="fas fa-edit"></i></a>@endcan
@can('eliminar materias')<form action="{{ route('materias.destroy',$m) }}" method="POST" style="display:inline">@csrf @method('DELETE')
<button class="btn bsm bdr" onclick="return confirm('¿Eliminar {{ $m->nombre }}?')"><i class="fas fa-trash"></i></button></form>@endcan
</div></td></tr>@endforeach</tbody></table></div></div></div>
@endsection
EOF

write_view resources/views/materias/create.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Nueva Materia')
@section('content')
<div class="ph"><h1>Registrar Materia</h1><p class="sub">Configurar ponderación de los 3 exámenes — deben sumar 100%</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('materias.index') }}">Materias</a></li><li>Nueva</li></ol></div>
<form action="{{ route('materias.store') }}" method="POST">@csrf
<div class="card" style="max-width:620px"><div class="card-hd"><i class="fas fa-book-open"></i>Datos de la materia</div><div class="card-bd">
<div class="fr c2g">
<div><label class="fl">Nombre <span class="rq">*</span></label>
<input type="text" name="nombre" class="fc" value="{{ old('nombre') }}" required placeholder="Ej: Computación">
<p class="fh">Computación · Matemáticas · Física · Inglés</p></div>
<div><label class="fl">Área de formación</label>
<input type="text" name="area_formacion" class="fc" value="{{ old('area_formacion') }}" placeholder="Ej: Computación / Informática">
<p class="fh">Usado para validar qué docente puede dictar esta materia</p></div>
</div>
<div style="margin-top:1rem"><label class="fl">Descripción</label><textarea name="descripcion" class="fc">{{ old('descripcion') }}</textarea></div>
<div style="margin-top:1.25rem"><div class="fs-t">Ponderación de los 3 exámenes</div>
<p style="font-size:.83rem;color:var(--t3);margin-bottom:.75rem">Los tres porcentajes deben sumar exactamente 100. Por defecto: 30%+30%+40%</p>
<div class="fr c3g">
<div><label class="fl">Examen 1 (%) <span class="rq">*</span></label><input type="number" name="pond_examen1" id="p1" class="fc" value="{{ old('pond_examen1',30) }}" min="1" max="98" required></div>
<div><label class="fl">Examen 2 (%) <span class="rq">*</span></label><input type="number" name="pond_examen2" id="p2" class="fc" value="{{ old('pond_examen2',30) }}" min="1" max="98" required></div>
<div><label class="fl">Examen 3 (%) <span class="rq">*</span></label><input type="number" name="pond_examen3" id="p3" class="fc" value="{{ old('pond_examen3',40) }}" min="1" max="98" required></div>
</div>
<div id="ptot" style="margin-top:.5rem;font-size:.85rem;font-weight:600"></div></div>
<div class="fr c2g" style="margin-top:1rem">
<div><label class="fl">Nota mínima aprobación <span class="rq">*</span></label><input type="number" name="nota_minima_aprobacion" class="fc" value="{{ old('nota_minima_aprobacion',60) }}" min="1" max="100" required></div>
<div><label class="fl">Orden visualización</label><input type="number" name="orden" class="fc" value="{{ old('orden',0) }}" min="0"></div>
</div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',1)?'checked':'' }}><span>Materia activa</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar</button>
<a href="{{ route('materias.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>
@push('js')<script>
function upd(){var s=+document.getElementById('p1').value+(+document.getElementById('p2').value)+(+document.getElementById('p3').value);var e=document.getElementById('ptot');e.textContent='Total: '+s+'%';e.style.color=s===100?'var(--v3)':'var(--d)';}
['p1','p2','p3'].forEach(function(i){document.getElementById(i).addEventListener('input',upd)});upd();
</script>@endpush
@endsection
EOF

write_view resources/views/materias/edit.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Editar Materia')
@section('content')
<div class="ph"><h1>Editar Materia: {{ $materia->nombre }}</h1>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('materias.index') }}">Materias</a></li><li>Editar</li></ol></div>
<form action="{{ route('materias.update',$materia) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:620px"><div class="card-hd"><i class="fas fa-edit"></i>Editando: {{ $materia->nombre }}</div><div class="card-bd">
<div class="fr c2g">
<div><label class="fl">Nombre <span class="rq">*</span></label><input type="text" name="nombre" class="fc" value="{{ old('nombre',$materia->nombre) }}" required></div>
<div><label class="fl">Área de formación</label><input type="text" name="area_formacion" class="fc" value="{{ old('area_formacion',$materia->area_formacion) }}"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Descripción</label><textarea name="descripcion" class="fc">{{ old('descripcion',$materia->descripcion) }}</textarea></div>
<div style="margin-top:1.25rem"><div class="fs-t">Ponderación de los 3 exámenes</div>
<div class="fr c3g">
<div><label class="fl">Examen 1 (%)</label><input type="number" name="pond_examen1" id="p1" class="fc" value="{{ old('pond_examen1',$materia->pond_examen1) }}" min="1" max="98" required></div>
<div><label class="fl">Examen 2 (%)</label><input type="number" name="pond_examen2" id="p2" class="fc" value="{{ old('pond_examen2',$materia->pond_examen2) }}" min="1" max="98" required></div>
<div><label class="fl">Examen 3 (%)</label><input type="number" name="pond_examen3" id="p3" class="fc" value="{{ old('pond_examen3',$materia->pond_examen3) }}" min="1" max="98" required></div>
</div>
<div id="ptot" style="margin-top:.5rem;font-size:.85rem;font-weight:600"></div></div>
<div class="fr c2g" style="margin-top:1rem">
<div><label class="fl">Nota mínima</label><input type="number" name="nota_minima_aprobacion" class="fc" value="{{ old('nota_minima_aprobacion',$materia->nota_minima_aprobacion) }}" min="1" max="100" required></div>
<div><label class="fl">Orden</label><input type="number" name="orden" class="fc" value="{{ old('orden',$materia->orden) }}" min="0"></div>
</div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',$materia->estado)?'checked':'' }}><span>Activa</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Actualizar</button>
<a href="{{ route('materias.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>
@push('js')<script>
function upd(){var s=+document.getElementById('p1').value+(+document.getElementById('p2').value)+(+document.getElementById('p3').value);var e=document.getElementById('ptot');e.textContent='Total: '+s+'%';e.style.color=s===100?'var(--v3)':'var(--d)';}
['p1','p2','p3'].forEach(function(i){document.getElementById(i).addEventListener('input',upd)});upd();
</script>@endpush
@endsection
EOF

nfo "Vistas de docentes..."

write_view resources/views/docentes/index.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Docentes')
@push('css')<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css">@endpush
@section('content')
<div class="ph"><h1>Docentes</h1><p class="sub">CU-14 a CU-16 — Máximo 4 grupos por docente</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Docentes</li></ol></div>
@can('crear docentes')<div style="margin-bottom:1rem"><a href="{{ route('docentes.create') }}" class="btn bp"><i class="fas fa-user-plus"></i> Registrar Docente</a></div>@endcan
<div class="card"><div class="card-hd"><i class="fas fa-chalkboard-teacher"></i>Docentes contratados para el CUP</div><div class="card-bd">
<div class="tw"><table id="td" class="ct" style="width:100%">
<thead><tr><th>#</th><th>CI</th><th>Apellidos y Nombres</th><th>Área</th><th>Título</th><th>Maestría</th><th>Estado</th><th>Acciones</th></tr></thead>
<tbody>@foreach($docentes as $d)<tr>
<td style="color:var(--t3);font-size:.8rem">{{ $loop->iteration }}</td>
<td style="font-family:'Courier New',monospace;font-size:.84rem">{{ $d->ci }}</td>
<td><strong>{{ $d->apellidos }}</strong>, {{ $d->nombres }}</td>
<td style="font-size:.83rem">{{ $d->area_formacion??'—' }}</td>
<td style="font-size:.81rem;color:var(--t3)">{{ Str::limit($d->titulo_profesional??'',35) }}</td>
<td style="font-size:.81rem;color:var(--t3)">{{ $d->maestria ? '✓ '.Str::limit($d->maestria,25) : '—' }}</td>
<td><span class="bg {{ $d->estado?'bv':'bg2' }}">{{ $d->estado?'Activo':'Inactivo' }}</span></td>
<td><div class="bg3">
<a href="{{ route('docentes.show',$d) }}" class="btn bsm bo2"><i class="fas fa-eye"></i></a>
@can('editar docentes')<a href="{{ route('docentes.edit',$d) }}" class="btn bsm bw"><i class="fas fa-edit"></i></a>@endcan
@can('eliminar docentes')<form action="{{ route('docentes.destroy',$d) }}" method="POST" style="display:inline">@csrf @method('DELETE')
<button class="btn bsm bdr" onclick="return confirm('¿Desactivar?')"><i class="fas fa-ban"></i></button></form>@endcan
</div></td></tr>@endforeach</tbody></table></div></div></div>
@push('js')<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<script>$(()=>$('#td').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},order:[[2,'asc']],pageLength:15}))</script>@endpush
@endsection
EOF

write_view resources/views/docentes/create.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Registrar Docente')
@section('content')
<div class="ph"><h1>Registrar Docente</h1><p class="sub">CU-14 — Requisitos: título profesional, maestría y diplomado en educación superior</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Registrar</li></ol></div>
<form action="{{ route('docentes.store') }}" method="POST">@csrf
<div class="card" style="max-width:780px"><div class="card-hd"><i class="fas fa-chalkboard-teacher"></i>Perfil del docente</div><div class="card-bd">
<div class="fs-t">Datos personales</div>
<div class="fr c3g">
<div><label class="fl">CI <span class="rq">*</span></label><input type="text" name="ci" class="fc" value="{{ old('ci') }}" required></div>
<div><label class="fl">Nombres <span class="rq">*</span></label><input type="text" name="nombres" class="fc" value="{{ old('nombres') }}" required></div>
<div><label class="fl">Apellidos <span class="rq">*</span></label><input type="text" name="apellidos" class="fc" value="{{ old('apellidos') }}" required></div>
<div><label class="fl">Teléfono</label><input type="text" name="telefono" class="fc" value="{{ old('telefono') }}"></div>
<div><label class="fl">Correo electrónico</label><input type="email" name="email" class="fc" value="{{ old('email') }}"></div>
<div><label class="fl">Área de formación <span class="rq">*</span></label>
<select name="area_formacion" class="fs" required>
<option value="">— Seleccionar —</option>
@foreach(['Computación / Informática','Matemáticas','Física','Inglés / Idiomas','Redes y Telecomunicaciones','Electrónica','Otra'] as $a)
<option value="{{ $a }}" {{ old('area_formacion')==$a?'selected':'' }}>{{ $a }}</option>@endforeach
</select>
<p class="fh">Determina qué materias puede dictar (CU-15)</p></div>
</div>
<div class="fs-t" style="margin-top:1.25rem">Perfil profesional (requisitos obligatorios de contratación)</div>
<div class="al al-w" style="margin-bottom:1rem"><i class="fas fa-info-circle"></i> Los tres primeros campos son obligatorios según el reglamento de contratación del CUP.</div>
<div class="fr c2g">
<div><label class="fl">Título profesional <span class="rq">*</span></label><input type="text" name="titulo_profesional" class="fc" value="{{ old('titulo_profesional') }}" required placeholder="Ej: Ing. en Sistemas de Información"></div>
<div><label class="fl">Maestría <span class="rq">*</span></label><input type="text" name="maestria" class="fc" value="{{ old('maestria') }}" required placeholder="Ej: Maestría en Tecnologías de la Información"></div>
<div><label class="fl">Diplomado en Educación Superior <span class="rq">*</span></label><input type="text" name="diplomado_educacion_superior" class="fc" value="{{ old('diplomado_educacion_superior') }}" required placeholder="Ej: Diplomado en Docencia Universitaria"></div>
<div><label class="fl">Certificación de Inglés</label><input type="text" name="certificacion_ingles" class="fc" value="{{ old('certificacion_ingles') }}" placeholder="Ej: TOEFL 550, Cambridge B2"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Otras certificaciones</label><textarea name="otras_certificaciones" class="fc" placeholder="Cursos, diplomados adicionales, certificaciones técnicas...">{{ old('otras_certificaciones') }}</textarea></div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',1)?'checked':'' }}><span>Docente activo</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Registrar Docente</button>
<a href="{{ route('docentes.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
EOF

write_view resources/views/docentes/edit.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Editar Docente')
@section('content')
<div class="ph"><h1>Editar Docente</h1><ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Editar</li></ol></div>
<form action="{{ route('docentes.update',$docente) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:780px"><div class="card-hd"><i class="fas fa-edit"></i>Editando: {{ $docente->nombre_completo }}</div><div class="card-bd">
<div class="fs-t">Datos personales</div>
<div class="fr c3g">
<div><label class="fl">CI <span class="rq">*</span></label><input type="text" name="ci" class="fc" value="{{ old('ci',$docente->ci) }}" required></div>
<div><label class="fl">Nombres <span class="rq">*</span></label><input type="text" name="nombres" class="fc" value="{{ old('nombres',$docente->nombres) }}" required></div>
<div><label class="fl">Apellidos <span class="rq">*</span></label><input type="text" name="apellidos" class="fc" value="{{ old('apellidos',$docente->apellidos) }}" required></div>
<div><label class="fl">Teléfono</label><input type="text" name="telefono" class="fc" value="{{ old('telefono',$docente->telefono) }}"></div>
<div><label class="fl">Email</label><input type="email" name="email" class="fc" value="{{ old('email',$docente->email) }}"></div>
<div><label class="fl">Área de formación <span class="rq">*</span></label>
<select name="area_formacion" class="fs" required>
@foreach(['Computación / Informática','Matemáticas','Física','Inglés / Idiomas','Redes y Telecomunicaciones','Electrónica','Otra'] as $a)
<option value="{{ $a }}" {{ old('area_formacion',$docente->area_formacion)==$a?'selected':'' }}>{{ $a }}</option>@endforeach
</select></div>
</div>
<div class="fs-t" style="margin-top:1.25rem">Perfil profesional</div>
<div class="fr c2g">
<div><label class="fl">Título profesional <span class="rq">*</span></label><input type="text" name="titulo_profesional" class="fc" value="{{ old('titulo_profesional',$docente->titulo_profesional) }}" required></div>
<div><label class="fl">Maestría <span class="rq">*</span></label><input type="text" name="maestria" class="fc" value="{{ old('maestria',$docente->maestria) }}" required></div>
<div><label class="fl">Diplomado en Educación Superior <span class="rq">*</span></label><input type="text" name="diplomado_educacion_superior" class="fc" value="{{ old('diplomado_educacion_superior',$docente->diplomado_educacion_superior) }}" required></div>
<div><label class="fl">Certificación de Inglés</label><input type="text" name="certificacion_ingles" class="fc" value="{{ old('certificacion_ingles',$docente->certificacion_ingles) }}"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Otras certificaciones</label><textarea name="otras_certificaciones" class="fc">{{ old('otras_certificaciones',$docente->otras_certificaciones) }}</textarea></div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',$docente->estado)?'checked':'' }}><span>Activo</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Actualizar</button>
<a href="{{ route('docentes.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
EOF

write_view resources/views/docentes/show.blade.php << 'EOF'
@extends('layouts.ap')
@section('title',$docente->nombre_completo)
@section('content')
<div class="ph"><h1>{{ $docente->nombre_completo }}</h1><p class="sub">CU-15 — Perfil profesional del docente</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Perfil</li></ol></div>
<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:780px">
<div class="card"><div class="card-hd"><i class="fas fa-user"></i>Datos personales</div><div class="card-bd" style="font-size:.88rem">
@foreach(['CI'=>$docente->ci,'Nombres'=>$docente->nombres,'Apellidos'=>$docente->apellidos,'Teléfono'=>$docente->telefono,'Email'=>$docente->email,'Área de formación'=>$docente->area_formacion,'Estado'=>null] as $lbl=>$v)
@if($lbl==='Estado')
<div style="display:flex;justify-content:space-between;padding:.4rem 0;border-bottom:1px solid var(--cr2)">
<span style="color:var(--t3)">Estado</span>
<span class="bg {{ $docente->estado?'bv':'bg2' }}">{{ $docente->estado?'Activo':'Inactivo' }}</span>
</div>
@else
<div style="display:flex;justify-content:space-between;padding:.4rem 0;border-bottom:1px solid var(--cr2)">
<span style="color:var(--t3)">{{ $lbl }}</span><span style="font-weight:500">{{ $v??'—' }}</span>
</div>
@endif
@endforeach
</div></div>
<div class="card"><div class="card-hd"><i class="fas fa-certificate"></i>Perfil profesional</div><div class="card-bd" style="font-size:.88rem">
@foreach(['Título profesional'=>$docente->titulo_profesional,'Maestría'=>$docente->maestria,'Diplomado en Edu. Superior'=>$docente->diplomado_educacion_superior,'Certif. de Inglés'=>$docente->certificacion_ingles,'Otras certificaciones'=>$docente->otras_certificaciones] as $l=>$v)
@if($v)
<div style="margin-bottom:.75rem">
<div style="font-size:.72rem;text-transform:uppercase;color:var(--t3);margin-bottom:.2rem">{{ $l }}</div>
<div style="font-weight:600">{{ $v }}</div>
</div>
@endif
@endforeach
</div></div>
</div>
<div style="margin-top:1rem;display:flex;gap:.75rem">
@can('editar docentes')<a href="{{ route('docentes.edit',$docente) }}" class="btn bw"><i class="fas fa-edit"></i> Editar</a>@endcan
<a href="{{ route('docentes.index') }}" class="btn bo2"><i class="fas fa-arrow-left"></i> Volver</a>
</div>
@endsection
EOF

nfo "Vistas de postulantes..."

write_view resources/views/postulantes/index.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Postulantes')
@push('css')<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css">@endpush
@section('content')
<div class="ph"><h1>Registro de Postulantes</h1><p class="sub">CU-05 a CU-09 — Inscripción al Curso Preuniversitario (CUP)</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Postulantes</li></ol></div>
@can('crear postulantes')<div style="margin-bottom:1rem"><a href="{{ route('postulantes.create') }}" class="btn bp"><i class="fas fa-user-plus"></i> Registrar Postulante</a></div>@endcan
<div class="card"><div class="card-hd"><i class="fas fa-users"></i>Postulantes inscritos</div><div class="card-bd">
<div class="tw"><table id="tp" class="ct" style="width:100%">
<thead><tr><th>#</th><th>CI</th><th>Apellidos y Nombres</th><th>1ª Opción</th><th>2ª Opción</th><th>Documentos</th><th>Estado</th><th>Acciones</th></tr></thead>
<tbody>@foreach($postulantes as $p)<tr>
<td style="color:var(--t3);font-size:.8rem">{{ $loop->iteration }}</td>
<td style="font-family:'Courier New',monospace;font-size:.84rem">{{ $p->ci }}</td>
<td><strong>{{ $p->apellidos }}</strong>, {{ $p->nombres }}</td>
<td style="font-size:.84rem">{{ $p->primeraOpcion?->nombre??'—' }}</td>
<td style="font-size:.84rem">{{ $p->segundaOpcion?->nombre??'—' }}</td>
<td style="text-align:center">
@php $dc=($p->doc_ci?1:0)+($p->doc_libreta_colegio?1:0)+($p->doc_titulo_bachiller?1:0);@endphp
<span class="bg {{ $dc==3?'bv':($dc>0?'bna':'bd') }}">{{ $dc }}/3</span>
</td>
<td><span class="bg {{ $p->estado_badge }}">{{ ucfirst(str_replace('_',' ',$p->estado)) }}</span></td>
<td><div class="bg3">
<a href="{{ route('postulantes.show',$p) }}" class="btn bsm bo2"><i class="fas fa-eye"></i></a>
@can('editar postulantes')<a href="{{ route('postulantes.edit',$p) }}" class="btn bsm bw"><i class="fas fa-edit"></i></a>@endcan
@can('eliminar postulantes')<form action="{{ route('postulantes.destroy',$p) }}" method="POST" style="display:inline">@csrf @method('DELETE')
<button class="btn bsm bdr" onclick="return confirm('¿Eliminar a {{ $p->nombre_completo }}?')"><i class="fas fa-trash"></i></button></form>@endcan
</div></td></tr>@endforeach</tbody></table></div></div></div>
@push('js')<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<script>$(()=>$('#tp').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},order:[[2,'asc']],pageLength:20}))</script>@endpush
@endsection
EOF

write_view resources/views/postulantes/create.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Registrar Postulante')
@section('content')
<div class="ph"><h1>Registrar Postulante</h1><p class="sub">CU-05 — Registro con validación de requisitos obligatorios</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('postulantes.index') }}">Postulantes</a></li><li>Registrar</li></ol></div>
<form action="{{ route('postulantes.store') }}" method="POST">@csrf
<div class="card" style="max-width:840px"><div class="card-hd"><i class="fas fa-user-plus"></i>Datos del postulante</div><div class="card-bd">

<div class="fs-t">Gestión académica</div>
<div class="fr c2g" style="margin-bottom:1rem">
<div><label class="fl">Gestión <span class="rq">*</span></label>
<select name="gestion_id" class="fs" required><option value="">— Seleccionar —</option>
@foreach($gestiones as $g)<option value="{{ $g->id }}" {{ old('gestion_id')==$g->id?'selected':'' }}>{{ $g->descripcion }}</option>@endforeach
</select></div>
</div>

<div class="fs-t">Datos personales</div>
<div class="fr c3g">
<div><label class="fl">CI <span class="rq">*</span></label><input type="text" name="ci" class="fc" value="{{ old('ci') }}" required placeholder="Ej: 12345678"></div>
<div><label class="fl">Nombres <span class="rq">*</span></label><input type="text" name="nombres" class="fc" value="{{ old('nombres') }}" required></div>
<div><label class="fl">Apellidos <span class="rq">*</span></label><input type="text" name="apellidos" class="fc" value="{{ old('apellidos') }}" required></div>
<div><label class="fl">Fecha de nacimiento</label><input type="date" name="fecha_nacimiento" class="fc" value="{{ old('fecha_nacimiento') }}"></div>
<div><label class="fl">Sexo</label>
<select name="sexo" class="fs"><option value="">—</option>
<option value="M" {{ old('sexo')=='M'?'selected':'' }}>Masculino</option>
<option value="F" {{ old('sexo')=='F'?'selected':'' }}>Femenino</option>
<option value="Otro" {{ old('sexo')=='Otro'?'selected':'' }}>Otro</option></select></div>
<div><label class="fl">Teléfono</label><input type="text" name="telefono" class="fc" value="{{ old('telefono') }}"></div>
<div><label class="fl">Correo electrónico</label><input type="email" name="email" class="fc" value="{{ old('email') }}"></div>
<div><label class="fl">Colegio de procedencia</label><input type="text" name="colegio_procedencia" class="fc" value="{{ old('colegio_procedencia') }}"></div>
<div><label class="fl">Ciudad</label><input type="text" name="ciudad" class="fc" value="{{ old('ciudad') }}" placeholder="Ej: Santa Cruz"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Dirección</label><input type="text" name="direccion" class="fc" value="{{ old('direccion') }}"></div>

<div class="fs-t" style="margin-top:1.25rem">Opciones de carrera (CU-08)</div>
<div class="fr c2g">
<div><label class="fl">1ª Opción de carrera <span class="rq">*</span></label>
<select name="primera_opcion_id" class="fs" required><option value="">— Seleccionar —</option>
@foreach($carreras as $c)<option value="{{ $c->id }}" {{ old('primera_opcion_id')==$c->id?'selected':'' }}>{{ $c->nombre }}</option>@endforeach</select></div>
<div><label class="fl">2ª Opción de carrera <span class="rq">*</span></label>
<select name="segunda_opcion_id" class="fs" required><option value="">— Seleccionar —</option>
@foreach($carreras as $c)<option value="{{ $c->id }}" {{ old('segunda_opcion_id')==$c->id?'selected':'' }}>{{ $c->nombre }}</option>@endforeach</select>
<p class="fh">Debe ser diferente a la primera opción.</p></div>
</div>

<div class="fs-t" style="margin-top:1.25rem">Documentos requeridos (CU-06)</div>
<div class="al al-w" style="margin-bottom:.75rem"><i class="fas fa-info-circle"></i> Los tres documentos son obligatorios para completar la inscripción (CI, libreta de colegio y título de bachiller).</div>
<div style="display:flex;flex-direction:column;gap:.5rem">
<label class="fck"><input type="checkbox" name="doc_ci" value="1" {{ old('doc_ci')?'checked':'' }}><span>Fotocopia de Cédula de Identidad (CI)</span></label>
<label class="fck"><input type="checkbox" name="doc_libreta_colegio" value="1" {{ old('doc_libreta_colegio')?'checked':'' }}><span>Libreta de colegio</span></label>
<label class="fck"><input type="checkbox" name="doc_titulo_bachiller" value="1" {{ old('doc_titulo_bachiller')?'checked':'' }}><span>Título de Bachiller</span></label>
</div>

<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Registrar Postulante</button>
<a href="{{ route('postulantes.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
EOF

write_view resources/views/postulantes/edit.blade.php << 'EOF'
@extends('layouts.ap')
@section('title','Editar Postulante')
@section('content')
<div class="ph"><h1>Editar Postulante</h1><p class="sub">Modificar datos antes del cierre de inscripciones</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('postulantes.index') }}">Postulantes</a></li><li>Editar</li></ol></div>
<form action="{{ route('postulantes.update',$postulante) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:840px"><div class="card-hd"><i class="fas fa-user-edit"></i>Editando: {{ $postulante->nombre_completo }}</div><div class="card-bd">
<div class="fs-t">Gestión académica</div>
<div class="fr c2g" style="margin-bottom:1rem"><div><label class="fl">Gestión <span class="rq">*</span></label>
<select name="gestion_id" class="fs" required><option value="">— Seleccionar —</option>
@foreach($gestiones as $g)<option value="{{ $g->id }}" {{ old('gestion_id',$postulante->gestion_id)==$g->id?'selected':'' }}>{{ $g->descripcion }}</option>@endforeach</select></div></div>
<div class="fs-t">Datos personales</div>
<div class="fr c3g">
<div><label class="fl">CI <span class="rq">*</span></label><input type="text" name="ci" class="fc" value="{{ old('ci',$postulante->ci) }}" required></div>
<div><label class="fl">Nombres <span class="rq">*</span></label><input type="text" name="nombres" class="fc" value="{{ old('nombres',$postulante->nombres) }}" required></div>
<div><label class="fl">Apellidos <span class="rq">*</span></label><input type="text" name="apellidos" class="fc" value="{{ old('apellidos',$postulante->apellidos) }}" required></div>
<div><label class="fl">Fecha de nacimiento</label><input type="date" name="fecha_nacimiento" class="fc" value="{{ old('fecha_nacimiento',$postulante->fecha_nacimiento?->format('Y-m-d')) }}"></div>
<div><label class="fl">Sexo</label><select name="sexo" class="fs"><option value="">—</option>
<option value="M" {{ old('sexo',$postulante->sexo)=='M'?'selected':'' }}>Masculino</option>
<option value="F" {{ old('sexo',$postulante->sexo)=='F'?'selected':'' }}>Femenino</option>
<option value="Otro" {{ old('sexo',$postulante->sexo)=='Otro'?'selected':'' }}>Otro</option></select></div>
<div><label class="fl">Teléfono</label><input type="text" name="telefono" class="fc" value="{{ old('telefono',$postulante->telefono) }}"></div>
<div><label class="fl">Correo</label><input type="email" name="email" class="fc" value="{{ old('email',$postulante->email) }}"></div>
<div><label class="fl">Colegio</label><input type="text" name="colegio_procedencia" class="fc" value="{{ old('colegio_procedencia',$postulante->colegio_procedencia) }}"></div>
<div><label class="fl">Ciudad</label><input type="text" name="ciudad" class="fc" value="{{ old('ciudad',$postulante->ciudad) }}"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Dirección</label><input type="text" name="direccion" class="fc" value="{{ old('direccion',$postulante->direccion) }}"></div>
<div class="fs-t" style="margin-top:1.25rem">Opciones de carrera</div>
<div class="fr c2g">
<div><label class="fl">1ª Opción <span class="rq">*</span></label><select name="primera_opcion_id" class="fs" required>
@foreach($carreras as $c)<option value="{{ $c->id }}" {{ old('primera_opcion_id',$postulante->primera_opcion_id)==$c->id?'selected':'' }}>{{ $c->nombre }}</option>@endforeach</select></div>
<div><label class="fl">2ª Opción <span class="rq">*</span></label><select name="segunda_opcion_id" class="fs" required>
@foreach($carreras as $c)<option value="{{ $c->id }}" {{ old('segunda_opcion_id',$postulante->segunda_opcion_id)==$c->id?'selected':'' }}>{{ $c->nombre }}</option>@endforeach</select></div>
</div>
<div class="fs-t" style="margin-top:1.25rem">Documentos entregados</div>
<div style="display:flex;flex-direction:column;gap:.5rem">
<label class="fck"><input type="checkbox" name="doc_ci" value="1" {{ old('doc_ci',$postulante->doc_ci)?'checked':'' }}><span>CI</span></label>
<label class="fck"><input type="checkbox" name="doc_libreta_colegio" value="1" {{ old('doc_libreta_colegio',$postulante->doc_libreta_colegio)?'checked':'' }}><span>Libreta de colegio</span></label>
<label class="fck"><input type="checkbox" name="doc_titulo_bachiller" value="1" {{ old('doc_titulo_bachiller',$postulante->doc_titulo_bachiller)?'checked':'' }}><span>Título de Bachiller</span></label>
</div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Actualizar</button>
<a href="{{ route('postulantes.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
EOF

write_view resources/views/postulantes/show.blade.php << 'EOF'
@extends('layouts.ap')
@section('title',$postulante->nombre_completo)
@section('content')
<div class="ph"><h1>{{ $postulante->nombre_completo }}</h1><p class="sub">CU-09 — Estado del postulante</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('postulantes.index') }}">Postulantes</a></li><li>Detalle</li></ol></div>
<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:840px">
<div class="card"><div class="card-hd"><i class="fas fa-user"></i>Datos personales</div><div class="card-bd" style="font-size:.87rem">
@foreach(['CI'=>$postulante->ci,'Nombres'=>$postulante->nombres,'Apellidos'=>$postulante->apellidos,'Fecha de nac.'=>$postulante->fecha_nacimiento?->format('d/m/Y'),'Sexo'=>$postulante->sexo,'Teléfono'=>$postulante->telefono,'Correo'=>$postulante->email,'Colegio'=>$postulante->colegio_procedencia,'Ciudad'=>$postulante->ciudad,'Dirección'=>$postulante->direccion] as $l=>$v)
<div style="display:flex;justify-content:space-between;padding:.4rem 0;border-bottom:1px solid var(--cr2)">
<span style="color:var(--t3)">{{ $l }}</span><span style="font-weight:500">{{ $v??'—' }}</span></div>
@endforeach
</div></div>
<div>
<div class="card" style="margin-bottom:1rem"><div class="card-hd"><i class="fas fa-graduation-cap"></i>Opciones de carrera</div><div class="card-bd" style="font-size:.88rem">
<div style="margin-bottom:.6rem"><span style="font-size:.72rem;text-transform:uppercase;color:var(--t3)">1ª OPCIÓN</span>
<div style="font-weight:600;color:var(--v)">{{ $postulante->primeraOpcion?->nombre??'—' }}</div></div>
<div><span style="font-size:.72rem;text-transform:uppercase;color:var(--t3)">2ª OPCIÓN</span>
<div style="font-weight:600">{{ $postulante->segundaOpcion?->nombre??'—' }}</div></div>
</div></div>
<div class="card" style="margin-bottom:1rem"><div class="card-hd"><i class="fas fa-file-check"></i>Documentos (CU-06)</div><div class="card-bd" style="font-size:.88rem;display:flex;flex-direction:column;gap:.4rem">
@foreach(['doc_ci'=>'CI','doc_libreta_colegio'=>'Libreta de colegio','doc_titulo_bachiller'=>'Título de Bachiller'] as $col=>$lbl)
<div><i class="fas fa-{{ $postulante->$col ? 'check-circle':'times-circle' }}" style="color:{{ $postulante->$col ? 'var(--v3)':'var(--d)' }}"></i> {{ $lbl }}</div>
@endforeach
</div></div>
<div class="card"><div class="card-hd"><i class="fas fa-info-circle"></i>Estado (CU-09)</div><div class="card-bd" style="text-align:center;padding:1.5rem">
<span class="bg {{ $postulante->estado_badge }}" style="font-size:.9rem;padding:.4rem 1rem">
{{ ucfirst(str_replace('_',' ',$postulante->estado)) }}</span>
@if($postulante->promedio_general)
<div style="margin-top:.75rem;font-size:.88rem;color:var(--t3)">Promedio: <strong>{{ number_format($postulante->promedio_general,2) }}</strong></div>
@endif
</div></div>
</div></div>
<div style="margin-top:1rem;display:flex;gap:.75rem">
@can('editar postulantes')<a href="{{ route('postulantes.edit',$postulante) }}" class="btn bw"><i class="fas fa-edit"></i> Editar</a>@endcan
<a href="{{ route('postulantes.index') }}" class="btn bo2"><i class="fas fa-arrow-left"></i> Volver</a></div>
@endsection
EOF

ok "Todas las vistas creadas"

# ─────────────────────────────────────────────────────────────────────────────
#  14. RUTAS
# ─────────────────────────────────────────────────────────────────────────────
nfo "routes/web.php..."
cat > routes/web.php << 'EOF'
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
EOF
ok "routes/web.php"

# ─────────────────────────────────────────────────────────────────────────────
#  15. SEEDERS
# ─────────────────────────────────────────────────────────────────────────────
nfo "Seeders..."

cat > database/seeders/PermissionSeeder.php << 'EOF'
<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
class PermissionSeeder extends Seeder {
    public function run(): void {
        $perms = [
            'ver usuarios','crear usuarios','editar usuarios','eliminar usuarios',
            'ver roles','crear roles','editar roles','eliminar roles',
            'ver bitacora',
            'ver postulantes','crear postulantes','editar postulantes','eliminar postulantes',
            'ver gestiones','crear gestiones','editar gestiones','eliminar gestiones',
            'ver carreras','crear carreras','editar carreras','eliminar carreras',
            'ver materias','crear materias','editar materias','eliminar materias',
            'ver docentes','crear docentes','editar docentes','eliminar docentes',
            'ver grupos','crear grupos','editar grupos','eliminar grupos',
            'ver notas','crear notas','editar notas',
            'procesar admision','ver reportes',
        ];
        foreach($perms as $p) Permission::firstOrCreate(['name'=>$p,'guard_name'=>'web']);
    }
}
EOF

cat > database/seeders/RolesSeeder.php << 'EOF'
<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\{Role,Permission};
class RolesSeeder extends Seeder {
    public function run(): void {
        $admin = Role::firstOrCreate(['name'=>'Administrador del Sistema','guard_name'=>'web']);
        $admin->syncPermissions(Permission::all());

        $doc = Role::firstOrCreate(['name'=>'Docente','guard_name'=>'web']);
        $doc->syncPermissions(['ver grupos','ver postulantes','ver notas','crear notas','editar notas']);

        $pos = Role::firstOrCreate(['name'=>'Postulante','guard_name'=>'web']);
        $pos->syncPermissions(['ver postulantes']);
    }
}
EOF

cat > database/seeders/CupDataSeeder.php << 'EOF'
<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
class CupDataSeeder extends Seeder {
    public function run(): void {
        DB::table('gestiones')->insertOrIgnore([
            ['descripcion'=>'Semestre 1-2026','fecha_inicio'=>'2026-01-15','fecha_fin'=>'2026-06-30','estado'=>'en_curso','created_at'=>now(),'updated_at'=>now()],
            ['descripcion'=>'Semestre 2-2026','fecha_inicio'=>'2026-07-15','fecha_fin'=>'2026-12-15','estado'=>'planificacion','created_at'=>now(),'updated_at'=>now()],
        ]);
        DB::table('carreras')->insertOrIgnore([
            ['nombre'=>'Ingeniería Informática',                  'sigla'=>'INF','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Ingeniería de Sistemas',                  'sigla'=>'SIS','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Ingeniería en Redes y Telecomunicaciones','sigla'=>'RYT','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Ingeniería en Robótica',                  'sigla'=>'ROB','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
        ]);
        DB::table('materias')->insertOrIgnore([
            ['nombre'=>'Computación', 'area_formacion'=>'Computación / Informática','pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>1,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Matemáticas', 'area_formacion'=>'Matemáticas',              'pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>2,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Física',      'area_formacion'=>'Física',                   'pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>3,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Inglés',      'area_formacion'=>'Inglés / Idiomas',         'pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>4,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
        ]);
    }
}
EOF

cat > database/seeders/DatabaseSeeder.php << 'EOF'
<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
class DatabaseSeeder extends Seeder {
    public function run(): void {
        $this->call([
            PermissionSeeder::class,
            RolesSeeder::class,
            UsuariosSeeder::class,
            CupDataSeeder::class,
        ]);
    }
}
EOF
ok "Seeders"

# ─────────────────────────────────────────────────────────────────────────────
#  16. Páginas de error simples (para que no falle al cargar)
# ─────────────────────────────────────────────────────────────────────────────
for code in 401 404 500; do
cat > resources/views/pages/${code}.blade.php << BLADE
<!DOCTYPE html><html lang="es"><head><meta charset="utf-8"><title>${code}</title>
<link href="{{ asset('css/cup.css') }}" rel="stylesheet"></head>
<body style="min-height:100vh;display:grid;place-items:center;background:var(--cr)">
<div style="text-align:center">
<div style="font-family:var(--fd);font-size:5rem;font-weight:700;color:var(--v);line-height:1">${code}</div>
<div style="color:var(--t3);margin:.5rem 0 1.5rem">@if($code==401) No autorizado @elseif($code==404) Página no encontrada @else Error del servidor @endif</div>
<a href="/" style="color:var(--v3)"><i class="fas fa-arrow-left"></i> Volver al inicio</a>
</div></body></html>
BLADE
done
ok "Páginas de error"

# ─────────────────────────────────────────────────────────────────────────────
#  17. Caché
# ─────────────────────────────────────────────────────────────────────────────
nfo "Limpiando caché..."
php artisan config:clear 2>/dev/null||true
php artisan route:clear  2>/dev/null||true
php artisan view:clear   2>/dev/null||true
php artisan cache:clear  2>/dev/null||true
ok "Caché limpiada"

# ─────────────────────────────────────────────────────────────────────────────
#  RESUMEN
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${G}══════════════════════════════════════════════════════════════════${N}"
echo -e "${G}  CICLO 1 — 50% COMPLETADO ✓${N}"
echo -e "${G}══════════════════════════════════════════════════════════════════${N}"
echo ""
echo -e "  ${C}ENTREGADO:${N}"
echo "   ✓ Diseño Institucional Andino (verde oliva + oro + crema)"
echo "   ✓ Sidebar con los 6 módulos del documento PDF"
echo "   ✓ BitacoraMiddleware en bootstrap/app.php (Laravel 11)"
echo "   ✓ CRUD Gestiones Académicas        — CU-13"
echo "   ✓ CRUD Carreras + Cupos por gestión — CU-10, CU-11"
echo "   ✓ CRUD Materias con ponderación     — CU-12"
echo "   ✓ CRUD Docentes perfil completo     — CU-14, CU-15, CU-16"
echo "   ✓ CRUD Postulantes campos completos — CU-05 a CU-09"
echo "   ✓ Bitácora registra todas las rutas"
echo "   ✓ Seeders: 4 carreras, 4 materias, 2 gestiones, 3 usuarios"
echo ""
echo -e "  ${C}MÓDULOS DEL SIDEBAR (nombres exactos del documento):${N}"
echo "   1. Módulo de Autenticación y Seguridad"
echo "   2. Módulo de Registro de Postulantes"
echo "   3. Módulo de Gestión Académica"
echo "   4. Módulo de Asignación de Grupos y Docentes"
echo "   5. Módulo de Exámenes y Control Académico    (Ciclo 2)"
echo "   6. Módulo de Panel Administrativo y Reportes (Ciclo 2)"
echo ""
echo -e "  ${Y}PASOS OBLIGATORIOS:${N}"
echo "   php artisan migrate:fresh --seed"
echo ""
echo -e "  ${C}Credenciales (password: 12345678):${N}"
echo "   admin@cup.edu.bo      → Administrador del Sistema"
echo "   docente@cup.edu.bo    → Docente"
echo "   postulante@cup.edu.bo → Postulante"
echo ""
