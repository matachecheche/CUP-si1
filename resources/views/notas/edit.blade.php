@extends('layouts.ap')
@section('title','Editar Nota')
@section('content')
<div class="ph"><h1>Editar Nota</h1>
<p class="sub">{{ $nota->postulante?->nombre_completo }} · {{ $nota->materia?->nombre }}</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('notas.index',['grupo_id'=>$nota->grupo_id,'materia_id'=>$nota->materia_id]) }}">Notas</a></li><li>Editar</li></ol>
</div>
<form action="{{ route('notas.update',$nota) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:500px"><div class="card-hd"><i class="fas fa-edit"></i>Exámenes</div><div class="card-bd">
<div class="fr c3g">
  <div><label class="fl">Examen 1</label><input type="number" name="examen1" class="fc" value="{{ $nota->examen1 }}" min="0" max="100" step="0.01" required></div>
  <div><label class="fl">Examen 2</label><input type="number" name="examen2" class="fc" value="{{ $nota->examen2 }}" min="0" max="100" step="0.01" required></div>
  <div><label class="fl">Examen 3</label><input type="number" name="examen3" class="fc" value="{{ $nota->examen3 }}" min="0" max="100" step="0.01" required></div>
</div>
<div class="al al-w" style="margin-top:.75rem"><i class="fas fa-calculator"></i> Nota actual: <strong>{{ $nota->nota_final }}</strong> — {{ $nota->aprobado?'Aprobado':'Reprobado' }}</div>
<div style="display:flex;gap:.75rem;margin-top:1.25rem">
  <button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar cambios</button>
  <a href="{{ route('notas.index',['grupo_id'=>$nota->grupo_id,'materia_id'=>$nota->materia_id]) }}" class="btn bo2">Cancelar</a>
</div>
</div></div>
</form>
@endsection
