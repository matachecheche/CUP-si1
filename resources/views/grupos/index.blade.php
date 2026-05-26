@extends('layouts.ap')
@section('title','Grupos del CUP')
@section('content')
<div class="ph">
  <h1>Grupos del CUP</h1>
  <p class="sub">CU-17 — Generación automática · CU-18/19/20/21 — Asignación docentes y postulantes</p>
  <ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Grupos</li></ol>
</div>

{{-- Resumen inscritos / grupos --}}
<div class="sg" style="margin-bottom:1.5rem">
  <div class="sc" style="cursor:default">
    <div class="si c1"><i class="fas fa-users"></i></div>
    <div><div class="sv">{{ $totalInscritos }}</div><div class="sl">Postulantes inscritos</div></div>
  </div>
  <div class="sc" style="cursor:default">
    <div class="si c2"><i class="fas fa-layer-group"></i></div>
    <div><div class="sv">{{ $gruposNecesarios }}</div><div class="sl">Grupos necesarios (÷60)</div></div>
  </div>
  <div class="sc" style="cursor:default">
    <div class="si c5"><i class="fas fa-check-circle"></i></div>
    <div><div class="sv">{{ $grupos->count() }}</div><div class="sl">Grupos generados</div></div>
  </div>
</div>

@can('crear grupos')
<div style="display:flex;gap:.75rem;margin-bottom:1.25rem">
  <form action="{{ route('grupos.generar') }}" method="POST" style="display:inline">@csrf
    <button type="submit" class="btn bp"><i class="fas fa-magic"></i> Generar grupos automáticamente</button>
  </form>
</div>
@endcan

@if(session('success'))<div class="al al-v"><i class="fas fa-check-circle"></i> {{ session('success') }}</div>@endif
@if($errors->any())<div class="al al-d"><ul>@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif

@if($grupos->isEmpty())
  <div class="al al-w"><i class="fas fa-info-circle"></i> No hay grupos aún. Usa el botón para generarlos.</div>
@else
<div class="card">
  <div class="card-hd"><i class="fas fa-layer-group"></i>Grupos — {{ $gestion?->descripcion }}</div>
  <div class="card-bd">
  <table class="ct">
    <thead><tr><th>Código</th><th>Turno</th><th>Modalidad</th><th>Capacidad</th><th>Inscritos</th><th>Asignaciones</th><th>Estado</th><th></th></tr></thead>
    <tbody>
    @foreach($grupos as $g)
    <tr>
      <td><strong>{{ $g->codigo }}</strong></td>
      <td>{{ ucfirst($g->turno) }}</td>
      <td>{{ ucfirst($g->modalidad) }}</td>
      <td>{{ $g->capacidad_maxima }}</td>
      <td>
        <span class="bg {{ $g->postulantes_count >= $g->capacidad_maxima ? 'bd' : 'bv' }}">
          {{ $g->postulantes_count }} / {{ $g->capacidad_maxima }}
        </span>
      </td>
      <td>{{ $g->asignaciones->count() }} / 4 materias</td>
      <td><span class="bg {{ $g->estado ? 'bv' : 'bg2' }}">{{ $g->estado ? 'Activo' : 'Inactivo' }}</span></td>
      <td><a href="{{ route('grupos.show',$g) }}" class="btn bw bsm"><i class="fas fa-eye"></i></a></td>
    </tr>
    @endforeach
    </tbody>
  </table>
  </div>
</div>
@endif
@endsection
