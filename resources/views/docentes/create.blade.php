@extends('layouts.ap')
@section('title','Registrar Docente')
@section('content')
<div class="page-header">
    <h1>Registrar Docente</h1>
    <p class="subtitle">CU-14 — Requisitos: título profesional, maestría y diplomado en educación superior</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Registrar</li></ol>
</div>
<form action="{{ route('docentes.store') }}" method="POST">
@csrf
<div class="card" style="max-width:800px">
    <div class="card-header"><i class="fas fa-chalkboard-teacher"></i> Perfil del docente</div>
    <div class="card-body">

        <div class="form-section">
            <div class="form-section-title">Datos personales</div>
            <div class="form-row cols-3">
                <div><label class="form-label">CI <span class="req">*</span></label><input type="text" name="ci" class="form-control" value="{{ old('ci') }}" required></div>
                <div><label class="form-label">Nombres <span class="req">*</span></label><input type="text" name="nombres" class="form-control" value="{{ old('nombres') }}" required></div>
                <div><label class="form-label">Apellidos <span class="req">*</span></label><input type="text" name="apellidos" class="form-control" value="{{ old('apellidos') }}" required></div>
                <div><label class="form-label">Teléfono</label><input type="text" name="telefono" class="form-control" value="{{ old('telefono') }}"></div>
                <div><label class="form-label">Correo electrónico</label><input type="email" name="email" class="form-control" value="{{ old('email') }}"></div>
                <div><label class="form-label">Área de formación <span class="req">*</span></label>
                    <select name="area_formacion" class="form-select" required>
                        <option value="">— Seleccionar —</option>
                        @foreach(['Computación / Informática','Matemáticas','Física','Inglés / Idiomas','Redes y Telecomunicaciones','Electrónica','Otra'] as $a)
                        <option value="{{ $a }}" {{ old('area_formacion')==$a?'selected':'' }}>{{ $a }}</option>
                        @endforeach
                    </select>
                    <div class="form-hint">Determina qué materias puede dictar (CU-15)</div>
                </div>
            </div>
        </div>

        <div class="form-section">
            <div class="form-section-title">Perfil profesional (requisitos de contratación)</div>
            <div class="alert alert-warn" style="margin-bottom:1rem"><i class="fas fa-info-circle"></i> Los tres primeros campos son requisitos obligatorios para ser contratado como docente del CUP.</div>
            <div class="form-row cols-2">
                <div>
                    <label class="form-label">Título profesional <span class="req">*</span></label>
                    <input type="text" name="titulo_profesional" class="form-control" value="{{ old('titulo_profesional') }}" required placeholder="Ej: Ing. en Sistemas de Información">
                </div>
                <div>
                    <label class="form-label">Maestría <span class="req">*</span></label>
                    <input type="text" name="maestria" class="form-control" value="{{ old('maestria') }}" required placeholder="Ej: Maestría en Tecnologías de la Información">
                </div>
                <div>
                    <label class="form-label">Diplomado en Educación Superior <span class="req">*</span></label>
                    <input type="text" name="diplomado_educacion_superior" class="form-control" value="{{ old('diplomado_educacion_superior') }}" required placeholder="Ej: Diplomado en Docencia Universitaria">
                </div>
                <div>
                    <label class="form-label">Certificación de Inglés</label>
                    <input type="text" name="certificacion_ingles" class="form-control" value="{{ old('certificacion_ingles') }}" placeholder="Ej: TOEFL 550, Cambridge B2">
                </div>
            </div>
            <div style="margin-top:1rem">
                <label class="form-label">Otras certificaciones</label>
                <textarea name="otras_certificaciones" class="form-control" placeholder="Cursos, diplomados adicionales, certificaciones técnicas...">{{ old('otras_certificaciones') }}</textarea>
            </div>
        </div>

        <div><label class="form-check"><input type="checkbox" name="estado" value="1" {{ old('estado',1)?'checked':'' }}><span>Docente activo</span></label></div>

        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Registrar Docente</button>
            <a href="{{ route('docentes.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
