@extends('layouts.ap')
@section('title','Editar Carrera')
@section('content')
<div class="ph"><h1>Editar Carrera</h1><ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>Editar</li></ol></div>
<form action="{{ route('carreras.update',$carrera) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:600px"><div class="card-hd"><i class="fas fa-edit"></i>Editando: {{ $carrera->nombre }}</div><div class="card-bd">
<div class="fr c2g">
<div><label class="fl">Nombre <span class="rq">*</span></label><input type="text" name="nombre" class="fc" value="{{ old('nombre',$carrera->nombre) }}" required></div>
<div><label class="fl">Sigla</label><input type="text" name="sigla" class="fc" value="{{ old('sigla',$carrera->sigla) }}"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Descripción</label><textarea name="descripcion" class="fc">{{ old('descripcion',$carrera->descripcion) }}</textarea></div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',$carrera->estado)?'checked':'' }}><span>Activa</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Actualizar</button>
<a href="{{ route('carreras.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
