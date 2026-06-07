@extends('layouts.ap')
@section('title','CU-13 · Planilla de notas')
@section('content')
<div class="ph"><h1>CU-13 · Planilla de Notas</h1><p class="sub">Captura masiva por grupo y materia — {{ $gestion->descripcion ?? '' }}</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('notas.index') }}">Notas</a></li><li>Planilla</li></ol></div>

@if(session('success'))<div style="background:#e8f6ee;color:#14532d;border:1px solid #bbe5c8;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('success') }}</div>@endif
@if(session('error'))<div style="background:#fdf4df;color:#7a5a10;border:1px solid #ecd49a;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('error') }}</div>@endif

<form method="GET" style="margin-bottom:1rem;display:flex;gap:.6rem;flex-wrap:wrap">
  <select name="grupo_id" onchange="this.form.submit()" style="padding:.45rem .6rem;border:1px solid #d8d2c4;border-radius:6px;background:#fff">
    @foreach($grupos as $g)<option value="{{ $g->id }}" {{ $grupoSel?->id===$g->id?'selected':'' }}>{{ $g->codigo }} — {{ ucfirst($g->turno) }}</option>@endforeach
  </select>
  <select name="materia_id" onchange="this.form.submit()" style="padding:.45rem .6rem;border:1px solid #d8d2c4;border-radius:6px;background:#fff">
    @foreach($materias as $m)<option value="{{ $m->id }}" {{ $matSel?->id===$m->id?'selected':'' }}>{{ $m->nombre }}</option>@endforeach
  </select>
  <span style="align-self:center;font-size:.8rem;color:var(--t3,#8a8678)">
    Ponderación: {{ $matSel?->pond_examen1 }}% / {{ $matSel?->pond_examen2 }}% / {{ $matSel?->pond_examen3 }}% · Mínima: {{ $matSel?->nota_minima_aprobacion }}</span>
</form>

@if($filas->isEmpty())
<div class="card"><div class="card-bd">El grupo no tiene postulantes inscritos.</div></div>
@else
<form method="POST" action="{{ route('notas.planilla.guardar') }}">@csrf
  <input type="hidden" name="grupo_id" value="{{ $grupoSel->id }}">
  <input type="hidden" name="materia_id" value="{{ $matSel->id }}">
  <div class="card"><div class="card-hd"><i class="fas fa-table"></i>{{ $grupoSel->codigo }} · {{ $matSel->nombre }} ({{ $filas->count() }} postulantes)</div><div class="card-bd">
  <div class="tw"><table class="ct" style="width:100%">
  <thead><tr><th>#</th><th>CI</th><th>Postulante</th><th>Examen 1 ({{ $matSel->pond_examen1 }}%)</th><th>Examen 2 ({{ $matSel->pond_examen2 }}%)</th><th>Examen 3 ({{ $matSel->pond_examen3 }}%)</th><th>Nota final</th><th>Estado</th></tr></thead>
  <tbody>@foreach($filas as $f)<tr>
    <td style="color:var(--t3);font-size:.8rem">{{ $loop->iteration }}</td>
    <td style="font-family:'Courier New',monospace;font-size:.84rem">{{ $f['p']->ci }}</td>
    <td><strong>{{ $f['p']->apellidos }}</strong>, {{ $f['p']->nombres }}</td>
    @foreach(['examen1','examen2','examen3'] as $ex)
    <td><input type="number" name="filas[{{ $f['p']->id }}][{{ $ex }}]" value="{{ old("filas.{$f['p']->id}.$ex", $f['n']?->$ex) }}"
           min="0" max="100" step="0.01" oninput="if(this.value!==''){this.value=Math.max(0,Math.min(100,this.value))}"
           style="width:90px;padding:.35rem .5rem;border:1px solid #d8d2c4;border-radius:6px"></td>
    @endforeach
    <td><strong>{{ $f['n']?->nota_final ?? '—' }}</strong></td>
    <td>@if(!is_null($f['n']?->aprobado))<span class="bg {{ $f['n']->aprobado?'bv':'bd' }}">{{ $f['n']->aprobado?'Aprobado':'Reprobado' }}</span>@else <span class="bg bg2">Sin nota</span>@endif</td>
  </tr>@endforeach</tbody></table></div>
  <div style="margin-top:1rem;display:flex;gap:.6rem;align-items:center;flex-wrap:wrap">
    <button class="btn bp" onclick="return confirm('¿Guardar la planilla? Las filas con los 3 exámenes se registran y recalculan.')"><i class="fas fa-save"></i> Guardar planilla</button>
    <span style="font-size:.78rem;color:var(--t3,#8a8678)">Filas vacías se ignoran; filas con exámenes faltantes no se guardan. Notas entre 0 y 100.</span>
  </div>
  </div></div>
</form>
@endif
@endsection
