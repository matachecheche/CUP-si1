<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            // Orden estricto: permisos → roles → usuarios
            PermissionSeeder::class,
            RolesSeeder::class,
            UsuariosSeeder::class,

            // Datos de referencia del dominio (descomenta a medida que implementes)
            // GestionSeeder::class,
            // CarreraSeeder::class,
            // MateriaSeeder::class,
            // DocenteSeeder::class,
        ]);
    }
}
