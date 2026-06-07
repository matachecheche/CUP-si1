@extends('layouts.ap')
@section('title','Proceso de Admisión')
@section('content')
<div class="ph"><h1>Proceso de Admisión</h1><p class="sub">CU-16 · CU-17 · CU-18 — Tablero del proceso ({{ $gestion->descripcion ?? 'sin gestión en curso' }})</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Admisión</li></ol></div>

@if(session('success'))<div style="background:#e8f6ee;color:#14532d;border:1px solid #bbe5c8;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('success') }}</div>@endif
@if(session('error'))<div style="background:#fdecea;color:#92271d;border:1px solid #f5c6c2;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('error') }}</div>@endif

@if($gestion && $e)
@php
  $p1 = $e['admitidos1'] > 0;
  $p2 = $p1 && $e['pendientes']->isEmpty();
  $p3 = $e['publicados'] > 0 && $e['publicados'] === $e['totalActas'] && $e['totalActas'] > 0;
@endphp
<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:1rem;margin-bottom:1.2rem">
  <div class="card"><div class="card-bd">
    <div style="display:flex;justify-content:space-between;align-items:center"><strong>Paso 1 · CU-16</strong>
      <span class="bg {{ $p1?'bv':'bna' }}">{{ $p1?'Procesado':'Pendiente' }}</span></div>
    <p style="font-size:.84rem;color:var(--t3,#8a8678)">Procesar admisión por primera opción</p>
    <div style="font-size:.86rem">Admitidos 1ª: <strong>{{ $e['admitidos1'] }}</strong> · En espera: <strong>{{ $e['pendientes']->count() }}</strong></div>
    <a class="btn bsm bp" style="margin-top:.7rem" href="{{ route('admision.primera') }}"><i class="fas fa-cogs"></i> Ir al paso 1</a>
  </div></div>
  <div class="card"><div class="card-bd">
    <div style="display:flex;justify-content:space-between;align-items:center"><strong>Paso 2 · CU-17</strong>
      <span class="bg {{ $p2?'bv':($p1?'bna':'bg2') }}">{{ $p2?'Completado':($p1?'Pendiente':'Espera paso 1') }}</span></div>
    <p style="font-size:.84rem;color:var(--t3,#8a8678)">Reasignar postulantes a segunda opción</p>
    <div style="font-size:.86rem">Admitidos 2ª: <strong>{{ $e['admitidos2'] }}</strong> · Sin cupo: <strong>{{ $e['noAdmitidos'] }}</strong></div>
    <a class="btn bsm bp" style="margin-top:.7rem" href="{{ route('admision.segunda') }}"><i class="fas fa-exchange-alt"></i> Ir al paso 2</a>
  </div></div>
  <div class="card"><div class="card-bd">
    <div style="display:flex;justify-content:space-between;align-items:center"><strong>Paso 3 · CU-18</strong>
      <span class="bg {{ $p3?'bv':'bna' }}">{{ $p3?'Publicado':'Sin publicar' }}</span></div>
    <p style="font-size:.84rem;color:var(--t3,#8a8678)">Publicar resultado final de admisión</p>
    <div style="font-size:.86rem">Actas publicadas: <strong>{{ $e['publicados'] }}/{{ $e['totalActas'] }}</strong></div>
    <a class="btn bsm bp" style="margin-top:.7rem" href="{{ route('admision.publicacion') }}"><i class="fas fa-bullhorn"></i> Ir al paso 3</a>
  </div></div>
</div>

@include('admision._cupos')

@can('procesar admision')
<div class="card" style="border-left:4px solid #7d2c2c"><div class="card-bd" style="display:flex;justify-content:space-between;align-items:center;gap:1rem;flex-wrap:wrap">
  <div><strong>Reiniciar proceso</strong>
  <p style="font-size:.82rem;color:var(--t3,#8a8678);margin:.2rem 0 0">Borra las actas de la gestión y devuelve a los admitidos/no admitidos al estado «aprobado» para re-ejecutar los 3 pasos. No toca notas ni reprobados.</p></div>
  <form method="POST" action="{{ route('admision.reiniciar') }}">@csrf
    <button class="btn bdr" onclick="return confirm('¿Reiniciar el proceso de admisión de esta gestión?')"><i class="fas fa-rotate-left"></i> Reiniciar</button>
  </form>
</div></div>
@endcan
@else
<div class="card"><div class="card-bd">No hay una gestión en curso.</div></div>
@endif
@endsection
