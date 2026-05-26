<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;

class PermissionSeeder extends Seeder
{
    public function run(): void
    {
        $permisos = [
            // Módulo Autenticación y Seguridad
            'ver usuarios','crear usuarios','editar usuarios','eliminar usuarios',
            'ver roles','crear roles','editar roles','eliminar roles',
            'ver bitacora',

            // Módulo Registro de Postulantes (CU-05 a CU-09)
            'ver postulantes','crear postulantes','editar postulantes','eliminar postulantes',

            // Módulo Gestión Académica (CU-10 a CU-13)
            'ver carreras','crear carreras','editar carreras','eliminar carreras',
            'ver materias','crear materias','editar materias','eliminar materias',
            'ver gestiones','crear gestiones','editar gestiones','eliminar gestiones',

            // Módulo Asignación de Grupos y Docentes (CU-14 a CU-21)
            'ver docentes','crear docentes','editar docentes','eliminar docentes',
            'ver grupos','crear grupos','editar grupos','eliminar grupos',

            // Módulo Exámenes y Control Académico (CU-22 a CU-26)
            'ver notas','crear notas','editar notas',

            // Módulo Panel Administrativo y Reportes (CU-27 a CU-33)
            'procesar admision','ver reportes',
        ];

        foreach ($permisos as $p) {
            Permission::firstOrCreate(['name' => $p, 'guard_name' => 'web']);
        }
    }
}
