@php $k = $dash['kpi'] ?? []; @endphp
@if($dash['gestion'])
<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:1rem;margin:1.2rem 0">
  @foreach([['Total inscritos',$k['inscritos'],'bv'],['Aprobaron el CUP',$k['aprobados'],'bv'],
            ['Reprobados',$k['reprobados'],'bd'],['Grupos habilitados',$k['grupos'],'baz'],
            ['Admitidos',$k['admitidos'],'bv'],['Recaudado','Bs '.number_format($k['recaudado'],2),'bo']] as [$l,$v,$b])
  <div class="card"><div class="card-bd" style="text-align:center">
    <div style="font-size:1.35rem;font-weight:700">{{ $v }}</div><span class="bg {{ $b }}">{{ $l }}</span>
  </div></div>
  @endforeach
</div>
<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(320px,1fr));gap:1rem;margin-bottom:1.4rem">
  <div class="card"><div class="card-hd"><i class="fas fa-chart-pie"></i>Postulantes por estado — {{ $dash['gestion']->descripcion }}</div>
    <div class="card-bd"><canvas id="chEstados" height="220"></canvas></div></div>
  <div class="card"><div class="card-hd"><i class="fas fa-chart-bar"></i>Postulantes por carrera (1ª opción)</div>
    <div class="card-bd"><canvas id="chCarreras" height="220"></canvas></div></div>
</div>
@push('js')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<script>
const P=['#1d3b2a','#b08a2e','#3a5b7d','#7d2c2c','#8a8678'];
new Chart(chEstados,{type:'doughnut',data:{labels:@json($dash['estados']['labels']),
  datasets:[{data:@json($dash['estados']['data']),backgroundColor:P}]},options:{plugins:{legend:{position:'bottom'}}}});
new Chart(chCarreras,{type:'bar',data:{labels:@json($dash['carreras']['labels']),
  datasets:[{label:'Postulantes',data:@json($dash['carreras']['data']),backgroundColor:'#1d3b2a'}]},
  options:{plugins:{legend:{display:false}},scales:{y:{beginAtZero:true}}}});
</script>
@endpush
@endif
