@extends('layouts.ap')
@section('title','Registro de Postulantes')
@push('css')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
@endpush
@section('content')
<div class="page-header">
    <h1>Registro de Postulantes</h1>
    <p class="subtitle">Módulo 2 — Inscripción de estudiantes al CUP (CU-05 a CU-09)</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Postulantes</li></ol>
</div>

@can('crear postulantes')
<div style="margin-bottom:1rem">
    <a href="{{ route('postulantes.create') }}" class="btn btn-primary"><i class="fas fa-user-plus"></i> Registrar Postulante</a>
</div>
@endcan

<div class="card">
    <div class="card-header"><i class="fas fa-users"></i> Postulantes inscritos</div>
    <div class="card-body">
        <div class="table-wrap">
            <table id="tblPost" class="cup-table" style="width:100%">
                <thead><tr><th>#</th><th>CI</th><th>Apellidos y Nombres</th><th>1ª Opción</th><th>2ª Opción</th><th>Documentos</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                @foreach($postulantes as $p)
                <tr>
                    <td style="color:var(--txt-3);font-size:.8rem">{{ $loop->iteration }}</td>
                    <td style="font-family:'Courier New',monospace;font-size:.85rem">{{ $p->ci }}</td>
                    <td><strong>{{ $p->apellidos }}</strong>, {{ $p->nombres }}</td>
                    <td style="font-size:.85rem">{{ $p->primeraOpcion?->nombre ?? '—' }}</td>
                    <td style="font-size:.85rem">{{ $p->segundaOpcion?->nombre ?? '—' }}</td>
                    <td style="text-align:center">
                        @php $docs = ($p->doc_ci ? 1:0)+($p->doc_libreta_colegio ? 1:0)+($p->doc_titulo_bachiller ? 1:0); @endphp
                        <span class="badge {{ $docs == 3 ? 'b-verde' : ($docs > 0 ? 'b-naranja' : 'b-rojo') }}">
                            {{ $docs }}/3
                        </span>
                    </td>
                    <td>
                        <span class="badge {{ $p->estado_badge }}">
                            {{ str_replace('_',' ', ucfirst($p->estado)) }}
                        </span>
                    </td>
                    <td>
                        <div class="btn-group">
                            <a href="{{ route('postulantes.show', $p) }}" class="btn btn-sm btn-outline" title="Ver"><i class="fas fa-eye"></i></a>
                            @can('editar postulantes')
                            <a href="{{ route('postulantes.edit', $p) }}" class="btn btn-sm btn-warn" title="Editar"><i class="fas fa-edit"></i></a>
                            @endcan
                            @can('eliminar postulantes')
                            <form action="{{ route('postulantes.destroy', $p) }}" method="POST" style="display:inline">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-danger" title="Eliminar"
                                    onclick="return confirm('¿Eliminar a {{ $p->nombre_completo }}?')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </form>
                            @endcan
                        </div>
                    </td>
                </tr>
                @endforeach
                </tbody>
            </table>
        </div>
    </div>
</div>
@push('js')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script>$(()=>$('#tblPost').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},order:[[2,'asc']],pageLength:20}))</script>
@endpush
@endsection
