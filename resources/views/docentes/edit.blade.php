@extends('layouts.ap')
@section('title','Editar Docente')
@section('content')
<div class="page-header">
    <h1>Editar Docente</h1>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Editar</li></ol>
</div>
<form action="{{ route('docentes.update',$docente) }}" method="POST">
@csrf @method('PUT')
<div class="card" style="max-width:800px">
    <div class="card-header"><i class="fas fa-edit"></i> Editando: {{ $docente->nombre_completo }}</div>
    <div class="card-body">
        <div class="form-section">
            <div class="form-section-title">Datos personales</div>
            <div class="form-row cols-3">
                <div><label class="form-label">CI <span class="req">*</span></label><input type="text" name="ci" class="form-control" value="{{ old('ci',$docente->ci) }}" required></div>
                <div><label class="form-label">Nombres <span class="req">*</span></label><input type="text" name="nombres" class="form-control" value="{{ old('nombres',$docente->nombres) }}" required></div>
                <div><label class="form-label">Apellidos <span class="req">*</span></label><input type="text" name="apellidos" class="form-control" value="{{ old('apellidos',$docente->apellidos) }}" required></div>
                <div><label class="form-label">Teléfono</label><input type="text" name="telefono" class="form-control" value="{{ old('telefono',$docente->telefono) }}"></div>
                <div><label class="form-label">Correo electrónico</label><input type="email" name="email" class="form-control" value="{{ old('email',$docente->email) }}"></div>
                <div><label class="form-label">Área de formación <span class="req">*</span></label>
                    <select name="area_formacion" class="form-select" required>
                        @foreach(['Computación / Informática','Matemáticas','Física','Inglés / Idiomas','Redes y Telecomunicaciones','Electrónica','Otra'] as $a)
                        <option value="{{ $a }}" {{ old('area_formacion',$docente->area_formacion)==$a?'selected':'' }}>{{ $a }}</option>
                        @endforeach
                    </select>
                </div>
            </div>
        </div>
        <div class="form-section">
            <div class="form-section-title">Perfil profesional</div>
            <div class="form-row cols-2">
                <div><label class="form-label">Título profesional <span class="req">*</span></label><input type="text" name="titulo_profesional" class="form-control" value="{{ old('titulo_profesional',$docente->titulo_profesional) }}" required></div>
                <div><label class="form-label">Maestría <span class="req">*</span></label><input type="text" name="maestria" class="form-control" value="{{ old('maestria',$docente->maestria) }}" required></div>
                <div><label class="form-label">Diplomado en Educación Superior <span class="req">*</span></label><input type="text" name="diplomado_educacion_superior" class="form-control" value="{{ old('diplomado_educacion_superior',$docente->diplomado_educacion_superior) }}" required></div>
                <div><label class="form-label">Certificación de Inglés</label><input type="text" name="certificacion_ingles" class="form-control" value="{{ old('certificacion_ingles',$docente->certificacion_ingles) }}"></div>
            </div>
            <div style="margin-top:1rem"><label class="form-label">Otras certificaciones</label><textarea name="otras_certificaciones" class="form-control">{{ old('otras_certificaciones',$docente->otras_certificaciones) }}</textarea></div>
        </div>
        <div><label class="form-check"><input type="checkbox" name="estado" value="1" {{ old('estado',$docente->estado)?'checked':'' }}><span>Activo</span></label></div>
        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Actualizar</button>
            <a href="{{ route('docentes.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
