@extends('layouts.ap')
@section('title','Nueva Materia')
@section('content')
<div class="ph"><h1>Registrar Materia</h1><p class="sub">Configurar ponderación de los 3 exámenes — deben sumar 100%</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('materias.index') }}">Materias</a></li><li>Nueva</li></ol></div>
<form action="{{ route('materias.store') }}" method="POST">@csrf
<div class="card" style="max-width:620px"><div class="card-hd"><i class="fas fa-book-open"></i>Datos de la materia</div><div class="card-bd">
<div class="fr c2g">
<div><label class="fl">Nombre <span class="rq">*</span></label>
<input type="text" name="nombre" class="fc" value="{{ old('nombre') }}" required placeholder="Ej: Computación">
<p class="fh">Computación · Matemáticas · Física · Inglés</p></div>
<div><label class="fl">Área de formación</label>
<input type="text" name="area_formacion" class="fc" value="{{ old('area_formacion') }}" placeholder="Ej: Computación / Informática">
<p class="fh">Usado para validar qué docente puede dictar esta materia</p></div>
</div>
<div style="margin-top:1rem"><label class="fl">Descripción</label><textarea name="descripcion" class="fc">{{ old('descripcion') }}</textarea></div>
<div style="margin-top:1.25rem"><div class="fs-t">Ponderación de los 3 exámenes</div>
<p style="font-size:.83rem;color:var(--t3);margin-bottom:.75rem">Los tres porcentajes deben sumar exactamente 100. Por defecto: 30%+30%+40%</p>
<div class="fr c3g">
<div><label class="fl">Examen 1 (%) <span class="rq">*</span></label><input type="number" name="pond_examen1" id="p1" class="fc" value="{{ old('pond_examen1',30) }}" min="1" max="98" required></div>
<div><label class="fl">Examen 2 (%) <span class="rq">*</span></label><input type="number" name="pond_examen2" id="p2" class="fc" value="{{ old('pond_examen2',30) }}" min="1" max="98" required></div>
<div><label class="fl">Examen 3 (%) <span class="rq">*</span></label><input type="number" name="pond_examen3" id="p3" class="fc" value="{{ old('pond_examen3',40) }}" min="1" max="98" required></div>
</div>
<div id="ptot" style="margin-top:.5rem;font-size:.85rem;font-weight:600"></div></div>
<div class="fr c2g" style="margin-top:1rem">
<div><label class="fl">Nota mínima aprobación <span class="rq">*</span></label><input type="number" name="nota_minima_aprobacion" class="fc" value="{{ old('nota_minima_aprobacion',60) }}" min="1" max="100" required></div>
<div><label class="fl">Orden visualización</label><input type="number" name="orden" class="fc" value="{{ old('orden',0) }}" min="0"></div>
</div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',1)?'checked':'' }}><span>Materia activa</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar</button>
<a href="{{ route('materias.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>
@push('js')<script>
function upd(){var s=+document.getElementById('p1').value+(+document.getElementById('p2').value)+(+document.getElementById('p3').value);var e=document.getElementById('ptot');e.textContent='Total: '+s+'%';e.style.color=s===100?'var(--v3)':'var(--d)';}
['p1','p2','p3'].forEach(function(i){document.getElementById(i).addEventListener('input',upd)});upd();
</script>@endpush
@endsection
