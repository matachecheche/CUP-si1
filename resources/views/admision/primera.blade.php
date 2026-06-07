@extends('layouts.ap')
@section('title','CU-16 · Primera opción')
@push('css')<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css">@endpush
@section('content')
<div class="ph"><h1>CU-16 · Procesar admisión por primera opción</h1><p class="sub">Ranking de aprobados vs cupos de su 1ª opción — {{ $gestion->descripcion }}</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('admision.index') }}">Admisión</a></li><li>Paso 1</li></ol></div>

@if(session('success'))<div style="background:#e8f6ee;color:#14532d;border:1px solid #bbe5c8;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('success') }}</div>@endif

@include('admision._cupos')

<div class="card" style="margin-bottom:1rem"><div class="card-hd"><i class="fas fa-list-ol"></i>Aprobados en espera ({{ $candidatos->count() }}) — proyección por ranking</div><div class="card-bd">
@if($candidatos->isEmpty())
  <p style="font-size:.9rem">No hay aprobados pendientes. @if($e['admitidos1']>0) El paso 1 ya fue procesado. @endif</p>
@else
<div class="tw"><table id="tc1" class="ct" style="width:100%">
<thead><tr><th>#</th><th>CI</th><th>Postulante</th><th>Promedio</th><th>1ª Opción</th><th>Proyección</th></tr></thead>
<tbody>@foreach($candidatos as $p)<tr>
<td style="color:var(--t3);font-size:.8rem">{{ $loop->iteration }}</td>
<td style="font-family:'Courier New',monospace;font-size:.84rem">{{ $p->ci }}</td>
<td><strong>{{ $p->apellidos }}</strong>, {{ $p->nombres }}</td>
<td><strong>{{ $p->promedio_general }}</strong></td>
<td style="font-size:.84rem">{{ $p->primeraOpcion?->nombre }}</td>
<td><span class="bg {{ $p->proyeccion==='entra'?'bv':'bna' }}">{{ $p->proyeccion==='entra'?'Entra en 1ª':'Pasa a 2ª (CU-17)' }}</span></td>
</tr>@endforeach</tbody></table></div>
<form method="POST" action="{{ route('admision.primera.procesar') }}" style="margin-top:1rem">@csrf
  <button class="btn bp" onclick="return confirm('¿Asignar la primera opción según el ranking y los cupos?')"><i class="fas fa-cogs"></i> Procesar 1ª opción</button>
</form>
@endif
</div></div>

@if($admitidos->isNotEmpty())
<div class="card"><div class="card-hd"><i class="fas fa-user-check"></i>Admitidos en 1ª opción ({{ $admitidos->count() }})</div><div class="card-bd">
<div class="tw"><table class="ct" style="width:100%">
<thead><tr><th>#</th><th>CI</th><th>Postulante</th><th>Promedio</th><th>Carrera asignada</th></tr></thead>
<tbody>@foreach($admitidos as $a)<tr>
<td style="color:var(--t3);font-size:.8rem">{{ $loop->iteration }}</td>
<td style="font-family:'Courier New',monospace;font-size:.84rem">{{ $a->postulante?->ci }}</td>
<td><strong>{{ $a->postulante?->apellidos }}</strong>, {{ $a->postulante?->nombres }}</td>
<td>{{ $a->promedio_general }}</td>
<td><strong>{{ $a->carreraAsignada?->nombre }}</strong></td>
</tr>@endforeach</tbody></table></div>
<a class="btn bsm bo2" style="margin-top:.8rem" href="{{ route('admision.segunda') }}">Continuar al paso 2 (CU-17) <i class="fas fa-arrow-right"></i></a>
</div></div>
@endif
@push('js')<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<script>$(()=>{ if(document.getElementById('tc1')) $('#tc1').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},order:[],pageLength:15}) })</script>@endpush
@endsection
