# Plan — Sidebar espejo del dashboard (mismos CU por módulo)

> **Para Claude Code Desktop.** Repo `CUP-si1`, rama `feature/mejiav2` (commit base `b83da50`).
> Stack: **Laravel 11 + AdminLTE 3 + Blade + Spatie Permission + PostgreSQL**.
> El **dashboard ya está correcto** (todos los CU visibles con "Sin acceso"/"Próximamente"). **Solo hay que arreglar el SIDEBAR.**

---

## Problema

El sidebar (`resources/views/layouts/ap.blade.php`) **no lista los mismos casos de uso** que cada módulo del dashboard (`resources/views/panel/index.blade.php`).

Ejemplo del Módulo 1: el sidebar muestra *Panel de Control, Gestión de Usuarios, Roles y Permisos, Bitácora*, pero **faltan CU-01 (Iniciar sesión), CU-02 (Cerrar sesión) y CU-03 (Recuperar contraseña)**.

## Objetivo

Reescribir el `<nav class="cup-sb">` para que **cada módulo del sidebar contenga exactamente los mismos CU que el mismo módulo del dashboard**, en el mismo orden, con su código CU, su ruta, su mismo `@can` y su estado "Sin acceso"/"Próximamente". Misma cantidad de ítems que el dashboard, 1:1.

Sin CSS nuevo: se reutilizan las clases existentes `ni`, `ico`, `ni pnd`, `nbg`.

---

## Mapa CU → sidebar (debe quedar idéntico al dashboard)

| Módulo | CU | Texto | Ruta | Gate |
|---|---|---|---|---|
| 1 | — | Panel de Control | `panel` | (siempre) |
| 1 | CU-01 | Iniciar sesión | `login` | público |
| 1 | CU-02 | Cerrar sesión | `logout` | público |
| 1 | CU-03 | Recuperar contraseña | `password.request` | público |
| 1 | CU-04 | Gestionar usuarios y roles | `users.index` | `ver usuarios` |
| 2 | CU-05 | Gestionar postulantes | `postulantes.index` | `ver postulantes` |
| 2 | CU-06 | Gestionar gestiones académicas | `gestiones.index` | `ver gestiones` |
| 2 | CU-07 | Gestionar carreras de la facultad | `carreras.index` | `ver carreras` |
| 2 | CU-08 | Definir cupos por carrera y gestión | `cupos.index` | `ver cupos` |
| 2 | CU-09 | Gestionar materias del CUP | `materias.index` | `ver materias` |
| 2 | CU-20 | Gestionar pasarela de pago | — | Próximamente |
| 3 | CU-10 | Gestionar docentes | `docentes.index` | `ver docentes` |
| 3 | CU-11 | Gestionar grupos | `grupos.index` | `ver grupos` |
| 3 | CU-12 | Asignar docente a grupos y materias | `grupos.index` | `ver grupos` |
| 4 | CU-13 | Registrar notas de exámenes | `notas.index` | `ver notas` |
| 4 | CU-14 | Calcular nota final, promedio y estado | `notas.index` | `ver notas` |
| 4 | CU-15 | Consultar notas del postulante | `notas.index` | `ver notas` |
| 5 | CU-16 | Procesar admisión por primera opción | `admision.index` | `procesar admision` |
| 5 | CU-17 | Reasignar postulantes a segunda opción | `admision.index` | `procesar admision` |
| 5 | CU-18 | Publicar resultado final de admisión | `admision.index` | `publicar admision` |
| 5 | CU-19 | Gestionar reportes y estadísticas | — | Próximamente |

> Nota: *Roles y Permisos* (`roles.index`) y *Bitácora* (`bitacora.index`) NO son CU del dashboard, pero se conservan como **accesos rápidos al final del Módulo 1** (después de CU-04), cada uno con su `@can` y su estado "Sin acceso".

---

## Acción única

Reemplazar **todo** el bloque `<nav class="cup-sb" id="cupSb"> ... </nav>` de `resources/views/layouts/ap.blade.php` por el siguiente (conserva el header `<header class="cup-top">` y el `<script>` del final tal como están):

