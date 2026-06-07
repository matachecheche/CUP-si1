@if($errors->any())<div style="background:#fdecea;color:#92271d;border:1px solid #f5c6c2;border-radius:6px;padding:.7rem 1rem;margin-bottom:1rem">
<ul style="margin:0;padding-left:1.1rem">@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif
<div class="card" style="max-width:720px"><div class="card-bd" style="display:flex;flex-direction:column;gap:.9rem">
  <label style="display:flex;flex-direction:column;gap:.3rem;font-size:.85rem">Título *
    <input type="text" name="titulo" value="{{ old('titulo', $comunicado->titulo ?? '') }}" maxlength="150" required
           style="padding:.5rem .7rem;border:1px solid #d8d2c4;border-radius:6px"></label>
  <label style="display:flex;flex-direction:column;gap:.3rem;font-size:.85rem">Contenido *
    <textarea name="contenido" rows="6" required maxlength="5000"
              style="padding:.5rem .7rem;border:1px solid #d8d2c4;border-radius:6px">{{ old('contenido', $comunicado->contenido ?? '') }}</textarea></label>
  <div style="display:flex;gap:1rem;flex-wrap:wrap">
    <label style="display:flex;flex-direction:column;gap:.3rem;font-size:.85rem">Audiencia *
      <select name="audiencia" style="padding:.5rem .7rem;border:1px solid #d8d2c4;border-radius:6px;background:#fff">
        @foreach(['todos'=>'Todos','postulantes'=>'Postulantes','docentes'=>'Docentes'] as $v=>$l)
          <option value="{{ $v }}" {{ old('audiencia', $comunicado->audiencia ?? 'todos')===$v?'selected':'' }}>{{ $l }}</option>
        @endforeach
      </select></label>
    <label style="display:flex;flex-direction:column;gap:.3rem;font-size:.85rem">Vigente hasta (opcional)
      <input type="date" name="vigente_hasta" value="{{ old('vigente_hasta', isset($comunicado)?$comunicado->vigente_hasta?->format('Y-m-d'):'') }}"
             style="padding:.5rem .7rem;border:1px solid #d8d2c4;border-radius:6px"></label>
    <label style="display:flex;align-items:center;gap:.45rem;font-size:.85rem;margin-top:1.3rem">
      <input type="checkbox" name="publicado" value="1" {{ old('publicado', $comunicado->publicado ?? true) ? 'checked':'' }}> Publicado</label>
  </div>
  <div style="display:flex;gap:.5rem">
    <button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar</button>
    <a href="{{ route('comunicados.index') }}" class="btn bo2">Cancelar</a>
  </div>
</div></div>
