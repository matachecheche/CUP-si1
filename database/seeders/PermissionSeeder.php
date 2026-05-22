<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;

/**
 * Permisos del Sistema de Admisión CUP
 * Derivados de los 33 casos de uso identificados en nuevo.odt § 6
 *
 * Roles que los consumen (§ 4):
 *   Administrador   → gestión total del sistema
 *   Docente         → registrar notas, consultar grupos y nóminas
 *   Postulante      → consultar sus propias notas y resultado
 */
class PermissionSeeder extends Seeder
{
    public function run(): void
    {
        $permisos = [

            // ── SEGURIDAD (CU-01 a CU-04) ─────────────────────────────────────
            // CU-01/02/03: login, logout y recuperar contraseña son rutas abiertas,
            // no requieren permiso explícito. Solo se protege la gestión de usuarios.
            'ver usuarios',       // CU-04 parcial
            'crear usuarios',
            'editar usuarios',
            'eliminar usuarios',
            'ver roles',
            'crear roles',
            'editar roles',
            'eliminar roles',
            'ver bitacora',

            // ── GESTIÓN DE POSTULANTES (CU-05 a CU-09) ───────────────────────
            'ver postulantes',           // CU-05, CU-09
            'crear postulantes',         // CU-05
            'editar postulantes',        // (modificar antes del cierre)
            'eliminar postulantes',
            'cargar documentos postulante',   // CU-06
            'validar requisitos postulante',  // CU-07
            'seleccionar opciones carrera',   // CU-08 — el postulante elige carreras
            'consultar estado propio',        // CU-09 — solo para el postulante

            // ── GESTIÓN ACADÉMICA (CU-10 a CU-13) ────────────────────────────
            'ver carreras',
            'crear carreras',     // CU-10
            'editar carreras',
            'eliminar carreras',
            'definir cupos',      // CU-11
            'ver cupos',
            'ver materias',
            'crear materias',     // CU-12
            'editar materias',
            'eliminar materias',
            'ver gestiones',
            'crear gestiones',    // CU-13
            'editar gestiones',
            'eliminar gestiones',

            // ── GESTIÓN DE DOCENTES (CU-14 a CU-16) ──────────────────────────
            'ver docentes',
            'crear docentes',     // CU-14
            'editar docentes',
            'eliminar docentes',
            'ver carga horaria docente',  // CU-16

            // ── CONFORMACIÓN DE GRUPOS (CU-17 a CU-21) ───────────────────────
            'generar grupos automaticos', // CU-17
            'ver grupos',
            'crear grupos',
            'editar grupos',
            'eliminar grupos',
            'asignar docente grupo',      // CU-18
            'ver horarios',
            'crear horarios',             // CU-20
            'editar horarios',
            'eliminar horarios',
            'inscribir postulantes grupos', // CU-21

            // ── EVALUACIÓN Y NOTAS (CU-22 a CU-26) ───────────────────────────
            'registrar notas',       // CU-22 — exclusivo del Docente
            'ver notas',             // CU-26 (admin/docente)
            'ver notas propias',     // CU-26 — solo el Postulante ve las suyas

            // ── ADMISIÓN (CU-27 a CU-29) ─────────────────────────────────────
            'procesar admision',          // CU-27
            'reasignar segunda opcion',   // CU-28
            'publicar resultado admision',// CU-29
            'ver resultados admision',    // Administrador
            'ver resultado propio',       // CU — Postulante consulta su resultado

            // ── REPORTES (CU-30 a CU-33) ─────────────────────────────────────
            'ver reportes',              // CU-30, CU-31, CU-32, CU-33
        ];

        foreach ($permisos as $permiso) {
            Permission::firstOrCreate(['name' => $permiso, 'guard_name' => 'web']);
        }
    }
}
