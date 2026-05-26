@extends('layouts.ap')
@section('title','Registrar Nota')
@section('content')
<div class="ph"><h1>Registrar Nota</h1>
<p class="sub">CU-22 — {{ $postulante->nombre_completo }} · {{ $materia->nombre }}</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('notas.index',['grupo_id'=>$grupo->id,'materia_id'=>$materia->id]) }}">Notas</a></li><li>Registrar</li></ol>
</div>
<form action="{{ route('notas.store') }}" method="POST">@csrf
<input type="hidden" name="postulante_id" value="{{ $postulante->id }}">
<input type="hidden" name="grupo_id"      value="{{ $grupo->id }}">
<input type="hidden" name="materia_id"    value="{{ $materia->id }}">
<div class="card" style="max-width:500px"><div class="card-hd"><i class="fas fa-pencil-alt"></i>Exámenes — ponderación {{ $materia->pond_examen1 }}%+{{ $materia->pond_examen2 }}%+{{ $materia->pond_examen3 }}%</div><div class="card-bd">
<div class="fr c3g">
  <div><label class="fl">Examen 1 ({{ $materia->pond_examen1 }}%) <span class="rq">*</span></label><input type="number" name="examen1" class="fc" min="0" max="100" step="0.01" required></div>
  <div><label class="fl">Examen 2 ({{ $materia->pond_examen2 }}%) <span class="rq">*</span></label><input type="number" name="examen2" class="fc" min="0" max="100" step="0.01" required></div>
  <div><label class="fl">Examen 3 ({{ $materia->pond_examen3 }}%) <span class="rq">*</span></label><input type="number" name="examen3" class="fc" min="0" max="100" step="0.01" required></div>
</div>
<div style="display:flex;gap:.75rem;margin-top:1.25rem">
  <button type="submit" class="btn bp"><i class="fas fa-save"></i> Registrar nota</button>
  <a href="{{ route('notas.index',['grupo_id'=>$grupo->id,'materia_id'=>$materia->id]) }}" class="btn bo2">Cancelar</a>
</div>
</div></div>
</form>
@endsection
