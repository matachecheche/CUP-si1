@extends('layouts.ap')
@section('title','Editar Grupo')
@section('content')
<div class="ph"><h1>Editar Grupo {{ $grupo->codigo }}</h1>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('grupos.index') }}">Grupos</a></li><li>Editar</li></ol>
</div>
<form action="{{ route('grupos.update',$grupo) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:500px"><div class="card-hd"><i class="fas fa-edit"></i>Editar grupo</div><div class="card-bd">
<div class="fr c2g">
  <div><label class="fl">Turno</label>
  <select name="turno" class="fs">
    @foreach(['mañana','tarde','noche'] as $t)<option value="{{ $t }}" {{ $grupo->turno===$t?'selected':'' }}>{{ ucfirst($t) }}</option>@endforeach
  </select></div>
  <div><label class="fl">Modalidad</label>
  <select name="modalidad" class="fs">
    @foreach(['presencial','virtual'] as $m)<option value="{{ $m }}" {{ $grupo->modalidad===$m?'selected':'' }}>{{ ucfirst($m) }}</option>@endforeach
  </select></div>
  <div><label class="fl">Capacidad máx.</label><input type="number" name="capacidad_maxima" class="fc" value="{{ $grupo->capacidad_maxima }}" min="1" max="100"></div>
</div>
<label class="fck" style="margin-top:.75rem"><input type="checkbox" name="estado" value="1" {{ $grupo->estado?'checked':'' }}><span>Grupo activo</span></label>
<div style="display:flex;gap:.75rem;margin-top:1.25rem">
  <button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar</button>
  <a href="{{ route('grupos.show',$grupo) }}" class="btn bo2">Cancelar</a>
</div>
</div></div>
</form>
@endsection
