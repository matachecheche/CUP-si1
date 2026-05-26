@extends('layouts.ap')
@section('title','Carreras y Cupos')
@push('css')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
@endpush
@section('content')
<div class="page-header">
    <h1>Carreras y Cupos</h1>
    <p class="subtitle">Módulo Gestión Académica — Las 4 carreras de la FICCT (CU-10, CU-11)</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Carreras</li></ol>
</div>
@can('crear carreras')
<div style="margin-bottom:1rem"><a href="{{ route('carreras.create') }}" class="btn btn-primary"><i class="fas fa-plus"></i> Nueva Carrera</a></div>
@endcan
<div class="card">
    <div class="card-header"><i class="fas fa-graduation-cap"></i> Carreras de la Facultad (FICCT)</div>
    <div class="card-body">
        <div class="table-wrap">
            <table id="tblCar" class="cup-table" style="width:100%">
                <thead><tr><th>#</th><th>Carrera</th><th>Sigla</th><th>Descripción</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                @foreach($carreras as $c)
                <tr>
                    <td style="color:var(--txt-3);font-size:.8rem">{{ $loop->iteration }}</td>
                    <td><strong>{{ $c->nombre }}</strong></td>
                    <td><span class="badge b-azul">{{ $c->sigla ?? '—' }}</span></td>
                    <td style="font-size:.85rem;color:var(--txt-3)">{{ Str::limit($c->descripcion, 60) ?? '—' }}</td>
                    <td><span class="badge {{ $c->estado ? 'b-verde':'b-gris' }}">{{ $c->estado?'Activa':'Inactiva' }}</span></td>
                    <td>
                        <div class="btn-group">
                            <a href="{{ route('carreras.show',$c) }}" class="btn btn-sm btn-outline" title="Ver / Cupos"><i class="fas fa-eye"></i></a>
                            @can('editar carreras')
                            <a href="{{ route('carreras.edit',$c) }}" class="btn btn-sm btn-warn" title="Editar"><i class="fas fa-edit"></i></a>
                            @endcan
                            @can('eliminar carreras')
                            <form action="{{ route('carreras.destroy',$c) }}" method="POST" style="display:inline">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-danger" onclick="return confirm('¿Eliminar {{ $c->nombre }}?')"><i class="fas fa-trash"></i></button>
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
<script>$(()=>$('#tblCar').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},pageLength:10}))</script>
@endpush
@endsection
