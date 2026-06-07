@extends('layouts.ap')
@section('title','Pago Exitoso')
@section('content')
<div class="ph"><h1>Pago de Inscripción</h1>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Pago</li></ol></div>

<div class="card" style="max-width:560px">
  <div class="card-bd" style="text-align:center;padding:2rem 1.5rem">
    @if($pago && $pago->estado === 'pagado')
      <i class="fas fa-check-circle" style="font-size:3rem;color:#16a34a"></i>
      <h2 style="margin:.6rem 0">¡Pago confirmado!</h2>
      <p><strong>{{ $pago->postulante->nombre_completo }}</strong> quedó <span class="bg bv">inscrito</span> al CUP.</p>
      <p style="color:var(--t3,#888)">Comprobante: <strong>{{ $pago->comprobante }}</strong> · Bs {{ number_format($pago->monto,2) }} · {{ $pago->fecha_pago?->format('d/m/Y H:i') }}</p>
      <a href="{{ route('postulantes.show',$pago->postulante) }}" class="btn bp" style="margin-top:.6rem">Ver postulante</a>
    @else
      <i class="fas fa-hourglass-half" style="font-size:3rem;color:#d97706"></i>
      <h2 style="margin:.6rem 0">Pago en verificación</h2>
      <p>Stripe aún no confirmó este pago. Si ya pagaste, espera unos segundos y recarga la página: el webhook lo confirmará automáticamente.</p>
      <a href="{{ route('postulantes.index') }}" class="btn bp" style="margin-top:.6rem">Volver a postulantes</a>
    @endif
  </div>
</div>
@endsection
