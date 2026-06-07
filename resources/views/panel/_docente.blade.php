@php $k = $dash['kpi']; $d = $dash['docente']; @endphp
<div class="card" style="margin:1.2rem 0 1rem;border-left:4px solid #1d3b2a"><div class="card-bd">
  <strong>Bienvenido(a), {{ $d?->nombres }} {{ $d?->apellidos }}</strong>
  <span style="font-size:.82rem;color:var(--t3,#8a8678)"> · {{ $d?->titulo_profesional }}</span>
</div></div>
<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:1rem;margin-bottom:1rem">
  @foreach([['Mis grupos',$k['grupos'],'bv'],['Materias',$k['materias'],'baz'],
            ['Estudiantes',$k['estudiantes'],'bo'],['Clases asignadas',$k['clases'],'bv']] as [$l,$v,$b])
  <div class="card"><div class="card-bd" style="text-align:center">
    <div style="font-size:1.35rem;font-weight:700">{{ $v }}</div><span class="bg {{ $b }}">{{ $l }}</span>
  </div></div>
  @endforeach
</div>
<div class="card" style="margin-bottom:1.4rem"><div class="card-hd"><i class="fas fa-chalkboard-teacher"></i>Mi carga horaria y avance de notas</div><div class="card-bd">
@if($dash['avance']->isEmpty())
  <p style="font-size:.9rem">Aún no tienes grupos asignados. Coordina con la administración (CU-12).</p>
@else
<div class="tw"><table class="ct" style="width:100%">
<thead><tr><th>Grupo</th><th>Materia</th><th>Día</th><th>Horario</th><th>Aula</th><th>Notas registradas</th><th></th></tr></thead>
<tbody>@foreach($dash['avance'] as $a)<tr>
<td><strong>{{ $a->grupo?->codigo }}</strong> <span style="font-size:.74rem;color:var(--t3,#8a8678)">({{ ucfirst($a->grupo?->turno) }})</span></td>
<td>{{ $a->materia?->nombre }}</td>
<td>{{ ucfirst($a->dia) }}</td>
<td style="font-size:.84rem">{{ substr($a->hora_inicio,0,5) }}–{{ substr($a->hora_fin,0,5) }}</td>
<td>{{ $a->aula ?? '—' }}</td>
<td><span class="bg {{ $a->pct>=100?'bv':($a->pct>0?'bna':'bd') }}">{{ $a->reg }}/{{ $a->insc }} ({{ $a->pct }}%)</span></td>
<td><a class="btn bsm bp" href="{{ route('notas.planilla',['grupo_id'=>$a->grupo_id,'materia_id'=>$a->materia_id]) }}" title="Abrir planilla"><i class="fas fa-table"></i> Planilla</a></td>
</tr>@endforeach</tbody></table></div>
<a class="btn bsm bo2" style="margin-top:.8rem" href="{{ route('notas.consultar') }}"><i class="fas fa-search"></i> Consultar notas de un postulante (CU-15)</a>
@endif
</div></div>
