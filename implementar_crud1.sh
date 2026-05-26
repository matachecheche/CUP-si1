#!/usr/bin/env bash
# =============================================================================
#  implementar_crud1.sh  — CUP Sistema de Admisión
#
#  Qué hace:
#    1. Corrige el layout principal (ap.blade.php) para que funcione con el
#       nuevo diseño (cup.css) — el repo actual sigue con el viejo SB Admin
#    2. Ajusta nombres de módulos exactamente como el documento PDF
#    3. Amplía migraciones de postulantes (campos faltantes del PDF)
#    4. Implementa los 4 CRUDs completos:
#         — CRUD Postulantes  (Módulo Registro de Postulantes)
#         — CRUD Carreras     (Módulo Gestión Académica)
#         — CRUD Materias     (Módulo Exámenes y Control Académico)
#         — CRUD Docentes     (Módulo Asignación de Grupos y Docentes)
#    5. Actualiza routes/web.php, seeders, permisos y sidebar
#
#  USO:  bash implementar_crud1.sh   (desde raíz del proyecto)
# =============================================================================

set -e
C='\033[0;36m'; G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; N='\033[0m'
info() { echo -e "${C}[INFO]${N}  $1"; }
ok()   { echo -e "${G}[OK]${N}    $1"; }
warn() { echo -e "${Y}[WARN]${N}  $1"; }
err()  { echo -e "${R}[ERROR]${N} $1"; exit 1; }

[ -f "artisan" ] || err "Ejecuta desde la raíz del proyecto Laravel."

mkdir -p public/css public/js \
         app/Models \
         app/Http/Controllers \
         resources/views/{layouts,layouts/partials,panel,bitacora,auth} \
         resources/views/{postulantes,carreras,materias,docentes,users,roles,components,pages}

# =============================================================================
#  1. CSS PRINCIPAL — cup.css
#     Diseño Institucional Andino: verde oliva + oro + crema
# =============================================================================
info "Escribiendo public/css/cup.css..."

cat > public/css/cup.css << 'ENDCSS'
/* ============================================================
   Sistema de Admisión CUP — Institucional Andino
   Paleta: #1a3a2a (verde) · #b8973e (oro) · #f5f0e8 (crema)
   Fuentes: Crimson Pro (display) · DM Sans (cuerpo)
   ============================================================ */
@import url('https://fonts.googleapis.com/css2?family=Crimson+Pro:wght@400;600;700&family=DM+Sans:wght@300;400;500;600;700&display=swap');

:root {
  --verde:      #1a3a2a; --verde-2:   #254d38; --verde-3:   #2e6347;
  --verde-lite: #d4e8dc; --oro:       #b8973e; --oro-lite:  #f0e2b6;
  --crema:      #f5f0e8; --crema-2:   #ede7d9; --txt:       #1c1c1c;
  --txt-2:      #4a4a4a; --txt-3:     #7a7a7a; --border:    #d6cfc2;
  --white:      #ffffff; --danger:    #a3290c; --danger-l:  #fde8e3;
  --warn:       #7a5c00; --warn-l:    #fff8e1; --sidebar-w: 260px;
  --topbar-h:   60px;    --radius:    8px;
  --shadow-sm:  0 1px 3px rgba(0,0,0,.08);
  --shadow:     0 4px 16px rgba(26,58,42,.12);
  --shadow-lg:  0 8px 32px rgba(26,58,42,.18);
  --font-d:     'Crimson Pro', Georgia, serif;
  --font-b:     'DM Sans', 'Helvetica Neue', sans-serif;
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
html{font-size:15px;-webkit-font-smoothing:antialiased}
body{font-family:var(--font-b);background:var(--crema);color:var(--txt);line-height:1.6;min-height:100vh}
a{color:var(--verde-3);text-decoration:none}
a:hover{color:var(--oro)}

/* ── Topbar ──────────────────────────────────────────── */
.cup-topbar{position:fixed;top:0;left:0;right:0;height:var(--topbar-h);background:var(--verde);
  display:flex;align-items:center;padding:0 1.25rem;gap:1rem;z-index:1000;
  border-bottom:3px solid var(--oro)}
.cup-topbar .brand{font-family:var(--font-d);font-size:1.2rem;font-weight:700;color:var(--white);
  display:flex;align-items:center;gap:.6rem;text-decoration:none}
.brand-icon{width:34px;height:34px;border-radius:6px;background:var(--oro);display:flex;
  align-items:center;justify-content:center;font-size:1rem;color:var(--verde);font-weight:700}
.btn-toggle{background:none;border:none;color:rgba(255,255,255,.7);font-size:1.1rem;cursor:pointer;
  padding:6px 8px;border-radius:6px;transition:.2s}
.btn-toggle:hover{background:rgba(255,255,255,.1);color:#fff}
.topbar-right{margin-left:auto;display:flex;align-items:center;gap:.75rem}
.topbar-user{display:flex;align-items:center;gap:.5rem;color:rgba(255,255,255,.85);font-size:.87rem;
  font-weight:500;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.14);
  border-radius:30px;padding:.3rem .85rem;cursor:pointer;position:relative}
.topbar-user .av{width:28px;height:28px;background:var(--oro);border-radius:50%;display:flex;
  align-items:center;justify-content:center;font-size:.78rem;font-weight:700;color:var(--verde)}
.usr-menu{position:absolute;right:0;top:calc(100% + 8px);background:var(--white);
  border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow-lg);
  min-width:180px;padding:.4rem 0;display:none;z-index:9999}
.topbar-user.open .usr-menu{display:block}
.usr-menu a{display:flex;align-items:center;gap:.6rem;padding:.5rem 1rem;font-size:.87rem;
  color:var(--txt-2);transition:.15s}
.usr-menu a:hover{background:var(--crema);color:var(--verde)}
.usr-menu .sep{border-top:1px solid var(--border);margin:.3rem 0}
.usr-menu a.danger{color:var(--danger)}
.usr-menu a.danger:hover{background:var(--danger-l)}

/* ── Sidebar ─────────────────────────────────────────── */
.cup-sidebar{position:fixed;top:var(--topbar-h);left:0;bottom:0;width:var(--sidebar-w);
  background:var(--white);border-right:1px solid var(--border);overflow-y:auto;
  overflow-x:hidden;z-index:900;transition:transform .28s ease}
.cup-sidebar.collapsed{transform:translateX(calc(-1 * var(--sidebar-w)))}
.cup-sidebar::-webkit-scrollbar{width:4px}
.cup-sidebar::-webkit-scrollbar-thumb{background:var(--border);border-radius:4px}

.sb-user{padding:1.1rem 1.2rem;border-bottom:1px solid var(--crema-2);background:var(--crema);
  display:flex;align-items:center;gap:.75rem}
.sb-user .av{width:38px;height:38px;border-radius:50%;background:var(--verde);display:flex;
  align-items:center;justify-content:center;font-size:.95rem;font-weight:700;
  color:var(--oro);flex-shrink:0}
.sb-name{font-size:.9rem;font-weight:600;color:var(--txt);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.sb-role{font-size:.73rem;color:var(--txt-3)}

.sb-section{padding:.6rem 1rem .2rem}
.sb-title{font-size:.65rem;font-weight:700;letter-spacing:.08em;text-transform:uppercase;
  color:var(--txt-3);padding:.5rem .2rem .2rem}
.nav-item{display:flex;align-items:center;gap:.65rem;padding:.52rem .8rem;border-radius:6px;
  margin-bottom:2px;color:var(--txt-2);font-size:.88rem;transition:.15s;position:relative;
  cursor:pointer;text-decoration:none}
.nav-item:hover{background:var(--crema);color:var(--verde)}
.nav-item.active{background:var(--verde-lite);color:var(--verde);font-weight:600}
.nav-item.active::before{content:'';position:absolute;left:-1px;top:20%;bottom:20%;
  width:3px;border-radius:0 3px 3px 0;background:var(--oro)}
.nav-item .ni{width:20px;text-align:center;font-size:.88rem;flex-shrink:0;color:var(--txt-3)}
.nav-item.active .ni,.nav-item:hover .ni{color:var(--verde-3)}
.nav-item.pending{color:var(--txt-3);pointer-events:none}
.nb{margin-left:auto;font-size:.6rem;font-weight:700;background:var(--crema-2);
  color:var(--txt-3);border-radius:10px;padding:1px 6px}
.nav-item.active .nb{background:var(--verde-lite);color:var(--verde-3)}
.sb-div{border-top:1px solid var(--crema-2);margin:.5rem 1rem}
.nav-item.logout{color:var(--danger)}
.nav-item.logout:hover{background:var(--danger-l);color:var(--danger)}
.nav-item.logout .ni{color:var(--danger)}

/* ── Main ────────────────────────────────────────────── */
.cup-main{margin-top:var(--topbar-h);margin-left:var(--sidebar-w);min-height:calc(100vh - var(--topbar-h));
  transition:margin-left .28s ease;display:flex;flex-direction:column}
.cup-main.expanded{margin-left:0}
.cup-content{flex:1;padding:2rem 2rem 1rem}
.cup-footer{padding:.75rem 2rem;border-top:1px solid var(--border);background:var(--white);
  display:flex;align-items:center;justify-content:space-between;font-size:.78rem;color:var(--txt-3)}

/* ── Page header ─────────────────────────────────────── */
.page-header{margin-bottom:1.75rem;border-bottom:1px solid var(--border);padding-bottom:1rem}
.page-header h1{font-family:var(--font-d);font-size:1.9rem;font-weight:700;color:var(--verde);line-height:1.2}
.page-header .subtitle{font-size:.88rem;color:var(--txt-3);margin-top:.2rem}
.breadcrumb{display:flex;align-items:center;gap:.4rem;list-style:none;font-size:.8rem;
  color:var(--txt-3);margin-top:.5rem}
.breadcrumb li+li::before{content:'/';margin-right:.4rem}
.breadcrumb a{color:var(--verde-3)}

/* ── Cards ───────────────────────────────────────────── */
.card{background:var(--white);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow-sm)}
.card-header{padding:.9rem 1.25rem;border-bottom:1px solid var(--crema-2);font-size:.93rem;
  font-weight:600;color:var(--verde);background:var(--crema);
  border-radius:var(--radius) var(--radius) 0 0;display:flex;align-items:center;gap:.5rem}
.card-header i{color:var(--oro)}
.card-body{padding:1.25rem}

/* ── Stats (panel) ───────────────────────────────────── */
.stat-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:1rem;margin-bottom:1.75rem}
.stat-card{background:var(--white);border:1px solid var(--border);border-radius:var(--radius);
  padding:1.1rem 1.25rem;display:flex;align-items:center;gap:1rem;box-shadow:var(--shadow-sm);
  text-decoration:none}
.stat-card:hover{box-shadow:var(--shadow);transform:translateY(-1px)}
.stat-icon{width:46px;height:46px;border-radius:10px;display:flex;align-items:center;
  justify-content:center;font-size:1.25rem;flex-shrink:0}
.stat-icon.c1{background:var(--verde-lite);color:var(--verde-3)}
.stat-icon.c2{background:var(--oro-lite);color:#7a5800}
.stat-icon.c3{background:var(--danger-l);color:var(--danger)}
.stat-icon.c4{background:var(--crema-2);color:var(--txt-3)}
.stat-icon.c5{background:#dbeafe;color:#1d4f8f}
.stat-val{font-size:1rem;font-weight:700;color:var(--verde);line-height:1}
.stat-lbl{font-size:.78rem;color:var(--txt-3);margin-top:.15rem}

/* ── Módulo cards (panel) ────────────────────────────── */
.mod-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(320px,1fr));gap:1.25rem;margin-bottom:2rem}
.mod-card{background:var(--white);border:1px solid var(--border);border-radius:var(--radius);
  overflow:hidden;box-shadow:var(--shadow-sm)}
.mod-head{display:flex;align-items:center;gap:.75rem;padding:.9rem 1.15rem;
  font-family:var(--font-d);font-size:1.05rem;font-weight:700;
  border-bottom:1px solid var(--crema-2)}
.mod-num{width:28px;height:28px;border-radius:50%;display:flex;align-items:center;
  justify-content:center;font-size:.82rem;font-weight:800;flex-shrink:0}
