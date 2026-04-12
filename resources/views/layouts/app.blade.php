
<!doctype html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSRF -->
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Condominios') }}</title>

    <!-- Fuente moderna -->
    <link href="https://fonts.bunny.net/css?family=Nunito:400,600,700" rel="stylesheet">

    <!-- Scripts -->
    @vite(['resources/sass/app.scss', 'resources/js/app.js'])
</head>

<body class="bg-dark text-light">

<div id="app">

    <!-- NAVBAR MODERNO -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-black shadow">
        <div class="container">

            <!-- LOGO -->
            <a class="navbar-brand fw-bold" href="{{ url('/') }}">
                🏢 {{ config('app.name', 'Condominios') }}
            </a>

            <!-- BOTÓN RESPONSIVE -->
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent">
                <span class="navbar-toggler-icon"></span>
            </button>

            <!-- CONTENIDO -->
            <div class="collapse navbar-collapse" id="navbarSupportedContent">

                <!-- IZQUIERDA -->
                <ul class="navbar-nav me-auto">
                    @auth
                        <li class="nav-item">
                            <a class="nav-link" href="/">Inicio</a>
                        </li>
                    @endauth
                </ul>

                <!-- DERECHA -->
                <ul class="navbar-nav ms-auto">

                    @guest
                        @if (Route::has('login'))
                            <li class="nav-item">
                                <a class="nav-link btn btn-outline-light px-3 mx-1" href="{{ route('login') }}">
                                    Login
                                </a>
                            </li>
                        @endif

                        @if (Route::has('register'))
                            <li class="nav-item">
                                <a class="nav-link btn btn-primary px-3 mx-1 text-white" href="{{ route('register') }}">
                                    Registro
                                </a>
                            </li>
                        @endif
                    @else

                        <!-- USUARIO -->
                        <li class="nav-item dropdown">
                            <a id="navbarDropdown" class="nav-link dropdown-toggle fw-semibold" href="#" role="button" data-bs-toggle="dropdown">
                                👤 {{ Auth::user()->name }}
                            </a>

                            <div class="dropdown-menu dropdown-menu-end shadow">

                                <a class="dropdown-item text-danger" href="{{ route('logout') }}"
                                   onclick="event.preventDefault();
                                   document.getElementById('logout-form').submit();">
                                    Cerrar sesión
                                </a>

                                <form id="logout-form" action="{{ route('logout') }}" method="POST" class="d-none">
                                    @csrf
                                </form>

                            </div>
                        </li>

                    @endguest

                </ul>
            </div>
        </div>
    </nav>

    <!-- CONTENIDO -->
    <main class="py-4 container">
        @yield('content')
    </main>

</div>

</body>
</html>
