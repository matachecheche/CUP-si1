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
