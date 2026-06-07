<div class="card" style="margin-bottom:1rem"><div class="card-hd"><i class="fas fa-sliders-h"></i>Cupos por carrera</div><div class="card-bd">
<div class="tw"><table class="ct" style="width:100%">
<thead><tr><th>Carrera</th><th>Cupo</th><th>Ocupados</th><th>Libres</th><th>Demanda 1ª opción</th></tr></thead>
<tbody>@foreach($e['cupos'] as $c)<tr>
<td><strong>{{ $c['carrera'] }}</strong></td><td>{{ $c['cupo'] }}</td><td>{{ $c['ocupados'] }}</td>
<td><span class="bg {{ $c['libres']>0 ? 'bv' : 'bd' }}">{{ $c['libres'] }}</span></td>
<td>{{ $c['demanda1'] }}</td></tr>@endforeach</tbody></table></div></div></div>
