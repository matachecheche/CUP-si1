@extends('layouts.ap')
@section('title','Materias del CUP')
@section('content')
<div class="page-header">
    <h1>Materias del CUP</h1>
    <p class="subtitle">Módulo Exámenes y Control Académico (CU-12) — Computación, Matemáticas, Física, Inglés</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Materias</li></ol>
</div>
@can('crear materias')
<div style="margin-bottom:1rem"><a href="{{ route('materias.create') }}" class="btn btn-primary"><i class="fas fa-plus"></i> Nueva Materia</a></div>
@endcan
<div class="card">
    <div class="card-header"><i class="fas fa-book-open"></i> Materias del Curso Preuniversitario</div>
    <div class="card-body">
        <div class="table-wrap">
            <table class="cup-table">
                <thead><tr><th>Ord.</th><th>Materia</th><th>Área de Formación</th><th>Ponderación (E1/E2/E3)</th><th>Nota mín.</th><th>Estado</th><th>Acciones</th></tr></thead>
                <tbody>
                @foreach($materias as $m)
                <tr>
                    <td style="color:var(--txt-3)">{{ $m->orden }}</td>
                    <td><strong>{{ $m->nombre }}</strong></td>
                    <td style="font-size:.85rem;color:var(--txt-3)">{{ $m->area_formacion ?? '—' }}</td>
                    <td style="font-family:'Courier New',monospace;font-size:.85rem">
                        <span class="badge b-azul">{{ $m->pond_examen1 }}%</span>
                        <span class="badge b-azul">{{ $m->pond_examen2 }}%</span>
                        <span class="badge b-naranja">{{ $m->pond_examen3 }}%</span>
                    </td>
                    <td style="text-align:center"><strong>{{ $m->nota_minima_aprobacion }}</strong></td>
                    <td><span class="badge {{ $m->estado?'b-verde':'b-gris' }}">{{ $m->estado?'Activa':'Inactiva' }}</span></td>
                    <td>
                        <div class="btn-group">
                            @can('editar materias')
                            <a href="{{ route('materias.edit',$m) }}" class="btn btn-sm btn-warn"><i class="fas fa-edit"></i></a>
                            @endcan
                            @can('eliminar materias')
                            <form action="{{ route('materias.destroy',$m) }}" method="POST" style="display:inline">
                                @csrf @method('DELETE')
                                <button class="btn btn-sm btn-danger" onclick="return confirm('¿Eliminar {{ $m->nombre }}?')"><i class="fas fa-trash"></i></button>
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
@endsection
