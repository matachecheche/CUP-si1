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
