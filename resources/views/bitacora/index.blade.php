@extends('layouts.ap')
@section('title','Bitácora del Sistema')
@push('css')
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/css/bootstrap.min.css">
@endpush
@section('content')
<div class="ph">
  <h1>Bitácora del Sistema</h1>
  <p class="sub">Registro completo de todas las acciones de los usuarios</p>
  <ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Bitácora</li></ol>
</div>
<div class="card">
  <div class="card-hd"><i class="fas fa-journal-whills"></i>Bitácora
    <span style="margin-left:auto;font-size:.8rem;color:var(--t3);font-weight:400">{{ $bitacoras->count() }} registros</span>
  </div>
  <div class="card-bd" style="padding:.75rem">
    <div class="tw">
      <table id="tblBit" class="ct" style="width:100%;font-size:.83rem">
        <thead><tr><th>Fecha y Hora</th><th>Usuario</th><th>Módulo</th><th>Acción</th><th>Método</th><th>Ruta</th><th>IP</th></tr></thead>
        <tbody>
        @forelse($bitacoras as $log)
        @php
          $mc = substr(preg_replace('/[^A-Za-z]/','',$log->modulo??''),0,3);
        @endphp
        <tr>
          <td style="white-space:nowrap;color:var(--t3)">{{ \Carbon\Carbon::parse($log->fecha_hora)->format('d/m/Y H:i:s') }}</td>
          <td style="font-weight:600">{{ $log->usuario??'—' }}</td>
          <td>@if($log->modulo)<span class="cmod {{ $mc }}">{{ $log->modulo }}</span>@else<span style="color:var(--t3)">—</span>@endif</td>
          <td style="color:var(--t)">{{ $log->accion }}</td>
          <td>@if($log->metodo_http)<span class="chttp h{{ $log->metodo_http }}">{{ $log->metodo_http }}</span>@endif</td>
          <td style="font-family:'Courier New',monospace;font-size:.78rem;color:var(--t3)">{{ $log->ruta??'—' }}</td>
          <td style="font-family:'Courier New',monospace;font-size:.78rem;color:var(--t3)">{{ $log->ip??'—' }}</td>
        </tr>
        @empty
        <tr><td colspan="7" style="text-align:center;padding:2rem;color:var(--t3)">Sin registros aún.</td></tr>
        @endforelse
        </tbody>
      </table>
    </div>
  </div>
</div>
@push('js')
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.1/dist/js/bootstrap.bundle.min.js"></script>
<script>$(()=>$('#tblBit').DataTable({language:{url:'https://cdn.datatables.net/plug-ins/1.13.6/i18n/es-ES.json'},order:[[0,'desc']],pageLength:25}))</script>
@endpush
@endsection
