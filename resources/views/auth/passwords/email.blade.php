@extends('adminlte::auth.passwords.email')

@section('auth_footer')
    <p class="mb-0">
        <a href="{{ route('login') }}">← Volver al inicio de sesión</a>
    </p>
@endsection