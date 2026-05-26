@extends('layouts.ap')
@section('title','Carrera: {{ $carrera->nombre }}')
@section('content')
<div class="page-header">
    <h1>{{ $carrera->nombre }}</h1>
    <p class="subtitle">CU-11 — Cupos por gestión</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>{{ $carrera->sigla }}</li></ol>
</div>

<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:800px;margin-bottom:1.5rem">
    <div class="card">
        <div class="card-header"><i class="fas fa-graduation-cap"></i> Información</div>
        <div class="card-body" style="font-size:.88rem">
            <div style="margin-bottom:.5rem"><span style="color:var(--txt-3)">Nombre completo:</span><div style="font-weight:600">{{ $carrera->nombre }}</div></div>
            <div style="margin-bottom:.5rem"><span style="color:var(--txt-3)">Sigla:</span><div><span class="badge b-azul">{{ $carrera->sigla ?? 'Sin sigla' }}</span></div></div>
            <div><span style="color:var(--txt-3)">Estado:</span><div><span class="badge {{ $carrera->estado ? 'b-verde':'b-gris' }}">{{ $carrera->estado?'Activa':'Inactiva' }}</span></div></div>
        </div>
    </div>

    <div class="card">
        <div class="card-header"><i class="fas fa-sliders-h"></i> Definir cupo (CU-11)</div>
        <div class="card-body">
            <form action="{{ route('carreras.cupos', $carrera) }}" method="POST">
                @csrf
                <div style="margin-bottom:.75rem">
                    <label class="form-label">Gestión <span class="req">*</span></label>
                    <select name="gestion_id" class="form-select" required>
                        <option value="">— Seleccionar —</option>
                        @foreach($gestiones as $g)<option value="{{ $g->id }}">{{ $g->descripcion }}</option>@endforeach
                    </select>
                </div>
                <div style="margin-bottom:.75rem">
                    <label class="form-label">Cupo máximo <span class="req">*</span></label>
                    <input type="number" name="cantidad_maxima" class="form-control" min="1" max="9999" required placeholder="Ej: 50">
                </div>
                <button type="submit" class="btn btn-primary btn-sm"><i class="fas fa-save"></i> Guardar cupo</button>
            </form>
        </div>
    </div>
</div>

<div class="card" style="max-width:800px">
    <div class="card-header"><i class="fas fa-table"></i> Cupos registrados por gestión</div>
    <div class="card-body">
        @if($cupos->isEmpty())
        <p style="color:var(--txt-3);font-size:.88rem;text-align:center;padding:1rem">No hay cupos definidos aún.</p>
        @else
        <table class="cup-table">
            <thead><tr><th>Gestión</th><th>Cupo máximo</th><th>Registrado</th></tr></thead>
            <tbody>
            @foreach($cupos as $cupo)
            <tr>
                <td>{{ $cupo->gestion?->descripcion }}</td>
                <td><strong style="color:var(--verde)">{{ $cupo->cantidad_maxima }}</strong></td>
                <td style="font-size:.8rem;color:var(--txt-3)">{{ $cupo->created_at->format('d/m/Y') }}</td>
            </tr>
            @endforeach
            </tbody>
        </table>
        @endif
    </div>
</div>

<div style="margin-top:1rem;display:flex;gap:.75rem">
    @can('editar carreras')
    <a href="{{ route('carreras.edit',$carrera) }}" class="btn btn-warn"><i class="fas fa-edit"></i> Editar</a>
    @endcan
    <a href="{{ route('carreras.index') }}" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Volver</a>
</div>
@endsection
