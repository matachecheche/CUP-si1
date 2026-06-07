@extends('layouts.ap')
@section('title','CU-15 · Consultar notas')
@push('css')<style>@media print{ .no-print, aside, nav, header, .ph ol, form{display:none !important} }</style>@endpush
@section('content')
<div class="ph"><h1>CU-15 · Consultar Notas del Postulante</h1><p class="sub">Boleta de calificaciones por postulante</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('notas.index') }}">Notas</a></li><li>Consulta</li></ol></div>

<form method="GET" class="no-print" style="margin-bottom:1rem;display:flex;gap:.6rem;flex-wrap:wrap">
  <input type="text" name="q" value="{{ $q }}" placeholder="CI o apellido del postulante…"
         style="flex:1;min-width:240px;padding:.55rem .8rem;border:1px solid #d8d2c4;border-radius:6px">
  <button class="btn bp"><i class="fas fa-search"></i> Buscar</button>
</form>

@if($matches->isNotEmpty())
<div class="card" style="margin-bottom:1rem"><div class="card-hd"><i class="fas fa-users"></i>Coincidencias ({{ $matches->count() }})</div><div class="card-bd">
<div class="tw"><table class="ct" style="width:100%"><thead><tr><th>CI</th><th>Postulante</th><th>1ª Opción</th><th></th></tr></thead>
<tbody>@foreach($matches as $m)<tr>
<td style="font-family:'Courier New',monospace;font-size:.84rem">{{ $m->ci }}</td>
<td><strong>{{ $m->apellidos }}</strong>, {{ $m->nombres }}</td>
<td style="font-size:.84rem">{{ $m->primeraOpcion?->nombre }}</td>
<td><a class="btn bsm bo2" href="{{ route('notas.consultar',['postulante_id'=>$m->id,'q'=>$q]) }}"><i class="fas fa-eye"></i> Ver boleta</a></td>
</tr>@endforeach</tbody></table></div></div></div>
@elseif(!is_null($q) && !$sel)
<div class="card" style="margin-bottom:1rem"><div class="card-bd">Sin coincidencias para «{{ $q }}».</div></div>
@endif

@if($sel)
<div class="card"><div class="card-hd"><i class="fas fa-file-alt"></i>Boleta de calificaciones</div><div class="card-bd">
  <div style="display:flex;justify-content:space-between;gap:1rem;flex-wrap:wrap;margin-bottom:.8rem">
    <div>
      <div style="font-size:1.1rem"><strong>{{ $sel->apellidos }}, {{ $sel->nombres }}</strong> · CI {{ $sel->ci }}</div>
      <div style="font-size:.84rem;color:var(--t3,#8a8678)">{{ $sel->gestion?->descripcion }} · 1ª: {{ $sel->primeraOpcion?->nombre }} · 2ª: {{ $sel->segundaOpcion?->nombre }}</div>
    </div>
    <div style="text-align:right">
      <div>Promedio general: <strong style="font-size:1.2rem">{{ $sel->promedio_general ?? '—' }}</strong></div>
      <span class="bg {{ $sel->estado_badge }}">{{ ucfirst(str_replace('_',' ',$sel->estado)) }}</span>
    </div>
  </div>
  @if($boleta->isEmpty())
    <p style="font-size:.9rem">Este postulante aún no tiene notas registradas.</p>
  @else
  <div class="tw"><table class="ct" style="width:100%">
  <thead><tr><th>Materia</th><th>Grupo</th><th>Examen 1</th><th>Examen 2</th><th>Examen 3</th><th>Nota final</th><th>Estado</th></tr></thead>
  <tbody>@foreach($boleta as $n)<tr>
    <td><strong>{{ $n->materia?->nombre }}</strong><div style="font-size:.74rem;color:var(--t3,#8a8678)">{{ $n->materia?->pond_examen1 }}/{{ $n->materia?->pond_examen2 }}/{{ $n->materia?->pond_examen3 }}%</div></td>
    <td style="font-size:.84rem">{{ $n->grupo?->codigo }}</td>
    <td>{{ $n->examen1 }}</td><td>{{ $n->examen2 }}</td><td>{{ $n->examen3 }}</td>
    <td><strong>{{ $n->nota_final ?? '—' }}</strong></td>
    <td>@if(!is_null($n->aprobado))<span class="bg {{ $n->aprobado?'bv':'bd' }}">{{ $n->aprobado?'Aprobado':'Reprobado' }}</span>@else <span class="bg bg2">Pendiente</span>@endif</td>
  </tr>@endforeach</tbody></table></div>
  <button class="btn bo2 no-print" style="margin-top:1rem" onclick="window.print()"><i class="fas fa-print"></i> Imprimir boleta</button>
  @endif
</div></div>
@endif
@endsection
