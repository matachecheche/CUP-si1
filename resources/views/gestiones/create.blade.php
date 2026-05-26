@extends('layouts.ap')
@section('title','Nueva Gestión')
@section('content')
<div class="ph"><h1>Nueva Gestión Académica</h1><ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('gestiones.index') }}">Gestiones</a></li><li>Nueva</li></ol></div>
<form action="{{ route('gestiones.store') }}" method="POST">@csrf
<div class="card" style="max-width:560px"><div class="card-hd"><i class="fas fa-calendar-plus"></i>Datos de la gestión</div><div class="card-bd">
<div style="margin-bottom:1rem"><label class="fl">Descripción <span class="rq">*</span></label>
<input type="text" name="descripcion" class="fc" value="{{ old('descripcion') }}" required placeholder="Ej: Semestre 1-2026">
<p class="fh">Formato sugerido: Semestre 1-2026, Semestre 2-2026, etc.</p></div>
<div class="fr c2g">
<div><label class="fl">Fecha de inicio <span class="rq">*</span></label><input type="date" name="fecha_inicio" class="fc" value="{{ old('fecha_inicio') }}" required></div>
<div><label class="fl">Fecha de fin <span class="rq">*</span></label><input type="date" name="fecha_fin" class="fc" value="{{ old('fecha_fin') }}" required></div>
</div>
<div style="margin-top:1rem"><label class="fl">Estado</label>
<select name="estado" class="fs"><option value="planificacion" {{ old('estado')=='planificacion'?'selected':'' }}>Planificación</option>
<option value="inscripcion" {{ old('estado')=='inscripcion'?'selected':'' }}>Inscripción</option>
<option value="en_curso" {{ old('estado')=='en_curso'?'selected':'' }}>En Curso</option>
<option value="finalizado" {{ old('estado')=='finalizado'?'selected':'' }}>Finalizado</option></select></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar</button>
<a href="{{ route('gestiones.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>
@endsection
