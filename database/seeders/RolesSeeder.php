<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

/**
 * Roles del Sistema de Admisión CUP — nuevo.odt § 4
 *
 * ┌─────────────────────────────┬──────────────────────────────────────────────┐
 * │ Rol                         │ Descripción (nuevo.odt)                      │
 * ├─────────────────────────────┼──────────────────────────────────────────────┤
 * │ Administrador del Sistema   │ Personal de la facultad. Configuración,      │
 * │                             │ gestión de usuarios, supervisión general,    │
 * │                             │ registro de postulantes, asignación de       │
 * │                             │ docentes, proceso de admisión, reportes.     │
 * ├─────────────────────────────┼──────────────────────────────────────────────┤
 * │ Docente                     │ Registra notas de sus grupos. Consulta       │
 * │                             │ nómina de alumnos a su cargo.                │
 * ├─────────────────────────────┼──────────────────────────────────────────────┤
 * │ Postulante                  │ Consulta sus notas y resultado de admisión.  │
 * │                             │ Carga documentos y elige opciones de carrera.│
 * └─────────────────────────────┴──────────────────────────────────────────────┘
 */
class RolesSeeder extends Seeder
{
    public function run(): void
    {
        // ── 1. Administrador del Sistema ──────────────────────────────────────
        // Tiene acceso total (todos los permisos del sistema)
        $admin = Role::firstOrCreate(['name' => 'Administrador del Sistema', 'guard_name' => 'web']);
        $admin->syncPermissions(Permission::all());

        // ── 2. Docente ────────────────────────────────────────────────────────
        // Solo opera sobre los grupos que le fueron asignados (CU-16, CU-22)
        $docente = Role::firstOrCreate(['name' => 'Docente', 'guard_name' => 'web']);
        $docente->syncPermissions([
            'ver grupos',
            'ver postulantes',
            'ver notas',
            'registrar notas',         // CU-22: registrar notas de sus grupos
            'ver carga horaria docente', // CU-16: consultar su propia carga
        ]);

        // ── 3. Postulante ─────────────────────────────────────────────────────
        // Acceso de solo lectura a sus propios datos (CU-06, CU-08, CU-09, CU-26)
        $postulante = Role::firstOrCreate(['name' => 'Postulante', 'guard_name' => 'web']);
        $postulante->syncPermissions([
            'cargar documentos postulante',  // CU-06
            'seleccionar opciones carrera',  // CU-08
            'consultar estado propio',       // CU-09
            'ver notas propias',             // CU-26
            'ver resultado propio',          // post CU-29
        ]);
    }
}
