@extends('layouts.ap')
@section('title','Perfil Docente')
@section('content')
<div class="page-header">
    <h1>{{ $docente->nombre_completo }}</h1>
    <p class="subtitle">CU-15 — Perfil profesional del docente</p>
    <ol class="breadcrumb"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('docentes.index') }}">Docentes</a></li><li>Perfil</li></ol>
</div>

<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:800px">
    <div class="card">
        <div class="card-header"><i class="fas fa-user"></i> Datos personales</div>
        <div class="card-body" style="font-size:.88rem">
            @foreach(['CI'=>$docente->ci,'Nombres'=>$docente->nombres,'Apellidos'=>$docente->apellidos,'Teléfono'=>$docente->telefono,'Email'=>$docente->email,'Área de formación'=>$docente->area_formacion] as $l=>$v)
            <div style="display:flex;justify-content:space-between;padding:.4rem 0;border-bottom:1px solid var(--crema-2)">
                <span style="color:var(--txt-3)">{{ $l }}</span>
                <span style="font-weight:500">{{ $v ?? '—' }}</span>
            </div>
            @endforeach
        </div>
    </div>
    <div class="card">
        <div class="card-header"><i class="fas fa-certificate"></i> Perfil profesional</div>
        <div class="card-body" style="font-size:.88rem">
            <div style="margin-bottom:.75rem">
                <div style="font-size:.72rem;text-transform:uppercase;color:var(--txt-3);margin-bottom:.2rem">Título profesional</div>
                <div style="font-weight:600">{{ $docente->titulo_profesional ?? '—' }}</div>
            </div>
            <div style="margin-bottom:.75rem">
                <div style="font-size:.72rem;text-transform:uppercase;color:var(--txt-3);margin-bottom:.2rem">Maestría</div>
                <div style="font-weight:600">{{ $docente->maestria ?? '—' }}</div>
            </div>
            <div style="margin-bottom:.75rem">
                <div style="font-size:.72rem;text-transform:uppercase;color:var(--txt-3);margin-bottom:.2rem">Diplomado en Educación Superior</div>
                <div style="font-weight:600">{{ $docente->diplomado_educacion_superior ?? '—' }}</div>
            </div>
            @if($docente->certificacion_ingles)
            <div style="margin-bottom:.75rem">
                <div style="font-size:.72rem;text-transform:uppercase;color:var(--txt-3);margin-bottom:.2rem">Certificación de Inglés</div>
                <div style="font-weight:600">{{ $docente->certificacion_ingles }}</div>
            </div>
            @endif
            @if($docente->otras_certificaciones)
            <div>
                <div style="font-size:.72rem;text-transform:uppercase;color:var(--txt-3);margin-bottom:.2rem">Otras certificaciones</div>
                <div style="font-size:.84rem">{{ $docente->otras_certificaciones }}</div>
            </div>
            @endif
        </div>
    </div>
</div>

<div style="margin-top:1rem;display:flex;gap:.75rem">
    @can('editar docentes')
    <a href="{{ route('docentes.edit',$docente) }}" class="btn btn-warn"><i class="fas fa-edit"></i> Editar</a>
    @endcan
    <a href="{{ route('docentes.index') }}" class="btn btn-outline"><i class="fas fa-arrow-left"></i> Volver</a>
</div>
@endsection
