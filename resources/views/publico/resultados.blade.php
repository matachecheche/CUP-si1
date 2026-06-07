<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Consulta de Resultados — Admisión CUP · FICCT</title>
<script src="https://use.fontawesome.com/releases/v6.3.0/js/all.js" crossorigin="anonymous"></script>
<style>
  :root{--v:#1d3b2a;--o:#b08a2e;--bg:#f4f1e8;--t3:#8a8678}
  *{box-sizing:border-box}body{margin:0;font-family:'Segoe UI',system-ui,sans-serif;background:var(--bg);min-height:100vh;display:flex;flex-direction:column}
  header{background:var(--v);color:#fff;padding:1rem 1.4rem;display:flex;align-items:center;gap:.7rem}
  header .logo{background:var(--o);color:var(--v);font-weight:800;border-radius:8px;width:38px;height:38px;display:flex;align-items:center;justify-content:center}
  header h1{font-size:1.05rem;margin:0}header p{margin:0;font-size:.72rem;opacity:.85}
  main{flex:1;display:flex;justify-content:center;padding:2rem 1rem}
  .wrap{width:100%;max-width:560px}
  .card{background:#fff;border:1px solid #e8e3d8;border-radius:12px;padding:1.4rem;box-shadow:0 2px 10px rgba(0,0,0,.05);margin-bottom:1rem}
  h2{margin:.2rem 0 .3rem;font-size:1.25rem;color:var(--v)}
  .sub{font-size:.82rem;color:var(--t3);margin:0 0 1rem}
  .fc{width:100%;padding:.7rem .9rem;border:1px solid #d8d2c4;border-radius:8px;font-size:1rem}
  .btn{width:100%;margin-top:.8rem;background:var(--v);color:#fff;border:none;border-radius:8px;padding:.75rem;font-size:.95rem;cursor:pointer}
  .btn:hover{filter:brightness(1.1)}
  .err{color:#92271d;font-size:.8rem;margin-top:.35rem}
  .res-badge{display:inline-block;padding:.45rem 1rem;border-radius:999px;font-weight:700;font-size:1rem}
  .ok{background:#e8f6ee;color:#14532d;border:1px solid #bbe5c8}
  .warn{background:#fdf4df;color:#7a5a10;border:1px solid #ecd49a}
  .bad{background:#fdecea;color:#92271d;border:1px solid #f5c6c2}
  .info{background:#eef3f8;color:#1d3b5a;border:1px solid #c8d8ea}
  table{width:100%;border-collapse:collapse;margin-top:.9rem;font-size:.9rem}
  th{text-align:left;color:var(--t3);font-weight:600;padding:.4rem 0;width:42%}td{padding:.4rem 0}
  footer{text-align:center;font-size:.74rem;color:var(--t3);padding:1rem}
  a{color:var(--v)}
</style>
</head>
<body>
<header>
  <div class="logo">C</div>
  <div><h1>Admisión CUP — Consulta de Resultados</h1>
  <p>Facultad de Ingeniería en Ciencias de la Computación y Telecomunicaciones · UAGRM</p></div>
</header>
<main><div class="wrap">

  <div class="card">
    <h2><i class="fas fa-search"></i> Consulta tu resultado</h2>
    <p class="sub">Ingresa tu número de carnet de identidad tal como lo registraste al inscribirte.</p>
    <form method="POST" action="{{ route('resultados.consultar') }}">
      @csrf
      <input class="fc" type="text" name="ci" value="{{ old('ci', $ci ?? '') }}" placeholder="Ej.: 10000138" maxlength="20" autofocus required>
      @error('ci')<div class="err">{{ $message }}</div>@enderror
      <button class="btn" type="submit"><i class="fas fa-magnifying-glass"></i> Consultar</button>
    </form>
  </div>

  @if(!empty($consultado))
  <div class="card">
    @if(! $postulante)
      <span class="res-badge bad"><i class="fas fa-circle-xmark"></i> CI no encontrado</span>
      <p class="sub" style="margin-top:.8rem">No existe ningún postulante registrado con el CI <strong>{{ $ci }}</strong>. Verifica el número e intenta nuevamente.</p>

    @elseif(! $publicado)
      @php $enProceso = in_array($postulante->estado, ['preinscrito','inscrito','en_curso']); @endphp
      <span class="res-badge info"><i class="fas fa-clock"></i> {{ $enProceso ? 'Proceso en curso' : 'Resultados no publicados' }}</span>
      <p class="sub" style="margin-top:.8rem">
        Hola, <strong>{{ $postulante->nombres }} {{ $postulante->apellidos }}</strong>.
        {{ $enProceso
            ? 'Tu proceso de admisión aún está en curso; los resultados estarán disponibles al finalizar las evaluaciones.'
            : 'Los resultados de tu gestión aún no han sido publicados oficialmente por la facultad. Vuelve a consultar más tarde.' }}
      </p>

    @else
      @php
        [$texto, $clase, $icono, $detalle] = match($postulante->estado) {
          'admitido' => ['ADMITIDO', 'ok', 'fa-circle-check',
              'Felicidades, fuiste admitido en tu PRIMERA opción.'],
          'admitido_segunda_opcion' => ['ADMITIDO — 2ª OPCIÓN', 'ok', 'fa-circle-check',
              'Aprobaste el CUP; por cupos, fuiste admitido en tu SEGUNDA opción.'],
          'no_admitido' => ['APROBADO SIN CUPO', 'warn', 'fa-triangle-exclamation',
              'Aprobaste el CUP, pero no alcanzaste cupo en tus carreras elegidas.'],
          'no_aprobado' => ['REPROBADO', 'bad', 'fa-circle-xmark',
              'No alcanzaste la nota mínima de aprobación (60 puntos).'],
          default => ['EN PROCESO', 'info', 'fa-clock', 'Tu resultado aún está en proceso.'],
        };
      @endphp
      <span class="res-badge {{ $clase }}"><i class="fas {{ $icono }}"></i> {{ $texto }}</span>
      <p class="sub" style="margin-top:.8rem">{{ $detalle }}</p>
      <table>
        <tr><th>Postulante</th><td><strong>{{ $postulante->apellidos }}, {{ $postulante->nombres }}</strong></td></tr>
        <tr><th>CI</th><td>{{ $postulante->ci }}</td></tr>
        <tr><th>Gestión</th><td>{{ $postulante->gestion->descripcion ?? '—' }}</td></tr>
        <tr><th>1ª / 2ª opción</th><td>{{ $postulante->primeraOpcion->nombre ?? '—' }} / {{ $postulante->segundaOpcion->nombre ?? '—' }}</td></tr>
        @if($admision->carreraAsignada)
        <tr><th>Carrera asignada</th><td><strong style="color:var(--v)">{{ $admision->carreraAsignada->nombre }}</strong></td></tr>
        @endif
        <tr><th>Promedio general</th><td>{{ $admision->promedio_general ?? $postulante->promedio_general ?? '—' }}</td></tr>
      </table>
    @endif
  </div>
  @endif

  <div style="text-align:center;font-size:.8rem"><a href="{{ route('login') }}"><i class="fas fa-sign-in-alt"></i> Ir al sistema (personal autorizado)</a></div>
</div></main>
<footer>© {{ date('Y') }} Sistema de Admisión CUP — FICCT · Resultado oficial solo una vez publicado por la facultad</footer>
</body>
</html>
