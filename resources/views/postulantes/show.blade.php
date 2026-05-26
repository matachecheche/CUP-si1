@extends('layouts.ap')
@section('title','Detalle Postulante')
@section('content')
<div class="page-header">
    <h1>{{ $postulante->nombre_completo }}</h1>
    <p class="subtitle">CU-09 — Estado del postulante</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('postulantes.index') }}">Postulantes</a></li><li>Detalle</li></ol>
</div>

<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:860px">
    <div class="card">
        <div class="card-header"><i class="fas fa-user"></i> Datos personales</div>
        <div class="card-body" style="font-size:.88rem">
            <table style="width:100%;border-collapse:collapse">
                @foreach([
                    'CI' => $postulante->ci,
                    'Nombres' => $postulante->nombres,
                    'Apellidos' => $postulante->apellidos,
                    'Fecha de nac.' => $postulante->fecha_nacimiento?->format('d/m/Y'),
                    'Sexo' => $postulante->sexo,
                    'Teléfono' => $postulante->telefono,
                    'Correo' => $postulante->email,
                    'Colegio' => $postulante->colegio_procedencia,
                    'Ciudad' => $postulante->ciudad,
                    'Dirección' => $postulante->direccion,
                ] as $lbl => $val)
                <tr style="border-bottom:1px solid var(--crema-2)">
                    <td style="padding:.45rem .5rem;color:var(--txt-3);white-space:nowrap">{{ $lbl }}</td>
                    <td style="padding:.45rem .5rem;font-weight:500">{{ $val ?? '—' }}</td>
                </tr>
                @endforeach
            </table>
        </div>
    </div>
    <div>
        <div class="card" style="margin-bottom:1rem">
            <div class="card-header"><i class="fas fa-graduation-cap"></i> Opciones de carrera</div>
            <div class="card-body" style="font-size:.88rem">
                <div style="margin-bottom:.6rem"><span style="color:var(--txt-3);font-size:.78rem">1ª OPCIÓN</span><div style="font-weight:600;color:var(--verde)">{{ $postulante->primeraOpcion?->nombre ?? '—' }}</div></div>
                <div><span style="color:var(--txt-3);font-size:.78rem">2ª OPCIÓN</span><div style="font-weight:600">{{ $postulante->segundaOpcion?->nombre ?? '—' }}</div></div>
            </div>
        </div>
        <div class="card" style="margin-bottom:1rem">
            <div class="card-header"><i class="fas fa-file-check"></i> Documentos</div>
            <div class="card-body" style="font-size:.88rem;display:flex;flex-direction:column;gap:.4rem">
                <div><i class="fas fa-{{ $postulante->doc_ci ? 'check-circle' : 'times-circle' }}" style="color:{{ $postulante->doc_ci ? 'var(--verde-3)' : 'var(--danger)' }}"></i> CI</div>
                <div><i class="fas fa-{{ $postulante->doc_libreta_colegio ? 'check-circle' : 'times-circle' }}" style="color:{{ $postulante->doc_libreta_colegio ? 'var(--verde-3)' : 'var(--danger)' }}"></i> Libreta de colegio</div>
                <div><i class="fas fa-{{ $postulante->doc_titulo_bachiller ? 'check-circle' : 'times-circle' }}" style="color:{{ $postulante->doc_titulo_bachiller ? 'var(--verde-3)' : 'var(--danger)' }}"></i> Título de Bachiller</div>
            </div>
        </div>
        <div class="card">
            <div class="card-header"><i class="fas fa-info-circle"></i> Estado actual</div>
            <div class="card-body" style="text-align:center;padding:1.5rem">
                <span class="badge {{ $postulante->estado_badge }}" style="font-size:.9rem;padding:.4rem 1rem">
                    {{ str_replace('_',' ', ucfirst($postulante->estado)) }}
                </span>
                @if($postulante->promedio_general)
                <div style="margin-top:.75rem;font-size:.88rem;color:var(--txt-3)">Promedio general: <strong>{{ number_format($postulante->promedio_general,2) }}</strong></div>
                @endif
            </div>
        </div>
    </div>
</div>

<div style="margin-top:1rem;display:flex;gap:.75rem">
    @can('editar postulantes')
    <a href="{{ route('postulantes.edit', $postulante) }}" class="btn btn-warn"><i class="fas fa-edit"></i> Editar</a>
    @endcan
    <a href="{{ route('postulantes.index') }}" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Volver</a>
</div>
@endsection
