@extends('layouts.ap')
@section('title','Registrar Docente')
@section('content')
<div class="ph"><h1>Registrar Docente</h1><p class="sub">CU-14 — Requisitos: título profesional, maestría y diplomado en educación superior</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Registrar</li></ol></div>
<form action="{{ route('docentes.store') }}" method="POST">@csrf
<div class="card" style="max-width:780px"><div class="card-hd"><i class="fas fa-chalkboard-teacher"></i>Perfil del docente</div><div class="card-bd">
<div class="fs-t">Datos personales</div>
<div class="fr c3g">
<div><label class="fl">CI <span class="rq">*</span></label><input type="text" name="ci" class="fc" value="{{ old('ci') }}" required></div>
<div><label class="fl">Nombres <span class="rq">*</span></label><input type="text" name="nombres" class="fc" value="{{ old('nombres') }}" required></div>
<div><label class="fl">Apellidos <span class="rq">*</span></label><input type="text" name="apellidos" class="fc" value="{{ old('apellidos') }}" required></div>
<div><label class="fl">Teléfono</label><input type="text" name="telefono" class="fc" value="{{ old('telefono') }}"></div>
<div><label class="fl">Correo electrónico</label><input type="email" name="email" class="fc" value="{{ old('email') }}"></div>
<div><label class="fl">Área de formación <span class="rq">*</span></label>
<select name="area_formacion" class="fs" required>
<option value="">— Seleccionar —</option>
@foreach(['Computación / Informática','Matemáticas','Física','Inglés / Idiomas','Redes y Telecomunicaciones','Electrónica','Otra'] as $a)
<option value="{{ $a }}" {{ old('area_formacion')==$a?'selected':'' }}>{{ $a }}</option>@endforeach
</select>
<p class="fh">Determina qué materias puede dictar (CU-15)</p></div>
</div>
<div class="fs-t" style="margin-top:1.25rem">Perfil profesional (requisitos obligatorios de contratación)</div>
<div class="al al-w" style="margin-bottom:1rem"><i class="fas fa-info-circle"></i> Los tres primeros campos son obligatorios según el reglamento de contratación del CUP.</div>
<div class="fr c2g">
<div><label class="fl">Título profesional <span class="rq">*</span></label><input type="text" name="titulo_profesional" class="fc" value="{{ old('titulo_profesional') }}" required placeholder="Ej: Ing. en Sistemas de Información"></div>
<div><label class="fl">Maestría <span class="rq">*</span></label><input type="text" name="maestria" class="fc" value="{{ old('maestria') }}" required placeholder="Ej: Maestría en Tecnologías de la Información"></div>
<div><label class="fl">Diplomado en Educación Superior <span class="rq">*</span></label><input type="text" name="diplomado_educacion_superior" class="fc" value="{{ old('diplomado_educacion_superior') }}" required placeholder="Ej: Diplomado en Docencia Universitaria"></div>
<div><label class="fl">Certificación de Inglés</label><input type="text" name="certificacion_ingles" class="fc" value="{{ old('certificacion_ingles') }}" placeholder="Ej: TOEFL 550, Cambridge B2"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Otras certificaciones</label><textarea name="otras_certificaciones" class="fc" placeholder="Cursos, diplomados adicionales, certificaciones técnicas...">{{ old('otras_certificaciones') }}</textarea></div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',1)?'checked':'' }}><span>Docente activo</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Registrar Docente</button>
<a href="{{ route('docentes.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