.m1{border-top:3px solid #3b82f6} .m1 .mod-num{background:#d4e2f7;color:#1d4f8f}
.m2{border-top:3px solid #22c55e} .m2 .mod-num{background:#d8f0e6;color:#1a5c38}
.m3{border-top:3px solid #f97316} .m3 .mod-num{background:#fde8cc;color:#8a4300}
.m4{border-top:3px solid #a855f7} .m4 .mod-num{background:#ede0f7;color:#5b2a8a}
.m5{border-top:3px solid #ef4444} .m5 .mod-num{background:#fce4e4;color:#8a1f1f}
.mod-body{padding:.6rem .8rem}
.cu-row{display:flex;align-items:center;gap:.6rem;padding:.45rem .6rem;border-radius:5px;
  margin-bottom:1px;font-size:.86rem;color:var(--txt-2);transition:.15s}
.cu-row.link:hover{background:var(--crema);color:var(--verde)}
.cu-row.link a{color:inherit;display:flex;align-items:center;gap:.6rem;width:100%;text-decoration:none}
.cu-row.link a:hover{color:var(--verde)}
.cu-row.disabled{color:var(--txt-3)}
.cu-tag{font-size:.63rem;font-weight:700;padding:1px 5px;border-radius:4px;flex-shrink:0;
  min-width:40px;text-align:center}
.cu-tag.done{background:#d4edda;color:#1a5c38;border:1px solid #a3d9b5}
.cu-tag.pending{background:var(--crema-2);color:var(--txt-3);border:1px solid var(--border)}
.cu-icon{width:16px;text-align:center;font-size:.82rem;color:var(--txt-3);flex-shrink:0}
.cu-row.link:hover .cu-icon{color:var(--verde-3)}
.cu-pl{margin-left:auto;font-size:.65rem;color:var(--txt-3);flex-shrink:0}

/* ── Tablas ──────────────────────────────────────────── */
.table-wrap{overflow-x:auto}
table.cup-table{width:100%;border-collapse:collapse;font-size:.88rem}
.cup-table th{background:var(--crema);color:var(--verde);font-weight:700;font-size:.78rem;
  text-transform:uppercase;letter-spacing:.05em;padding:.65rem 1rem;
  border-bottom:2px solid var(--border);white-space:nowrap}
.cup-table td{padding:.7rem 1rem;border-bottom:1px solid var(--crema-2);color:var(--txt-2);vertical-align:middle}
.cup-table tbody tr:hover{background:#fafaf7}
.cup-table tbody tr:last-child td{border-bottom:none}

/* ── Badges ──────────────────────────────────────────── */
.badge{display:inline-flex;align-items:center;padding:2px 9px;border-radius:20px;font-size:.72rem;font-weight:700}
.b-verde{background:var(--verde-lite);color:var(--verde)}
.b-oro{background:var(--oro-lite);color:#5c4200}
.b-rojo{background:var(--danger-l);color:var(--danger)}
.b-gris{background:var(--crema-2);color:var(--txt-3)}
.b-azul{background:#dbeafe;color:#1d4f8f}
.b-violeta{background:#ede0f7;color:#5b2a8a}
.b-naranja{background:#fde8cc;color:#8a4300}
.rol-admin{background:#1a3a2a22;color:#1a3a2a;border:1px solid #1a3a2a44}
.rol-docente{background:#1d4f8f22;color:#1d4f8f;border:1px solid #1d4f8f44}
.rol-postulante{background:#b8973e22;color:#7a5800;border:1px solid #b8973e44}

/* ── Botones ─────────────────────────────────────────── */
.btn{display:inline-flex;align-items:center;gap:.4rem;padding:.5rem 1.1rem;border-radius:6px;
  font-size:.87rem;font-weight:600;cursor:pointer;border:1px solid transparent;
  transition:.18s;white-space:nowrap;font-family:var(--font-b);text-decoration:none}
.btn-primary{background:var(--verde);color:var(--white);border-color:var(--verde)}
.btn-primary:hover{background:var(--verde-2);color:var(--white);box-shadow:var(--shadow-sm)}
.btn-oro{background:var(--oro);color:var(--white);border-color:var(--oro)}
.btn-oro:hover{background:#9c7e34;color:var(--white)}
.btn-outline{background:transparent;color:var(--verde);border-color:var(--verde)}
.btn-outline:hover{background:var(--verde-lite)}
.btn-danger{background:var(--danger);color:var(--white);border-color:var(--danger)}
.btn-danger:hover{background:#7c1e09;color:var(--white)}
.btn-warn{background:#c8860a;color:var(--white);border-color:#c8860a}
.btn-warn:hover{background:var(--warn);color:var(--white)}
.btn-sm{padding:.32rem .75rem;font-size:.8rem}
.btn-xs{padding:.2rem .55rem;font-size:.74rem}
.btn-group{display:flex;gap:.35rem;flex-wrap:wrap}

/* ── Formularios ─────────────────────────────────────── */
.form-label{display:block;font-size:.83rem;font-weight:600;color:var(--txt);margin-bottom:.35rem}
.form-label .req{color:var(--danger);margin-left:2px}
.form-control,.form-select{width:100%;padding:.52rem .85rem;background:var(--white);
  border:1px solid var(--border);border-radius:6px;font-family:var(--font-b);
  font-size:.88rem;color:var(--txt);transition:border-color .15s,box-shadow .15s;
  appearance:none;-webkit-appearance:none}
.form-control:focus,.form-select:focus{outline:none;border-color:var(--verde-3);
  box-shadow:0 0 0 3px rgba(46,99,71,.15)}
.form-control::placeholder{color:var(--txt-3)}
.form-select{background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3E%3Cpath d='M7.247 11.14L2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z' fill='%234a4a4a'/%3E%3C/svg%3E");
  background-repeat:no-repeat;background-position:right .65rem center;background-size:12px;padding-right:2.2rem}
textarea.form-control{resize:vertical;min-height:90px}
.form-row{display:grid;gap:1rem}
.cols-2{grid-template-columns:1fr 1fr}
.cols-3{grid-template-columns:1fr 1fr 1fr}
.form-hint{font-size:.76rem;color:var(--txt-3);margin-top:.25rem}
.form-check{display:flex;align-items:center;gap:.5rem}
.form-check input[type="checkbox"]{width:16px;height:16px;accent-color:var(--verde);cursor:pointer}
.form-section{margin-bottom:1.5rem}
.form-section-title{font-family:var(--font-d);font-size:1.1rem;font-weight:700;
  color:var(--verde);border-bottom:2px solid var(--oro-lite);padding-bottom:.4rem;margin-bottom:1rem}

/* Grupo permisos */
.perm-group{border:1px solid var(--border);border-radius:6px;overflow:hidden;margin-bottom:.75rem}
.perm-group-header{background:var(--crema);padding:.55rem .9rem;font-size:.78rem;font-weight:700;
  color:var(--verde);display:flex;align-items:center;justify-content:space-between}
.perm-group-body{padding:.6rem .9rem;display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:.3rem}

/* ── Alertas ─────────────────────────────────────────── */
.alert{display:flex;align-items:flex-start;gap:.6rem;padding:.75rem 1rem;border-radius:6px;
  font-size:.87rem;margin-bottom:1rem}
.alert-success{background:#e8f5ee;color:#1a5c38;border:1px solid #a3d9b5}
.alert-danger{background:var(--danger-l);color:var(--danger);border:1px solid #f5b8a8}
.alert-warn{background:var(--warn-l);color:var(--warn);border:1px solid #ffe082}
.alert ul{margin:.3rem 0 0 1rem;padding:0}

/* ── Bitácora chips ──────────────────────────────────── */
.chip-mod{display:inline-block;font-size:.63rem;font-weight:700;padding:2px 7px;border-radius:3px;
  text-transform:uppercase;letter-spacing:.05em;white-space:nowrap}
.c-Seguridad{background:#dbeafe;color:#1d4f8f}
.c-Usuarios{background:#d4e8dc;color:#1a5c38}
.c-Roles{background:#d8f0e6;color:#1a5c38}
.c-Bitácora{background:#ede0f7;color:#5b2a8a}
.c-Postulantes{background:#fde8cc;color:#8a4300}
.c-Docentes{background:#fff8e1;color:#7a5c00}
.c-Grupos{background:#fce4e4;color:#8a1f1f}
.c-Evaluación{background:#e0f7fa;color:#006064}
.c-Admisión{background:#f3e5f5;color:#6a1b9a}
.c-Reportes{background:#e8f5e9;color:#2e7d32}
.c-GestiónAcadémica,.c-Materias,.c-Carreras{background:#fef9c3;color:#78350f}
.chip-http{font-size:.65rem;font-weight:800;padding:1px 5px;border-radius:3px;font-family:'Courier New',monospace}
.h-GET{background:#e8f4fd;color:#0369a1}
.h-POST{background:#d4edda;color:#155724}
.h-PUT{background:#fff3cd;color:#856404}
.h-PATCH{background:#fff3cd;color:#856404}
.h-DELETE{background:#fde8e3;color:#a3290c}

/* ── Paginación ──────────────────────────────────────── */
.pagination{display:flex;gap:.3rem;list-style:none;flex-wrap:wrap}
.page-item .page-link{padding:.38rem .7rem;border-radius:5px;border:1px solid var(--border);
  color:var(--verde-3);font-size:.84rem;transition:.15s;display:inline-block}
.page-item.active .page-link{background:var(--verde);color:#fff;border-color:var(--verde)}
.page-item .page-link:hover{background:var(--crema)}

/* ── Responsive ──────────────────────────────────────── */
@media(max-width:768px){
  .cup-sidebar{transform:translateX(calc(-1 * var(--sidebar-w)))}
  .cup-sidebar.open{transform:translateX(0)}
  .cup-main{margin-left:0}
  .cols-2,.cols-3{grid-template-columns:1fr}
  .cup-content{padding:1.25rem 1rem}
  .mod-grid{grid-template-columns:1fr}
}
ENDCSS
ok "public/css/cup.css"

# =============================================================================
#  2. LAYOUT PRINCIPAL — reemplaza el layout viejo SB Admin
# =============================================================================
info "Reescribiendo resources/views/layouts/ap.blade.php..."

cat > resources/views/layouts/ap.blade.php << 'BLADE'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'CUP') — Admisión CUP</title>
    <link href="{{ asset('css/cup.css') }}" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    @stack('css')
</head>
<body>

<header class="cup-topbar">
    <button class="btn-toggle" id="sbToggle"><i class="fas fa-bars"></i></button>
    <a href="{{ route('panel') }}" class="brand">
        <div class="brand-icon">C</div>
        <span>Admisión <span style="color:var(--oro)">CUP</span></span>
    </a>
    <div class="topbar-right">
        <div class="topbar-user" id="usrDrop" onclick="this.classList.toggle('open')">
            <div class="av">{{ strtoupper(substr(Auth::user()->name ?? 'U',0,1)) }}</div>
            <span>{{ Auth::user()->name ?? 'Usuario' }}</span>
            <i class="fas fa-chevron-down" style="font-size:.6rem;opacity:.6;margin-left:.2rem"></i>
            <div class="usr-menu">
                <a href="{{ route('users.perfil') }}"><i class="fas fa-user-circle"></i> Mi perfil</a>
                <div class="sep"></div>
                <a href="{{ route('logout') }}" class="danger"><i class="fas fa-sign-out-alt"></i> Cerrar sesión</a>
            </div>
        </div>
    </div>
</header>

<nav class="cup-sidebar" id="cupSb">
    <div class="sb-user">
        <div class="av">{{ strtoupper(substr(Auth::user()->name ?? 'U',0,1)) }}</div>
        <div>
            <div class="sb-name">{{ Auth::user()->name ?? 'Usuario' }}</div>
            <div class="sb-role">{{ Auth::user()->getRoleNames()->first() ?? 'Sin rol' }}</div>
        </div>
    </div>

    {{-- ── MÓDULO AUTENTICACIÓN (CU-01 a CU-04) --}}
    <div class="sb-section">
        <div class="sb-title">🔐 Autenticación y Seguridad</div>
        <a class="nav-item {{ request()->routeIs('panel') ? 'active' : '' }}" href="{{ route('panel') }}">
            <i class="ni fas fa-th-large"></i> Panel de Control
        </a>
        @can('ver usuarios')
        <a class="nav-item {{ request()->routeIs('users.*') ? 'active' : '' }}" href="{{ route('users.index') }}">
            <i class="ni fas fa-users-cog"></i> Gestión de Usuarios
        </a>
        @endcan
        @can('ver roles')
        <a class="nav-item {{ request()->routeIs('roles.*') ? 'active' : '' }}" href="{{ route('roles.index') }}">
            <i class="ni fas fa-user-shield"></i> Roles y Permisos
        </a>
        @endcan
        @can('ver bitacora')
        <a class="nav-item {{ request()->routeIs('bitacora.*') ? 'active' : '' }}" href="{{ route('bitacora.index') }}">
            <i class="ni fas fa-journal-whills"></i> Bitácora
        </a>
        @endcan
    </div>

    <div class="sb-div"></div>

    {{-- ── MÓDULO REGISTRO DE POSTULANTES (CU-05 a CU-09) --}}
    <div class="sb-section">
        <div class="sb-title">👤 Registro de Postulantes</div>
        @can('ver postulantes')
        <a class="nav-item {{ request()->routeIs('postulantes.*') ? 'active' : '' }}" href="{{ route('postulantes.index') }}">
            <i class="ni fas fa-user-plus"></i> Postulantes
        </a>
        @else
        <span class="nav-item pending"><i class="ni fas fa-user-plus"></i> Postulantes <span class="nb">Sin acceso</span></span>
        @endcan
    </div>

    <div class="sb-div"></div>

    {{-- ── MÓDULO GESTIÓN ACADÉMICA (CU-10 a CU-13) --}}
    <div class="sb-section">
        <div class="sb-title">🎓 Gestión Académica</div>
        @can('ver carreras')
        <a class="nav-item {{ request()->routeIs('carreras.*') ? 'active' : '' }}" href="{{ route('carreras.index') }}">
            <i class="ni fas fa-graduation-cap"></i> Carreras y Cupos
        </a>
        @else
        <span class="nav-item pending"><i class="ni fas fa-graduation-cap"></i> Carreras y Cupos <span class="nb">Pronto</span></span>
        @endcan

        @can('ver materias')
        <a class="nav-item {{ request()->routeIs('materias.*') ? 'active' : '' }}" href="{{ route('materias.index') }}">
            <i class="ni fas fa-book-open"></i> Materias del CUP
        </a>
        @else
        <span class="nav-item pending"><i class="ni fas fa-book-open"></i> Materias del CUP <span class="nb">Pronto</span></span>
        @endcan

        <span class="nav-item pending"><i class="ni fas fa-calendar-alt"></i> Gestiones Académicas <span class="nb">Pronto</span></span>
    </div>

    <div class="sb-div"></div>

    {{-- ── MÓDULO ASIGNACIÓN DE GRUPOS Y DOCENTES (CU-14 a CU-21) --}}
    <div class="sb-section">
        <div class="sb-title">🏫 Grupos y Docentes</div>
        @can('ver docentes')
        <a class="nav-item {{ request()->routeIs('docentes.*') ? 'active' : '' }}" href="{{ route('docentes.index') }}">
            <i class="ni fas fa-chalkboard-teacher"></i> Docentes
        </a>
        @else
        <span class="nav-item pending"><i class="ni fas fa-chalkboard-teacher"></i> Docentes <span class="nb">Pronto</span></span>
        @endcan
        <span class="nav-item pending"><i class="ni fas fa-layer-group"></i> Grupos y Horarios <span class="nb">Pronto</span></span>
    </div>

    <div class="sb-div"></div>

    {{-- ── MÓDULO EXÁMENES Y CONTROL ACADÉMICO (CU-22 a CU-26) --}}
    <div class="sb-section">
        <div class="sb-title">📝 Exámenes y Control Académico</div>
        <span class="nav-item pending"><i class="ni fas fa-pen-nib"></i> Registro de Notas <span class="nb">Pronto</span></span>
    </div>

    <div class="sb-div"></div>

    {{-- ── MÓDULO PANEL ADMINISTRATIVO + REPORTES (CU-27 a CU-33) --}}
    <div class="sb-section">
        <div class="sb-title">📊 Panel Administrativo</div>
        <span class="nav-item pending"><i class="ni fas fa-trophy"></i> Proceso de Admisión <span class="nb">Pronto</span></span>
        <span class="nav-item pending"><i class="ni fas fa-chart-bar"></i> Reportes y Estadísticas <span class="nb">Pronto</span></span>
    </div>

    <div class="sb-div"></div>

    <div class="sb-section">
        <a class="nav-item logout" href="{{ route('logout') }}">
            <i class="ni fas fa-sign-out-alt"></i> Cerrar sesión
        </a>
    </div>
</nav>

<div class="cup-main" id="cupMain">
    <div class="cup-content">
        @include('layouts.partials.alert')
        @yield('content')
    </div>
    <footer class="cup-footer">
        <span>© {{ date('Y') }} Sistema de Admisión CUP — FICCT</span>
        <span>Facultad de Ingeniería en Ciencias de la Computación y Telecomunicaciones</span>
    </footer>
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.all.min.js"></script>
<script>
const sb=document.getElementById('cupSb'),mn=document.getElementById('cupMain'),tg=document.getElementById('sbToggle');
let col=window.innerWidth<769;
function apSb(){if(col){sb.classList.remove('open');if(window.innerWidth>=769){sb.classList.add('collapsed');mn.classList.add('expanded')}else{sb.classList.remove('collapsed');mn.classList.remove('expanded')}}else{sb.classList.add('open');sb.classList.remove('collapsed');mn.classList.remove('expanded')}}
apSb();
tg.addEventListener('click',()=>{col=!col;apSb()});
window.addEventListener('resize',()=>{col=window.innerWidth<769;apSb()});
document.addEventListener('click',e=>{const d=document.getElementById('usrDrop');if(d&&!d.contains(e.target))d.classList.remove('open')});
window.addEventListener('beforeunload',()=>navigator.sendBeacon('{{ route("bitacora.page-close") }}',new URLSearchParams({_token:'{{ csrf_token() }}'})));
</script>
@stack('js')
</body>
</html>
BLADE
ok "resources/views/layouts/ap.blade.php"

# =============================================================================
#  3. PARTIALS / ALERT
# =============================================================================
cat > resources/views/layouts/partials/alert.blade.php << 'BLADE'
@if(session('success'))
<script>
document.addEventListener('DOMContentLoaded',()=>{
    if(typeof Swal!=='undefined')
        Swal.mixin({toast:true,position:'top-end',showConfirmButton:false,timer:2800,timerProgressBar:true})
            .fire({icon:'success',title:@json(session('success'))});
});
</script>
@endif
@if(session('error'))
<div class="alert alert-danger"><i class="fas fa-exclamation-triangle"></i> {{ session('error') }}</div>
@endif
@if($errors->any())
<div class="alert alert-danger"><i class="fas fa-times-circle"></i>
    <div><ul>@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>
</div>
@endif
BLADE
ok "layouts/partials/alert.blade.php"

# =============================================================================
#  4. MIGRACIÓN POSTULANTES — amplía con campos completos del documento PDF
# =============================================================================
info "Actualizando migración de postulantes..."

cat > database/migrations/0001_01_01_000008_create_postulantes_table.php << 'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Módulo Registro de Postulantes (CU-05 a CU-09)
 * Campos según documento PDF sección 2 — Requerimientos Funcionales
 */
return new class extends Migration {
    public function up(): void {
        Schema::create('postulantes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gestion_id')->constrained('gestiones');

            // Opciones de carrera (CU-08)
            $table->foreignId('primera_opcion_id')->constrained('carreras');
            $table->foreignId('segunda_opcion_id')->constrained('carreras');

            // Datos personales (§ 2 documento PDF)
            $table->string('ci', 20)->unique();
            $table->string('nombres', 100);
            $table->string('apellidos', 100);
            $table->date('fecha_nacimiento')->nullable();
            $table->enum('sexo', ['M', 'F', 'Otro'])->nullable();
            $table->string('direccion', 200)->nullable();
            $table->string('telefono', 20)->nullable();
            $table->string('email', 100)->nullable();
            $table->string('colegio_procedencia', 150)->nullable();
            $table->string('ciudad', 80)->nullable();

            // Documentos requeridos (CU-06)
            $table->boolean('doc_ci')->default(false);
            $table->boolean('doc_libreta_colegio')->default(false);
            $table->boolean('doc_titulo_bachiller')->default(false);

            // Estado del postulante (CU-09)
            $table->enum('estado', [
                'inscrito',               // recién registrado
                'en_curso',               // cursando el CUP
                'aprobado',               // promedio >= 60
                'no_aprobado',            // promedio < 60
                'admitido',               // cupo asignado primera opción
                'admitido_segunda_opcion',// cupo en segunda opción
                'no_admitido',            // aprobó pero no alcanzó cupo
            ])->default('inscrito');

            // Resultados de evaluación (calculados automáticamente)
            $table->decimal('promedio_general', 5, 2)->nullable();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('postulantes'); }
};
PHP
ok "Migración postulantes actualizada"

# =============================================================================
#  5. MIGRACIÓN CARRERAS — agrega porcentaje_cupo y datos completos
# =============================================================================
info "Actualizando migración de carreras..."

cat > database/migrations/0001_01_01_000004_create_carreras_table.php << 'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Módulo Gestión Académica — Carreras (CU-10, CU-11)
 * Las 4 carreras: Informática, Sistemas, Redes y Telecomunicaciones, Robótica
 */
return new class extends Migration {
    public function up(): void {
        Schema::create('carreras', function (Blueprint $table) {
            $table->id();
            $table->string('nombre', 100)->unique();
            $table->string('sigla', 10)->nullable();
            $table->text('descripcion')->nullable();
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('carreras'); }
};
PHP
ok "Migración carreras actualizada"

# =============================================================================
#  6. MIGRACIÓN CUPOS — vincula carrera + gestión + cantidad
# =============================================================================
cat > database/migrations/2026_01_01_000001_create_cupos_carrera_table.php << 'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/** CU-11: Definir cupos por carrera y gestión */
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
PHP
ok "Migración cupos_carrera"

# =============================================================================
#  7. MIGRACIÓN MATERIAS — agrega ponderacion_examen y orden
# =============================================================================
info "Actualizando migración de materias..."

cat > database/migrations/0001_01_01_000006_create_materias_table.php << 'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Módulo Exámenes y Control Académico — Materias (CU-12)
 * Las 4 materias: Computación, Matemáticas, Física, Inglés
 * Cada materia tiene 3 exámenes con ponderación 30%+30%+40%
 */
return new class extends Migration {
    public function up(): void {
        Schema::create('materias', function (Blueprint $table) {
            $table->id();
            $table->string('nombre', 100)->unique();
            $table->string('area_formacion', 80)->nullable();
            $table->text('descripcion')->nullable();

            // Ponderación de los 3 exámenes (deben sumar 100)
            $table->unsignedInteger('pond_examen1')->default(30); // 30%
            $table->unsignedInteger('pond_examen2')->default(30); // 30%
            $table->unsignedInteger('pond_examen3')->default(40); // 40%

            $table->unsignedInteger('nota_minima_aprobacion')->default(60);
            $table->unsignedInteger('orden')->default(0);
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('materias'); }
};
PHP
ok "Migración materias actualizada"

# =============================================================================
#  8. MIGRACIÓN DOCENTES — perfil profesional completo del documento
# =============================================================================
info "Actualizando migración de docentes..."

cat > database/migrations/0001_01_01_000007_create_docentes_table.php << 'PHP'
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Módulo Asignación de Grupos y Docentes — Docentes (CU-14 a CU-16)
 * Perfil profesional: título, maestría, diplomado en educación superior,
 * certificaciones de inglés, área afín (para validar qué materia puede dictar)
 * Regla: máximo 4 grupos por docente
 */
return new class extends Migration {
    public function up(): void {
        Schema::create('docentes', function (Blueprint $table) {
            $table->id();

            // Datos personales
            $table->string('ci', 20)->unique();
            $table->string('nombres', 100);
            $table->string('apellidos', 100);
            $table->string('telefono', 20)->nullable();
            $table->string('email', 100)->nullable()->unique();

            // Perfil profesional (CU-14, CU-15 — requisitos de contratación)
            $table->string('titulo_profesional', 150)->nullable();
            $table->string('maestria', 150)->nullable();
            $table->string('diplomado_educacion_superior', 150)->nullable();
            $table->string('certificacion_ingles', 100)->nullable();
            $table->text('otras_certificaciones')->nullable();

            // Área afín (determina qué materias puede dictar — CU-15)
            $table->string('area_formacion', 80)->nullable();

            // Estado y límite de grupos (regla: máx 4 grupos)
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('docentes'); }
};
PHP
ok "Migración docentes actualizada"

# =============================================================================
#  9. MODELOS
# =============================================================================
info "Creando modelos Eloquent..."

cat > app/Models/Carrera.php << 'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Carrera extends Model
{
    protected $table    = 'carreras';
    protected $fillable = ['nombre', 'sigla', 'descripcion', 'estado'];

    public function cupos() {
        return $this->hasMany(CupoCarrera::class);
    }
    public function postulantesOpcion1() {
        return $this->hasMany(Postulante::class, 'primera_opcion_id');
    }
    public function postulantesOpcion2() {
        return $this->hasMany(Postulante::class, 'segunda_opcion_id');
    }
}
PHP

cat > app/Models/CupoCarrera.php << 'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class CupoCarrera extends Model
{
    protected $table    = 'cupos_carrera';
    protected $fillable = ['carrera_id', 'gestion_id', 'cantidad_maxima'];

    public function carrera()  { return $this->belongsTo(Carrera::class); }
    public function gestion()  { return $this->belongsTo(Gestion::class); }
}
PHP

cat > app/Models/Materia.php << 'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Materia extends Model
{
    protected $table    = 'materias';
    protected $fillable = [
        'nombre', 'area_formacion', 'descripcion',
        'pond_examen1', 'pond_examen2', 'pond_examen3',
        'nota_minima_aprobacion', 'orden', 'estado',
    ];

    /** Valida que las ponderaciones sumen 100 */
    public function getPonderacionTotalAttribute(): int {
        return $this->pond_examen1 + $this->pond_examen2 + $this->pond_examen3;
    }
}
PHP

cat > app/Models/Docente.php << 'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Docente extends Model
{
    protected $table    = 'docentes';
    protected $fillable = [
        'ci', 'nombres', 'apellidos', 'telefono', 'email',
        'titulo_profesional', 'maestria', 'diplomado_educacion_superior',
        'certificacion_ingles', 'otras_certificaciones',
        'area_formacion', 'estado',
    ];

    public function getNombreCompletoAttribute(): string {
        return $this->nombres . ' ' . $this->apellidos;
    }

    public function user() {
        return $this->hasOne(User::class);
    }
}
PHP

cat > app/Models/Gestion.php << 'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Gestion extends Model
{
    protected $table    = 'gestiones';
    protected $fillable = ['descripcion', 'fecha_inicio', 'fecha_fin', 'estado'];
    protected $casts    = ['fecha_inicio' => 'date', 'fecha_fin' => 'date'];
}
PHP

cat > app/Models/Postulante.php << 'PHP'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Postulante extends Model
{
    protected $table    = 'postulantes';
    protected $fillable = [
        'gestion_id', 'primera_opcion_id', 'segunda_opcion_id',
        'ci', 'nombres', 'apellidos', 'fecha_nacimiento', 'sexo',
        'direccion', 'telefono', 'email', 'colegio_procedencia', 'ciudad',
        'doc_ci', 'doc_libreta_colegio', 'doc_titulo_bachiller',
        'estado', 'promedio_general',
    ];
    protected $casts = ['fecha_nacimiento' => 'date'];

    public function gestion()         { return $this->belongsTo(Gestion::class); }
    public function primeraOpcion()   { return $this->belongsTo(Carrera::class, 'primera_opcion_id'); }
    public function segundaOpcion()   { return $this->belongsTo(Carrera::class, 'segunda_opcion_id'); }
    public function getNombreCompletoAttribute(): string { return $this->nombres . ' ' . $this->apellidos; }

    public function tieneDocumentos(): bool {
        return $this->doc_ci && $this->doc_libreta_colegio && $this->doc_titulo_bachiller;
    }

    public function getEstadoBadgeAttribute(): string {
        return match($this->estado) {
            'inscrito'               => 'b-azul',
            'en_curso'               => 'b-naranja',
            'aprobado'               => 'b-verde',
            'no_aprobado'            => 'b-rojo',
            'admitido'               => 'b-verde',
            'admitido_segunda_opcion'=> 'b-oro',
            'no_admitido'            => 'b-rojo',
            default                  => 'b-gris',
        };
    }
}
PHP
ok "Modelos creados"

# =============================================================================
#  10. CONTROLADORES
# =============================================================================
info "Creando controladores..."

# ── CarreraController ─────────────────────────────────────────────────────────
cat > app/Http/Controllers/CarreraController.php << 'PHP'
<?php
namespace App\Http\Controllers;

use App\Models\Carrera;
use App\Models\CupoCarrera;
use App\Models\Gestion;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;

class CarreraController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver carreras')->only('index','show');
        $this->middleware('permission:crear carreras')->only('create','store');
        $this->middleware('permission:editar carreras')->only('edit','update');
        $this->middleware('permission:eliminar carreras')->only('destroy');
    }

    public function index()
    {
        $carreras = Carrera::orderBy('nombre')->get();
        return view('carreras.index', compact('carreras'));
    }

    public function create()
    {
        return view('carreras.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nombre'      => 'required|string|max:100|unique:carreras,nombre',
            'sigla'       => 'nullable|string|max:10',
            'descripcion' => 'nullable|string',
            'estado'      => 'boolean',
        ]);
        $data['estado'] = $request->boolean('estado', true);
        $c = Carrera::create($data);
        $this->registrarEnBitacora("Registró carrera: {$c->nombre}", $c->id, 'Carreras');
        return redirect()->route('carreras.index')
            ->with('success', "Carrera «{$c->nombre}» registrada correctamente.");
    }

    public function show(Carrera $carrera)
    {
        $gestiones = Gestion::orderByDesc('fecha_inicio')->get();
        $cupos     = CupoCarrera::where('carrera_id', $carrera->id)
                        ->with('gestion')->orderByDesc('id')->get();
        return view('carreras.show', compact('carrera', 'gestiones', 'cupos'));
    }

    public function edit(Carrera $carrera)
    {
        return view('carreras.edit', compact('carrera'));
    }

    public function update(Request $request, Carrera $carrera)
    {
        $data = $request->validate([
            'nombre'      => "required|string|max:100|unique:carreras,nombre,{$carrera->id}",
            'sigla'       => 'nullable|string|max:10',
            'descripcion' => 'nullable|string',
            'estado'      => 'boolean',
        ]);
        $data['estado'] = $request->boolean('estado', true);
        $carrera->update($data);
        $this->registrarEnBitacora("Actualizó carrera: {$carrera->nombre}", $carrera->id, 'Carreras');
        return redirect()->route('carreras.index')
            ->with('success', "Carrera «{$carrera->nombre}» actualizada.");
    }

    public function destroy(Carrera $carrera)
    {
        $nombre = $carrera->nombre;
        $carrera->delete();
        $this->registrarEnBitacora("Eliminó carrera: {$nombre}", null, 'Carreras');
        return redirect()->route('carreras.index')
            ->with('success', "Carrera «{$nombre}» eliminada.");
    }

    /** CU-11: Definir cupo para una carrera en una gestión */
    public function storeCupo(Request $request, Carrera $carrera)
    {
        $data = $request->validate([
            'gestion_id'      => 'required|exists:gestiones,id',
            'cantidad_maxima' => 'required|integer|min:1|max:9999',
        ]);
        $cupo = CupoCarrera::updateOrCreate(
            ['carrera_id' => $carrera->id, 'gestion_id' => $data['gestion_id']],
            ['cantidad_maxima' => $data['cantidad_maxima']]
        );
        $this->registrarEnBitacora(
            "Definió cupo {$cupo->cantidad_maxima} para {$carrera->nombre}",
            $carrera->id, 'Carreras'
        );
        return redirect()->route('carreras.show', $carrera)
            ->with('success', 'Cupo definido correctamente.');
    }
}
PHP

# ── MateriaController ─────────────────────────────────────────────────────────
cat > app/Http/Controllers/MateriaController.php << 'PHP'
<?php
namespace App\Http\Controllers;

use App\Models\Materia;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;

class MateriaController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver materias')->only('index','show');
        $this->middleware('permission:crear materias')->only('create','store');
        $this->middleware('permission:editar materias')->only('edit','update');
        $this->middleware('permission:eliminar materias')->only('destroy');
    }

    public function index()
    {
        $materias = Materia::orderBy('orden')->orderBy('nombre')->get();
        return view('materias.index', compact('materias'));
    }

    public function create()
    {
        return view('materias.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nombre'                 => 'required|string|max:100|unique:materias,nombre',
            'area_formacion'         => 'nullable|string|max:80',
            'descripcion'            => 'nullable|string',
            'pond_examen1'           => 'required|integer|min:1|max:98',
            'pond_examen2'           => 'required|integer|min:1|max:98',
            'pond_examen3'           => 'required|integer|min:1|max:98',
            'nota_minima_aprobacion' => 'required|integer|min:1|max:100',
            'orden'                  => 'nullable|integer|min:0',
            'estado'                 => 'boolean',
        ]);
        // Validar que las ponderaciones sumen 100
        if (($data['pond_examen1'] + $data['pond_examen2'] + $data['pond_examen3']) !== 100) {
            return back()->withErrors(['pond_examen1' => 'Las ponderaciones deben sumar exactamente 100%'])->withInput();
        }
        $data['estado'] = $request->boolean('estado', true);
        $data['orden']  = $data['orden'] ?? 0;
        $m = Materia::create($data);
        $this->registrarEnBitacora("Registró materia: {$m->nombre}", $m->id, 'Materias');
        return redirect()->route('materias.index')
            ->with('success', "Materia «{$m->nombre}» registrada correctamente.");
    }

    public function show(Materia $materia)
    {
        return view('materias.show', compact('materia'));
    }

    public function edit(Materia $materia)
    {
        return view('materias.edit', compact('materia'));
    }

    public function update(Request $request, Materia $materia)
    {
        $data = $request->validate([
            'nombre'                 => "required|string|max:100|unique:materias,nombre,{$materia->id}",
            'area_formacion'         => 'nullable|string|max:80',
            'descripcion'            => 'nullable|string',
            'pond_examen1'           => 'required|integer|min:1|max:98',
            'pond_examen2'           => 'required|integer|min:1|max:98',
            'pond_examen3'           => 'required|integer|min:1|max:98',
            'nota_minima_aprobacion' => 'required|integer|min:1|max:100',
            'orden'                  => 'nullable|integer|min:0',
            'estado'                 => 'boolean',
        ]);
        if (($data['pond_examen1'] + $data['pond_examen2'] + $data['pond_examen3']) !== 100) {
            return back()->withErrors(['pond_examen1' => 'Las ponderaciones deben sumar exactamente 100%'])->withInput();
        }
        $data['estado'] = $request->boolean('estado', true);
        $materia->update($data);
        $this->registrarEnBitacora("Actualizó materia: {$materia->nombre}", $materia->id, 'Materias');
        return redirect()->route('materias.index')
            ->with('success', "Materia «{$materia->nombre}» actualizada.");
    }

    public function destroy(Materia $materia)
    {
        $nombre = $materia->nombre;
        $materia->delete();
        $this->registrarEnBitacora("Eliminó materia: {$nombre}", null, 'Materias');
        return redirect()->route('materias.index')
            ->with('success', "Materia «{$nombre}» eliminada.");
    }
}
PHP

# ── DocenteController ─────────────────────────────────────────────────────────
cat > app/Http/Controllers/DocenteController.php << 'PHP'
<?php
namespace App\Http\Controllers;

use App\Models\Docente;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;

class DocenteController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver docentes')->only('index','show');
        $this->middleware('permission:crear docentes')->only('create','store');
        $this->middleware('permission:editar docentes')->only('edit','update');
        $this->middleware('permission:eliminar docentes')->only('destroy');
    }

    public function index()
    {
        $docentes = Docente::orderBy('apellidos')->get();
        return view('docentes.index', compact('docentes'));
    }

    public function create()
    {
        return view('docentes.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'ci'                            => 'required|string|max:20|unique:docentes,ci',
            'nombres'                       => 'required|string|max:100',
            'apellidos'                     => 'required|string|max:100',
            'telefono'                      => 'nullable|string|max:20',
            'email'                         => 'nullable|email|max:100|unique:docentes,email',
            'titulo_profesional'            => 'required|string|max:150',
            'maestria'                      => 'required|string|max:150',
            'diplomado_educacion_superior'  => 'required|string|max:150',
            'certificacion_ingles'          => 'nullable|string|max:100',
            'otras_certificaciones'         => 'nullable|string',
            'area_formacion'                => 'required|string|max:80',
            'estado'                        => 'boolean',
        ]);
        $data['estado'] = $request->boolean('estado', true);
        $d = Docente::create($data);
        $this->registrarEnBitacora("Registró docente: {$d->nombre_completo}", $d->id, 'Docentes');
        return redirect()->route('docentes.index')
            ->with('success', "Docente «{$d->nombre_completo}» registrado correctamente.");
    }

    public function show(Docente $docente)
    {
        return view('docentes.show', compact('docente'));
    }

    public function edit(Docente $docente)
    {
        return view('docentes.edit', compact('docente'));
    }

    public function update(Request $request, Docente $docente)
    {
        $data = $request->validate([
            'ci'                            => "required|string|max:20|unique:docentes,ci,{$docente->id}",
            'nombres'                       => 'required|string|max:100',
            'apellidos'                     => 'required|string|max:100',
            'telefono'                      => 'nullable|string|max:20',
            'email'                         => "nullable|email|max:100|unique:docentes,email,{$docente->id}",
            'titulo_profesional'            => 'required|string|max:150',
            'maestria'                      => 'required|string|max:150',
            'diplomado_educacion_superior'  => 'required|string|max:150',
            'certificacion_ingles'          => 'nullable|string|max:100',
            'otras_certificaciones'         => 'nullable|string',
            'area_formacion'                => 'required|string|max:80',
            'estado'                        => 'boolean',
        ]);
        $data['estado'] = $request->boolean('estado', true);
        $docente->update($data);
        $this->registrarEnBitacora("Actualizó docente: {$docente->nombre_completo}", $docente->id, 'Docentes');
        return redirect()->route('docentes.index')
            ->with('success', "Docente «{$docente->nombre_completo}» actualizado.");
    }

    public function destroy(Docente $docente)
    {
        $nombre = $docente->nombre_completo;
        $docente->update(['estado' => false]);
        $this->registrarEnBitacora("Desactivó docente: {$nombre}", $docente->id, 'Docentes');
        return redirect()->route('docentes.index')
            ->with('success', "Docente «{$nombre}» desactivado.");
    }
}
PHP

# ── PostulanteController ──────────────────────────────────────────────────────
cat > app/Http/Controllers/PostulanteController.php << 'PHP'
<?php
namespace App\Http\Controllers;

use App\Models\Postulante;
use App\Models\Carrera;
use App\Models\Gestion;
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;

class PostulanteController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver postulantes')->only('index','show');
        $this->middleware('permission:crear postulantes')->only('create','store');
        $this->middleware('permission:editar postulantes')->only('edit','update');
        $this->middleware('permission:eliminar postulantes')->only('destroy');
    }

    public function index()
    {
        $postulantes = Postulante::with('primeraOpcion', 'segundaOpcion', 'gestion')
                        ->orderBy('apellidos')->get();
        return view('postulantes.index', compact('postulantes'));
    }

    public function create()
    {
        $carreras  = Carrera::where('estado', true)->orderBy('nombre')->get();
        $gestiones = Gestion::orderByDesc('fecha_inicio')->get();
        return view('postulantes.create', compact('carreras', 'gestiones'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'gestion_id'          => 'required|exists:gestiones,id',
            'primera_opcion_id'   => 'required|exists:carreras,id',
            'segunda_opcion_id'   => 'required|exists:carreras,id|different:primera_opcion_id',
            'ci'                  => 'required|string|max:20|unique:postulantes,ci',
            'nombres'             => 'required|string|max:100',
            'apellidos'           => 'required|string|max:100',
            'fecha_nacimiento'    => 'nullable|date|before:today',
            'sexo'                => 'nullable|in:M,F,Otro',
            'direccion'           => 'nullable|string|max:200',
            'telefono'            => 'nullable|string|max:20',
            'email'               => 'nullable|email|max:100',
            'colegio_procedencia' => 'nullable|string|max:150',
            'ciudad'              => 'nullable|string|max:80',
            'doc_ci'              => 'boolean',
            'doc_libreta_colegio' => 'boolean',
            'doc_titulo_bachiller'=> 'boolean',
        ]);

        // Validar: la 2ª opción debe ser diferente a la 1ª
        if ($data['primera_opcion_id'] === $data['segunda_opcion_id']) {
            return back()->withErrors(['segunda_opcion_id' => 'La segunda opción debe ser diferente a la primera.'])->withInput();
        }

        $data['doc_ci']               = $request->boolean('doc_ci');
        $data['doc_libreta_colegio']  = $request->boolean('doc_libreta_colegio');
        $data['doc_titulo_bachiller'] = $request->boolean('doc_titulo_bachiller');

        $p = Postulante::create($data);
        $this->registrarEnBitacora("Registró postulante: {$p->nombre_completo} CI:{$p->ci}", $p->id, 'Postulantes');
        return redirect()->route('postulantes.index')
            ->with('success', "Postulante «{$p->nombre_completo}» registrado correctamente.");
    }

    public function show(Postulante $postulante)
    {
        $postulante->load('primeraOpcion', 'segundaOpcion', 'gestion');
        return view('postulantes.show', compact('postulante'));
    }

    public function edit(Postulante $postulante)
    {
        $carreras  = Carrera::where('estado', true)->orderBy('nombre')->get();
        $gestiones = Gestion::orderByDesc('fecha_inicio')->get();
        return view('postulantes.edit', compact('postulante', 'carreras', 'gestiones'));
    }

    public function update(Request $request, Postulante $postulante)
    {
        $data = $request->validate([
            'gestion_id'          => 'required|exists:gestiones,id',
            'primera_opcion_id'   => 'required|exists:carreras,id',
            'segunda_opcion_id'   => "required|exists:carreras,id|different:primera_opcion_id",
            'ci'                  => "required|string|max:20|unique:postulantes,ci,{$postulante->id}",
            'nombres'             => 'required|string|max:100',
            'apellidos'           => 'required|string|max:100',
            'fecha_nacimiento'    => 'nullable|date|before:today',
            'sexo'                => 'nullable|in:M,F,Otro',
            'direccion'           => 'nullable|string|max:200',
            'telefono'            => 'nullable|string|max:20',
            'email'               => 'nullable|email|max:100',
            'colegio_procedencia' => 'nullable|string|max:150',
            'ciudad'              => 'nullable|string|max:80',
            'doc_ci'              => 'boolean',
            'doc_libreta_colegio' => 'boolean',
            'doc_titulo_bachiller'=> 'boolean',
        ]);
        $data['doc_ci']               = $request->boolean('doc_ci');
        $data['doc_libreta_colegio']  = $request->boolean('doc_libreta_colegio');
        $data['doc_titulo_bachiller'] = $request->boolean('doc_titulo_bachiller');
        $postulante->update($data);
        $this->registrarEnBitacora("Actualizó postulante: {$postulante->nombre_completo}", $postulante->id, 'Postulantes');
        return redirect()->route('postulantes.index')
            ->with('success', "Postulante «{$postulante->nombre_completo}» actualizado.");
    }

    public function destroy(Postulante $postulante)
    {
        $nombre = $postulante->nombre_completo;
        $postulante->delete();
        $this->registrarEnBitacora("Eliminó postulante: {$nombre}", null, 'Postulantes');
        return redirect()->route('postulantes.index')
            ->with('success', "Postulante «{$nombre}» eliminado.");
    }
}
PHP
ok "Controladores creados"

# =============================================================================
#  11. VISTAS — POSTULANTES
# =============================================================================
info "Creando vistas de postulantes..."

cat > resources/views/postulantes/index.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Registro de Postulantes')
@push('css')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
@endpush
@section('content')
<div class="page-header">
    <h1>Registro de Postulantes</h1>
    <p class="subtitle">Módulo 2 — Inscripción de estudiantes al CUP (CU-05 a CU-09)</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Postulantes</li></ol>
</div>

@can('crear postulantes')
<div style="margin-bottom:1rem">
    <a href="{{ route('postulantes.create') }}" class="btn btn-primary"><i class="fas fa-user-plus"></i> Registrar Postulante</a>
</div>
@endcan

<div class="card">
    <div class="card-header"><i class="fas fa-users"></i> Postulantes inscritos</div>
    <div class="card-body">
        <div class="table-wrap">
            <table id="tblPost" class="cup-table" style="width:100%">
                <thead><tr><th>#</th><th>CI</th><th>Apellidos y Nombres</th><th>1ª Opción</th><th>2ª Opción</th><th>Documentos</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                @foreach($postulantes as $p)
                <tr>
                    <td style="color:var(--txt-3);font-size:.8rem">{{ $loop->iteration }}</td>
                    <td style="font-family:'Courier New',monospace;font-size:.85rem">{{ $p->ci }}</td>
                    <td><strong>{{ $p->apellidos }}</strong>, {{ $p->nombres }}</td>
                    <td style="font-size:.85rem">{{ $p->primeraOpcion?->nombre ?? '—' }}</td>
                    <td style="font-size:.85rem">{{ $p->segundaOpcion?->nombre ?? '—' }}</td>
                    <td style="text-align:center">
                        @php $docs = ($p->doc_ci ? 1:0)+($p->doc_libreta_colegio ? 1:0)+($p->doc_titulo_bachiller ? 1:0); @endphp
                        <span class="badge {{ $docs == 3 ? 'b-verde' : ($docs > 0 ? 'b-naranja' : 'b-rojo') }}">
                            {{ $docs }}/3
                        </span>
                    </td>
                    <td>
                        <span class="badge {{ $p->estado_badge }}">
                            {{ str_replace('_',' ', ucfirst($p->estado)) }}
                        </span>
                    </td>
                    <td>
                        <div class="btn-group">
                            <a href="{{ route('postulantes.show', $p) }}" class="btn btn-sm btn-outline" title="Ver"><i class="fas fa-eye"></i></a>
                            @can('editar postulantes')
                            <a href="{{ route('postulantes.edit', $p) }}" class="btn btn-sm btn-warn" title="Editar"><i class="fas fa-edit"></i></a>
                            @endcan
                            @can('eliminar postulantes')
                            <form action="{{ route('postulantes.destroy', $p) }}" method="POST" style="display:inline">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-danger" title="Eliminar"
                                    onclick="return confirm('¿Eliminar a {{ $p->nombre_completo }}?')">
                                    <i class="fas fa-trash"></i>
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
@push('js')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script>$(()=>$('#tblPost').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},order:[[2,'asc']],pageLength:20}))</script>
@endpush
@endsection
BLADE

cat > resources/views/postulantes/create.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Registrar Postulante')
@section('content')
<div class="page-header">
    <h1>Registrar Postulante</h1>
    <p class="subtitle">CU-05 — Registro con validación de requisitos obligatorios</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('postulantes.index') }}">Postulantes</a></li><li>Registrar</li></ol>
</div>

<form action="{{ route('postulantes.store') }}" method="POST">
@csrf
<div class="card" style="max-width:860px">
    <div class="card-header"><i class="fas fa-user-plus"></i> Datos del postulante</div>
    <div class="card-body">

        {{-- Gestión --}}
        <div class="form-section">
            <div class="form-section-title">Gestión académica</div>
            <div class="form-row cols-2">
                <div>
                    <label class="form-label">Gestión <span class="req">*</span></label>
                    <select name="gestion_id" class="form-select" required>
                        <option value="">— Seleccionar gestión —</option>
                        @foreach($gestiones as $g)
                        <option value="{{ $g->id }}" {{ old('gestion_id') == $g->id ? 'selected':'' }}>{{ $g->descripcion }}</option>
                        @endforeach
                    </select>
                </div>
            </div>
        </div>

        {{-- Datos personales --}}
        <div class="form-section">
            <div class="form-section-title">Datos personales</div>
            <div class="form-row cols-3">
                <div>
                    <label class="form-label">CI <span class="req">*</span></label>
                    <input type="text" name="ci" class="form-control" value="{{ old('ci') }}" required placeholder="Ej: 12345678">
                </div>
                <div>
                    <label class="form-label">Nombres <span class="req">*</span></label>
                    <input type="text" name="nombres" class="form-control" value="{{ old('nombres') }}" required>
                </div>
                <div>
                    <label class="form-label">Apellidos <span class="req">*</span></label>
                    <input type="text" name="apellidos" class="form-control" value="{{ old('apellidos') }}" required>
                </div>
                <div>
                    <label class="form-label">Fecha de nacimiento</label>
                    <input type="date" name="fecha_nacimiento" class="form-control" value="{{ old('fecha_nacimiento') }}">
                </div>
                <div>
                    <label class="form-label">Sexo</label>
                    <select name="sexo" class="form-select">
                        <option value="">— Seleccionar —</option>
                        <option value="M" {{ old('sexo')=='M'?'selected':'' }}>Masculino</option>
                        <option value="F" {{ old('sexo')=='F'?'selected':'' }}>Femenino</option>
                        <option value="Otro" {{ old('sexo')=='Otro'?'selected':'' }}>Otro</option>
                    </select>
                </div>
                <div>
                    <label class="form-label">Teléfono</label>
                    <input type="text" name="telefono" class="form-control" value="{{ old('telefono') }}" placeholder="Ej: 70012345">
                </div>
                <div>
                    <label class="form-label">Correo electrónico</label>
                    <input type="email" name="email" class="form-control" value="{{ old('email') }}">
                </div>
                <div>
                    <label class="form-label">Colegio de procedencia</label>
                    <input type="text" name="colegio_procedencia" class="form-control" value="{{ old('colegio_procedencia') }}">
                </div>
                <div>
                    <label class="form-label">Ciudad</label>
                    <input type="text" name="ciudad" class="form-control" value="{{ old('ciudad') }}" placeholder="Ej: Santa Cruz">
                </div>
            </div>
            <div style="margin-top:1rem">
                <label class="form-label">Dirección</label>
                <input type="text" name="direccion" class="form-control" value="{{ old('direccion') }}">
            </div>
        </div>

        {{-- Opciones de carrera --}}
        <div class="form-section">
            <div class="form-section-title">Opciones de carrera (CU-08)</div>
            <div class="form-row cols-2">
                <div>
                    <label class="form-label">1ª Opción de carrera <span class="req">*</span></label>
                    <select name="primera_opcion_id" class="form-select" required>
                        <option value="">— Seleccionar —</option>
                        @foreach($carreras as $c)
                        <option value="{{ $c->id }}" {{ old('primera_opcion_id') == $c->id ? 'selected':'' }}>{{ $c->nombre }}</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="form-label">2ª Opción de carrera <span class="req">*</span></label>
                    <select name="segunda_opcion_id" class="form-select" required>
                        <option value="">— Seleccionar —</option>
                        @foreach($carreras as $c)
                        <option value="{{ $c->id }}" {{ old('segunda_opcion_id') == $c->id ? 'selected':'' }}>{{ $c->nombre }}</option>
                        @endforeach
                    </select>
                    <div class="form-hint">Debe ser diferente a la primera opción.</div>
                </div>
            </div>
        </div>

        {{-- Documentos --}}
        <div class="form-section">
            <div class="form-section-title">Documentos requeridos (CU-06)</div>
            <p style="font-size:.83rem;color:var(--txt-3);margin-bottom:.75rem">Los tres documentos son obligatorios para completar la inscripción.</p>
            <div style="display:flex;flex-direction:column;gap:.5rem">
                <label class="form-check">
                    <input type="checkbox" name="doc_ci" value="1" {{ old('doc_ci') ? 'checked':'' }}>
                    <span>Fotocopia de Cédula de Identidad (CI)</span>
                </label>
                <label class="form-check">
                    <input type="checkbox" name="doc_libreta_colegio" value="1" {{ old('doc_libreta_colegio') ? 'checked':'' }}>
                    <span>Libreta de colegio</span>
                </label>
                <label class="form-check">
                    <input type="checkbox" name="doc_titulo_bachiller" value="1" {{ old('doc_titulo_bachiller') ? 'checked':'' }}>
                    <span>Título de Bachiller</span>
                </label>
            </div>
        </div>

        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Registrar Postulante</button>
            <a href="{{ route('postulantes.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
BLADE

# edit y show de postulantes — reutiliza estructura similar
sed 's/Registrar Postulante/Editar Postulante/g; s/postulantes.store/postulantes.update, $postulante/g; s|action="{{ route('\''postulantes.store'\'') }}"|action="{{ route('\''postulantes.update'\'', $postulante) }}" |g' \
    resources/views/postulantes/create.blade.php > /tmp/post_edit_tmp.blade.php 2>/dev/null || true

cat > resources/views/postulantes/edit.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Editar Postulante')
@section('content')
<div class="page-header">
    <h1>Editar Postulante</h1>
    <p class="subtitle">Modificar datos antes del cierre de inscripciones</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('postulantes.index') }}">Postulantes</a></li><li>Editar</li></ol>
</div>
<form action="{{ route('postulantes.update', $postulante) }}" method="POST">
@csrf @method('PUT')
<div class="card" style="max-width:860px">
    <div class="card-header"><i class="fas fa-user-edit"></i> Editando: {{ $postulante->nombre_completo }}</div>
    <div class="card-body">
        <div class="form-section">
            <div class="form-section-title">Gestión académica</div>
            <div class="form-row cols-2"><div>
                <label class="form-label">Gestión <span class="req">*</span></label>
                <select name="gestion_id" class="form-select" required>
                    <option value="">— Seleccionar —</option>
                    @foreach($gestiones as $g)
                    <option value="{{ $g->id }}" {{ old('gestion_id',$postulante->gestion_id) == $g->id ? 'selected':'' }}>{{ $g->descripcion }}</option>
                    @endforeach
                </select>
            </div></div>
        </div>
        <div class="form-section">
            <div class="form-section-title">Datos personales</div>
            <div class="form-row cols-3">
                <div><label class="form-label">CI <span class="req">*</span></label><input type="text" name="ci" class="form-control" value="{{ old('ci',$postulante->ci) }}" required></div>
                <div><label class="form-label">Nombres <span class="req">*</span></label><input type="text" name="nombres" class="form-control" value="{{ old('nombres',$postulante->nombres) }}" required></div>
                <div><label class="form-label">Apellidos <span class="req">*</span></label><input type="text" name="apellidos" class="form-control" value="{{ old('apellidos',$postulante->apellidos) }}" required></div>
                <div><label class="form-label">Fecha de nacimiento</label><input type="date" name="fecha_nacimiento" class="form-control" value="{{ old('fecha_nacimiento',$postulante->fecha_nacimiento?->format('Y-m-d')) }}"></div>
                <div><label class="form-label">Sexo</label>
                    <select name="sexo" class="form-select">
                        <option value="">—</option>
                        <option value="M" {{ old('sexo',$postulante->sexo)=='M'?'selected':'' }}>Masculino</option>
                        <option value="F" {{ old('sexo',$postulante->sexo)=='F'?'selected':'' }}>Femenino</option>
                        <option value="Otro" {{ old('sexo',$postulante->sexo)=='Otro'?'selected':'' }}>Otro</option>
                    </select>
                </div>
                <div><label class="form-label">Teléfono</label><input type="text" name="telefono" class="form-control" value="{{ old('telefono',$postulante->telefono) }}"></div>
                <div><label class="form-label">Correo electrónico</label><input type="email" name="email" class="form-control" value="{{ old('email',$postulante->email) }}"></div>
                <div><label class="form-label">Colegio de procedencia</label><input type="text" name="colegio_procedencia" class="form-control" value="{{ old('colegio_procedencia',$postulante->colegio_procedencia) }}"></div>
                <div><label class="form-label">Ciudad</label><input type="text" name="ciudad" class="form-control" value="{{ old('ciudad',$postulante->ciudad) }}"></div>
            </div>
            <div style="margin-top:1rem"><label class="form-label">Dirección</label><input type="text" name="direccion" class="form-control" value="{{ old('direccion',$postulante->direccion) }}"></div>
        </div>
        <div class="form-section">
            <div class="form-section-title">Opciones de carrera</div>
            <div class="form-row cols-2">
                <div><label class="form-label">1ª Opción <span class="req">*</span></label>
                    <select name="primera_opcion_id" class="form-select" required>
                        @foreach($carreras as $c)<option value="{{ $c->id }}" {{ old('primera_opcion_id',$postulante->primera_opcion_id)==$c->id?'selected':'' }}>{{ $c->nombre }}</option>@endforeach
                    </select>
                </div>
                <div><label class="form-label">2ª Opción <span class="req">*</span></label>
                    <select name="segunda_opcion_id" class="form-select" required>
                        @foreach($carreras as $c)<option value="{{ $c->id }}" {{ old('segunda_opcion_id',$postulante->segunda_opcion_id)==$c->id?'selected':'' }}>{{ $c->nombre }}</option>@endforeach
                    </select>
                </div>
            </div>
        </div>
        <div class="form-section">
            <div class="form-section-title">Documentos entregados</div>
            <div style="display:flex;flex-direction:column;gap:.5rem">
                <label class="form-check"><input type="checkbox" name="doc_ci" value="1" {{ old('doc_ci',$postulante->doc_ci)?'checked':'' }}><span>CI</span></label>
                <label class="form-check"><input type="checkbox" name="doc_libreta_colegio" value="1" {{ old('doc_libreta_colegio',$postulante->doc_libreta_colegio)?'checked':'' }}><span>Libreta de colegio</span></label>
                <label class="form-check"><input type="checkbox" name="doc_titulo_bachiller" value="1" {{ old('doc_titulo_bachiller',$postulante->doc_titulo_bachiller)?'checked':'' }}><span>Título de Bachiller</span></label>
            </div>
        </div>
        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Actualizar</button>
            <a href="{{ route('postulantes.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
BLADE

cat > resources/views/postulantes/show.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Detalle Postulante')
@section('content')
<div class="page-header">
    <h1>{{ $postulante->nombre_completo }}</h1>
    <p class="subtitle">CU-09 — Estado del postulante</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('postulantes.index') }}">Postulantes</a></li><li>Detalle</li></ol>
</div>

<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:860px">
    <div class="card">
        <div class="card-header"><i class="fas fa-user"></i> Datos personales</div>
        <div class="card-body" style="font-size:.88rem">
            <table style="width:100%;border-collapse:collapse">
                @foreach([
                    'CI' => $postulante->ci,
                    'Nombres' => $postulante->nombres,
                    'Apellidos' => $postulante->apellidos,
                    'Fecha de nac.' => $postulante->fecha_nacimiento?->format('d/m/Y'),
                    'Sexo' => $postulante->sexo,
                    'Teléfono' => $postulante->telefono,
                    'Correo' => $postulante->email,
                    'Colegio' => $postulante->colegio_procedencia,
                    'Ciudad' => $postulante->ciudad,
                    'Dirección' => $postulante->direccion,
                ] as $lbl => $val)
                <tr style="border-bottom:1px solid var(--crema-2)">
                    <td style="padding:.45rem .5rem;color:var(--txt-3);white-space:nowrap">{{ $lbl }}</td>
                    <td style="padding:.45rem .5rem;font-weight:500">{{ $val ?? '—' }}</td>
                </tr>
                @endforeach
            </table>
        </div>
    </div>
    <div>
        <div class="card" style="margin-bottom:1rem">
            <div class="card-header"><i class="fas fa-graduation-cap"></i> Opciones de carrera</div>
            <div class="card-body" style="font-size:.88rem">
                <div style="margin-bottom:.6rem"><span style="color:var(--txt-3);font-size:.78rem">1ª OPCIÓN</span><div style="font-weight:600;color:var(--verde)">{{ $postulante->primeraOpcion?->nombre ?? '—' }}</div></div>
                <div><span style="color:var(--txt-3);font-size:.78rem">2ª OPCIÓN</span><div style="font-weight:600">{{ $postulante->segundaOpcion?->nombre ?? '—' }}</div></div>
            </div>
        </div>
        <div class="card" style="margin-bottom:1rem">
            <div class="card-header"><i class="fas fa-file-check"></i> Documentos</div>
            <div class="card-body" style="font-size:.88rem;display:flex;flex-direction:column;gap:.4rem">
                <div><i class="fas fa-{{ $postulante->doc_ci ? 'check-circle' : 'times-circle' }}" style="color:{{ $postulante->doc_ci ? 'var(--verde-3)' : 'var(--danger)' }}"></i> CI</div>
                <div><i class="fas fa-{{ $postulante->doc_libreta_colegio ? 'check-circle' : 'times-circle' }}" style="color:{{ $postulante->doc_libreta_colegio ? 'var(--verde-3)' : 'var(--danger)' }}"></i> Libreta de colegio</div>
                <div><i class="fas fa-{{ $postulante->doc_titulo_bachiller ? 'check-circle' : 'times-circle' }}" style="color:{{ $postulante->doc_titulo_bachiller ? 'var(--verde-3)' : 'var(--danger)' }}"></i> Título de Bachiller</div>
            </div>
        </div>
        <div class="card">
            <div class="card-header"><i class="fas fa-info-circle"></i> Estado actual</div>
            <div class="card-body" style="text-align:center;padding:1.5rem">
                <span class="badge {{ $postulante->estado_badge }}" style="font-size:.9rem;padding:.4rem 1rem">
                    {{ str_replace('_',' ', ucfirst($postulante->estado)) }}
                </span>
                @if($postulante->promedio_general)
                <div style="margin-top:.75rem;font-size:.88rem;color:var(--txt-3)">Promedio general: <strong>{{ number_format($postulante->promedio_general,2) }}</strong></div>
                @endif
            </div>
        </div>
    </div>
</div>

<div style="margin-top:1rem;display:flex;gap:.75rem">
    @can('editar postulantes')
    <a href="{{ route('postulantes.edit', $postulante) }}" class="btn btn-warn"><i class="fas fa-edit"></i> Editar</a>
    @endcan
    <a href="{{ route('postulantes.index') }}" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Volver</a>
</div>
@endsection
BLADE
ok "Vistas postulantes"

# =============================================================================
#  12. VISTAS — CARRERAS
# =============================================================================
info "Creando vistas de carreras..."

cat > resources/views/carreras/index.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Carreras y Cupos')
@push('css')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
@endpush
@section('content')
<div class="page-header">
    <h1>Carreras y Cupos</h1>
    <p class="subtitle">Módulo Gestión Académica — Las 4 carreras de la FICCT (CU-10, CU-11)</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Carreras</li></ol>
</div>
@can('crear carreras')
<div style="margin-bottom:1rem"><a href="{{ route('carreras.create') }}" class="btn btn-primary"><i class="fas fa-plus"></i> Nueva Carrera</a></div>
@endcan
<div class="card">
    <div class="card-header"><i class="fas fa-graduation-cap"></i> Carreras de la Facultad (FICCT)</div>
    <div class="card-body">
        <div class="table-wrap">
            <table id="tblCar" class="cup-table" style="width:100%">
                <thead><tr><th>#</th><th>Carrera</th><th>Sigla</th><th>Descripción</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                @foreach($carreras as $c)
                <tr>
                    <td style="color:var(--txt-3);font-size:.8rem">{{ $loop->iteration }}</td>
                    <td><strong>{{ $c->nombre }}</strong></td>
                    <td><span class="badge b-azul">{{ $c->sigla ?? '—' }}</span></td>
                    <td style="font-size:.85rem;color:var(--txt-3)">{{ Str::limit($c->descripcion, 60) ?? '—' }}</td>
                    <td><span class="badge {{ $c->estado ? 'b-verde':'b-gris' }}">{{ $c->estado?'Activa':'Inactiva' }}</span></td>
                    <td>
                        <div class="btn-group">
                            <a href="{{ route('carreras.show',$c) }}" class="btn btn-sm btn-outline" title="Ver / Cupos"><i class="fas fa-eye"></i></a>
                            @can('editar carreras')
                            <a href="{{ route('carreras.edit',$c) }}" class="btn btn-sm btn-warn" title="Editar"><i class="fas fa-edit"></i></a>
                            @endcan
                            @can('eliminar carreras')
                            <form action="{{ route('carreras.destroy',$c) }}" method="POST" style="display:inline">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-danger" onclick="return confirm('¿Eliminar {{ $c->nombre }}?')"><i class="fas fa-trash"></i></button>
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
@push('js')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script>$(()=>$('#tblCar').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},pageLength:10}))</script>
@endpush
@endsection
BLADE

cat > resources/views/carreras/create.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Nueva Carrera')
@section('content')
<div class="page-header">
    <h1>Registrar Carrera</h1>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>Nueva</li></ol>
</div>
<form action="{{ route('carreras.store') }}" method="POST">
@csrf
<div class="card" style="max-width:600px">
    <div class="card-header"><i class="fas fa-graduation-cap"></i> Datos de la carrera</div>
    <div class="card-body">
        <div class="form-row cols-2">
            <div>
                <label class="form-label">Nombre <span class="req">*</span></label>
                <input type="text" name="nombre" class="form-control" value="{{ old('nombre') }}" required
                    placeholder="Ej: Ingeniería Informática">
                <div class="form-hint">Las 4 carreras: Informática, Sistemas, Redes y Telecomunicaciones, Robótica</div>
            </div>
            <div>
                <label class="form-label">Sigla</label>
                <input type="text" name="sigla" class="form-control" value="{{ old('sigla') }}" placeholder="Ej: INF">
            </div>
        </div>
        <div style="margin-top:1rem">
            <label class="form-label">Descripción</label>
            <textarea name="descripcion" class="form-control">{{ old('descripcion') }}</textarea>
        </div>
        <div style="margin-top:1rem">
            <label class="form-check">
                <input type="checkbox" name="estado" value="1" {{ old('estado',1) ? 'checked':'' }}>
                <span>Carrera activa</span>
            </label>
        </div>
        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Guardar</button>
            <a href="{{ route('carreras.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
BLADE

cat > resources/views/carreras/edit.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Editar Carrera')
@section('content')
<div class="page-header">
    <h1>Editar Carrera</h1>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>Editar</li></ol>
</div>
<form action="{{ route('carreras.update',$carrera) }}" method="POST">
@csrf @method('PUT')
<div class="card" style="max-width:600px">
    <div class="card-header"><i class="fas fa-edit"></i> Editando: {{ $carrera->nombre }}</div>
    <div class="card-body">
        <div class="form-row cols-2">
            <div><label class="form-label">Nombre <span class="req">*</span></label><input type="text" name="nombre" class="form-control" value="{{ old('nombre',$carrera->nombre) }}" required></div>
            <div><label class="form-label">Sigla</label><input type="text" name="sigla" class="form-control" value="{{ old('sigla',$carrera->sigla) }}"></div>
        </div>
        <div style="margin-top:1rem"><label class="form-label">Descripción</label><textarea name="descripcion" class="form-control">{{ old('descripcion',$carrera->descripcion) }}</textarea></div>
        <div style="margin-top:1rem"><label class="form-check"><input type="checkbox" name="estado" value="1" {{ old('estado',$carrera->estado)?'checked':'' }}><span>Carrera activa</span></label></div>
        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Actualizar</button>
            <a href="{{ route('carreras.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
BLADE

cat > resources/views/carreras/show.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Carrera: {{ $carrera->nombre }}')
@section('content')
<div class="page-header">
    <h1>{{ $carrera->nombre }}</h1>
    <p class="subtitle">CU-11 — Cupos por gestión</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>{{ $carrera->sigla }}</li></ol>
</div>

<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:800px;margin-bottom:1.5rem">
    <div class="card">
        <div class="card-header"><i class="fas fa-graduation-cap"></i> Información</div>
        <div class="card-body" style="font-size:.88rem">
            <div style="margin-bottom:.5rem"><span style="color:var(--txt-3)">Nombre completo:</span><div style="font-weight:600">{{ $carrera->nombre }}</div></div>
            <div style="margin-bottom:.5rem"><span style="color:var(--txt-3)">Sigla:</span><div><span class="badge b-azul">{{ $carrera->sigla ?? 'Sin sigla' }}</span></div></div>
            <div><span style="color:var(--txt-3)">Estado:</span><div><span class="badge {{ $carrera->estado ? 'b-verde':'b-gris' }}">{{ $carrera->estado?'Activa':'Inactiva' }}</span></div></div>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><i class="fas fa-sliders-h"></i> Definir cupo (CU-11)</div>
        <div class="card-body">
            <form action="{{ route('carreras.cupos', $carrera) }}" method="POST">
                @csrf
                <div style="margin-bottom:.75rem">
                    <label class="form-label">Gestión <span class="req">*</span></label>
                    <select name="gestion_id" class="form-select" required>
                        <option value="">— Seleccionar —</option>
                        @foreach($gestiones as $g)<option value="{{ $g->id }}">{{ $g->descripcion }}</option>@endforeach
                    </select>
                </div>
                <div style="margin-bottom:.75rem">
                    <label class="form-label">Cupo máximo <span class="req">*</span></label>
                    <input type="number" name="cantidad_maxima" class="form-control" min="1" max="9999" required placeholder="Ej: 50">
                </div>
                <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-save"></i> Guardar cupo</button>
            </form>
        </div>
    </div>
</div>

<div class="card" style="max-width:800px">
    <div class="card-header"><i class="fas fa-table"></i> Cupos registrados por gestión</div>
    <div class="card-body">
        @if($cupos->isEmpty())
        <p style="color:var(--txt-3);font-size:.88rem;text-align:center;padding:1rem">No hay cupos definidos aún.</p>
        @else
        <table class="cup-table">
            <thead><tr><th>Gestión</th><th>Cupo máximo</th><th>Registrado</th></tr></thead>
            <tbody>
            @foreach($cupos as $cupo)
            <tr>
                <td>{{ $cupo->gestion?->descripcion }}</td>
                <td><strong style="color:var(--verde)">{{ $cupo->cantidad_maxima }}</strong></td>
                <td style="font-size:.8rem;color:var(--txt-3)">{{ $cupo->created_at->format('d/m/Y') }}</td>
            </tr>
            @endforeach
            </tbody>
        </table>
        @endif
    </div>
</div>

<div style="margin-top:1rem;display:flex;gap:.75rem">
    @can('editar carreras')
    <a href="{{ route('carreras.edit',$carrera) }}" class="btn btn-warn"><i class="fas fa-edit"></i> Editar</a>
    @endcan
    <a href="{{ route('carreras.index') }}" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Volver</a>
</div>
@endsection
BLADE
ok "Vistas carreras"

# =============================================================================
#  13. VISTAS — MATERIAS
# =============================================================================
info "Creando vistas de materias..."

cat > resources/views/materias/index.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Materias del CUP')
@section('content')
<div class="page-header">
    <h1>Materias del CUP</h1>
    <p class="subtitle">Módulo Exámenes y Control Académico (CU-12) — Computación, Matemáticas, Física, Inglés</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Materias</li></ol>
</div>
@can('crear materias')
<div style="margin-bottom:1rem"><a href="{{ route('materias.create') }}" class="btn btn-primary"><i class="fas fa-plus"></i> Nueva Materia</a></div>
@endcan
<div class="card">
    <div class="card-header"><i class="fas fa-book-open"></i> Materias del Curso Preuniversitario</div>
    <div class="card-body">
        <div class="table-wrap">
            <table class="cup-table">
                <thead><tr><th>Ord.</th><th>Materia</th><th>Área de Formación</th><th>Ponderación (E1/E2/E3)</th><th>Nota mín.</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                @foreach($materias as $m)
                <tr>
                    <td style="color:var(--txt-3)">{{ $m->orden }}</td>
                    <td><strong>{{ $m->nombre }}</strong></td>
                    <td style="font-size:.85rem;color:var(--txt-3)">{{ $m->area_formacion ?? '—' }}</td>
                    <td style="font-family:'Courier New',monospace;font-size:.85rem">
                        <span class="badge b-azul">{{ $m->pond_examen1 }}%</span>
                        <span class="badge b-azul">{{ $m->pond_examen2 }}%</span>
                        <span class="badge b-naranja">{{ $m->pond_examen3 }}%</span>
                    </td>
                    <td style="text-align:center"><strong>{{ $m->nota_minima_aprobacion }}</strong></td>
                    <td><span class="badge {{ $m->estado?'b-verde':'b-gris' }}">{{ $m->estado?'Activa':'Inactiva' }}</span></td>
                    <td>
                        <div class="btn-group">
                            @can('editar materias')
                            <a href="{{ route('materias.edit',$m) }}" class="btn btn-sm btn-warn"><i class="fas fa-edit"></i></a>
                            @endcan
                            @can('eliminar materias')
                            <form action="{{ route('materias.destroy',$m) }}" method="POST" style="display:inline">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-danger" onclick="return confirm('¿Eliminar {{ $m->nombre }}?')"><i class="fas fa-trash"></i></button>
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

cat > resources/views/materias/create.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Nueva Materia')
@section('content')
<div class="page-header">
    <h1>Registrar Materia</h1>
    <p class="subtitle">Configurar ponderación de los 3 exámenes (deben sumar 100%)</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('materias.index') }}">Materias</a></li><li>Nueva</li></ol>
</div>
<form action="{{ route('materias.store') }}" method="POST">
@csrf
<div class="card" style="max-width:640px">
    <div class="card-header"><i class="fas fa-book-open"></i> Datos de la materia</div>
    <div class="card-body">
        <div class="form-row cols-2">
            <div>
                <label class="form-label">Nombre <span class="req">*</span></label>
                <input type="text" name="nombre" class="form-control" value="{{ old('nombre') }}" required
                    placeholder="Ej: Computación">
                <div class="form-hint">Computación · Matemáticas · Física · Inglés</div>
            </div>
            <div>
                <label class="form-label">Área de formación</label>
                <input type="text" name="area_formacion" class="form-control" value="{{ old('area_formacion') }}"
                    placeholder="Ej: Ingeniería de Sistemas">
                <div class="form-hint">Usada para validar qué docente puede dictar esta materia</div>
            </div>
        </div>
        <div style="margin-top:1rem">
            <label class="form-label">Descripción</label>
            <textarea name="descripcion" class="form-control">{{ old('descripcion') }}</textarea>
        </div>

        <div class="form-section" style="margin-top:1.25rem">
            <div class="form-section-title">Ponderación de exámenes</div>
            <p style="font-size:.83rem;color:var(--txt-3);margin-bottom:.75rem">Los tres porcentajes deben sumar exactamente 100. Por defecto: 30% + 30% + 40%</p>
            <div class="form-row cols-3">
                <div>
                    <label class="form-label">Examen 1 (%) <span class="req">*</span></label>
                    <input type="number" name="pond_examen1" class="form-control" value="{{ old('pond_examen1',30) }}" min="1" max="98" required id="p1">
                </div>
                <div>
                    <label class="form-label">Examen 2 (%) <span class="req">*</span></label>
                    <input type="number" name="pond_examen2" class="form-control" value="{{ old('pond_examen2',30) }}" min="1" max="98" required id="p2">
                </div>
                <div>
                    <label class="form-label">Examen 3 (%) <span class="req">*</span></label>
                    <input type="number" name="pond_examen3" class="form-control" value="{{ old('pond_examen3',40) }}" min="1" max="98" required id="p3">
                </div>
            </div>
            <div id="pond-total" style="margin-top:.5rem;font-size:.85rem;font-weight:600"></div>
        </div>

        <div class="form-row cols-2" style="margin-top:1rem">
            <div>
                <label class="form-label">Nota mínima de aprobación <span class="req">*</span></label>
                <input type="number" name="nota_minima_aprobacion" class="form-control" value="{{ old('nota_minima_aprobacion',60) }}" min="1" max="100" required>
            </div>
            <div>
                <label class="form-label">Orden de visualización</label>
                <input type="number" name="orden" class="form-control" value="{{ old('orden',0) }}" min="0">
            </div>
        </div>
        <div style="margin-top:1rem">
            <label class="form-check"><input type="checkbox" name="estado" value="1" {{ old('estado',1)?'checked':'' }}><span>Materia activa</span></label>
        </div>
        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Guardar</button>
            <a href="{{ route('materias.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@push('js')
<script>
function updPond(){
    const s=+document.getElementById('p1').value+(+document.getElementById('p2').value)+(+document.getElementById('p3').value);
    const el=document.getElementById('pond-total');
    el.textContent='Total: '+s+'%';
    el.style.color=s===100?'var(--verde-3)':'var(--danger)';
}
['p1','p2','p3'].forEach(id=>document.getElementById(id).addEventListener('input',updPond));
updPond();
</script>
@endpush
@endsection
BLADE

cat > resources/views/materias/edit.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Editar Materia')
@section('content')
<div class="page-header">
    <h1>Editar Materia: {{ $materia->nombre }}</h1>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('materias.index') }}">Materias</a></li><li>Editar</li></ol>
</div>
<form action="{{ route('materias.update',$materia) }}" method="POST">
@csrf @method('PUT')
<div class="card" style="max-width:640px">
    <div class="card-header"><i class="fas fa-edit"></i> Editando: {{ $materia->nombre }}</div>
    <div class="card-body">
        <div class="form-row cols-2">
            <div><label class="form-label">Nombre <span class="req">*</span></label><input type="text" name="nombre" class="form-control" value="{{ old('nombre',$materia->nombre) }}" required></div>
            <div><label class="form-label">Área de formación</label><input type="text" name="area_formacion" class="form-control" value="{{ old('area_formacion',$materia->area_formacion) }}"></div>
        </div>
        <div style="margin-top:1rem"><label class="form-label">Descripción</label><textarea name="descripcion" class="form-control">{{ old('descripcion',$materia->descripcion) }}</textarea></div>
        <div class="form-section" style="margin-top:1.25rem">
            <div class="form-section-title">Ponderación de exámenes</div>
            <div class="form-row cols-3">
                <div><label class="form-label">Examen 1 (%) <span class="req">*</span></label><input type="number" name="pond_examen1" class="form-control" value="{{ old('pond_examen1',$materia->pond_examen1) }}" min="1" max="98" required id="p1"></div>
                <div><label class="form-label">Examen 2 (%) <span class="req">*</span></label><input type="number" name="pond_examen2" class="form-control" value="{{ old('pond_examen2',$materia->pond_examen2) }}" min="1" max="98" required id="p2"></div>
                <div><label class="form-label">Examen 3 (%) <span class="req">*</span></label><input type="number" name="pond_examen3" class="form-control" value="{{ old('pond_examen3',$materia->pond_examen3) }}" min="1" max="98" required id="p3"></div>
            </div>
            <div id="pond-total" style="margin-top:.5rem;font-size:.85rem;font-weight:600"></div>
        </div>
        <div class="form-row cols-2" style="margin-top:1rem">
            <div><label class="form-label">Nota mínima</label><input type="number" name="nota_minima_aprobacion" class="form-control" value="{{ old('nota_minima_aprobacion',$materia->nota_minima_aprobacion) }}" min="1" max="100" required></div>
            <div><label class="form-label">Orden</label><input type="number" name="orden" class="form-control" value="{{ old('orden',$materia->orden) }}" min="0"></div>
        </div>
        <div style="margin-top:1rem"><label class="form-check"><input type="checkbox" name="estado" value="1" {{ old('estado',$materia->estado)?'checked':'' }}><span>Activa</span></label></div>
        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Actualizar</button>
            <a href="{{ route('materias.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@push('js')
<script>
function updPond(){const s=+document.getElementById('p1').value+(+document.getElementById('p2').value)+(+document.getElementById('p3').value);const el=document.getElementById('pond-total');el.textContent='Total: '+s+'%';el.style.color=s===100?'var(--verde-3)':'var(--danger)';}
['p1','p2','p3'].forEach(id=>document.getElementById(id).addEventListener('input',updPond));updPond();
</script>
@endpush
@endsection
BLADE
ok "Vistas materias"

# =============================================================================
#  14. VISTAS — DOCENTES
# =============================================================================
info "Creando vistas de docentes..."

cat > resources/views/docentes/index.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Docentes')
@push('css')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
@endpush
@section('content')
<div class="page-header">
    <h1>Docentes</h1>
    <p class="subtitle">Módulo Asignación de Grupos y Docentes (CU-14 a CU-16) — Máximo 4 grupos por docente</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Docentes</li></ol>
</div>
@can('crear docentes')
<div style="margin-bottom:1rem"><a href="{{ route('docentes.create') }}" class="btn btn-primary"><i class="fas fa-user-plus"></i> Registrar Docente</a></div>
@endcan
<div class="card">
    <div class="card-header"><i class="fas fa-chalkboard-teacher"></i> Docentes contratados para el CUP</div>
    <div class="card-body">
        <div class="table-wrap">
            <table id="tblDoc" class="cup-table" style="width:100%">
                <thead><tr><th>#</th><th>CI</th><th>Apellidos y Nombres</th><th>Área de Formación</th><th>Título Profesional</th><th>Maestría</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                @foreach($docentes as $d)
                <tr>
                    <td style="color:var(--txt-3);font-size:.8rem">{{ $loop->iteration }}</td>
                    <td style="font-family:'Courier New',monospace;font-size:.85rem">{{ $d->ci }}</td>
                    <td><strong>{{ $d->apellidos }}</strong>, {{ $d->nombres }}</td>
                    <td style="font-size:.85rem">{{ $d->area_formacion ?? '—' }}</td>
                    <td style="font-size:.82rem;color:var(--txt-3)">{{ Str::limit($d->titulo_profesional,40) ?? '—' }}</td>
                    <td style="font-size:.82rem;color:var(--txt-3)">{{ $d->maestria ? '✓ '.\Str::limit($d->maestria,30) : '—' }}</td>
                    <td><span class="badge {{ $d->estado?'b-verde':'b-gris' }}">{{ $d->estado?'Activo':'Inactivo' }}</span></td>
                    <td>
                        <div class="btn-group">
                            <a href="{{ route('docentes.show',$d) }}" class="btn btn-sm btn-outline" title="Ver perfil"><i class="fas fa-eye"></i></a>
                            @can('editar docentes')
                            <a href="{{ route('docentes.edit',$d) }}" class="btn btn-sm btn-warn" title="Editar"><i class="fas fa-edit"></i></a>
                            @endcan
                            @can('eliminar docentes')
                            <form action="{{ route('docentes.destroy',$d) }}" method="POST" style="display:inline">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-danger" onclick="return confirm('¿Desactivar a {{ $d->nombre_completo }}?')"><i class="fas fa-ban"></i></button>
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
@push('js')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script>$(()=>$('#tblDoc').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},order:[[2,'asc']],pageLength:15}))</script>
@endpush
@endsection
BLADE

cat > resources/views/docentes/create.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Registrar Docente')
@section('content')
<div class="page-header">
    <h1>Registrar Docente</h1>
    <p class="subtitle">CU-14 — Requisitos: título profesional, maestría y diplomado en educación superior</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Registrar</li></ol>
</div>
<form action="{{ route('docentes.store') }}" method="POST">
@csrf
<div class="card" style="max-width:800px">
    <div class="card-header"><i class="fas fa-chalkboard-teacher"></i> Perfil del docente</div>
    <div class="card-body">

        <div class="form-section">
            <div class="form-section-title">Datos personales</div>
            <div class="form-row cols-3">
                <div><label class="form-label">CI <span class="req">*</span></label><input type="text" name="ci" class="form-control" value="{{ old('ci') }}" required></div>
                <div><label class="form-label">Nombres <span class="req">*</span></label><input type="text" name="nombres" class="form-control" value="{{ old('nombres') }}" required></div>
                <div><label class="form-label">Apellidos <span class="req">*</span></label><input type="text" name="apellidos" class="form-control" value="{{ old('apellidos') }}" required></div>
                <div><label class="form-label">Teléfono</label><input type="text" name="telefono" class="form-control" value="{{ old('telefono') }}"></div>
                <div><label class="form-label">Correo electrónico</label><input type="email" name="email" class="form-control" value="{{ old('email') }}"></div>
                <div><label class="form-label">Área de formación <span class="req">*</span></label>
                    <select name="area_formacion" class="form-select" required>
                        <option value="">— Seleccionar —</option>
                        @foreach(['Computación / Informática','Matemáticas','Física','Inglés / Idiomas','Redes y Telecomunicaciones','Electrónica','Otra'] as $a)
                        <option value="{{ $a }}" {{ old('area_formacion')==$a?'selected':'' }}>{{ $a }}</option>
                        @endforeach
                    </select>
                    <div class="form-hint">Determina qué materias puede dictar (CU-15)</div>
                </div>
            </div>
        </div>

        <div class="form-section">
            <div class="form-section-title">Perfil profesional (requisitos de contratación)</div>
            <div class="alert alert-warn" style="margin-bottom:1rem"><i class="fas fa-info-circle"></i> Los tres primeros campos son requisitos obligatorios para ser contratado como docente del CUP.</div>
            <div class="form-row cols-2">
                <div>
                    <label class="form-label">Título profesional <span class="req">*</span></label>
                    <input type="text" name="titulo_profesional" class="form-control" value="{{ old('titulo_profesional') }}" required placeholder="Ej: Ing. en Sistemas de Información">
                </div>
                <div>
                    <label class="form-label">Maestría <span class="req">*</span></label>
                    <input type="text" name="maestria" class="form-control" value="{{ old('maestria') }}" required placeholder="Ej: Maestría en Tecnologías de la Información">
                </div>
                <div>
                    <label class="form-label">Diplomado en Educación Superior <span class="req">*</span></label>
                    <input type="text" name="diplomado_educacion_superior" class="form-control" value="{{ old('diplomado_educacion_superior') }}" required placeholder="Ej: Diplomado en Docencia Universitaria">
                </div>
                <div>
                    <label class="form-label">Certificación de Inglés</label>
                    <input type="text" name="certificacion_ingles" class="form-control" value="{{ old('certificacion_ingles') }}" placeholder="Ej: TOEFL 550, Cambridge B2">
                </div>
            </div>
            <div style="margin-top:1rem">
                <label class="form-label">Otras certificaciones</label>
                <textarea name="otras_certificaciones" class="form-control" placeholder="Cursos, diplomados adicionales, certificaciones técnicas...">{{ old('otras_certificaciones') }}</textarea>
            </div>
        </div>

        <div><label class="form-check"><input type="checkbox" name="estado" value="1" {{ old('estado',1)?'checked':'' }}><span>Docente activo</span></label></div>

        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Registrar Docente</button>
            <a href="{{ route('docentes.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
BLADE

cat > resources/views/docentes/edit.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Editar Docente')
@section('content')
<div class="page-header">
    <h1>Editar Docente</h1>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Editar</li></ol>
</div>
<form action="{{ route('docentes.update',$docente) }}" method="POST">
@csrf @method('PUT')
<div class="card" style="max-width:800px">
    <div class="card-header"><i class="fas fa-edit"></i> Editando: {{ $docente->nombre_completo }}</div>
    <div class="card-body">
        <div class="form-section">
            <div class="form-section-title">Datos personales</div>
            <div class="form-row cols-3">
                <div><label class="form-label">CI <span class="req">*</span></label><input type="text" name="ci" class="form-control" value="{{ old('ci',$docente->ci) }}" required></div>
                <div><label class="form-label">Nombres <span class="req">*</span></label><input type="text" name="nombres" class="form-control" value="{{ old('nombres',$docente->nombres) }}" required></div>
                <div><label class="form-label">Apellidos <span class="req">*</span></label><input type="text" name="apellidos" class="form-control" value="{{ old('apellidos',$docente->apellidos) }}" required></div>
                <div><label class="form-label">Teléfono</label><input type="text" name="telefono" class="form-control" value="{{ old('telefono',$docente->telefono) }}"></div>
                <div><label class="form-label">Correo electrónico</label><input type="email" name="email" class="form-control" value="{{ old('email',$docente->email) }}"></div>
                <div><label class="form-label">Área de formación <span class="req">*</span></label>
                    <select name="area_formacion" class="form-select" required>
                        @foreach(['Computación / Informática','Matemáticas','Física','Inglés / Idiomas','Redes y Telecomunicaciones','Electrónica','Otra'] as $a)
                        <option value="{{ $a }}" {{ old('area_formacion',$docente->area_formacion)==$a?'selected':'' }}>{{ $a }}</option>
                        @endforeach
                    </select>
                </div>
            </div>
        </div>
        <div class="form-section">
            <div class="form-section-title">Perfil profesional</div>
            <div class="form-row cols-2">
                <div><label class="form-label">Título profesional <span class="req">*</span></label><input type="text" name="titulo_profesional" class="form-control" value="{{ old('titulo_profesional',$docente->titulo_profesional) }}" required></div>
                <div><label class="form-label">Maestría <span class="req">*</span></label><input type="text" name="maestria" class="form-control" value="{{ old('maestria',$docente->maestria) }}" required></div>
                <div><label class="form-label">Diplomado en Educación Superior <span class="req">*</span></label><input type="text" name="diplomado_educacion_superior" class="form-control" value="{{ old('diplomado_educacion_superior',$docente->diplomado_educacion_superior) }}" required></div>
                <div><label class="form-label">Certificación de Inglés</label><input type="text" name="certificacion_ingles" class="form-control" value="{{ old('certificacion_ingles',$docente->certificacion_ingles) }}"></div>
            </div>
            <div style="margin-top:1rem"><label class="form-label">Otras certificaciones</label><textarea name="otras_certificaciones" class="form-control">{{ old('otras_certificaciones',$docente->otras_certificaciones) }}</textarea></div>
        </div>
        <div><label class="form-check"><input type="checkbox" name="estado" value="1" {{ old('estado',$docente->estado)?'checked':'' }}><span>Activo</span></label></div>
        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Actualizar</button>
            <a href="{{ route('docentes.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
BLADE

cat > resources/views/docentes/show.blade.php << 'BLADE'
@extends('layouts.ap')
@section('title','Perfil Docente')
@section('content')
<div class="page-header">
    <h1>{{ $docente->nombre_completo }}</h1>
    <p class="subtitle">CU-15 — Perfil profesional del docente</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Perfil</li></ol>
</div>

<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:800px">
    <div class="card">
        <div class="card-header"><i class="fas fa-user"></i> Datos personales</div>
        <div class="card-body" style="font-size:.88rem">
            @foreach(['CI'=>$docente->ci,'Nombres'=>$docente->nombres,'Apellidos'=>$docente->apellidos,'Teléfono'=>$docente->telefono,'Email'=>$docente->email,'Área de formación'=>$docente->area_formacion] as $l=>$v)
            <div style="display:flex;justify-content:space-between;padding:.4rem 0;border-bottom:1px solid var(--crema-2)">
                <span style="color:var(--txt-3)">{{ $l }}</span>
                <span style="font-weight:500">{{ $v ?? '—' }}</span>
            </div>
            @endforeach
        </div>
    </div>
    <div class="card">
        <div class="card-header"><i class="fas fa-certificate"></i> Perfil profesional</div>
        <div class="card-body" style="font-size:.88rem">
            <div style="margin-bottom:.75rem">
                <div style="font-size:.72rem;text-transform:uppercase;color:var(--txt-3);margin-bottom:.2rem">Título profesional</div>
                <div style="font-weight:600">{{ $docente->titulo_profesional ?? '—' }}</div>
            </div>
            <div style="margin-bottom:.75rem">
                <div style="font-size:.72rem;text-transform:uppercase;color:var(--txt-3);margin-bottom:.2rem">Maestría</div>
                <div style="font-weight:600">{{ $docente->maestria ?? '—' }}</div>
            </div>
            <div style="margin-bottom:.75rem">
                <div style="font-size:.72rem;text-transform:uppercase;color:var(--txt-3);margin-bottom:.2rem">Diplomado en Educación Superior</div>
                <div style="font-weight:600">{{ $docente->diplomado_educacion_superior ?? '—' }}</div>
            </div>
            @if($docente->certificacion_ingles)
            <div style="margin-bottom:.75rem">
                <div style="font-size:.72rem;text-transform:uppercase;color:var(--txt-3);margin-bottom:.2rem">Certificación de Inglés</div>
                <div style="font-weight:600">{{ $docente->certificacion_ingles }}</div>
            </div>
            @endif
            @if($docente->otras_certificaciones)
            <div>
                <div style="font-size:.72rem;text-transform:uppercase;color:var(--txt-3);margin-bottom:.2rem">Otras certificaciones</div>
                <div style="font-size:.84rem">{{ $docente->otras_certificaciones }}</div>
            </div>
            @endif
        </div>
    </div>
</div>

<div style="margin-top:1rem;display:flex;gap:.75rem">
    @can('editar docentes')
    <a href="{{ route('docentes.edit',$docente) }}" class="btn btn-warn"><i class="fas fa-edit"></i> Editar</a>
    @endcan
    <a href="{{ route('docentes.index') }}" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Volver</a>
</div>
@endsection
BLADE
ok "Vistas docentes"

# =============================================================================
#  15. RUTAS — descomenta y agrega los 4 nuevos recursos
# =============================================================================
info "Actualizando routes/web.php..."

cat > routes/web.php << 'PHP'
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
PHP
ok "routes/web.php"

# =============================================================================
#  16. PERMISOS — agrega los nuevos al PermissionSeeder
# =============================================================================
info "Actualizando PermissionSeeder con permisos de los 4 CRUDs..."

cat > database/seeders/PermissionSeeder.php << 'PHP'
<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;

class PermissionSeeder extends Seeder
{
    public function run(): void
    {
        $permisos = [
            // Módulo Autenticación y Seguridad
            'ver usuarios','crear usuarios','editar usuarios','eliminar usuarios',
            'ver roles','crear roles','editar roles','eliminar roles',
            'ver bitacora',

            // Módulo Registro de Postulantes (CU-05 a CU-09)
            'ver postulantes','crear postulantes','editar postulantes','eliminar postulantes',

            // Módulo Gestión Académica (CU-10 a CU-13)
            'ver carreras','crear carreras','editar carreras','eliminar carreras',
            'ver materias','crear materias','editar materias','eliminar materias',
            'ver gestiones','crear gestiones','editar gestiones','eliminar gestiones',

            // Módulo Asignación de Grupos y Docentes (CU-14 a CU-21)
            'ver docentes','crear docentes','editar docentes','eliminar docentes',
            'ver grupos','crear grupos','editar grupos','eliminar grupos',

            // Módulo Exámenes y Control Académico (CU-22 a CU-26)
            'ver notas','crear notas','editar notas',

            // Módulo Panel Administrativo y Reportes (CU-27 a CU-33)
            'procesar admision','ver reportes',
        ];

        foreach ($permisos as $p) {
            Permission::firstOrCreate(['name' => $p, 'guard_name' => 'web']);
        }
    }
}
PHP

# Actualiza RolesSeeder para que el Admin tenga los nuevos permisos
cat > database/seeders/RolesSeeder.php << 'PHP'
<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolesSeeder extends Seeder
{
    public function run(): void
    {
        // Administrador del Sistema — acceso total
        $admin = Role::firstOrCreate(['name' => 'Administrador del Sistema', 'guard_name' => 'web']);
        $admin->syncPermissions(Permission::all());

        // Docente — solo notas y consulta de sus grupos
        $docente = Role::firstOrCreate(['name' => 'Docente', 'guard_name' => 'web']);
        $docente->syncPermissions([
            'ver grupos','ver postulantes','ver notas','crear notas','editar notas',
        ]);

        // Postulante — consulta sus propios datos
        $postulante = Role::firstOrCreate(['name' => 'Postulante', 'guard_name' => 'web']);
        $postulante->syncPermissions([
            'ver postulantes',
        ]);
    }
}
PHP
ok "Seeders actualizados"

# =============================================================================
#  17. SEEDER de datos iniciales del dominio CUP
#     Carga las 4 carreras, 4 materias y 1 gestión de ejemplo
# =============================================================================
info "Creando CupDataSeeder (carreras, materias, gestión ejemplo)..."

cat > database/seeders/CupDataSeeder.php << 'PHP'
<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Datos maestros del CUP según el documento PDF
 * — 4 carreras de la FICCT
 * — 4 materias con ponderación 30%+30%+40%
 * — 1 gestión académica de ejemplo
 */
class CupDataSeeder extends Seeder
{
    public function run(): void
    {
        // Gestión ejemplo
        DB::table('gestiones')->insertOrIgnore([
            ['descripcion' => 'Semestre 1-2026', 'fecha_inicio' => '2026-01-15',
             'fecha_fin' => '2026-06-30', 'estado' => 'en_curso',
             'created_at' => now(), 'updated_at' => now()],
        ]);

        // 4 Carreras de la FICCT
        DB::table('carreras')->insertOrIgnore([
            ['nombre' => 'Ingeniería Informática',                'sigla' => 'INF',  'estado' => true, 'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Ingeniería de Sistemas',                'sigla' => 'SIS',  'estado' => true, 'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Ingeniería en Redes y Telecomunicaciones','sigla' => 'RYT', 'estado' => true, 'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Ingeniería en Robótica',                'sigla' => 'ROB',  'estado' => true, 'created_at' => now(), 'updated_at' => now()],
        ]);

        // 4 Materias con ponderación 30%+30%+40%
        DB::table('materias')->insertOrIgnore([
            ['nombre' => 'Computación',  'area_formacion' => 'Computación / Informática',
             'pond_examen1' => 30, 'pond_examen2' => 30, 'pond_examen3' => 40,
             'nota_minima_aprobacion' => 60, 'orden' => 1, 'estado' => true,
             'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Matemáticas',  'area_formacion' => 'Matemáticas',
             'pond_examen1' => 30, 'pond_examen2' => 30, 'pond_examen3' => 40,
             'nota_minima_aprobacion' => 60, 'orden' => 2, 'estado' => true,
             'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Física',       'area_formacion' => 'Física',
             'pond_examen1' => 30, 'pond_examen2' => 30, 'pond_examen3' => 40,
             'nota_minima_aprobacion' => 60, 'orden' => 3, 'estado' => true,
             'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Inglés',       'area_formacion' => 'Inglés / Idiomas',
             'pond_examen1' => 30, 'pond_examen2' => 30, 'pond_examen3' => 40,
             'nota_minima_aprobacion' => 60, 'orden' => 4, 'estado' => true,
             'created_at' => now(), 'updated_at' => now()],
        ]);
    }
}
PHP

# Agregar CupDataSeeder al DatabaseSeeder
cat > database/seeders/DatabaseSeeder.php << 'PHP'
<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            PermissionSeeder::class,
            RolesSeeder::class,
            UsuariosSeeder::class,
            CupDataSeeder::class,  // datos maestros: 4 carreras, 4 materias, gestión
        ]);
    }
}
PHP
ok "CupDataSeeder y DatabaseSeeder actualizados"

# =============================================================================
#  18. Limpiar caché
# =============================================================================
info "Limpiando caché..."
php artisan config:clear 2>/dev/null || true
php artisan route:clear  2>/dev/null || true
php artisan view:clear   2>/dev/null || true
php artisan cache:clear  2>/dev/null || true
ok "Caché limpiada"

# =============================================================================
#  RESUMEN
# =============================================================================
echo ""
echo -e "${G}══════════════════════════════════════════════════════════════${N}"
echo -e "${G}  IMPLEMENTACIÓN COMPLETADA — CUP Ciclo 1${N}"
echo -e "${G}══════════════════════════════════════════════════════════════${N}"
echo ""
echo -e "  ${C}MÓDULOS DEL SISTEMA (nombres exactos del documento PDF):${N}"
echo "   1. Módulo de Autenticación y Seguridad       → /users, /roles, /bitacora"
echo "   2. Módulo de Registro de Postulantes          → /postulantes"
echo "   3. Módulo de Gestión Académica                → /carreras, /materias"
echo "   4. Módulo de Asignación de Grupos y Docentes  → /docentes"
echo "   5. Módulo de Exámenes y Control Académico     → próximo ciclo"
echo "   6. Módulo de Panel Administrativo y Reportes  → próximo ciclo"
echo ""
echo -e "  ${C}CRUDs IMPLEMENTADOS:${N}"
echo "   ✓ CRUD Postulantes — campos completos del PDF (CI, sexo, colegio,"
echo "     dirección, opciones de carrera, 3 documentos)"
echo "   ✓ CRUD Carreras    — 4 carreras FICCT + cupos por gestión (CU-11)"
echo "   ✓ CRUD Materias    — ponderación configurable 30%+30%+40%"
echo "   ✓ CRUD Docentes    — perfil profesional completo (título, maestría,"
echo "     diplomado, certificación inglés, área de formación)"
echo ""
echo -e "  ${C}DATOS DE EJEMPLO CARGADOS:${N}"
echo "   • 4 carreras: Informática, Sistemas, Redes y Telecom, Robótica"
echo "   • 4 materias: Computación, Matemáticas, Física, Inglés"
echo "   • 1 gestión: Semestre 1-2026"
echo ""
echo -e "  ${Y}PASOS OBLIGATORIOS:${N}"
echo "   1. php artisan migrate:fresh --seed"
echo "   2. Verificar que fix_bitacora_cup.sh se aplicó (bootstrap/app.php)"
echo ""
echo -e "  ${C}Credenciales (password: 12345678):${N}"
echo "   admin@cup.edu.bo   → Administrador del Sistema (acceso completo)"
echo "   docente@cup.edu.bo → Docente"
echo ""
