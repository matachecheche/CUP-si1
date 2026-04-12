
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

                <!-- MÓDULOS -->
                <div class="sb-sidenav-menu-heading text-uppercase small text-secondary mt-3">Módulos</div>

                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('users.index') }}">
                    <div class="sb-nav-link-icon"><i class="fas fa-users"></i></div>
                    <span>Usuarios</span>
                </a>

                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('roles.index') }}">
                    <div class="sb-nav-link-icon"><i class="fa-solid fa-person-circle-plus"></i></div>
                    <span>Roles</span>
                </a>

                <!-- EMPLEADOS (COLAPSABLE) -->
                <a class="nav-link collapsed d-flex align-items-center gap-2" href="#"
                   data-bs-toggle="collapse" data-bs-target="#collapseEmpleados"
                   aria-expanded="false" aria-controls="collapseEmpleados">

                    <div class="sb-nav-link-icon"><i class="fas fa-id-card"></i></div>
                    <span>Empleados</span>
                    <div class="sb-sidenav-collapse-arrow ms-auto">
                        <i class="fas fa-angle-down"></i>
                    </div>
                </a>

                <div class="collapse" id="collapseEmpleados"
                     aria-labelledby="headingOne"
                     data-bs-parent="#sidenavAccordion">

                    <nav class="sb-sidenav-menu-nested nav">

                        <a class="nav-link ps-4" href="{{ route('empleados.index') }}">
                            <i class="fas fa-list me-2"></i> Lista de Empleados
                        </a>

                        <a class="nav-link ps-4" href="{{ route('cargos.index') }}">
                            <i class="fas fa-briefcase me-2"></i> Cargos
                        </a>

                    </nav>
                </div>

                <!-- OTROS -->
                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('residentes.index') }}">
                    <div class="sb-nav-link-icon"><i class="fas fa-building"></i></div>
                    <span>Residentes</span>
                </a>

                <a class="nav-link d-flex align-items-center gap-2" href="{{ route('bitacora.index') }}">
                    <div class="sb-nav-link-icon"><i class="fas fa-book"></i></div>
                    <span>Bitácora</span>
                </a>

                <!-- SALIR -->
                <a class="nav-link d-flex align-items-center gap-2 text-danger" href="{{ route('logout') }}">
                    <div class="sb-nav-link-icon"><i class="fa fa-sign-out"></i></div>
                    <span>Salir</span>
                </a>

            </div>
        </div>

    </nav>
</div>

