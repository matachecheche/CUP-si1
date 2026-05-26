<?php
namespace Database\Seeders;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
class CupDataSeeder extends Seeder {
    public function run(): void {
        DB::table('gestiones')->insertOrIgnore([
            ['descripcion'=>'Semestre 1-2026','fecha_inicio'=>'2026-01-15','fecha_fin'=>'2026-06-30','estado'=>'en_curso','created_at'=>now(),'updated_at'=>now()],
            ['descripcion'=>'Semestre 2-2026','fecha_inicio'=>'2026-07-15','fecha_fin'=>'2026-12-15','estado'=>'planificacion','created_at'=>now(),'updated_at'=>now()],
        ]);
        DB::table('carreras')->insertOrIgnore([
            ['nombre'=>'Ingeniería Informática',                  'sigla'=>'INF','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Ingeniería de Sistemas',                  'sigla'=>'SIS','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Ingeniería en Redes y Telecomunicaciones','sigla'=>'RYT','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Ingeniería en Robótica',                  'sigla'=>'ROB','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
        ]);
        DB::table('materias')->insertOrIgnore([
            ['nombre'=>'Computación', 'area_formacion'=>'Computación / Informática','pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>1,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Matemáticas', 'area_formacion'=>'Matemáticas',              'pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>2,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Física',      'area_formacion'=>'Física',                   'pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>3,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Inglés',      'area_formacion'=>'Inglés / Idiomas',         'pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>4,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
        ]);
    }
}
