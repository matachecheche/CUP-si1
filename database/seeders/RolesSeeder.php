<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolesSeeder extends Seeder
{
    public function run(): void
    {
        // Administrador del Sistema — acceso total
        $admin = Role::firstOrCreate(['name' => 'Administrador del Sistema', 'guard_name' => 'web']);
        $admin->syncPermissions(Permission::all());

        // Docente — solo notas y consulta de sus grupos
        $docente = Role::firstOrCreate(['name' => 'Docente', 'guard_name' => 'web']);
        $docente->syncPermissions([
            'ver grupos','ver postulantes','ver notas','crear notas','editar notas',
        ]);

        // Postulante — consulta sus propios datos
        $postulante = Role::firstOrCreate(['name' => 'Postulante', 'guard_name' => 'web']);
        $postulante->syncPermissions([
            'ver postulantes',
        ]);
    }
}
