@extends('layouts.ap')
@section('title','Editar Gestión')
@section('content')
<div class="ph"><h1>Editar Gestión</h1><ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('gestiones.index') }}">Gestiones</a></li><li>Editar</li></ol></div>
<form action="{{ route('gestiones.update',$gestion) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:560px"><div class="card-hd"><i class="fas fa-edit"></i>Editando: {{ $gestion->descripcion }}</div><div class="card-bd">
<div style="margin-bottom:1rem"><label class="fl">Descripción <span class="rq">*</span></label>
<input type="text" name="descripcion" class="fc" value="{{ old('descripcion',$gestion->descripcion) }}" required></div>
<div class="fr c2g">
<div><label class="fl">Fecha de inicio <span class="rq">*</span></label><input type="date" name="fecha_inicio" class="fc" value="{{ old('fecha_inicio',$gestion->fecha_inicio->format('Y-m-d')) }}" required></div>
<div><label class="fl">Fecha de fin <span class="rq">*</span></label><input type="date" name="fecha_fin" class="fc" value="{{ old('fecha_fin',$gestion->fecha_fin->format('Y-m-d')) }}" required></div>
</div>
<div style="margin-top:1rem"><label class="fl">Estado</label>
<select name="estado" class="fs">@foreach(['planificacion'=>'Planificación','inscripcion'=>'Inscripción','en_curso'=>'En Curso','finalizado'=>'Finalizado'] as $v=>$l)
<option value="{{ $v }}" {{ old('estado',$gestion->estado)==$v?'selected':'' }}>{{ $l }}</option>@endforeach</select></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Actualizar</button>
<a href="{{ route('gestiones.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>
@endsection
