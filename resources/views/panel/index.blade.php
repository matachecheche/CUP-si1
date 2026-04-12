
@extends('plantilla')

@section('title', 'Inicio')

@section('content')

<style>
    body {
        background-color: #0f172a; /* fondo general oscuro */
    }

    .dark-container {
        background-color: #0f172a;
        color: #e2e8f0;
    }

    .card-dark {
        border-radius: 18px;
        transition: 0.3s;
    }

    .card-dark:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 25px rgba(0,0,0,0.6);
    }
</style>

<div class="container-fluid px-4 dark-container">

    <h1 class="mt-4 fw-bold text-light">Panel de Control</h1>
    <p class="text-secondary">Seleccionar módulo</p>

    <div class="row g-4">

        <!-- Usuarios -->
        <div class="col-xl-3 col-md-6">
            <div class="card card-dark h-100 border-0 text-white shadow-lg"
                 style="background: linear-gradient(135deg, #7f1d1d, #dc2626);">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold">Usuarios</h5>
                    <i class="fas fa-users fa-2x"></i>
                </div>
                <div class="card-footer bg-transparent border-0">
                    <a class="text-white stretched-link text-decoration-none" href="{{ route('users.index') }}">
                        Ver detalles →
                    </a>
                </div>
            </div>
        </div>

        <!-- Roles -->
        <div class="col-xl-3 col-md-6">
            <div class="card card-dark h-100 border-0 text-white shadow-lg"
                 style="background: linear-gradient(135deg, #1e3a8a, #3b82f6);">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold">Roles</h5>
                    <i class="fas fa-user-shield fa-2x"></i>
                </div>
                <div class="card-footer bg-transparent border-0">
                    <a class="text-white stretched-link text-decoration-none" href="{{ route('roles.index') }}">
                        Ver detalles →
                    </a>
                </div>
            </div>
        </div>

        <!-- Empleados -->
        <div class="col-xl-3 col-md-6">
            <div class="card card-dark h-100 border-0 text-white shadow-lg"
                 style="background: linear-gradient(135deg, #064e3b, #10b981);">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold">Empleados</h5>
                    <i class="fas fa-id-badge fa-2x"></i>
                </div>
                <div class="card-footer bg-transparent border-0">
                    <a class="text-white stretched-link text-decoration-none" href="{{ route('empleados.index') }}">
                        Ver detalles →
                    </a>
                </div>
            </div>
        </div>

        <!-- Residentes -->
        <div class="col-xl-3 col-md-6">
            <div class="card card-dark h-100 border-0 text-white shadow-lg"
                 style="background: linear-gradient(135deg, #78350f, #f59e0b);">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold">Residentes</h5>
                    <i class="fas fa-building fa-2x"></i>
                </div>
                <div class="card-footer bg-transparent border-0">
                    <a class="text-white stretched-link text-decoration-none" href="{{ route('residentes.index') }}">
                        Ver detalles →
                    </a>
                </div>
            </div>
        </div>

        <!-- Bitácora -->
        <div class="col-xl-3 col-md-6">
            <div class="card card-dark h-100 border-0 text-white shadow-lg"
                 style="background: linear-gradient(135deg, #4c1d95, #8b5cf6);">
                <div class="card-body d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold">Bitácora</h5>
                    <i class="fas fa-book fa-2x"></i>
                </div>
                <div class="card-footer bg-transparent border-0">
                    <a class="text-white stretched-link text-decoration-none" href="{{ route('bitacora.index') }}">
                        Ver detalles →
                    </a>
                </div>
            </div>
        </div>

    </div>
</div>
@endsection

