@extends('layouts.ap')
@section('title','Nueva Carrera')
@section('content')
<div class="ph"><h1>Registrar Carrera</h1><ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('carreras.index') }}">Carreras</a></li><li>Nueva</li></ol></div>
<form action="{{ route('carreras.store') }}" method="POST">@csrf
<div class="card" style="max-width:600px"><div class="card-hd"><i class="fas fa-graduation-cap"></i>Datos de la carrera</div><div class="card-bd">
<div class="fr c2g">
<div><label class="fl">Nombre <span class="rq">*</span></label>
<input type="text" name="nombre" class="fc" value="{{ old('nombre') }}" required placeholder="Ej: Ingeniería Informática">
<p class="fh">Informática · Sistemas · Redes y Telecomunicaciones · Robótica</p></div>
<div><label class="fl">Sigla</label><input type="text" name="sigla" class="fc" value="{{ old('sigla') }}" placeholder="INF"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Descripción</label><textarea name="descripcion" class="fc">{{ old('descripcion') }}</textarea></div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',1)?'checked':'' }}><span>Carrera activa</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar</button>
<a href="{{ route('carreras.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
