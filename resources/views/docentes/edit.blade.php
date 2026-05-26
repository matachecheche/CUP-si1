@extends('layouts.ap')
@section('title','Editar Docente')
@section('content')
<div class="ph"><h1>Editar Docente</h1><ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Editar</li></ol></div>
<form action="{{ route('docentes.update',$docente) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:780px"><div class="card-hd"><i class="fas fa-edit"></i>Editando: {{ $docente->nombre_completo }}</div><div class="card-bd">
<div class="fs-t">Datos personales</div>
<div class="fr c3g">
<div><label class="fl">CI <span class="rq">*</span></label><input type="text" name="ci" class="fc" value="{{ old('ci',$docente->ci) }}" required></div>
<div><label class="fl">Nombres <span class="rq">*</span></label><input type="text" name="nombres" class="fc" value="{{ old('nombres',$docente->nombres) }}" required></div>
<div><label class="fl">Apellidos <span class="rq">*</span></label><input type="text" name="apellidos" class="fc" value="{{ old('apellidos',$docente->apellidos) }}" required></div>
<div><label class="fl">Teléfono</label><input type="text" name="telefono" class="fc" value="{{ old('telefono',$docente->telefono) }}"></div>
<div><label class="fl">Email</label><input type="email" name="email" class="fc" value="{{ old('email',$docente->email) }}"></div>
<div><label class="fl">Área de formación <span class="rq">*</span></label>
<select name="area_formacion" class="fs" required>
@foreach(['Computación / Informática','Matemáticas','Física','Inglés / Idiomas','Redes y Telecomunicaciones','Electrónica','Otra'] as $a)
<option value="{{ $a }}" {{ old('area_formacion',$docente->area_formacion)==$a?'selected':'' }}>{{ $a }}</option>@endforeach
</select></div>
</div>
<div class="fs-t" style="margin-top:1.25rem">Perfil profesional</div>
<div class="fr c2g">
<div><label class="fl">Título profesional <span class="rq">*</span></label><input type="text" name="titulo_profesional" class="fc" value="{{ old('titulo_profesional',$docente->titulo_profesional) }}" required></div>
<div><label class="fl">Maestría <span class="rq">*</span></label><input type="text" name="maestria" class="fc" value="{{ old('maestria',$docente->maestria) }}" required></div>
<div><label class="fl">Diplomado en Educación Superior <span class="rq">*</span></label><input type="text" name="diplomado_educacion_superior" class="fc" value="{{ old('diplomado_educacion_superior',$docente->diplomado_educacion_superior) }}" required></div>
<div><label class="fl">Certificación de Inglés</label><input type="text" name="certificacion_ingles" class="fc" value="{{ old('certificacion_ingles',$docente->certificacion_ingles) }}"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Otras certificaciones</label><textarea name="otras_certificaciones" class="fc">{{ old('otras_certificaciones',$docente->otras_certificaciones) }}</textarea></div>
<div style="margin-top:1rem"><label class="fck"><input type="checkbox" name="estado" value="1" {{ old('estado',$docente->estado)?'checked':'' }}><span>Activo</span></label></div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Actualizar</button>
<a href="{{ route('docentes.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
