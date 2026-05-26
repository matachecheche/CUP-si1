@extends('layouts.ap')
@section('title',$grupo->codigo)
@section('content')
<div class="ph">
  <h1>Grupo {{ $grupo->codigo }}</h1>
  <p class="sub">CU-18/19: Asignar docentes · CU-21: Inscribir postulantes</p>
  <ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('grupos.index') }}">Grupos</a></li><li>{{ $grupo->codigo }}</li></ol>
</div>

@if(session('success'))<div class="al al-v"><i class="fas fa-check-circle"></i> {{ session('success') }}</div>@endif
@if($errors->any())<div class="al al-d"><ul>@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif

<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:900px">

{{-- Info del grupo --}}
<div class="card"><div class="card-hd"><i class="fas fa-info-circle"></i>Datos del grupo</div><div class="card-bd" style="font-size:.88rem">
  @foreach(['Código'=>$grupo->codigo,'Turno'=>ucfirst($grupo->turno),'Modalidad'=>ucfirst($grupo->modalidad),'Capacidad'=>$grupo->capacidad_maxima,'Inscritos'=>$grupo->postulantes->count()] as $l=>$v)
  <div style="display:flex;justify-content:space-between;padding:.4rem 0;border-bottom:1px solid var(--cr2)">
    <span style="color:var(--t3)">{{ $l }}</span><span style="font-weight:500">{{ $v }}</span>
  </div>
  @endforeach
</div></div>

{{-- Asignar docente (CU-18/19) --}}
@can('editar grupos')
<div class="card"><div class="card-hd"><i class="fas fa-user-tie"></i>Asignar docente — materia (CU-18)</div><div class="card-bd">
<form action="{{ route('grupos.asignarDocente',$grupo) }}" method="POST">@csrf
  <div style="margin-bottom:.6rem">
    <label class="fl">Materia <span class="rq">*</span></label>
    <select name="materia_id" class="fs" required><option value="">— Seleccionar —</option>
    @foreach($materias as $m)<option value="{{ $m->id }}">{{ $m->nombre }}</option>@endforeach
    </select>
  </div>
  <div style="margin-bottom:.6rem">
    <label class="fl">Docente <span class="rq">*</span></label>
    <select name="docente_id" class="fs" required><option value="">— Seleccionar —</option>
    @foreach($docentes as $d)<option value="{{ $d->id }}">{{ $d->nombres }} {{ $d->apellidos }} — {{ $d->area_formacion }}</option>@endforeach
    </select>
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:.5rem;margin-bottom:.6rem">
    <div><label class="fl">Día <span class="rq">*</span></label>
    <select name="dia" class="fs" required><option value="">—</option>
    @foreach(['lunes','martes','miercoles','jueves','viernes','sabado'] as $dia)
    <option value="{{ $dia }}">{{ ucfirst($dia) }}</option>
    @endforeach</select></div>
    <div><label class="fl">Hora inicio</label><input type="time" name="hora_inicio" class="fc" required></div>
    <div><label class="fl">Hora fin</label><input type="time" name="hora_fin" class="fc" required></div>
  </div>
  <button type="submit" class="btn bp bsm"><i class="fas fa-save"></i> Guardar asignación</button>
</form>
</div></div>
@endcan

</div>

{{-- Tabla asignaciones actuales --}}
<div class="card" style="max-width:900px;margin-top:1rem">
  <div class="card-hd"><i class="fas fa-table"></i>Asignaciones de docentes ({{ $grupo->asignaciones->count() }}/4)</div>
  <div class="card-bd">
  @if($grupo->asignaciones->isEmpty())<p style="color:var(--t3);text-align:center">Sin asignaciones aún.</p>
  @else
  <table class="ct"><thead><tr><th>Materia</th><th>Docente</th><th>Día</th><th>Horario</th></tr></thead>
  <tbody>
  @foreach($grupo->asignaciones as $a)
  <tr>
    <td><strong>{{ $a->materia?->nombre }}</strong></td>
    <td>{{ $a->docente?->nombres }} {{ $a->docente?->apellidos }}</td>
    <td>{{ ucfirst($a->dia) }}</td>
    <td>{{ $a->hora_inicio }} — {{ $a->hora_fin }}</td>
  </tr>
  @endforeach
  </tbody></table>
  @endif
  </div>
</div>

{{-- Postulantes inscritos --}}
<div class="card" style="max-width:900px;margin-top:1rem">
  <div class="card-hd"><i class="fas fa-users"></i>Postulantes inscritos ({{ $grupo->postulantes->count() }}/{{ $grupo->capacidad_maxima }})</div>
  <div class="card-bd">
  @if($grupo->postulantes->isEmpty())<p style="color:var(--t3);text-align:center">Sin postulantes inscritos.</p>
  @else
  <table class="ct"><thead><tr><th>CI</th><th>Nombre</th><th>Estado</th></tr></thead>
  <tbody>
  @foreach($grupo->postulantes as $p)
  <tr>
    <td>{{ $p->ci }}</td>
    <td>{{ $p->nombre_completo }}</td>
    <td><span class="bg {{ in_array($p->estado,['aprobado','admitido','admitido_segunda_opcion'])?'bv':'bg2' }}">{{ $p->estado }}</span></td>
  </tr>
  @endforeach
  </tbody></table>
  @endif
  </div>
</div>

<div style="margin-top:1rem"><a href="{{ route('grupos.index') }}" class="btn bo2"><i class="fas fa-arrow-left"></i> Volver</a></div>
@endsection
