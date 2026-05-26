@extends('layouts.ap')
@section('title','Nueva Materia')
@section('content')
<div class="page-header">
    <h1>Registrar Materia</h1>
    <p class="subtitle">Configurar ponderación de los 3 exámenes (deben sumar 100%)</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('materias.index') }}">Materias</a></li><li>Nueva</li></ol>
</div>
<form action="{{ route('materias.store') }}" method="POST">
@csrf
<div class="card" style="max-width:640px">
    <div class="card-header"><i class="fas fa-book-open"></i> Datos de la materia</div>
    <div class="card-body">
        <div class="form-row cols-2">
            <div>
                <label class="form-label">Nombre <span class="req">*</span></label>
                <input type="text" name="nombre" class="form-control" value="{{ old('nombre') }}" required
                    placeholder="Ej: Computación">
                <div class="form-hint">Computación · Matemáticas · Física · Inglés</div>
            </div>
            <div>
                <label class="form-label">Área de formación</label>
                <input type="text" name="area_formacion" class="form-control" value="{{ old('area_formacion') }}"
                    placeholder="Ej: Ingeniería de Sistemas">
                <div class="form-hint">Usada para validar qué docente puede dictar esta materia</div>
            </div>
        </div>
        <div style="margin-top:1rem">
            <label class="form-label">Descripción</label>
            <textarea name="descripcion" class="form-control">{{ old('descripcion') }}</textarea>
        </div>

        <div class="form-section" style="margin-top:1.25rem">
            <div class="form-section-title">Ponderación de exámenes</div>
            <p style="font-size:.83rem;color:var(--txt-3);margin-bottom:.75rem">Los tres porcentajes deben sumar exactamente 100. Por defecto: 30% + 30% + 40%</p>
            <div class="form-row cols-3">
                <div>
                    <label class="form-label">Examen 1 (%) <span class="req">*</span></label>
                    <input type="number" name="pond_examen1" class="form-control" value="{{ old('pond_examen1',30) }}" min="1" max="98" required id="p1">
                </div>
                <div>
                    <label class="form-label">Examen 2 (%) <span class="req">*</span></label>
                    <input type="number" name="pond_examen2" class="form-control" value="{{ old('pond_examen2',30) }}" min="1" max="98" required id="p2">
                </div>
                <div>
                    <label class="form-label">Examen 3 (%) <span class="req">*</span></label>
                    <input type="number" name="pond_examen3" class="form-control" value="{{ old('pond_examen3',40) }}" min="1" max="98" required id="p3">
                </div>
            </div>
            <div id="pond-total" style="margin-top:.5rem;font-size:.85rem;font-weight:600"></div>
        </div>

        <div class="form-row cols-2" style="margin-top:1rem">
            <div>
                <label class="form-label">Nota mínima de aprobación <span class="req">*</span></label>
                <input type="number" name="nota_minima_aprobacion" class="form-control" value="{{ old('nota_minima_aprobacion',60) }}" min="1" max="100" required>
            </div>
            <div>
                <label class="form-label">Orden de visualización</label>
                <input type="number" name="orden" class="form-control" value="{{ old('orden',0) }}" min="0">
            </div>
        </div>
        <div style="margin-top:1rem">
            <label class="form-check"><input type="checkbox" name="estado" value="1" {{ old('estado',1)?'checked':'' }}><span>Materia activa</span></label>
        </div>
        <div style="display:flex;gap:.75rem;margin-top:1.5rem">
            <button type="submit" class="btn btn-primary"><i class="fas fa-save"></i> Guardar</button>
            <a href="{{ route('materias.index') }}" class="btn btn-outline">Cancelar</a>
        </div>
    </div>
</div>
</form>
@push('js')
<script>
function updPond(){
    const s=+document.getElementById('p1').value+(+document.getElementById('p2').value)+(+document.getElementById('p3').value);
    const el=document.getElementById('pond-total');
    el.textContent='Total: '+s+'%';
    el.style.color=s===100?'var(--verde-3)':'var(--danger)';
}
['p1','p2','p3'].forEach(id=>document.getElementById(id).addEventListener('input',updPond));
updPond();
</script>
@endpush
@endsection
