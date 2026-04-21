<div id="layoutSidenav_nav">
    <nav class="sb-sidenav accordion sb-sidenav-dark bg-black shadow" id="sidenavAccordion">
        <div class="sb-sidenav-menu">
            <div class="nav">

                <!-- INICIO -->
                <div class="sb-sidenav-menu-heading text-uppercase small text-secondary">Inicio</div>
                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('panel') }}">
                    <div class="sb-nav-link-icon"><i class="fas fa-tachometer-alt"></i></div>
                    <span>Inicio</span>
                </a>

                {{-- ================================================ --}}
                {{-- PAQUETE 1 — Acceso y Seguridad                   --}}
                {{-- CU1 · CU2 · CU3 · CU4                           --}}
                {{-- ================================================ --}}
                <div class="sb-sidenav-menu-heading text-uppercase small mt-3"
                     style="color:#60a5fa; font-size:0.67rem; letter-spacing:0.05em; padding: 0.5rem 1rem 0.25rem;">
                    📦 Paquete 1 — Acceso y Seguridad
                </div>

                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('login') }}">
                    <div class="sb-nav-link-icon"><i class="fas fa-sign-in-alt"></i></div>
                    <span>CU1 · Iniciar sesión</span>
                </a>

                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('logout') }}">
                    <div class="sb-nav-link-icon"><i class="fas fa-sign-out-alt"></i></div>
                    <span>CU2 · Cerrar sesión</span>
                </a>

                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('users.index') }}">
                    <div class="sb-nav-link-icon"><i class="fas fa-users"></i></div>
                    <span>CU3 · Usuarios</span>
                </a>

                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('roles.index') }}">
                    <div class="sb-nav-link-icon"><i class="fas fa-user-shield"></i></div>
                    <span>CU4 · Roles y Permisos</span>
                </a>

                {{-- ================================================ --}}
                {{-- PAQUETE 2 — Personas y Estructura                --}}
                {{-- CU5 ✓ · CU6 ✓ · CU13 (pendiente)               --}}
                {{-- ================================================ --}}
                <div class="sb-sidenav-menu-heading text-uppercase small mt-3"
                     style="color:#34d399; font-size:0.67rem; letter-spacing:0.05em; padding: 0.5rem 1rem 0.25rem;">
                    📦 Paquete 2 — Personas y Estructura
                </div>

                <!-- Empleados colapsable (CU5) -->
                <a class="nav-link collapsed d-flex align-items-center gap-2" href="#"
                   data-bs-toggle="collapse" data-bs-target="#collapseEmpleados"
                   aria-expanded="false" aria-controls="collapseEmpleados">
                    <div class="sb-nav-link-icon"><i class="fas fa-id-card"></i></div>
                    <span>CU5 · Empleados</span>
                    <div class="sb-sidenav-collapse-arrow ms-auto"><i class="fas fa-angle-down"></i></div>
                </a>
                <div class="collapse" id="collapseEmpleados" data-bs-parent="#sidenavAccordion">
                    <nav class="sb-sidenav-menu-nested nav">
                        <a class="nav-link ps-4" href="{{ route('empleados.index') }}">
                            <i class="fas fa-list me-2"></i> Lista de Empleados
                        </a>
                        <a class="nav-link ps-4" href="{{ route('cargos.index') }}">
                            <i class="fas fa-briefcase me-2"></i> Cargos
                        </a>
                    </nav>
                </div>

                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('residentes.index') }}">
                    <div class="sb-nav-link-icon"><i class="fas fa-building"></i></div>
                    <span>CU6 · Residentes</span>
                </a>

                <span class="nav-link d-flex align-items-center gap-2" style="color:#334155; cursor:default;">
                    <div class="sb-nav-link-icon"><i class="fas fa-link"></i></div>
                    <span>CU13 · Vincular residente-unidad</span>
                    <small class="ms-auto" style="font-size:0.62rem; color:#334155;">Ciclo 2</small>
                </span>

                {{-- ================================================ --}}
                {{-- PAQUETE 3 — Gestión Operativa                    --}}
                {{-- CU7 · CU8 · CU9 · CU10 · CU15 (pendientes)     --}}
                {{-- ================================================ --}}
                <div class="sb-sidenav-menu-heading text-uppercase small mt-3"
                     style="color:#fb923c; font-size:0.67rem; letter-spacing:0.05em; padding: 0.5rem 1rem 0.25rem;">
                    📦 Paquete 3 — Gestión Operativa
                </div>

                <span class="nav-link d-flex align-items-center gap-2" style="color:#334155; cursor:default;">
                    <div class="sb-nav-link-icon"><i class="fas fa-dollar-sign"></i></div>
                    <span>CU7 · Pagos de cuotas</span>
                    <small class="ms-auto" style="font-size:0.62rem; color:#334155;">Ciclo 2</small>
                </span>
                <span class="nav-link d-flex align-items-center gap-2" style="color:#334155; cursor:default;">
                    <div class="sb-nav-link-icon"><i class="fas fa-calendar-check"></i></div>
                    <span>CU8 · Reservas áreas comunes</span>
                    <small class="ms-auto" style="font-size:0.62rem; color:#334155;">Ciclo 2</small>
                </span>
                <span class="nav-link d-flex align-items-center gap-2" style="color:#334155; cursor:default;">
                    <div class="sb-nav-link-icon"><i class="fas fa-tools"></i></div>
                    <span>CU9 · Mantenimientos</span>
                    <small class="ms-auto" style="font-size:0.62rem; color:#334155;">Ciclo 2</small>
                </span>
                <span class="nav-link d-flex align-items-center gap-2" style="color:#334155; cursor:default;">
                    <div class="sb-nav-link-icon"><i class="fas fa-door-open"></i></div>
                    <span>CU10 · Visitas</span>
                    <small class="ms-auto" style="font-size:0.62rem; color:#334155;">Ciclo 2</small>
                </span>
                <span class="nav-link d-flex align-items-center gap-2" style="color:#334155; cursor:default;">
                    <div class="sb-nav-link-icon"><i class="fas fa-handshake"></i></div>
                    <span>CU15 · Contratación empresas</span>
                    <small class="ms-auto" style="font-size:0.62rem; color:#334155;">Ciclo 2</small>
                </span>

                {{-- ================================================ --}}
                {{-- PAQUETE 4 — Comunicación y Reportes              --}}
                {{-- CU11 · CU12 · CU14 (pendientes)                 --}}
                {{-- ================================================ --}}
                <div class="sb-sidenav-menu-heading text-uppercase small mt-3"
                     style="color:#a78bfa; font-size:0.67rem; letter-spacing:0.05em; padding: 0.5rem 1rem 0.25rem;">
                    📦 Paquete 4 — Comunicación y Reportes
                </div>

                <span class="nav-link d-flex align-items-center gap-2" style="color:#334155; cursor:default;">
                    <div class="sb-nav-link-icon"><i class="fas fa-envelope"></i></div>
                    <span>CU11 · Comunicados internos</span>
                    <small class="ms-auto" style="font-size:0.62rem; color:#334155;">Ciclo 2</small>
                </span>
                <span class="nav-link d-flex align-items-center gap-2" style="color:#334155; cursor:default;">
                    <div class="sb-nav-link-icon"><i class="fas fa-file-alt"></i></div>
                    <span>CU12 · Informes administrativos</span>
                    <small class="ms-auto" style="font-size:0.62rem; color:#334155;">Ciclo 2</small>
                </span>
                <span class="nav-link d-flex align-items-center gap-2" style="color:#334155; cursor:default;">
                    <div class="sb-nav-link-icon"><i class="fas fa-receipt"></i></div>
                    <span>CU14 · Reportes de pago</span>
                    <small class="ms-auto" style="font-size:0.62rem; color:#334155;">Ciclo 2</small>
                </span>

                <!-- OTROS -->
                <div class="sb-sidenav-menu-heading text-uppercase small text-secondary mt-3">Otros</div>
                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('bitacora.index') }}">
                    <div class="sb-nav-link-icon"><i class="fas fa-book"></i></div>
                    <span>Bitácora</span>
                </a>

                <!-- SALIR -->
                <a class="nav-link d-flex align-items-center gap-2 text-danger mt-2" href="{{ route('logout') }}">
                    <div class="sb-nav-link-icon"><i class="fa fa-sign-out"></i></div>
                    <span>Salir</span>
                </a>

            </div>
        </div>
    </nav>
</div>