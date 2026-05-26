@extends('layouts.ap')
@section('title','Editar Carrera')
@section('content')
<div class="page-header">
    <h1>Editar Carrera</h1>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>Editar</li></ol>
</div>
<form action="{{ route('carreras.update',$carrera) }}" method="POST">
@csrf @method('PUT')
<div class="card" style="max-width:600px">
    <div class="card-header"><i class="fas fa-edit"></i> Editando: {{ $carrera->nombre }}</div>
    <div class="card-body">
        <div class="form-row cols-2">
            <div><label class="form-label">Nombre <span class="req">*</span></label><input type="text" name="nombre" class="form-control" value="{{ old('nombre',$carrera->nombre) }}" required></div>
            <div><label class="form-label">Sigla</label><input type="text" name="sigla" class="form-control" value="{{ old('sigla',$carrera->sigla) }}"></div>
        </div>
        <div style="margin-top:1rem"><label class="form-label">Descripción</label><textarea name="descripcion" class="form-control">{{ old('descripcion',$carrera->descripcion) }}</textarea></div>
        <div style="margin-top:1rem"><label class="form-check"><input type="checkbox" name="estado" value="1" {{ old('estado',$carrera->estado)?'checked':'' }}><span>Carrera activa</span></label></div>
        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Actualizar</button>
            <a href="{{ route('carreras.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
