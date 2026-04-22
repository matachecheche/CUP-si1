@extends('layouts.ap')

@section('content')
<div class="container">
    <h2 class="mb-4">Registrar Usuario</h2>

    @if ($errors->any())
    <div class="alert alert-danger">
        <ul class="mb-0">
            @foreach ($errors->all() as $error)
            <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
    @endif

    <form action="{{ route('users.store') }}" method="POST">
        @csrf

        <div class="mb-3">
            <label class="form-label">Nombre</label>
            <input type="text" name="name" class="form-control" value="{{ old('name') }}" required>
        </div>

        <div class="mb-3">
            <label class="form-label">Correo Electrónico</label>
            <input type="email" name="email" class="form-control" value="{{ old('email') }}" required>
        </div>

        <div class="mb-3">
            <label for="password" class="form-label">Contraseña</label>
            <input type="password" name="password" id="password" class="form-control" required>
            <div class="form-text">Mínimo 8 caracteres, debe incluir mayúsculas, números y símbolos.</div>
        </div>

        <div class="mb-3">
            <label for="password_confirmation" class="form-label">Confirmar Contraseña</label>
            <input type="password" name="password_confirmation" id="password_confirmation" class="form-control" required>
        </div>

        <div class="mb-3">
            <label class="form-label">Rol</label>
            <select name="role" class="form-select" required>
                <option value="">-- Seleccionar rol --</option>
                @foreach($roles as $rol)
                <option value="{{ $rol->name }}" {{ old('role') == $rol->name ? 'selected' : '' }}>
                    {{ ucfirst($rol->name) }}
                </option>
                @endforeach
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Empleado (si aplica)</label>
            <select name="empleado_id" class="form-select">
                <option value="">-- No asignar empleado --</option>
                @foreach($empleados as $empleado)
                <option value="{{ $empleado->id }}" {{ old('empleado_id') == $empleado->id ? 'selected' : '' }}>
                    {{ $empleado->nombre }} {{ $empleado->apellido }} - {{ $empleado->ci }}
                </option>
                @endforeach
            </select>
        </div>

        <div class="mb-3">
            <label class="form-label">Residente (si aplica)</label>
            <select name="residente_id" class="form-select">
                <option value="">-- No asignar residente --</option>
                @foreach($residentes as $residente)
                <option value="{{ $residente->id }}" {{ old('residente_id') == $residente->id ? 'selected' : '' }}>
                    {{ $residente->nombre }} {{ $residente->apellido }} - {{ $residente->ci }}
                </option>
                @endforeach
            </select>
        </div>

        <button type="submit" class="btn btn-primary">Registrar</button>
        <a href="{{ route('users.index') }}" class="btn btn-secondary">Cancelar</a>
    </form>
</div>
@endsection