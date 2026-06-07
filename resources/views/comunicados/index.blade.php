@extends('layouts.ap')
@section('title','Comunicados')
@push('css')<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css">@endpush
@section('content')
<div class="ph"><h1>Gestión de Comunicados</h1><p class="sub">CU-21 — Avisos institucionales por audiencia</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Comunicados</li></ol></div>

@if(session('success'))<div style="background:#e8f6ee;color:#14532d;border:1px solid #bbe5c8;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('success') }}</div>@endif
@can('crear comunicados')<div style="margin-bottom:1rem"><a href="{{ route('comunicados.create') }}" class="btn bp"><i class="fas fa-bullhorn"></i> Nuevo Comunicado</a></div>@endcan

<div class="card"><div class="card-hd"><i class="fas fa-bullhorn"></i>Comunicados registrados</div><div class="card-bd">
<div class="tw"><table id="tc" class="ct" style="width:100%">
<thead><tr><th>#</th><th>Título</th><th>Audiencia</th><th>Estado</th><th>Vigente hasta</th><th>Autor</th><th>Creado</th><th>Acciones</th></tr></thead>
<tbody>@foreach($comunicados as $c)<tr>
<td style="color:var(--t3);font-size:.8rem">{{ $loop->iteration }}</td>
<td><strong>{{ $c->titulo }}</strong><div style="font-size:.78rem;color:var(--t3,#8a8678)">{{ \Illuminate\Support\Str::limit($c->contenido, 90) }}</div></td>
<td><span class="bg {{ $c->audiencia_badge }}">{{ ucfirst($c->audiencia) }}</span></td>
<td><span class="bg {{ $c->estado_badge }}">{{ $c->estado_calculado }}</span></td>
<td style="font-size:.84rem">{{ $c->vigente_hasta?->format('d/m/Y') ?? 'Sin vencimiento' }}</td>
<td style="font-size:.84rem">{{ $c->autor?->name ?? '—' }}</td>
<td style="font-size:.84rem">{{ $c->created_at->format('d/m/Y H:i') }}</td>
<td><div class="bg3">
@can('editar comunicados')<a href="{{ route('comunicados.edit',$c) }}" class="btn bsm bw"><i class="fas fa-edit"></i></a>@endcan
@can('eliminar comunicados')<form action="{{ route('comunicados.destroy',$c) }}" method="POST" style="display:inline">@csrf @method('DELETE')
<button class="btn bsm bdr" onclick="return confirm('¿Eliminar «{{ $c->titulo }}»?')"><i class="fas fa-trash"></i></button></form>@endcan
</div></td></tr>@endforeach</tbody></table></div></div></div>
@push('js')<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<script>$(()=>$('#tc').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},order:[[6,'desc']],pageLength:15}))</script>@endpush
@endsection