```blade
<nav class="cup-sb" id="cupSb">
  <div class="sb-usr">
    <div class="av">{{ strtoupper(substr(Auth::user()->name??'U',0,1)) }}</div>
    <div>
      <div class="sbn">{{ Auth::user()->name??'Usuario' }}</div>
      <div class="sbr">{{ Auth::user()->getRoleNames()->first()??'Sin rol' }}</div>
    </div>
  </div>

  {{-- Módulo 1: Autenticación y Seguridad --}}
  <div class="sb-sec">
    <div class="sb-ttl">🔐 Autenticación y Seguridad</div>
    <a class="ni {{ request()->routeIs('panel') ? 'act':'' }}" href="{{ route('panel') }}">
      <i class="ico fas fa-th-large"></i>Panel de Control</a>
    <a class="ni" href="{{ route('login') }}">
      <i class="ico fas fa-sign-in-alt"></i>CU-01 · Iniciar sesión</a>
    <a class="ni" href="{{ route('logout') }}">
      <i class="ico fas fa-sign-out-alt"></i>CU-02 · Cerrar sesión</a>
    <a class="ni" href="{{ route('password.request') }}">
      <i class="ico fas fa-key"></i>CU-03 · Recuperar contraseña</a>
    @can('ver usuarios')
    <a class="ni {{ request()->routeIs('users.*') ? 'act':'' }}" href="{{ route('users.index') }}">
      <i class="ico fas fa-users-cog"></i>CU-04 · Gestionar usuarios y roles</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-users-cog"></i>CU-04 · Gestionar usuarios y roles<span class="nbg">Sin acceso</span></span>
    @endcan
    {{-- Accesos rápidos (no son CU del dashboard) --}}
    @can('ver roles')
    <a class="ni {{ request()->routeIs('roles.*') ? 'act':'' }}" href="{{ route('roles.index') }}">
      <i class="ico fas fa-user-shield"></i>Roles y Permisos</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-user-shield"></i>Roles y Permisos<span class="nbg">Sin acceso</span></span>
    @endcan
    @can('ver bitacora')
    <a class="ni {{ request()->routeIs('bitacora.*') ? 'act':'' }}" href="{{ route('bitacora.index') }}">
      <i class="ico fas fa-journal-whills"></i>Bitácora</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-journal-whills"></i>Bitácora<span class="nbg">Sin acceso</span></span>
    @endcan
  </div>
  <div class="sbdiv"></div>

  {{-- Módulo 2: Registro de Postulantes y Gestión Académica --}}
  <div class="sb-sec">
    <div class="sb-ttl">👤 Registro de Postulantes y Gestión Académica</div>
    @can('ver postulantes')
    <a class="ni {{ request()->routeIs('postulantes.*') ? 'act':'' }}" href="{{ route('postulantes.index') }}">
      <i class="ico fas fa-user-plus"></i>CU-05 · Gestionar postulantes</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-user-plus"></i>CU-05 · Gestionar postulantes<span class="nbg">Sin acceso</span></span>
    @endcan
    @can('ver gestiones')
    <a class="ni {{ request()->routeIs('gestiones.*') ? 'act':'' }}" href="{{ route('gestiones.index') }}">
      <i class="ico fas fa-calendar-alt"></i>CU-06 · Gestionar gestiones académicas</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-calendar-alt"></i>CU-06 · Gestionar gestiones académicas<span class="nbg">Sin acceso</span></span>
    @endcan
    @can('ver carreras')
    <a class="ni {{ request()->routeIs('carreras.*') ? 'act':'' }}" href="{{ route('carreras.index') }}">
      <i class="ico fas fa-graduation-cap"></i>CU-07 · Gestionar carreras de la facultad</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-graduation-cap"></i>CU-07 · Gestionar carreras de la facultad<span class="nbg">Sin acceso</span></span>
    @endcan
    @can('ver cupos')
    <a class="ni {{ request()->routeIs('cupos.*') ? 'act':'' }}" href="{{ route('cupos.index') }}">
      <i class="ico fas fa-sliders-h"></i>CU-08 · Definir cupos por carrera y gestión</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-sliders-h"></i>CU-08 · Definir cupos por carrera y gestión<span class="nbg">Sin acceso</span></span>
    @endcan
    @can('ver materias')
    <a class="ni {{ request()->routeIs('materias.*') ? 'act':'' }}" href="{{ route('materias.index') }}">
      <i class="ico fas fa-book-open"></i>CU-09 · Gestionar materias del CUP</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-book-open"></i>CU-09 · Gestionar materias del CUP<span class="nbg">Sin acceso</span></span>
    @endcan
    <span class="ni pnd"><i class="ico fas fa-credit-card"></i>CU-20 · Gestionar pasarela de pago<span class="nbg">Próximamente</span></span>
  </div>
  <div class="sbdiv"></div>

  {{-- Módulo 3: Asignación de Grupos y Docentes --}}
  <div class="sb-sec">
    <div class="sb-ttl">🏫 Asignación de Grupos y Docentes</div>
    @can('ver docentes')
    <a class="ni {{ request()->routeIs('docentes.*') ? 'act':'' }}" href="{{ route('docentes.index') }}">
      <i class="ico fas fa-chalkboard-teacher"></i>CU-10 · Gestionar docentes</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-chalkboard-teacher"></i>CU-10 · Gestionar docentes<span class="nbg">Sin acceso</span></span>
    @endcan
    @can('ver grupos')
    <a class="ni {{ request()->routeIs('grupos.*') ? 'act':'' }}" href="{{ route('grupos.index') }}">
      <i class="ico fas fa-layer-group"></i>CU-11 · Gestionar grupos</a>
    <a class="ni {{ request()->routeIs('grupos.*') ? 'act':'' }}" href="{{ route('grupos.index') }}">
      <i class="ico fas fa-user-tie"></i>CU-12 · Asignar docente a grupos y materias</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-layer-group"></i>CU-11 · Gestionar grupos<span class="nbg">Sin acceso</span></span>
    <span class="ni pnd"><i class="ico fas fa-user-tie"></i>CU-12 · Asignar docente a grupos y materias<span class="nbg">Sin acceso</span></span>
    @endcan
  </div>
  <div class="sbdiv"></div>

  {{-- Módulo 4: Exámenes y Control Académico --}}
  <div class="sb-sec">
    <div class="sb-ttl">📝 Exámenes y Control Académico</div>
    @can('ver notas')
    <a class="ni {{ request()->routeIs('notas.*') ? 'act':'' }}" href="{{ route('notas.index') }}">
      <i class="ico fas fa-pencil-alt"></i>CU-13 · Registrar notas de exámenes</a>
    <a class="ni {{ request()->routeIs('notas.*') ? 'act':'' }}" href="{{ route('notas.index') }}">
      <i class="ico fas fa-calculator"></i>CU-14 · Calcular nota final, promedio y estado</a>
    <a class="ni {{ request()->routeIs('notas.*') ? 'act':'' }}" href="{{ route('notas.index') }}">
      <i class="ico fas fa-search"></i>CU-15 · Consultar notas del postulante</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-pencil-alt"></i>CU-13 · Registrar notas de exámenes<span class="nbg">Sin acceso</span></span>
    <span class="ni pnd"><i class="ico fas fa-calculator"></i>CU-14 · Calcular nota final, promedio y estado<span class="nbg">Sin acceso</span></span>
    <span class="ni pnd"><i class="ico fas fa-search"></i>CU-15 · Consultar notas del postulante<span class="nbg">Sin acceso</span></span>
    @endcan
  </div>
  <div class="sbdiv"></div>

  {{-- Módulo 5: Panel Administrativo y Reportes --}}
  <div class="sb-sec">
    <div class="sb-ttl">📊 Panel Administrativo y Reportes</div>
    @can('procesar admision')
    <a class="ni {{ request()->routeIs('admision.*') ? 'act':'' }}" href="{{ route('admision.index') }}">
      <i class="ico fas fa-cogs"></i>CU-16 · Procesar admisión por primera opción</a>
    <a class="ni {{ request()->routeIs('admision.*') ? 'act':'' }}" href="{{ route('admision.index') }}">
      <i class="ico fas fa-exchange-alt"></i>CU-17 · Reasignar postulantes a segunda opción</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-cogs"></i>CU-16 · Procesar admisión por primera opción<span class="nbg">Sin acceso</span></span>
    <span class="ni pnd"><i class="ico fas fa-exchange-alt"></i>CU-17 · Reasignar postulantes a segunda opción<span class="nbg">Sin acceso</span></span>
    @endcan
    @can('publicar admision')
    <a class="ni {{ request()->routeIs('admision.*') ? 'act':'' }}" href="{{ route('admision.index') }}">
      <i class="ico fas fa-bullhorn"></i>CU-18 · Publicar resultado final de admisión</a>
    @else
    <span class="ni pnd"><i class="ico fas fa-bullhorn"></i>CU-18 · Publicar resultado final de admisión<span class="nbg">Sin acceso</span></span>
    @endcan
    <span class="ni pnd"><i class="ico fas fa-chart-bar"></i>CU-19 · Gestionar reportes y estadísticas<span class="nbg">Próximamente</span></span>
  </div>
  <div class="sbdiv"></div>

  <div class="sb-sec">
    <a class="ni lgt" href="{{ route('logout') }}"><i class="ico fas fa-sign-out-alt"></i>Cerrar sesión</a>
  </div>
</nav>
```

