@extends('layouts.ap')
@section('title','Registrar Postulante')
@section('content')
<div class="page-header">
    <h1>Registrar Postulante</h1>
    <p class="subtitle">CU-05 — Registro con validación de requisitos obligatorios</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('postulantes.index') }}">Postulantes</a></li><li>Registrar</li></ol>
</div>

<form action="{{ route('postulantes.store') }}" method="POST">
@csrf
<div class="card" style="max-width:860px">
    <div class="card-header"><i class="fas fa-user-plus"></i> Datos del postulante</div>
    <div class="card-body">

        {{-- Gestión --}}
        <div class="form-section">
            <div class="form-section-title">Gestión académica</div>
            <div class="form-row cols-2">
                <div>
                    <label class="form-label">Gestión <span class="req">*</span></label>
                    <select name="gestion_id" class="form-select" required>
                        <option value="">— Seleccionar gestión —</option>
                        @foreach($gestiones as $g)
                        <option value="{{ $g->id }}" {{ old('gestion_id') == $g->id ? 'selected':'' }}>{{ $g->descripcion }}</option>
                        @endforeach
                    </select>
                </div>
            </div>
        </div>

        {{-- Datos personales --}}
        <div class="form-section">
            <div class="form-section-title">Datos personales</div>
            <div class="form-row cols-3">
                <div>
                    <label class="form-label">CI <span class="req">*</span></label>
                    <input type="text" name="ci" class="form-control" value="{{ old('ci') }}" required placeholder="Ej: 12345678">
                </div>
                <div>
                    <label class="form-label">Nombres <span class="req">*</span></label>
                    <input type="text" name="nombres" class="form-control" value="{{ old('nombres') }}" required>
                </div>
                <div>
                    <label class="form-label">Apellidos <span class="req">*</span></label>
                    <input type="text" name="apellidos" class="form-control" value="{{ old('apellidos') }}" required>
                </div>
                <div>
                    <label class="form-label">Fecha de nacimiento</label>
                    <input type="date" name="fecha_nacimiento" class="form-control" value="{{ old('fecha_nacimiento') }}">
                </div>
                <div>
                    <label class="form-label">Sexo</label>
                    <select name="sexo" class="form-select">
                        <option value="">— Seleccionar —</option>
                        <option value="M" {{ old('sexo')=='M'?'selected':'' }}>Masculino</option>
                        <option value="F" {{ old('sexo')=='F'?'selected':'' }}>Femenino</option>
                        <option value="Otro" {{ old('sexo')=='Otro'?'selected':'' }}>Otro</option>
                    </select>
                </div>
                <div>
                    <label class="form-label">Teléfono</label>
                    <input type="text" name="telefono" class="form-control" value="{{ old('telefono') }}" placeholder="Ej: 70012345">
                </div>
                <div>
                    <label class="form-label">Correo electrónico</label>
                    <input type="email" name="email" class="form-control" value="{{ old('email') }}">
                </div>
                <div>
                    <label class="form-label">Colegio de procedencia</label>
                    <input type="text" name="colegio_procedencia" class="form-control" value="{{ old('colegio_procedencia') }}">
                </div>
                <div>
                    <label class="form-label">Ciudad</label>
                    <input type="text" name="ciudad" class="form-control" value="{{ old('ciudad') }}" placeholder="Ej: Santa Cruz">
                </div>
            </div>
            <div style="margin-top:1rem">
                <label class="form-label">Dirección</label>
                <input type="text" name="direccion" class="form-control" value="{{ old('direccion') }}">
            </div>
        </div>

        {{-- Opciones de carrera --}}
        <div class="form-section">
            <div class="form-section-title">Opciones de carrera (CU-08)</div>
            <div class="form-row cols-2">
                <div>
                    <label class="form-label">1ª Opción de carrera <span class="req">*</span></label>
                    <select name="primera_opcion_id" class="form-select" required>
                        <option value="">— Seleccionar —</option>
                        @foreach($carreras as $c)
                        <option value="{{ $c->id }}" {{ old('primera_opcion_id') == $c->id ? 'selected':'' }}>{{ $c->nombre }}</option>
                        @endforeach
                    </select>
                </div>
                <div>
                    <label class="form-label">2ª Opción de carrera <span class="req">*</span></label>
                    <select name="segunda_opcion_id" class="form-select" required>
                        <option value="">— Seleccionar —</option>
                        @foreach($carreras as $c)
                        <option value="{{ $c->id }}" {{ old('segunda_opcion_id') == $c->id ? 'selected':'' }}>{{ $c->nombre }}</option>
                        @endforeach
                    </select>
                    <div class="form-hint">Debe ser diferente a la primera opción.</div>
                </div>
            </div>
        </div>

        {{-- Documentos --}}
        <div class="form-section">
            <div class="form-section-title">Documentos requeridos (CU-06)</div>
            <p style="font-size:.83rem;color:var(--txt-3);margin-bottom:.75rem">Los tres documentos son obligatorios para completar la inscripción.</p>
            <div style="display:flex;flex-direction:column;gap:.5rem">
                <label class="form-check">
                    <input type="checkbox" name="doc_ci" value="1" {{ old('doc_ci') ? 'checked':'' }}>
                    <span>Fotocopia de Cédula de Identidad (CI)</span>
                </label>
                <label class="form-check">
                    <input type="checkbox" name="doc_libreta_colegio" value="1" {{ old('doc_libreta_colegio') ? 'checked':'' }}>
                    <span>Libreta de colegio</span>
                </label>
                <label class="form-check">
                    <input type="checkbox" name="doc_titulo_bachiller" value="1" {{ old('doc_titulo_bachiller') ? 'checked':'' }}>
                    <span>Título de Bachiller</span>
                </label>
            </div>
        </div>

        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Registrar Postulante</button>
            <a href="{{ route('postulantes.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@endsection
