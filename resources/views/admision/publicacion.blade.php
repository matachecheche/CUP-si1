@extends('layouts.ap')
@section('title','CU-18 · Publicación')
@section('content')
<div class="ph"><h1>CU-18 · Publicar resultado final de admisión</h1><p class="sub">Resumen y publicación oficial — {{ $gestion->descripcion }}</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('admision.index') }}">Admisión</a></li><li>Paso 3</li></ol></div>

@if(session('success'))<div style="background:#e8f6ee;color:#14532d;border:1px solid #bbe5c8;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('success') }}</div>@endif
@if(session('error'))<div style="background:#fdecea;color:#92271d;border:1px solid #f5c6c2;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('error') }}</div>@endif

<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(170px,1fr));gap:1rem;margin-bottom:1.2rem">
  @foreach([['Admitidos 1ª',$e['admitidos1'],'bv'],['Admitidos 2ª',$e['admitidos2'],'bv'],
            ['Sin cupo',$e['noAdmitidos'],'bna'],['Reprobados',$e['noAprobados'],'bd'],
            ['En espera',$e['pendientes']->count(),$e['pendientes']->isEmpty()?'bv':'bd']] as [$l,$v,$b])
  <div class="card"><div class="card-bd" style="text-align:center">
    <div style="font-size:1.6rem;font-weight:700">{{ $v }}</div>
    <span class="bg {{ $b }}">{{ $l }}</span>
  </div></div>
  @endforeach
</div>

@include('admision._cupos')

<div class="card"><div class="card-bd" style="display:flex;justify-content:space-between;align-items:center;gap:1rem;flex-wrap:wrap">
  <div>
    <strong>Publicación oficial</strong>
    <p style="font-size:.84rem;color:var(--t3,#8a8678);margin:.2rem 0 0">
      Actas publicadas: <strong>{{ $e['publicados'] }}/{{ $e['totalActas'] }}</strong>.
      Al publicar se genera el acta de los reprobados y los resultados quedan visibles en la
      <a href="{{ route('resultados.publico') }}" target="_blank">consulta pública (CU-22)</a>.
    </p>
    @if($e['pendientes']->isNotEmpty())
    <p style="font-size:.84rem;color:#92271d;margin:.4rem 0 0"><i class="fas fa-triangle-exclamation"></i>
      Bloqueado: hay {{ $e['pendientes']->count() }} aprobados sin asignar — completa <a href="{{ route('admision.primera') }}">CU-16</a> y <a href="{{ route('admision.segunda') }}">CU-17</a>.</p>
    @endif
  </div>
  @can('publicar admision')
  <form method="POST" action="{{ route('admision.publicar') }}">@csrf
    <button class="btn bp" {{ $e['pendientes']->isNotEmpty() ? 'disabled style=opacity:.5;cursor:not-allowed' : '' }}
            onclick="return confirm('¿Publicar oficialmente los resultados de la gestión?')">
      <i class="fas fa-bullhorn"></i> Publicar resultados</button>
  </form>
  @endcan
</div></div>
@endsection
