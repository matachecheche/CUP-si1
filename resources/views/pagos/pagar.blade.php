@extends('layouts.ap')
@section('title','Pago de Inscripción')
@section('content')
<div class="ph"><h1>Pago de Inscripción — CUP</h1><p class="sub">CU-20 — Pasarela de pagos (Stripe Checkout)</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('postulantes.index') }}">Postulantes</a></li><li>Pago</li></ol></div>

@if(session('error'))<div style="background:#fdecea;color:#92271d;border:1px solid #f5c6c2;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('error') }}</div>@endif
@if(session('success'))<div style="background:#e8f6ee;color:#14532d;border:1px solid #bbe5c8;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">{{ session('success') }}</div>@endif

<div class="card" style="max-width:560px">
  <div class="card-hd"><i class="fas fa-credit-card"></i> Resumen de pago</div>
  <div class="card-bd">
    <table class="ct" style="width:100%">
      <tr><th style="text-align:left;width:38%">Postulante</th><td>{{ $postulante->nombre_completo }} (CI {{ $postulante->ci }})</td></tr>
      <tr><th style="text-align:left">Gestión</th><td>{{ $postulante->gestion->descripcion }}</td></tr>
      <tr><th style="text-align:left">1ª opción</th><td>{{ $postulante->primeraOpcion?->nombre ?? '—' }}</td></tr>
      <tr><th style="text-align:left">Concepto</th><td>Inscripción al Curso Preuniversitario (CUP)</td></tr>
      <tr><th style="text-align:left">Monto</th><td><strong style="font-size:1.25rem">Bs {{ number_format($monto,2) }}</strong></td></tr>
    </table>
    <form action="{{ route('pagos.checkout',$postulante) }}" method="POST" style="margin-top:1rem">@csrf
      <button type="submit" class="btn bp" style="width:100%"><i class="fab fa-stripe-s"></i> Pagar con Stripe</button>
    </form>
    <p style="font-size:.78rem;color:var(--t3,#888);margin-top:.6rem">
      Serás redirigido a la pasarela segura de Stripe. <strong>Modo prueba:</strong> tarjeta 4242 4242 4242 4242, cualquier fecha futura y CVC.
    </p>
  </div>
</div>
@endsection
