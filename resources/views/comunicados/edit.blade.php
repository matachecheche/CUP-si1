@extends('layouts.ap')
@section('title','Editar Comunicado')
@section('content')
<div class="ph"><h1>Editar Comunicado</h1><p class="sub">CU-21 — Modificar aviso institucional</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('comunicados.index') }}">Comunicados</a></li><li>Editar</li></ol></div>
<form method="POST" action="{{ route('comunicados.update',$comunicado) }}">@csrf @method('PUT') @include('comunicados._form')</form>
@endsection
