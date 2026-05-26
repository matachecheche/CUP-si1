@extends('layouts.ap')
@section('title','Docentes')
@push('css')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
@endpush
@section('content')
<div class="page-header">
    <h1>Docentes</h1>
    <p class="subtitle">Módulo Asignación de Grupos y Docentes (CU-14 a CU-16) — Máximo 4 grupos por docente</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Docentes</li></ol>
</div>
@can('crear docentes')
<div style="margin-bottom:1rem"><a href="{{ route('docentes.create') }}" class="btn btn-primary"><i class="fas fa-user-plus"></i> Registrar Docente</a></div>
@endcan
<div class="card">
    <div class="card-header"><i class="fas fa-chalkboard-teacher"></i> Docentes contratados para el CUP</div>
    <div class="card-body">
        <div class="table-wrap">
            <table id="tblDoc" class="cup-table" style="width:100%">
                <thead><tr><th>#</th><th>CI</th><th>Apellidos y Nombres</th><th>Área de Formación</th><th>Título Profesional</th><th>Maestría</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                @foreach($docentes as $d)
                <tr>
                    <td style="color:var(--txt-3);font-size:.8rem">{{ $loop->iteration }}</td>
                    <td style="font-family:'Courier New',monospace;font-size:.85rem">{{ $d->ci }}</td>
                    <td><strong>{{ $d->apellidos }}</strong>, {{ $d->nombres }}</td>
                    <td style="font-size:.85rem">{{ $d->area_formacion ?? '—' }}</td>
                    <td style="font-size:.82rem;color:var(--txt-3)">{{ Str::limit($d->titulo_profesional,40) ?? '—' }}</td>
                    <td style="font-size:.82rem;color:var(--txt-3)">{{ $d->maestria ? '✓ '.\Str::limit($d->maestria,30) : '—' }}</td>
                    <td><span class="badge {{ $d->estado?'b-verde':'b-gris' }}">{{ $d->estado?'Activo':'Inactivo' }}</span></td>
                    <td>
                        <div class="btn-group">
                            <a href="{{ route('docentes.show',$d) }}" class="btn btn-sm btn-outline" title="Ver perfil"><i class="fas fa-eye"></i></a>
                            @can('editar docentes')
                            <a href="{{ route('docentes.edit',$d) }}" class="btn btn-sm btn-warn" title="Editar"><i class="fas fa-edit"></i></a>
                            @endcan
                            @can('eliminar docentes')
                            <form action="{{ route('docentes.destroy',$d) }}" method="POST" style="display:inline">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-danger" onclick="return confirm('¿Desactivar a {{ $d->nombre_completo }}?')"><i class="fas fa-ban"></i></button>
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
<script>$(()=>$('#tblDoc').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},order:[[2,'asc']],pageLength:15}))</script>
@endpush
@endsection