---

## Verificación

Probar con los 3 usuarios sembrados (password `12345678`): `admin@cup.edu.bo`, `docente@cup.edu.bo`, `postulante@cup.edu.bo`.

- [ ] Cada módulo del **sidebar** muestra **exactamente los mismos CU** (mismos códigos y mismo orden) que el módulo correspondiente del **dashboard**.
- [ ] Módulo 1 del sidebar ya incluye CU-01, CU-02, CU-03 y CU-04.
- [ ] Al final del Módulo 1 aparecen *Roles y Permisos* y *Bitácora* como accesos rápidos (con "Sin acceso" si el rol no tiene permiso).
- [ ] Los CU sin permiso aparecen como "Sin acceso" (no desaparecen). CU-19 y CU-20 como "Próximamente".
- [ ] **Admin:** todos activos salvo Próximamente. **Docente:** activos Grupos y Notas (+postulantes si el rol lo tiene); resto "Sin acceso". **Postulante:** casi todo "Sin acceso".
- [ ] Cada enlace activo navega a su ruta sin error (HTTP 200).
- [ ] No se agregó CSS nuevo.

Comandos:
```bash
npm run dev        # o npm run build
php artisan serve  # :8002
./vendor/bin/pint
```

## Pasos para Claude Code
1. Abrir `resources/views/layouts/ap.blade.php`.
2. Reemplazar el bloque `<nav class="cup-sb" id="cupSb"> ... </nav>` completo por el de arriba.
3. Dejar intactos el `<header>` y el `<script>`.
4. Levantar la app y validar la lista con los 3 usuarios.
5. `./vendor/bin/pint` y reportar.
