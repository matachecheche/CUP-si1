@php
  $p = $dash['p']; $paso = $dash['paso'];
  $pasos = ['Preinscripción','Pago','En curso','Notas','Resultado'];
  [$rTxt,$rBadge] = match($p->estado){
    'admitido' => ['ADMITIDO — 1ª opción','bv'],
    'admitido_segunda_opcion' => ['ADMITIDO — 2ª opción','bv'],
    'no_admitido' => ['Aprobado sin cupo','bna'],
    'no_aprobado' => ['Reprobado','bd'],
    default => [ucfirst(str_replace('_',' ',$p->estado)),'bg2']};
@endphp
<div class="card" style="margin:1.2rem 0 1rem"><div class="card-bd">
  <strong>Hola, {{ $p->nombres }} {{ $p->apellidos }}</strong>
  <span style="font-size:.82rem;color:var(--t3,#8a8678)"> · CI {{ $p->ci }} · {{ $p->gestion?->descripcion }} · 1ª: {{ $p->primeraOpcion?->nombre }}</span>
  <div style="display:flex;align-items:center;gap:.2rem;margin-top:1rem;flex-wrap:wrap">
    @foreach($pasos as $i => $nombre)
      @php $n=$i+1; $done=$n<$paso; $act=$n===$paso; @endphp
      <div style="display:flex;align-items:center;gap:.4rem">
        <div style="width:30px;height:30px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:.8rem;font-weight:700;
          {{ $done?'background:#1d3b2a;color:#fff':($act?'background:#b08a2e;color:#fff':'background:#eee9dd;color:#8a8678') }}">
          {{ $done ? '✓' : $n }}</div>
        <span style="font-size:.78rem;{{ $act?'font-weight:700':'color:var(--t3,#8a8678)' }}">{{ $nombre }}</span>
      </div>
      @if(!$loop->last)<div style="flex:0 0 26px;height:2px;background:{{ $done?'#1d3b2a':'#e3ddcd' }};margin:0 .3rem"></div>@endif
    @endforeach
  </div>
</div></div>

<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:1rem;margin-bottom:1rem">
  <div class="card"><div class="card-hd"><i class="fas fa-credit-card"></i>Mi pago de inscripción</div><div class="card-bd">
    @if($dash['pago']?->estado === 'pagado')
      <span class="bg bv">Pagado</span>
      <div style="font-size:.86rem;margin-top:.5rem">Comprobante: <strong style="font-family:'Courier New',monospace">{{ $dash['pago']->comprobante }}</strong><br>
      Monto: Bs {{ number_format($dash['pago']->monto,2) }} · {{ $dash['pago']->fecha_pago?->format('d/m/Y H:i') }}</div>
    @elseif($p->estado === 'preinscrito')
      <span class="bg bna">Pendiente</span>
      <p style="font-size:.84rem;margin:.5rem 0">Completa el pago de Bs {{ number_format($p->gestion->costo_inscripcion ?? 850,2) }} para quedar inscrito.</p>
      <a class="btn bp" href="{{ route('pagos.pagar',$p->id) }}"><i class="fas fa-credit-card"></i> Pagar mi inscripción</a>
    @else
      <span class="bg bg2">Sin pago registrado</span>
    @endif
  </div></div>
  <div class="card"><div class="card-hd"><i class="fas fa-bullhorn"></i>Mi resultado de admisión</div><div class="card-bd">
    @if($dash['admision'])
      <span class="bg {{ $rBadge }}">{{ $rTxt }}</span>
      @if($dash['admision']->carreraAsignada)
      <div style="font-size:.95rem;margin-top:.5rem">Carrera asignada: <strong>{{ $dash['admision']->carreraAsignada->nombre }}</strong></div>
      @endif
      <div style="font-size:.86rem;margin-top:.3rem">Promedio: <strong>{{ $dash['admision']->promedio_general ?? $p->promedio_general ?? '—' }}</strong></div>
    @else
      <span class="bg bg2">Pendiente de publicación</span>
      <p style="font-size:.82rem;margin:.5rem 0 0;color:var(--t3,#8a8678)">Cuando la facultad publique los resultados podrás verlos aquí y en la
      <a href="{{ route('resultados.publico') }}" target="_blank">consulta pública</a>.</p>
    @endif
  </div></div>
</div>

@if($dash['notas']->isNotEmpty())
<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:1rem;margin-bottom:1rem">
  <div class="card"><div class="card-hd"><i class="fas fa-file-alt"></i>Mis notas (promedio: {{ $p->promedio_general ?? '—' }})</div><div class="card-bd">
    <div class="tw"><table class="ct" style="width:100%">
    <thead><tr><th>Materia</th><th>Nota final</th><th>Estado</th></tr></thead>
    <tbody>@foreach($dash['notas'] as $n)<tr>
      <td>{{ $n->materia?->nombre }}</td><td><strong>{{ $n->nota_final ?? '—' }}</strong></td>
      <td>@if(!is_null($n->aprobado))<span class="bg {{ $n->aprobado?'bv':'bd' }}">{{ $n->aprobado?'Aprobada':'Reprobada' }}</span>@else <span class="bg bg2">Pendiente</span>@endif</td>
    </tr>@endforeach</tbody></table></div>
  </div></div>
  <div class="card"><div class="card-hd"><i class="fas fa-chart-bar"></i>Mis notas por materia</div><div class="card-bd"><canvas id="chNotas" height="220"></canvas></div></div>
</div>
@push('js')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<script>
const nf=@json($dash['notas']->map(fn($n)=>(float)($n->nota_final ?? 0))->all());
new Chart(chNotas,{type:'bar',data:{labels:@json($dash['notas']->map(fn($n)=>$n->materia?->nombre)->all()),
  datasets:[{label:'Nota final',data:nf,backgroundColor:nf.map(v=>v>=60?'#1d3b2a':'#7d2c2c')}]},
  options:{plugins:{legend:{display:false}},scales:{y:{beginAtZero:true,max:100}}}});
</script>
@endpush
@endif

@if($dash['grupo'])
<div class="card" style="margin-bottom:1.4rem"><div class="card-hd"><i class="fas fa-calendar-alt"></i>Mi grupo: {{ $dash['grupo']->codigo }} ({{ ucfirst($dash['grupo']->turno) }} · {{ ucfirst($dash['grupo']->modalidad) }})</div><div class="card-bd">
<div class="tw"><table class="ct" style="width:100%">
<thead><tr><th>Día</th><th>Horario</th><th>Materia</th><th>Docente</th><th>Aula</th></tr></thead>
<tbody>@foreach($dash['horario'] as $h)<tr>
<td>{{ ucfirst($h->dia) }}</td>
<td style="font-size:.84rem">{{ substr($h->hora_inicio,0,5) }}–{{ substr($h->hora_fin,0,5) }}</td>
<td><strong>{{ $h->materia?->nombre }}</strong></td>
<td style="font-size:.84rem">{{ $h->docente?->apellidos }}, {{ $h->docente?->nombres }}</td>
<td>{{ $h->aula ?? '—' }}</td>
</tr>@endforeach</tbody></table></div>
</div></div>
@endif
