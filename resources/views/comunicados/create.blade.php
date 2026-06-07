@extends('layouts.ap')
@section('title','Nuevo Comunicado')
@section('content')
<div class="ph"><h1>Nuevo Comunicado</h1><p class="sub">CU-21 — Crear aviso institucional</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('comunicados.index') }}">Comunicados</a></li><li>Nuevo</li></ol></div>
<form method="POST" action="{{ route('comunicados.store') }}">@csrf @include('comunicados._form')</form>
@endsection
