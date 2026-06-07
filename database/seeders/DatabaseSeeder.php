<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
class DatabaseSeeder extends Seeder {
    public function run(): void {
        $this->call([
            PermissionSeeder::class,
            RolesSeeder::class,
            UsuariosSeeder::class,
            CupDataSeeder::class,
            PagosSeeder::class,
            ComunicadosSeeder::class,
        ]);
    }
}
