@extends('layouts.ap')
@section('title','Nueva Carrera')
@section('content')
<div class="page-header">
    <h1>Registrar Carrera</h1>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>Nueva</li></ol>
</div>
<form action="{{ route('carreras.store') }}" method="POST">
@csrf
<div class="card" style="max-width:600px">
    <div class="card-header"><i class="fas fa-graduation-cap"></i> Datos de la carrera</div>
    <div class="card-body">
        <div class="form-row cols-2">
            <div>
                <label class="form-label">Nombre <span class="req">*</span></label>
                <input type="text" name="nombre" class="form-control" value="{{ old('nombre') }}" required
                    placeholder="Ej: Ingeniería Informática">
                <div class="form-hint">Las 4 carreras: Informática, Sistemas, Redes y Telecomunicaciones, Robótica</div>
            </div>
            <div>
                <label class="form-label">Sigla</label>
                <input type="text" name="sigla" class="form-control" value="{{ old('sigla') }}" placeholder="Ej: INF">
            </div>
        </div>
        <div style="margin-top:1rem">
            <label class="form-label">Descripción</label>
            <textarea name="descripcion" class="form-control">{{ old('descripcion') }}</textarea>
        </div>
        <div style="margin-top:1rem">
            <label class="form-check">
                <input type="checkbox" name="estado" value="1" {{ old('estado',1) ? 'checked':'' }}>
                <span>Carrera activa</span>
            </label>
        </div>
        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Guardar</button>
            <a href="{{ route('carreras.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
