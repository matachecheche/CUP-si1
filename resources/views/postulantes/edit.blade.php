@extends('layouts.ap')
@section('title','Editar Postulante')
@section('content')
<div class="ph"><h1>Editar Postulante</h1><p class="sub">Modificar datos antes del cierre de inscripciones</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('postulantes.index') }}">Postulantes</a></li><li>Editar</li></ol></div>
<form action="{{ route('postulantes.update',$postulante) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:840px"><div class="card-hd"><i class="fas fa-user-edit"></i>Editando: {{ $postulante->nombre_completo }}</div><div class="card-bd">
<div class="fs-t">Gestión académica</div>
<div class="fr c2g" style="margin-bottom:1rem"><div><label class="fl">Gestión <span class="rq">*</span></label>
<select name="gestion_id" class="fs" required><option value="">— Seleccionar —</option>
@foreach($gestiones as $g)<option value="{{ $g->id }}" {{ old('gestion_id',$postulante->gestion_id)==$g->id?'selected':'' }}>{{ $g->descripcion }}</option>@endforeach</select></div></div>
<div class="fs-t">Datos personales</div>
<div class="fr c3g">
<div><label class="fl">CI <span class="rq">*</span></label><input type="text" name="ci" class="fc" value="{{ old('ci',$postulante->ci) }}" required></div>
<div><label class="fl">Nombres <span class="rq">*</span></label><input type="text" name="nombres" class="fc" value="{{ old('nombres',$postulante->nombres) }}" required></div>
<div><label class="fl">Apellidos <span class="rq">*</span></label><input type="text" name="apellidos" class="fc" value="{{ old('apellidos',$postulante->apellidos) }}" required></div>
<div><label class="fl">Fecha de nacimiento</label><input type="date" name="fecha_nacimiento" class="fc" value="{{ old('fecha_nacimiento',$postulante->fecha_nacimiento?->format('Y-m-d')) }}"></div>
<div><label class="fl">Sexo</label><select name="sexo" class="fs"><option value="">—</option>
<option value="M" {{ old('sexo',$postulante->sexo)=='M'?'selected':'' }}>Masculino</option>
<option value="F" {{ old('sexo',$postulante->sexo)=='F'?'selected':'' }}>Femenino</option>
<option value="Otro" {{ old('sexo',$postulante->sexo)=='Otro'?'selected':'' }}>Otro</option></select></div>
<div><label class="fl">Teléfono</label><input type="text" name="telefono" class="fc" value="{{ old('telefono',$postulante->telefono) }}"></div>
<div><label class="fl">Correo</label><input type="email" name="email" class="fc" value="{{ old('email',$postulante->email) }}"></div>
<div><label class="fl">Colegio</label><input type="text" name="colegio_procedencia" class="fc" value="{{ old('colegio_procedencia',$postulante->colegio_procedencia) }}"></div>
<div><label class="fl">Ciudad</label><input type="text" name="ciudad" class="fc" value="{{ old('ciudad',$postulante->ciudad) }}"></div>
</div>
<div style="margin-top:1rem"><label class="fl">Dirección</label><input type="text" name="direccion" class="fc" value="{{ old('direccion',$postulante->direccion) }}"></div>
<div class="fs-t" style="margin-top:1.25rem">Opciones de carrera</div>
<div class="fr c2g">
<div><label class="fl">1ª Opción <span class="rq">*</span></label><select name="primera_opcion_id" class="fs" required>
@foreach($carreras as $c)<option value="{{ $c->id }}" {{ old('primera_opcion_id',$postulante->primera_opcion_id)==$c->id?'selected':'' }}>{{ $c->nombre }}</option>@endforeach</select></div>
<div><label class="fl">2ª Opción <span class="rq">*</span></label><select name="segunda_opcion_id" class="fs" required>
@foreach($carreras as $c)<option value="{{ $c->id }}" {{ old('segunda_opcion_id',$postulante->segunda_opcion_id)==$c->id?'selected':'' }}>{{ $c->nombre }}</option>@endforeach</select></div>
</div>
<div class="fs-t" style="margin-top:1.25rem">Documentos entregados</div>
<div style="display:flex;flex-direction:column;gap:.5rem">
<label class="fck"><input type="checkbox" name="doc_ci" value="1" {{ old('doc_ci',$postulante->doc_ci)?'checked':'' }}><span>CI</span></label>
<label class="fck"><input type="checkbox" name="doc_libreta_colegio" value="1" {{ old('doc_libreta_colegio',$postulante->doc_libreta_colegio)?'checked':'' }}><span>Libreta de colegio</span></label>
<label class="fck"><input type="checkbox" name="doc_titulo_bachiller" value="1" {{ old('doc_titulo_bachiller',$postulante->doc_titulo_bachiller)?'checked':'' }}><span>Título de Bachiller</span></label>
</div>
<div style="display:flex;gap:.75rem;margin-top:1.5rem">
<button type="submit" class="btn bp"><i class="fas fa-save"></i> Actualizar</button>
<a href="{{ route('postulantes.index') }}" class="btn bo2">Cancelar</a></div>
</div></div></form>@endsection
