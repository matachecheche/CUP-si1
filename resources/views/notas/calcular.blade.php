@extends('layouts.ap')
@section('title','CU-14 · Cálculo de notas')
@section('content')
<div class="ph"><h1>CU-14 · Calcular Nota Final, Promedio y Estado</h1><p class="sub">Ponderaciones por materia y recálculo masivo — {{ $gestion->descripcion ?? '' }}</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('notas.index') }}">Notas</a></li><li>Cálculo</li></ol></div>

@if(session('success'))<div style="background:#e8f6ee;color:#14532d;border:1px solid #bbe5c8;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('success') }}</div>@endif

<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:1rem;margin-bottom:1.2rem">
  @foreach([['Notas registradas',$resumen['notas'],'bv'],['Sin nota final',$resumen['sin_final'],$resumen['sin_final']?'bna':'bv'],
            ['Aprobados',$resumen['aprobados'],'bv'],['Reprobados',$resumen['reprobados'],'bd'],['Aún en curso',$resumen['en_curso'],'bg2']] as [$l,$v,$b])
  <div class="card"><div class="card-bd" style="text-align:center">
    <div style="font-size:1.5rem;font-weight:700">{{ $v }}</div><span class="bg {{ $b }}">{{ $l }}</span>
  </div></div>
  @endforeach
</div>

<div class="card" style="margin-bottom:1rem"><div class="card-hd"><i class="fas fa-percentage"></i>Ponderaciones por materia (editable en CU-09)</div><div class="card-bd">
<div class="tw"><table class="ct" style="width:100%">
<thead><tr><th>Materia</th><th>Examen 1</th><th>Examen 2</th><th>Examen 3</th><th>Suma</th><th>Nota mínima</th></tr></thead>
<tbody>@foreach($materias as $m)@php $s=$m->pond_examen1+$m->pond_examen2+$m->pond_examen3;@endphp<tr>
<td><strong>{{ $m->nombre }}</strong></td><td>{{ $m->pond_examen1 }}%</td><td>{{ $m->pond_examen2 }}%</td><td>{{ $m->pond_examen3 }}%</td>
<td><span class="bg {{ $s===100?'bv':'bd' }}">{{ $s }}%</span></td><td>{{ $m->nota_minima_aprobacion }}</td>
</tr>@endforeach</tbody></table></div>
<p style="font-size:.82rem;color:var(--t3,#8a8678);margin:.8rem 0 0">
  Fórmula: <code>NotaFinal = E1·p1 + E2·p2 + E3·p3</code> · Materia aprobada si NotaFinal ≥ nota mínima ·
  Postulante <strong>APROBADO</strong> solo si aprueba <strong>las 4 materias</strong>; su promedio general es el promedio de las 4 notas finales.</p>
</div></div>

<div class="card"><div class="card-bd" style="display:flex;justify-content:space-between;align-items:center;gap:1rem;flex-wrap:wrap">
  <div><strong>Recalcular todo</strong>
  <p style="font-size:.82rem;color:var(--t3,#8a8678);margin:.2rem 0 0">Reprocesa la nota final y el estado de todas las notas de la gestión, y el promedio/estado de los postulantes. Los que ya pasaron por admisión (admitidos / no admitidos) no se modifican.</p></div>
  <form method="POST" action="{{ route('notas.calcular.procesar') }}">@csrf
    <button class="btn bp" onclick="return confirm('¿Recalcular notas finales, promedios y estados de toda la gestión?')"><i class="fas fa-calculator"></i> Recalcular todo</button>
  </form>
</div></div>
@endsection
