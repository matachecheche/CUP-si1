<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Datos maestros del CUP según el documento PDF
 * — 4 carreras de la FICCT
 * — 4 materias con ponderación 30%+30%+40%
 * — 1 gestión académica de ejemplo
 */
class CupDataSeeder extends Seeder
{
    public function run(): void
    {
        // Gestión ejemplo
        DB::table('gestiones')->insertOrIgnore([
            ['descripcion' => 'Semestre 1-2026', 'fecha_inicio' => '2026-01-15',
             'fecha_fin' => '2026-06-30', 'estado' => 'en_curso',
             'created_at' => now(), 'updated_at' => now()],
        ]);

        // 4 Carreras de la FICCT
        DB::table('carreras')->insertOrIgnore([
            ['nombre' => 'Ingeniería Informática',                'sigla' => 'INF',  'estado' => true, 'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Ingeniería de Sistemas',                'sigla' => 'SIS',  'estado' => true, 'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Ingeniería en Redes y Telecomunicaciones','sigla' => 'RYT', 'estado' => true, 'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Ingeniería en Robótica',                'sigla' => 'ROB',  'estado' => true, 'created_at' => now(), 'updated_at' => now()],
        ]);

        // 4 Materias con ponderación 30%+30%+40%
        DB::table('materias')->insertOrIgnore([
            ['nombre' => 'Computación',  'area_formacion' => 'Computación / Informática',
             'pond_examen1' => 30, 'pond_examen2' => 30, 'pond_examen3' => 40,
             'nota_minima_aprobacion' => 60, 'orden' => 1, 'estado' => true,
             'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Matemáticas',  'area_formacion' => 'Matemáticas',
             'pond_examen1' => 30, 'pond_examen2' => 30, 'pond_examen3' => 40,
             'nota_minima_aprobacion' => 60, 'orden' => 2, 'estado' => true,
             'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Física',       'area_formacion' => 'Física',
             'pond_examen1' => 30, 'pond_examen2' => 30, 'pond_examen3' => 40,
             'nota_minima_aprobacion' => 60, 'orden' => 3, 'estado' => true,
             'created_at' => now(), 'updated_at' => now()],
            ['nombre' => 'Inglés',       'area_formacion' => 'Inglés / Idiomas',
             'pond_examen1' => 30, 'pond_examen2' => 30, 'pond_examen3' => 40,
             'nota_minima_aprobacion' => 60, 'orden' => 4, 'estado' => true,
             'created_at' => now(), 'updated_at' => now()],
        ]);
    }
}
