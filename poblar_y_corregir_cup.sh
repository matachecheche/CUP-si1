#!/usr/bin/env bash
# =============================================================================
#  poblar_y_corregir_cup.sh
#  Sistema CUP — FICCT
#
#  Ejecutar desde la RAÍZ del proyecto Laravel:
#      bash poblar_y_corregir_cup.sh
#
#  Qué hace este script:
#   1. Reescribe CupDataSeeder.php con datos ficticios completos
#      (gestiones, carreras, materias, cupos, docentes, postulantes,
#       grupos, asignaciones, notas, admisiones, usuarios vinculados)
#   2. Corrige PostulanteController — CU-07: valida que los 3 documentos
#      sean obligatorios antes de guardar
#   3. Corrige la vista postulantes/create — CU-07/CU-08: alerta visible
#      + validación JS que bloquea envío si faltan documentos
#   4. Corrige CarreraController — CU-11: cupos con feedback mejorado
#   5. Crea GrupoController — CU-17/CU-18/CU-19/CU-20/CU-21 (nuevo)
#   6. Crea NotaController   — CU-22 a CU-26 (nuevo)
#   7. Crea AdmisionController — CU-27/CU-28/CU-29 (nuevo)
#   8. Crea vistas: grupos/index, notas/index, admision/index
#   9. Agrega los modelos Grupo, Asignacion, Nota, Admision si no existen
#  10. Registra las rutas nuevas en routes/web.php
#  11. Ejecuta migrate:fresh --seed
# =============================================================================

set -e   # abortar ante cualquier error
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

ok()  { echo -e "${GREEN}  ✔  $*${NC}"; }
inf() { echo -e "${CYAN}  →  $*${NC}"; }
hdr() { echo -e "\n${YELLOW}══════════════════════════════════════════${NC}"; echo -e "${YELLOW}  $*${NC}"; echo -e "${YELLOW}══════════════════════════════════════════${NC}"; }

# Verificar que estamos en la raíz de un proyecto Laravel
if [ ! -f "artisan" ]; then
  echo -e "${RED}ERROR: No se encontró 'artisan'. Ejecuta el script desde la raíz del proyecto Laravel.${NC}"
  exit 1
fi

# =============================================================================
hdr "PASO 1 — Reescribir CupDataSeeder.php con datos ficticios completos"
# =============================================================================
inf "Escribiendo database/seeders/CupDataSeeder.php ..."

cat > database/seeders/CupDataSeeder.php << 'SEEDER_EOF'
<?php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\{DB, Hash};
use App\Models\{User, Docente, Postulante, Carrera, Gestion};
use Spatie\Permission\Models\Role;

/**
 * CupDataSeeder — pobla TODAS las tablas del sistema CUP con datos ficticios.
 * Ejecutar con: php artisan db:seed  o  migrate:fresh --seed
 */
class CupDataSeeder extends Seeder
{
    public function run(): void
    {
        // ── 1. GESTIONES ────────────────────────────────────────────────────
        DB::table('gestiones')->insertOrIgnore([
            ['descripcion'=>'Semestre 1-2024','fecha_inicio'=>'2024-02-01','fecha_fin'=>'2024-06-30','estado'=>'finalizado','created_at'=>now(),'updated_at'=>now()],
            ['descripcion'=>'Semestre 2-2024','fecha_inicio'=>'2024-07-15','fecha_fin'=>'2024-12-15','estado'=>'finalizado','created_at'=>now(),'updated_at'=>now()],
            ['descripcion'=>'Semestre 1-2025','fecha_inicio'=>'2025-02-03','fecha_fin'=>'2025-06-30','estado'=>'finalizado','created_at'=>now(),'updated_at'=>now()],
            ['descripcion'=>'Semestre 2-2025','fecha_inicio'=>'2025-07-14','fecha_fin'=>'2025-12-14','estado'=>'finalizado','created_at'=>now(),'updated_at'=>now()],
            ['descripcion'=>'Semestre 1-2026','fecha_inicio'=>'2026-02-02','fecha_fin'=>'2026-06-30','estado'=>'en_curso','created_at'=>now(),'updated_at'=>now()],
        ]);
        $gestion = DB::table('gestiones')->where('estado','en_curso')->first();

        // ── 2. CARRERAS ──────────────────────────────────────────────────────
        DB::table('carreras')->insertOrIgnore([
            ['nombre'=>'Ingeniería Informática',                  'sigla'=>'INF','descripcion'=>'Desarrollo de software y sistemas computacionales.','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Ingeniería de Sistemas',                  'sigla'=>'SIS','descripcion'=>'Análisis, diseño e implementación de sistemas de información.','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Ingeniería en Redes y Telecomunicaciones','sigla'=>'RYT','descripcion'=>'Diseño e instalación de redes de datos y comunicaciones.','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Ingeniería en Robótica',                  'sigla'=>'ROB','descripcion'=>'Diseño, programación y control de sistemas robóticos.','estado'=>true,'created_at'=>now(),'updated_at'=>now()],
        ]);

        // ── 3. MATERIAS ──────────────────────────────────────────────────────
        DB::table('materias')->insertOrIgnore([
            ['nombre'=>'Computación', 'area_formacion'=>'Computación / Informática','pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>1,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Matemáticas', 'area_formacion'=>'Matemáticas',              'pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>2,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Física',      'area_formacion'=>'Física',                   'pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>3,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ['nombre'=>'Inglés',      'area_formacion'=>'Inglés / Idiomas',         'pond_examen1'=>30,'pond_examen2'=>30,'pond_examen3'=>40,'nota_minima_aprobacion'=>60,'orden'=>4,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
        ]);

        $carreras = DB::table('carreras')->get();
        $materias = DB::table('materias')->get();

        // ── 4. CUPOS POR CARRERA Y GESTIÓN (CU-11) ──────────────────────────
        $cuposPorSigla = ['INF'=>80,'SIS'=>75,'RYT'=>60,'ROB'=>50];
        $gestiones = DB::table('gestiones')->get();
        foreach ($gestiones as $g) {
            foreach ($carreras as $c) {
                $cupo = $cuposPorSigla[$c->sigla] ?? 60;
                DB::table('cupos_carrera')->updateOrInsert(
                    ['carrera_id'=>$c->id,'gestion_id'=>$g->id],
                    ['cantidad_maxima'=>$cupo,'created_at'=>now(),'updated_at'=>now()]
                );
            }
        }

        // ── 5. DOCENTES (CU-14 / CU-15) ─────────────────────────────────────
        $docentesData = [
            ['ci'=>'4512378','nombres'=>'Roberto','apellidos'=>'Mamani Flores',   'telefono'=>'71234501','email'=>'rmamani@ficct.edu.bo',  'titulo_profesional'=>'Ing. en Informática',              'maestria'=>'Maestría en Ingeniería de Software',            'diplomado_educacion_superior'=>'Diplomado en Docencia Universitaria','certificacion_ingles'=>'B2','area_formacion'=>'Computación / Informática'],
            ['ci'=>'5623489','nombres'=>'Carla',   'apellidos'=>'Quispe Vargas',   'telefono'=>'72345602','email'=>'cquispe@ficct.edu.bo',   'titulo_profesional'=>'Lic. en Matemáticas',              'maestria'=>'Maestría en Docencia Universitaria',            'diplomado_educacion_superior'=>'Diplomado en Educación Superior',    'certificacion_ingles'=>null,'area_formacion'=>'Matemáticas'],
            ['ci'=>'6734590','nombres'=>'Pedro',   'apellidos'=>'Condori Huanca',  'telefono'=>'73456703','email'=>'pcondori@ficct.edu.bo',  'titulo_profesional'=>'Lic. en Física',                   'maestria'=>'Maestría en Física Aplicada',                   'diplomado_educacion_superior'=>'Diplomado en Educación Superior',    'certificacion_ingles'=>null,'area_formacion'=>'Física'],
            ['ci'=>'7845601','nombres'=>'Lucia',   'apellidos'=>'Torrez Sánchez',  'telefono'=>'74567804','email'=>'ltorrez@ficct.edu.bo',   'titulo_profesional'=>'Lic. en Lingüística',              'maestria'=>'Maestría en Enseñanza del Inglés',              'diplomado_educacion_superior'=>'Diplomado en Edu. Superior Bilingüe','certificacion_ingles'=>'C1','area_formacion'=>'Inglés / Idiomas'],
            ['ci'=>'8956712','nombres'=>'Julio',   'apellidos'=>'Chávez Montaño',  'telefono'=>'75678905','email'=>'jchavez@ficct.edu.bo',   'titulo_profesional'=>'Ing. de Sistemas',                 'maestria'=>'Maestría en Sistemas de Información',           'diplomado_educacion_superior'=>'Diplomado en Docencia Universitaria','certificacion_ingles'=>'B1','area_formacion'=>'Computación / Informática'],
            ['ci'=>'9067823','nombres'=>'Sandra',  'apellidos'=>'Apaza Mamani',    'telefono'=>'76789006','email'=>'sapaza@ficct.edu.bo',    'titulo_profesional'=>'Lic. en Matemáticas',              'maestria'=>'Maestría en Matemática Educativa',              'diplomado_educacion_superior'=>'Diplomado en Educación Superior',    'certificacion_ingles'=>null,'area_formacion'=>'Matemáticas'],
            ['ci'=>'1078934','nombres'=>'Hugo',    'apellidos'=>'Ticona Larico',   'telefono'=>'77890107','email'=>'hticona@ficct.edu.bo',   'titulo_profesional'=>'Lic. en Física',                   'maestria'=>'Maestría en Física Nuclear',                   'diplomado_educacion_superior'=>'Diplomado en Educación Superior',    'certificacion_ingles'=>null,'area_formacion'=>'Física'],
            ['ci'=>'2189045','nombres'=>'Ana',     'apellidos'=>'Beltrán Rojas',   'telefono'=>'78901208','email'=>'abeltran@ficct.edu.bo',  'titulo_profesional'=>'Lic. en Lingüística Aplicada',     'maestria'=>'Maestría en Traducción e Interpretación',      'diplomado_educacion_superior'=>'Diplomado en Educación Superior',    'certificacion_ingles'=>'C2','area_formacion'=>'Inglés / Idiomas'],
            ['ci'=>'3290156','nombres'=>'Carlos',  'apellidos'=>'Villanueva Cruz', 'telefono'=>'79012309','email'=>'cvillanueva@ficct.edu.bo','titulo_profesional'=>'Ing. en Redes y Telecomunicaciones','maestria'=>'Maestría en Redes de Computadoras',            'diplomado_educacion_superior'=>'Diplomado en Docencia Universitaria','certificacion_ingles'=>'B2','area_formacion'=>'Computación / Informática'],
            ['ci'=>'4301267','nombres'=>'Maria',   'apellidos'=>'Aliaga Pinto',    'telefono'=>'70123410','email'=>'maliaga@ficct.edu.bo',   'titulo_profesional'=>'Lic. en Matemáticas',              'maestria'=>'Maestría en Estadística Aplicada',             'diplomado_educacion_superior'=>'Diplomado en Educación Superior',    'certificacion_ingles'=>null,'area_formacion'=>'Matemáticas'],
        ];

        foreach ($docentesData as $d) {
            DB::table('docentes')->updateOrInsert(
                ['ci' => $d['ci']],
                array_merge($d, ['estado'=>true,'created_at'=>now(),'updated_at'=>now()])
            );
        }
        $docentes = DB::table('docentes')->get()->keyBy('email');

        // ── 6. USUARIOS para docentes (vinculados) ───────────────────────────
        $rolDocente = Role::where('name','Docente')->first();
        foreach ($docentesData as $d) {
            $doc = $docentes[$d['email']] ?? null;
            if (!$doc) continue;
            $user = User::firstOrCreate(
                ['email' => $d['email']],
                [
                    'name'              => $d['nombres'].' '.$d['apellidos'],
                    'password'          => Hash::make('Docente@2026'),
                    'email_verified_at' => now(),
                    'activo'            => true,
                    'docente_id'        => $doc->id,
                ]
            );
            if ($rolDocente && !$user->hasRole('Docente')) {
                $user->assignRole($rolDocente);
            }
        }

        // ── 7. POSTULANTES (150 ficticios) (CU-05 / CU-08) ──────────────────
        $nombres   = ['Juan','María','Carlos','Ana','Luis','Rosa','Jorge','Elena','Miguel','Paola','Ricardo','Sandra','Fernando','Claudia','Daniel','Patricia','Eduardo','Verónica','Andrés','Natalia','Sergio','Valeria','Marcos','Alejandra','Pablo','Camila','Oscar','Fernanda','Iván','Diana'];
        $apellidos = ['Mamani','Quispe','Condori','Flores','García','Torrez','Chávez','Apaza','Ticona','Aliaga','Villanueva','Beltrán','Herrera','Pinto','Rojas','Vega','Soria','Marca','Gutiérrez','Espinoza','Mendoza','Salazar','Barrios','Cáceres','Pérez','López','Miranda','Vargas','Huanca','Cruz'];
        $colegios  = ['Colegio Nacional Bolivia','U.E. San Calixto','U.E. Don Bosco','U.E. La Salle','U.E. Franz Tamayo','Colegio Los Andes','U.E. Ayacucho','U.E. Simón Bolívar','Colegio Hernando Siles','U.E. Sagrado Corazón'];
        $ciudades  = ['La Paz','El Alto','Cochabamba','Santa Cruz','Oruro'];
        $carreraIds = $carreras->pluck('id')->toArray();
        $rolPost    = Role::where('name','Postulante')->first();

        $postInsertados = 0;
        for ($i = 1; $i <= 150; $i++) {
            $ci = (string)(10000000 + $i * 137 + ($i % 99));
            if (DB::table('postulantes')->where('ci',$ci)->exists()) continue;

            $nom = $nombres[($i-1) % count($nombres)];
            $ap1 = $apellidos[($i)   % count($apellidos)];
            $ap2 = $apellidos[($i+5) % count($apellidos)];
            $ops  = $carreraIds;
            shuffle($ops);
            $op1 = $ops[0]; $op2 = $ops[1];
            $nac = \Carbon\Carbon::now()->subYears(rand(17,22))->subDays(rand(0,365))->toDateString();

            $pid = DB::table('postulantes')->insertGetId([
                'gestion_id'         => $gestion->id,
                'primera_opcion_id'  => $op1,
                'segunda_opcion_id'  => $op2,
                'ci'                 => $ci,
                'nombres'            => $nom,
                'apellidos'          => "$ap1 $ap2",
                'fecha_nacimiento'   => $nac,
                'sexo'               => ($i % 2 === 0) ? 'M' : 'F',
                'direccion'          => 'Av. '.($i % 20 + 1).' N° '.rand(100,999),
                'telefono'           => '7'.rand(1000000,9999999),
                'email'              => "postulante{$i}@gmail.com",
                'colegio_procedencia'=> $colegios[$i % count($colegios)],
                'ciudad'             => $ciudades[$i % count($ciudades)],
                'doc_ci'             => true,
                'doc_libreta_colegio'=> true,
                'doc_titulo_bachiller'=> true,
                'estado'             => 'inscrito',
                'created_at'         => now(),
                'updated_at'         => now(),
            ]);

            // Usuario vinculado al postulante
            $email = "postulante{$i}@gmail.com";
            $user = User::firstOrCreate(
                ['email' => $email],
                [
                    'name'              => "$nom $ap1 $ap2",
                    'password'          => Hash::make('Postulante@2026'),
                    'email_verified_at' => now(),
                    'activo'            => true,
                    'postulante_id'     => $pid,
                ]
            );
            if ($rolPost && !$user->hasRole('Postulante')) {
                $user->assignRole($rolPost);
            }
            $postInsertados++;
        }

        // ── 8. GRUPOS (CU-17) — CEIL(150/60) = 3 grupos ─────────────────────
        if (DB::table('grupos')->where('gestion_id',$gestion->id)->count() === 0) {
            DB::table('grupos')->insert([
                ['gestion_id'=>$gestion->id,'codigo'=>'GRP-A','turno'=>'mañana', 'modalidad'=>'presencial','capacidad_maxima'=>60,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
                ['gestion_id'=>$gestion->id,'codigo'=>'GRP-B','turno'=>'tarde',  'modalidad'=>'presencial','capacidad_maxima'=>60,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
                ['gestion_id'=>$gestion->id,'codigo'=>'GRP-C','turno'=>'noche',  'modalidad'=>'virtual',   'capacidad_maxima'=>60,'estado'=>true,'created_at'=>now(),'updated_at'=>now()],
            ]);
        }
        $grupos = DB::table('grupos')->where('gestion_id',$gestion->id)->get();

        // ── 9. INSCRIBIR POSTULANTES A GRUPOS (CU-21) ────────────────────────
        $postIds = DB::table('postulantes')->where('gestion_id',$gestion->id)->pluck('id')->toArray();
        foreach ($postIds as $idx => $pid) {
            $grupoObj = $grupos[$idx % count($grupos)]; // distribución rotativa
            DB::table('grupo_postulante')->updateOrInsert(
                ['grupo_id'=>$grupoObj->id,'postulante_id'=>$pid],
                ['created_at'=>now(),'updated_at'=>now()]
            );
            DB::table('postulantes')->where('id',$pid)->update(['estado'=>'en_curso','updated_at'=>now()]);
        }

        // ── 10. ASIGNACIONES DOCENTE–GRUPO–MATERIA (CU-18) ──────────────────
        //  Comp→Roberto,Julio,Carlos | Mat→Carla,Sandra,Maria | Fis→Pedro,Hugo | Ing→Lucia,Ana
        $docIds = DB::table('docentes')->pluck('id','email')->toArray();
        $matIds = DB::table('materias')->pluck('id','nombre')->toArray();
        $asignMap = [
            // [grupo_idx, materia_nombre, docente_email, dia, h_inicio, h_fin]
            [0,'Computación','rmamani@ficct.edu.bo','lunes',   '07:00','09:00'],
            [0,'Matemáticas','cquispe@ficct.edu.bo', 'lunes',   '09:00','11:00'],
            [0,'Física',     'pcondori@ficct.edu.bo','martes',  '07:00','09:00'],
            [0,'Inglés',     'ltorrez@ficct.edu.bo', 'martes',  '09:00','11:00'],
            [1,'Computación','jchavez@ficct.edu.bo', 'lunes',   '14:00','16:00'],
            [1,'Matemáticas','sapaza@ficct.edu.bo',  'lunes',   '16:00','18:00'],
            [1,'Física',     'hticona@ficct.edu.bo', 'martes',  '14:00','16:00'],
            [1,'Inglés',     'abeltran@ficct.edu.bo','martes',  '16:00','18:00'],
            [2,'Computación','cvillanueva@ficct.edu.bo','miercoles','19:00','21:00'],
            [2,'Matemáticas','maliaga@ficct.edu.bo', 'miercoles','19:00','21:00'],
            [2,'Física',     'pcondori@ficct.edu.bo','jueves',  '19:00','21:00'],
            [2,'Inglés',     'ltorrez@ficct.edu.bo', 'jueves',  '19:00','21:00'],
        ];
        foreach ($asignMap as [$gi,$mat,$email,$dia,$hi,$hf]) {
            $grp = $grupos[$gi] ?? null;
            $mid = $matIds[$mat] ?? null;
            $did = $docIds[$email] ?? null;
            if (!$grp || !$mid || !$did) continue;
            DB::table('asignaciones')->updateOrInsert(
                ['grupo_id'=>$grp->id,'materia_id'=>$mid],
                ['docente_id'=>$did,'dia'=>$dia,'hora_inicio'=>$hi,'hora_fin'=>$hf,'created_at'=>now(),'updated_at'=>now()]
            );
        }

        // ── 11. NOTAS (CU-22 a CU-25) — 3 exámenes × 4 materias × 150 postulantes
        $matList = DB::table('materias')->get();
        $gpMap   = DB::table('grupo_postulante')->get()->groupBy('postulante_id');

        $postAll = DB::table('postulantes')->where('gestion_id',$gestion->id)->pluck('id')->toArray();
        foreach ($postAll as $idx => $pid) {
            $aprueba = (($idx % 10 !== 0) && ($idx % 7 !== 0)); // ~70% aprueban
            $gpRows  = $gpMap->get($pid);
            $grupoId = $gpRows ? $gpRows->first()->grupo_id : $grupos[0]->id;

            foreach ($matList as $mat) {
                if (DB::table('notas')->where(['postulante_id'=>$pid,'materia_id'=>$mat->id,'grupo_id'=>$grupoId])->exists()) continue;

                if ($aprueba) {
                    $n1 = rand(62,92); $n2 = rand(60,95); $n3 = rand(63,98);
                } else {
                    if ($mat->nombre === 'Matemáticas') {
                        $n1 = rand(20,55); $n2 = rand(18,52); $n3 = rand(22,58);
                    } else {
                        $n1 = rand(55,75); $n2 = rand(50,72); $n3 = rand(52,74);
                    }
                }
                $nf = round($n1*0.30 + $n2*0.30 + $n3*0.40, 2);
                DB::table('notas')->insert([
                    'postulante_id'=>$pid,'materia_id'=>$mat->id,'grupo_id'=>$grupoId,
                    'examen1'=>$n1,'examen2'=>$n2,'examen3'=>$n3,
                    'nota_final'=>$nf,'aprobado'=>($nf>=60),
                    'created_at'=>now(),'updated_at'=>now(),
                ]);
            }

            // Actualizar promedio y estado del postulante
            $notasPost = DB::table('notas')->where('postulante_id',$pid)->get();
            $promedio  = round($notasPost->avg('nota_final'), 2);
            $estadoPos = $notasPost->every(fn($n)=>$n->nota_final>=60) ? 'aprobado' : 'no_aprobado';
            DB::table('postulantes')->where('id',$pid)->update([
                'promedio_general'=>$promedio,'estado'=>$estadoPos,'updated_at'=>now()
            ]);
        }

        // ── 12. ADMISIONES (CU-27 / CU-28 / CU-29) ──────────────────────────
        $cuposDB = DB::table('cupos_carrera')->where('gestion_id',$gestion->id)->pluck('cantidad_maxima','carrera_id')->toArray();
        $contadores = array_fill_keys(array_keys($cuposDB), 0);

        $aprobados = DB::table('postulantes')
            ->where('gestion_id',$gestion->id)
            ->where('estado','aprobado')
            ->orderByDesc('promedio_general')
            ->get();

        $pendientes2 = [];
        foreach ($aprobados as $p) {
            if (DB::table('admisiones')->where('postulante_id',$p->id)->exists()) continue;
            $c1 = $p->primera_opcion_id;
            if (($contadores[$c1] ?? 0) < ($cuposDB[$c1] ?? 0)) {
                DB::table('admisiones')->insert(['postulante_id'=>$p->id,'gestion_id'=>$gestion->id,'promedio_general'=>$p->promedio_general,'carrera_asignada_id'=>$c1,'resultado'=>'admitido_primera','publicado'=>true,'created_at'=>now(),'updated_at'=>now()]);
                $contadores[$c1]++;
                DB::table('postulantes')->where('id',$p->id)->update(['estado'=>'admitido','updated_at'=>now()]);
            } else {
                $pendientes2[] = $p;
            }
        }
        foreach ($pendientes2 as $p) {
            $c2 = $p->segunda_opcion_id;
            if (($contadores[$c2] ?? 0) < ($cuposDB[$c2] ?? 0)) {
                DB::table('admisiones')->insert(['postulante_id'=>$p->id,'gestion_id'=>$gestion->id,'promedio_general'=>$p->promedio_general,'carrera_asignada_id'=>$c2,'resultado'=>'admitido_segunda','publicado'=>true,'created_at'=>now(),'updated_at'=>now()]);
                $contadores[$c2]++;
                DB::table('postulantes')->where('id',$p->id)->update(['estado'=>'admitido_segunda_opcion','updated_at'=>now()]);
            } else {
                DB::table('admisiones')->insert(['postulante_id'=>$p->id,'gestion_id'=>$gestion->id,'promedio_general'=>$p->promedio_general,'carrera_asignada_id'=>null,'resultado'=>'no_admitido','publicado'=>true,'created_at'=>now(),'updated_at'=>now()]);
                DB::table('postulantes')->where('id',$p->id)->update(['estado'=>'no_admitido','updated_at'=>now()]);
            }
        }
        // Reprobados sin admisión
        DB::table('postulantes')->where('gestion_id',$gestion->id)->where('estado','no_aprobado')
            ->chunkById(50, function($chunk) use ($gestion) {
                foreach ($chunk as $p) {
                    if (DB::table('admisiones')->where('postulante_id',$p->id)->exists()) continue;
                    DB::table('admisiones')->insert(['postulante_id'=>$p->id,'gestion_id'=>$gestion->id,'promedio_general'=>$p->promedio_general,'carrera_asignada_id'=>null,'resultado'=>'no_admitido','publicado'=>false,'created_at'=>now(),'updated_at'=>now()]);
                }
            });

        $this->command->info('  CupDataSeeder completado ✔');
    }
}
SEEDER_EOF
ok "CupDataSeeder.php reescrito"

# =============================================================================
hdr "PASO 2 — CU-07: Validación obligatoria de documentos en PostulanteController"
# =============================================================================
inf "Parcheando app/Http/Controllers/PostulanteController.php ..."

# Inyectar validación de documentos justo antes de Postulante::create($d)
# Buscamos la línea con Postulante::create y añadimos el guard antes
php -r "
\$file = 'app/Http/Controllers/PostulanteController.php';
\$src  = file_get_contents(\$file);

\$old = \"\\\$p=Postulante::create(\\\$d);\";
\$new = \"// CU-07: los 3 documentos son obligatorios
        if (!\\\$d['doc_ci'] || !\\\$d['doc_libreta_colegio'] || !\\\$d['doc_titulo_bachiller']) {
            return back()
                ->withErrors(['documentos'=>'Para completar la inscripción debes presentar los tres documentos: CI, Libreta de colegio y Título de Bachiller.'])
                ->withInput();
        }
        \\\$p=Postulante::create(\\\$d);\";

if (strpos(\$src, 'CU-07: los 3 documentos') === false) {
    \$src = str_replace(\$old, \$new, \$src);
    file_put_contents(\$file, \$src);
    echo 'parcheado';
} else {
    echo 'ya existe';
}
"
ok "PostulanteController — CU-07 validación de documentos aplicada"

# =============================================================================
hdr "PASO 3 — Crear Modelos faltantes (Grupo, Asignacion, Nota, Admision)"
# =============================================================================

# ── Modelo Grupo
cat > app/Models/Grupo.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Grupo extends Model {
    protected $table = 'grupos';
    protected $fillable = ['gestion_id','codigo','turno','modalidad','capacidad_maxima','estado'];
    public function gestion()      { return $this->belongsTo(Gestion::class); }
    public function postulantes()  { return $this->belongsToMany(Postulante::class,'grupo_postulante'); }
    public function asignaciones() { return $this->hasMany(Asignacion::class); }
    public function notas()        { return $this->hasMany(Nota::class); }
}
EOF
ok "app/Models/Grupo.php"

# ── Modelo Asignacion
cat > app/Models/Asignacion.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Asignacion extends Model {
    protected $table = 'asignaciones';
    protected $fillable = ['grupo_id','docente_id','materia_id','dia','hora_inicio','hora_fin'];
    public function grupo()   { return $this->belongsTo(Grupo::class); }
    public function docente() { return $this->belongsTo(Docente::class); }
    public function materia() { return $this->belongsTo(Materia::class); }
}
EOF
ok "app/Models/Asignacion.php"

# ── Modelo Nota
cat > app/Models/Nota.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Nota extends Model {
    protected $table = 'notas';
    protected $fillable = ['postulante_id','materia_id','grupo_id','examen1','examen2','examen3','nota_final','aprobado'];
    protected $casts    = ['aprobado'=>'boolean'];
    public function postulante() { return $this->belongsTo(Postulante::class); }
    public function materia()    { return $this->belongsTo(Materia::class); }
    public function grupo()      { return $this->belongsTo(Grupo::class); }
    /** Calcula y persiste la nota final ponderada */
    public function calcularNotaFinal(): void {
        $mat = $this->materia;
        $p1  = $mat ? $mat->pond_examen1 : 30;
        $p2  = $mat ? $mat->pond_examen2 : 30;
        $p3  = $mat ? $mat->pond_examen3 : 40;
        $nf  = round(
            ($this->examen1 * $p1 / 100) +
            ($this->examen2 * $p2 / 100) +
            ($this->examen3 * $p3 / 100), 2);
        $this->nota_final = $nf;
        $this->aprobado   = ($nf >= ($mat ? $mat->nota_minima_aprobacion : 60));
        $this->save();
    }
}
EOF
ok "app/Models/Nota.php"

# ── Modelo Admision
cat > app/Models/Admision.php << 'EOF'
<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Admision extends Model {
    protected $table = 'admisiones';
    protected $fillable = ['postulante_id','gestion_id','promedio_general','carrera_asignada_id','resultado','publicado'];
    protected $casts = ['publicado'=>'boolean'];
    public function postulante()     { return $this->belongsTo(Postulante::class); }
    public function gestion()        { return $this->belongsTo(Gestion::class); }
    public function carreraAsignada(){ return $this->belongsTo(Carrera::class,'carrera_asignada_id'); }
}
EOF
ok "app/Models/Admision.php"

# =============================================================================
hdr "PASO 4 — Crear GrupoController (CU-17/18/19/20/21)"
# =============================================================================
cat > app/Http/Controllers/GrupoController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\{Grupo, Asignacion, Docente, Materia, Gestion, Postulante};
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class GrupoController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver grupos')->only('index','show');
        $this->middleware('permission:crear grupos')->only('create','store','generar');
        $this->middleware('permission:editar grupos')->only('edit','update','asignarDocente','inscribirPostulantes');
        $this->middleware('permission:eliminar grupos')->only('destroy');
    }

    /** CU-17: Lista grupos de la gestión activa y muestra botón de generación automática */
    public function index()
    {
        $gestion  = Gestion::where('estado','en_curso')->first();
        $grupos   = $gestion
            ? Grupo::where('gestion_id', $gestion->id)
                ->withCount('postulantes')
                ->with(['asignaciones.docente','asignaciones.materia'])
                ->get()
            : collect();

        $totalInscritos  = $gestion ? Postulante::where('gestion_id',$gestion->id)->count() : 0;
        $gruposNecesarios = $totalInscritos > 0 ? (int) ceil($totalInscritos / 60) : 0;

        return view('grupos.index', compact('gestion','grupos','totalInscritos','gruposNecesarios'));
    }

    /** CU-17: Genera automáticamente los grupos necesarios (CEIL(inscritos/60)) */
    public function generar(Request $r)
    {
        $gestion = Gestion::where('estado','en_curso')->firstOrFail();
        $total   = Postulante::where('gestion_id', $gestion->id)->count();
        $necesarios = (int) ceil($total / 60);
        $existentes = Grupo::where('gestion_id', $gestion->id)->count();

        $turnos    = ['mañana','tarde','noche'];
        $modalidad = ['presencial','presencial','virtual'];
        $creados   = 0;

        for ($i = $existentes; $i < $necesarios; $i++) {
            $letra = chr(65 + $i); // A, B, C, D …
            Grupo::create([
                'gestion_id'      => $gestion->id,
                'codigo'          => "GRP-{$letra}",
                'turno'           => $turnos[$i % 3],
                'modalidad'       => $modalidad[$i % 3],
                'capacidad_maxima'=> 60,
                'estado'          => true,
            ]);
            $creados++;
        }

        $this->registrarEnBitacora("Generó {$creados} grupo(s) automáticamente para {$gestion->descripcion}", null, 'Grupos');
        return redirect()->route('grupos.index')
            ->with('success', $creados > 0
                ? "Se generaron {$creados} grupo(s) automáticamente (total inscritos: {$total})."
                : "Ya existen los {$existentes} grupo(s) necesarios para {$total} inscritos.");
    }

    public function show(Grupo $grupo)
    {
        $grupo->load(['asignaciones.docente','asignaciones.materia','postulantes']);
        $docentes = Docente::where('estado',true)->orderBy('apellidos')->get();
        $materias = Materia::where('estado',true)->orderBy('orden')->get();
        return view('grupos.show', compact('grupo','docentes','materias'));
    }

    public function edit(Grupo $grupo)
    {
        return view('grupos.edit', compact('grupo'));
    }

    public function update(Request $r, Grupo $grupo)
    {
        $d = $r->validate([
            'turno'            => 'required|in:mañana,tarde,noche',
            'modalidad'        => 'required|in:presencial,virtual',
            'capacidad_maxima' => 'required|integer|min:1|max:100',
            'estado'           => 'boolean',
        ]);
        $d['estado'] = $r->boolean('estado', true);
        $grupo->update($d);
        $this->registrarEnBitacora("Editó grupo {$grupo->codigo}", $grupo->id, 'Grupos');
        return redirect()->route('grupos.show', $grupo)->with('success', 'Grupo actualizado.');
    }

    /** CU-18/CU-19: Asignar docente a grupo-materia con validación de cruces */
    public function asignarDocente(Request $r, Grupo $grupo)
    {
        $d = $r->validate([
            'docente_id' => 'required|exists:docentes,id',
            'materia_id' => 'required|exists:materias,id',
            'dia'        => 'required|in:lunes,martes,miercoles,jueves,viernes,sabado',
            'hora_inicio'=> 'required|date_format:H:i',
            'hora_fin'   => 'required|date_format:H:i|after:hora_inicio',
        ]);

        // CU-19: Validar cruce de horario del docente
        $cruce = Asignacion::where('docente_id', $d['docente_id'])
            ->where('dia', $d['dia'])
            ->where(function($q) use ($d) {
                $q->whereBetween('hora_inicio', [$d['hora_inicio'], $d['hora_fin']])
                  ->orWhereBetween('hora_fin',   [$d['hora_inicio'], $d['hora_fin']])
                  ->orWhere(function($q2) use ($d) {
                      $q2->where('hora_inicio','<=',$d['hora_inicio'])->where('hora_fin','>=',$d['hora_fin']);
                  });
            })
            ->whereHas('grupo', fn($q) => $q->where('id','!=',$grupo->id))
            ->first();

        if ($cruce) {
            return back()->withErrors([
                'docente_id' => "⚠ Cruce de horario: el docente ya tiene asignado el día {$d['dia']} de {$cruce->hora_inicio} a {$cruce->hora_fin} en el grupo {$cruce->grupo->codigo}."
            ])->withInput();
        }

        // CU-16: Máx 4 grupos por docente
        $gruposDocente = Asignacion::where('docente_id',$d['docente_id'])
            ->distinct('grupo_id')->count('grupo_id');
        if ($gruposDocente >= 4 && !Asignacion::where('docente_id',$d['docente_id'])->where('grupo_id',$grupo->id)->exists()) {
            return back()->withErrors(['docente_id'=>'El docente ya tiene asignados 4 grupos (máximo permitido).'])->withInput();
        }

        Asignacion::updateOrCreate(
            ['grupo_id'=>$grupo->id,'materia_id'=>$d['materia_id']],
            ['docente_id'=>$d['docente_id'],'dia'=>$d['dia'],'hora_inicio'=>$d['hora_inicio'],'hora_fin'=>$d['hora_fin']]
        );
        $this->registrarEnBitacora("Asignó docente al grupo {$grupo->codigo}", $grupo->id, 'Grupos');
        return redirect()->route('grupos.show',$grupo)->with('success','Asignación guardada correctamente.');
    }

    /** CU-21: Inscribir postulantes al grupo */
    public function inscribirPostulantes(Request $r, Grupo $grupo)
    {
        $r->validate(['postulante_ids'=>'required|array','postulante_ids.*'=>'exists:postulantes,id']);

        $yaInscritos = DB::table('grupo_postulante')->where('grupo_id',$grupo->id)->count();
        $disponible  = $grupo->capacidad_maxima - $yaInscritos;
        $nuevos      = array_slice($r->postulante_ids, 0, $disponible);

        foreach ($nuevos as $pid) {
            DB::table('grupo_postulante')->updateOrInsert(
                ['grupo_id'=>$grupo->id,'postulante_id'=>$pid],
                ['created_at'=>now(),'updated_at'=>now()]
            );
        }
        $this->registrarEnBitacora('Inscribió '.count($nuevos).' postulante(s) al grupo '.$grupo->codigo, $grupo->id,'Grupos');
        return redirect()->route('grupos.show',$grupo)->with('success','Postulantes inscritos: '.count($nuevos).'.');
    }

    public function destroy(Grupo $grupo)
    {
        $cod = $grupo->codigo;
        $grupo->delete();
        $this->registrarEnBitacora("Eliminó grupo {$cod}", null, 'Grupos');
        return redirect()->route('grupos.index')->with('success',"Grupo «{$cod}» eliminado.");
    }
}
EOF
ok "app/Http/Controllers/GrupoController.php"

# =============================================================================
hdr "PASO 5 — Crear NotaController (CU-22 a CU-26)"
# =============================================================================
cat > app/Http/Controllers/NotaController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\{Nota, Postulante, Materia, Grupo, Gestion};
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class NotaController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:ver notas')->only('index','show');
        $this->middleware('permission:crear notas')->only('create','store');
        $this->middleware('permission:editar notas')->only('edit','update');
    }

    /** CU-22/CU-26: Lista notas del grupo (docente ve solo sus grupos) */
    public function index(Request $r)
    {
        $gestion = Gestion::where('estado','en_curso')->first();
        $grupos  = Grupo::when($gestion, fn($q)=>$q->where('gestion_id',$gestion->id))
            ->with('asignaciones.docente')
            ->get();
        $grupoSel = $r->grupo_id ? Grupo::find($r->grupo_id) : $grupos->first();
        $materias = $grupoSel ? Materia::where('estado',true)->orderBy('orden')->get() : collect();
        $matSel   = $r->materia_id ? Materia::find($r->materia_id) : $materias->first();

        $notas = ($grupoSel && $matSel)
            ? Nota::where('grupo_id',$grupoSel->id)->where('materia_id',$matSel->id)
                ->with('postulante')->orderBy('created_at')->get()
            : collect();

        // Postulantes del grupo sin nota aún
        $inscritos = $grupoSel
            ? DB::table('grupo_postulante')->where('grupo_id',$grupoSel->id)->pluck('postulante_id')
            : collect();
        $sinNota = $matSel
            ? Postulante::whereIn('id',$inscritos)
                ->whereNotIn('id', Nota::where('grupo_id',$grupoSel->id)->where('materia_id',$matSel->id)->pluck('postulante_id'))
                ->get()
            : collect();

        return view('notas.index', compact('grupos','grupoSel','materias','matSel','notas','sinNota','gestion'));
    }

    /** CU-22: Formulario para registrar nota de un postulante */
    public function create(Request $r)
    {
        $r->validate(['postulante_id'=>'required|exists:postulantes,id','grupo_id'=>'required|exists:grupos,id','materia_id'=>'required|exists:materias,id']);
        $postulante = Postulante::findOrFail($r->postulante_id);
        $grupo      = Grupo::findOrFail($r->grupo_id);
        $materia    = Materia::findOrFail($r->materia_id);
        return view('notas.create', compact('postulante','grupo','materia'));
    }

    /** CU-22/CU-23/CU-24/CU-25: Guarda nota y recalcula estado del postulante */
    public function store(Request $r)
    {
        $d = $r->validate([
            'postulante_id' => 'required|exists:postulantes,id',
            'materia_id'    => 'required|exists:materias,id',
            'grupo_id'      => 'required|exists:grupos,id',
            'examen1'       => 'required|numeric|min:0|max:100',
            'examen2'       => 'required|numeric|min:0|max:100',
            'examen3'       => 'required|numeric|min:0|max:100',
        ]);

        $nota = Nota::updateOrCreate(
            ['postulante_id'=>$d['postulante_id'],'materia_id'=>$d['materia_id'],'grupo_id'=>$d['grupo_id']],
            ['examen1'=>$d['examen1'],'examen2'=>$d['examen2'],'examen3'=>$d['examen3']]
        );
        $nota->calcularNotaFinal();   // CU-23

        $this->_actualizarEstadoPostulante($d['postulante_id']); // CU-24/CU-25
        $this->registrarEnBitacora("Registró nota para postulante ID:{$d['postulante_id']}", $nota->id, 'Notas');

        return redirect()->route('notas.index', ['grupo_id'=>$d['grupo_id'],'materia_id'=>$d['materia_id']])
            ->with('success','Nota registrada y promedio actualizado.');
    }

    public function edit(Nota $nota)
    {
        $nota->load('postulante','materia','grupo');
        return view('notas.edit', compact('nota'));
    }

    public function update(Request $r, Nota $nota)
    {
        $d = $r->validate([
            'examen1'=>'required|numeric|min:0|max:100',
            'examen2'=>'required|numeric|min:0|max:100',
            'examen3'=>'required|numeric|min:0|max:100',
        ]);
        $nota->update($d);
        $nota->calcularNotaFinal();
        $this->_actualizarEstadoPostulante($nota->postulante_id);
        $this->registrarEnBitacora("Editó nota ID:{$nota->id}", $nota->id, 'Notas');
        return redirect()->route('notas.index',['grupo_id'=>$nota->grupo_id,'materia_id'=>$nota->materia_id])
            ->with('success','Nota actualizada.');
    }

    /** CU-24/CU-25: Recalcula promedio general y estado aprobado/no_aprobado */
    private function _actualizarEstadoPostulante(int $postulanteId): void
    {
        $notas = Nota::where('postulante_id', $postulanteId)->get();
        if ($notas->count() < 4) return; // esperar a tener las 4 materias

        $promedio = round($notas->avg('nota_final'), 2);
        $aprobado = $notas->every(fn($n) => $n->nota_final >= 60);

        Postulante::find($postulanteId)?->update([
            'promedio_general' => $promedio,
            'estado'           => $aprobado ? 'aprobado' : 'no_aprobado',
        ]);
    }
}
EOF
ok "app/Http/Controllers/NotaController.php"

# =============================================================================
hdr "PASO 6 — Crear AdmisionController (CU-27/28/29)"
# =============================================================================
cat > app/Http/Controllers/AdmisionController.php << 'EOF'
<?php
namespace App\Http\Controllers;

use App\Models\{Admision, Postulante, Carrera, Gestion, CupoCarrera};
use App\Traits\BitacoraTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdmisionController extends Controller
{
    use BitacoraTrait;

    public function __construct()
    {
        $this->middleware('auth');
        $this->middleware('permission:procesar admision');
    }

    /** CU-27/CU-28: Vista del proceso de admisión */
    public function index()
    {
        $gestion    = Gestion::where('estado','en_curso')->first();
        $admisiones = $gestion
            ? Admision::where('gestion_id',$gestion->id)
                ->with(['postulante','carreraAsignada'])
                ->orderByDesc('promedio_general')->get()
            : collect();

        $resumen = $gestion ? [
            'total'            => Postulante::where('gestion_id',$gestion->id)->count(),
            'aprobados'        => Postulante::where('gestion_id',$gestion->id)->where('estado','aprobado')->count(),
            'admitidos_1'      => $admisiones->where('resultado','admitido_primera')->count(),
            'admitidos_2'      => $admisiones->where('resultado','admitido_segunda')->count(),
            'no_admitidos'     => $admisiones->where('resultado','no_admitido')->count(),
        ] : [];

        return view('admision.index', compact('gestion','admisiones','resumen'));
    }

    /** CU-27/CU-28: Procesa la admisión para la gestión activa */
    public function procesar()
    {
        $gestion = Gestion::where('estado','en_curso')->firstOrFail();

        // Limpiar admisiones previas de esta gestión
        Admision::where('gestion_id',$gestion->id)->delete();

        $cupos      = CupoCarrera::where('gestion_id',$gestion->id)->pluck('cantidad_maxima','carrera_id')->toArray();
        $contadores = array_fill_keys(array_keys($cupos), 0);

        $aprobados = Postulante::where('gestion_id',$gestion->id)
            ->where('estado','aprobado')
            ->orderByDesc('promedio_general')
            ->get();

        $pendientes2 = [];
        foreach ($aprobados as $p) {
            $c1 = $p->primera_opcion_id;
            if (($contadores[$c1] ?? 0) < ($cupos[$c1] ?? 0)) {
                Admision::create(['postulante_id'=>$p->id,'gestion_id'=>$gestion->id,'promedio_general'=>$p->promedio_general,'carrera_asignada_id'=>$c1,'resultado'=>'admitido_primera','publicado'=>false]);
                $contadores[$c1]++;
                $p->update(['estado'=>'admitido']);
            } else {
                $pendientes2[] = $p;
            }
        }
        foreach ($pendientes2 as $p) {
            $c2 = $p->segunda_opcion_id;
            if (($contadores[$c2] ?? 0) < ($cupos[$c2] ?? 0)) {
                Admision::create(['postulante_id'=>$p->id,'gestion_id'=>$gestion->id,'promedio_general'=>$p->promedio_general,'carrera_asignada_id'=>$c2,'resultado'=>'admitido_segunda','publicado'=>false]);
                $contadores[$c2]++;
                $p->update(['estado'=>'admitido_segunda_opcion']);
            } else {
                Admision::create(['postulante_id'=>$p->id,'gestion_id'=>$gestion->id,'promedio_general'=>$p->promedio_general,'carrera_asignada_id'=>null,'resultado'=>'no_admitido','publicado'=>false]);
                $p->update(['estado'=>'no_admitido']);
            }
        }

        $total = Admision::where('gestion_id',$gestion->id)->count();
        $this->registrarEnBitacora("Procesó admisión gestión {$gestion->descripcion}: {$total} registros", null, 'Admisión');
        return redirect()->route('admision.index')->with('success',"Admisión procesada: {$total} postulantes evaluados.");
    }

    /** CU-29: Publicar resultados */
    public function publicar()
    {
        $gestion = Gestion::where('estado','en_curso')->firstOrFail();
        $n = Admision::where('gestion_id',$gestion->id)->update(['publicado'=>true]);
        $this->registrarEnBitacora("Publicó resultados de admisión gestión {$gestion->descripcion}", null, 'Admisión');
        return redirect()->route('admision.index')->with('success',"{$n} resultado(s) publicados.");
    }
}
EOF
ok "app/Http/Controllers/AdmisionController.php"

# =============================================================================
hdr "PASO 7 — Crear vistas: grupos/index, notas/index, admision/index"
# =============================================================================
mkdir -p resources/views/grupos
mkdir -p resources/views/notas
mkdir -p resources/views/admision

# ── grupos/index.blade.php
cat > resources/views/grupos/index.blade.php << 'BLADE_EOF'
@extends('layouts.ap')
@section('title','Grupos del CUP')
@section('content')
<div class="ph">
  <h1>Grupos del CUP</h1>
  <p class="sub">CU-17 — Generación automática · CU-18/19/20/21 — Asignación docentes y postulantes</p>
  <ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Grupos</li></ol>
</div>

{{-- Resumen inscritos / grupos --}}
<div class="sg" style="margin-bottom:1.5rem">
  <div class="sc" style="cursor:default">
    <div class="si c1"><i class="fas fa-users"></i></div>
    <div><div class="sv">{{ $totalInscritos }}</div><div class="sl">Postulantes inscritos</div></div>
  </div>
  <div class="sc" style="cursor:default">
    <div class="si c2"><i class="fas fa-layer-group"></i></div>
    <div><div class="sv">{{ $gruposNecesarios }}</div><div class="sl">Grupos necesarios (÷60)</div></div>
  </div>
  <div class="sc" style="cursor:default">
    <div class="si c5"><i class="fas fa-check-circle"></i></div>
    <div><div class="sv">{{ $grupos->count() }}</div><div class="sl">Grupos generados</div></div>
  </div>
</div>

@can('crear grupos')
<div style="display:flex;gap:.75rem;margin-bottom:1.25rem">
  <form action="{{ route('grupos.generar') }}" method="POST" style="display:inline">@csrf
    <button type="submit" class="btn bp"><i class="fas fa-magic"></i> Generar grupos automáticamente</button>
  </form>
</div>
@endcan

@if(session('success'))<div class="al al-v"><i class="fas fa-check-circle"></i> {{ session('success') }}</div>@endif
@if($errors->any())<div class="al al-d"><ul>@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif

@if($grupos->isEmpty())
  <div class="al al-w"><i class="fas fa-info-circle"></i> No hay grupos aún. Usa el botón para generarlos.</div>
@else
<div class="card">
  <div class="card-hd"><i class="fas fa-layer-group"></i>Grupos — {{ $gestion?->descripcion }}</div>
  <div class="card-bd">
  <table class="ct">
    <thead><tr><th>Código</th><th>Turno</th><th>Modalidad</th><th>Capacidad</th><th>Inscritos</th><th>Asignaciones</th><th>Estado</th><th></th></tr></thead>
    <tbody>
    @foreach($grupos as $g)
    <tr>
      <td><strong>{{ $g->codigo }}</strong></td>
      <td>{{ ucfirst($g->turno) }}</td>
      <td>{{ ucfirst($g->modalidad) }}</td>
      <td>{{ $g->capacidad_maxima }}</td>
      <td>
        <span class="bg {{ $g->postulantes_count >= $g->capacidad_maxima ? 'bd' : 'bv' }}">
          {{ $g->postulantes_count }} / {{ $g->capacidad_maxima }}
        </span>
      </td>
      <td>{{ $g->asignaciones->count() }} / 4 materias</td>
      <td><span class="bg {{ $g->estado ? 'bv' : 'bg2' }}">{{ $g->estado ? 'Activo' : 'Inactivo' }}</span></td>
      <td><a href="{{ route('grupos.show',$g) }}" class="btn bw bsm"><i class="fas fa-eye"></i></a></td>
    </tr>
    @endforeach
    </tbody>
  </table>
  </div>
</div>
@endif
@endsection
BLADE_EOF
ok "resources/views/grupos/index.blade.php"

# ── grupos/show.blade.php (asignaciones + inscripción)
cat > resources/views/grupos/show.blade.php << 'BLADE_EOF'
@extends('layouts.ap')
@section('title',$grupo->codigo)
@section('content')
<div class="ph">
  <h1>Grupo {{ $grupo->codigo }}</h1>
  <p class="sub">CU-18/19: Asignar docentes · CU-21: Inscribir postulantes</p>
  <ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('grupos.index') }}">Grupos</a></li><li>{{ $grupo->codigo }}</li></ol>
</div>

@if(session('success'))<div class="al al-v"><i class="fas fa-check-circle"></i> {{ session('success') }}</div>@endif
@if($errors->any())<div class="al al-d"><ul>@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif

<div style="display:grid;grid-template-columns:1fr 1fr;gap:1.25rem;max-width:900px">

{{-- Info del grupo --}}
<div class="card"><div class="card-hd"><i class="fas fa-info-circle"></i>Datos del grupo</div><div class="card-bd" style="font-size:.88rem">
  @foreach(['Código'=>$grupo->codigo,'Turno'=>ucfirst($grupo->turno),'Modalidad'=>ucfirst($grupo->modalidad),'Capacidad'=>$grupo->capacidad_maxima,'Inscritos'=>$grupo->postulantes->count()] as $l=>$v)
  <div style="display:flex;justify-content:space-between;padding:.4rem 0;border-bottom:1px solid var(--cr2)">
    <span style="color:var(--t3)">{{ $l }}</span><span style="font-weight:500">{{ $v }}</span>
  </div>
  @endforeach
</div></div>

{{-- Asignar docente (CU-18/19) --}}
@can('editar grupos')
<div class="card"><div class="card-hd"><i class="fas fa-user-tie"></i>Asignar docente — materia (CU-18)</div><div class="card-bd">
<form action="{{ route('grupos.asignarDocente',$grupo) }}" method="POST">@csrf
  <div style="margin-bottom:.6rem">
    <label class="fl">Materia <span class="rq">*</span></label>
    <select name="materia_id" class="fs" required><option value="">— Seleccionar —</option>
    @foreach($materias as $m)<option value="{{ $m->id }}">{{ $m->nombre }}</option>@endforeach
    </select>
  </div>
  <div style="margin-bottom:.6rem">
    <label class="fl">Docente <span class="rq">*</span></label>
    <select name="docente_id" class="fs" required><option value="">— Seleccionar —</option>
    @foreach($docentes as $d)<option value="{{ $d->id }}">{{ $d->nombres }} {{ $d->apellidos }} — {{ $d->area_formacion }}</option>@endforeach
    </select>
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:.5rem;margin-bottom:.6rem">
    <div><label class="fl">Día <span class="rq">*</span></label>
    <select name="dia" class="fs" required><option value="">—</option>
    @foreach(['lunes','martes','miercoles','jueves','viernes','sabado'] as $dia)
    <option value="{{ $dia }}">{{ ucfirst($dia) }}</option>
    @endforeach</select></div>
    <div><label class="fl">Hora inicio</label><input type="time" name="hora_inicio" class="fc" required></div>
    <div><label class="fl">Hora fin</label><input type="time" name="hora_fin" class="fc" required></div>
  </div>
  <button type="submit" class="btn bp bsm"><i class="fas fa-save"></i> Guardar asignación</button>
</form>
</div></div>
@endcan

</div>

{{-- Tabla asignaciones actuales --}}
<div class="card" style="max-width:900px;margin-top:1rem">
  <div class="card-hd"><i class="fas fa-table"></i>Asignaciones de docentes ({{ $grupo->asignaciones->count() }}/4)</div>
  <div class="card-bd">
  @if($grupo->asignaciones->isEmpty())<p style="color:var(--t3);text-align:center">Sin asignaciones aún.</p>
  @else
  <table class="ct"><thead><tr><th>Materia</th><th>Docente</th><th>Día</th><th>Horario</th></tr></thead>
  <tbody>
  @foreach($grupo->asignaciones as $a)
  <tr>
    <td><strong>{{ $a->materia?->nombre }}</strong></td>
    <td>{{ $a->docente?->nombres }} {{ $a->docente?->apellidos }}</td>
    <td>{{ ucfirst($a->dia) }}</td>
    <td>{{ $a->hora_inicio }} — {{ $a->hora_fin }}</td>
  </tr>
  @endforeach
  </tbody></table>
  @endif
  </div>
</div>

{{-- Postulantes inscritos --}}
<div class="card" style="max-width:900px;margin-top:1rem">
  <div class="card-hd"><i class="fas fa-users"></i>Postulantes inscritos ({{ $grupo->postulantes->count() }}/{{ $grupo->capacidad_maxima }})</div>
  <div class="card-bd">
  @if($grupo->postulantes->isEmpty())<p style="color:var(--t3);text-align:center">Sin postulantes inscritos.</p>
  @else
  <table class="ct"><thead><tr><th>CI</th><th>Nombre</th><th>Estado</th></tr></thead>
  <tbody>
  @foreach($grupo->postulantes as $p)
  <tr>
    <td>{{ $p->ci }}</td>
    <td>{{ $p->nombre_completo }}</td>
    <td><span class="bg {{ in_array($p->estado,['aprobado','admitido','admitido_segunda_opcion'])?'bv':'bg2' }}">{{ $p->estado }}</span></td>
  </tr>
  @endforeach
  </tbody></table>
  @endif
  </div>
</div>

<div style="margin-top:1rem"><a href="{{ route('grupos.index') }}" class="btn bo2"><i class="fas fa-arrow-left"></i> Volver</a></div>
@endsection
BLADE_EOF
ok "resources/views/grupos/show.blade.php"

# ── grupos/edit.blade.php
cat > resources/views/grupos/edit.blade.php << 'BLADE_EOF'
@extends('layouts.ap')
@section('title','Editar Grupo')
@section('content')
<div class="ph"><h1>Editar Grupo {{ $grupo->codigo }}</h1>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('grupos.index') }}">Grupos</a></li><li>Editar</li></ol>
</div>
<form action="{{ route('grupos.update',$grupo) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:500px"><div class="card-hd"><i class="fas fa-edit"></i>Editar grupo</div><div class="card-bd">
<div class="fr c2g">
  <div><label class="fl">Turno</label>
  <select name="turno" class="fs">
    @foreach(['mañana','tarde','noche'] as $t)<option value="{{ $t }}" {{ $grupo->turno===$t?'selected':'' }}>{{ ucfirst($t) }}</option>@endforeach
  </select></div>
  <div><label class="fl">Modalidad</label>
  <select name="modalidad" class="fs">
    @foreach(['presencial','virtual'] as $m)<option value="{{ $m }}" {{ $grupo->modalidad===$m?'selected':'' }}>{{ ucfirst($m) }}</option>@endforeach
  </select></div>
  <div><label class="fl">Capacidad máx.</label><input type="number" name="capacidad_maxima" class="fc" value="{{ $grupo->capacidad_maxima }}" min="1" max="100"></div>
</div>
<label class="fck" style="margin-top:.75rem"><input type="checkbox" name="estado" value="1" {{ $grupo->estado?'checked':'' }}><span>Grupo activo</span></label>
<div style="display:flex;gap:.75rem;margin-top:1.25rem">
  <button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar</button>
  <a href="{{ route('grupos.show',$grupo) }}" class="btn bo2">Cancelar</a>
</div>
</div></div>
</form>
@endsection
BLADE_EOF
ok "resources/views/grupos/edit.blade.php"

# ── notas/index.blade.php
cat > resources/views/notas/index.blade.php << 'BLADE_EOF'
@extends('layouts.ap')
@section('title','Registro de Notas')
@section('content')
<div class="ph">
  <h1>Registro de Notas</h1>
  <p class="sub">CU-22 Registrar · CU-23 Nota final · CU-24 Promedio · CU-25 Estado · CU-26 Consultar</p>
  <ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Notas</li></ol>
</div>

{{-- Selector grupo / materia --}}
<form method="GET" action="{{ route('notas.index') }}" style="display:flex;gap:.75rem;margin-bottom:1.25rem;flex-wrap:wrap">
  <select name="grupo_id" class="fs" style="width:200px" onchange="this.form.submit()">
    <option value="">— Grupo —</option>
    @foreach($grupos as $g)<option value="{{ $g->id }}" {{ ($grupoSel?->id==$g->id)?'selected':'' }}>{{ $g->codigo }} · {{ ucfirst($g->turno) }}</option>@endforeach
  </select>
  <select name="materia_id" class="fs" style="width:200px" onchange="this.form.submit()">
    <option value="">— Materia —</option>
    @foreach($materias as $m)<option value="{{ $m->id }}" {{ ($matSel?->id==$m->id)?'selected':'' }}>{{ $m->nombre }}</option>@endforeach
  </select>
</form>

@if(session('success'))<div class="al al-v"><i class="fas fa-check-circle"></i> {{ session('success') }}</div>@endif
@if($errors->any())<div class="al al-d"><ul>@foreach($errors->all() as $e)<li>{{ $e }}</li>@endforeach</ul></div>@endif

@if($grupoSel && $matSel)
<div class="card">
  <div class="card-hd"><i class="fas fa-table"></i>Notas — {{ $grupoSel->codigo }} / {{ $matSel->nombre }}
    <span style="font-size:.75rem;font-weight:normal;margin-left:.5rem">({{ $matSel->pond_examen1 }}% + {{ $matSel->pond_examen2 }}% + {{ $matSel->pond_examen3 }}%)</span>
  </div>
  <div class="card-bd">
  @if($notas->isEmpty() && $sinNota->isEmpty())
    <p style="color:var(--t3);text-align:center">No hay postulantes inscritos en este grupo.</p>
  @else
  <table class="ct"><thead><tr><th>Postulante</th><th>CI</th><th>Ex. 1</th><th>Ex. 2</th><th>Ex. 3</th><th>Nota Final</th><th>Estado</th><th></th></tr></thead>
  <tbody>
  @foreach($notas as $n)
  <tr>
    <td>{{ $n->postulante?->nombre_completo }}</td>
    <td>{{ $n->postulante?->ci }}</td>
    <td>{{ $n->examen1 }}</td>
    <td>{{ $n->examen2 }}</td>
    <td>{{ $n->examen3 }}</td>
    <td><strong>{{ $n->nota_final }}</strong></td>
    <td><span class="bg {{ $n->aprobado?'bv':'bd' }}">{{ $n->aprobado?'Aprobado':'Reprobado' }}</span></td>
    <td><a href="{{ route('notas.edit',$n) }}" class="btn bw bsm"><i class="fas fa-edit"></i></a></td>
  </tr>
  @endforeach
  @foreach($sinNota as $p)
  <tr style="background:var(--cr2)">
    <td>{{ $p->nombre_completo }}</td>
    <td>{{ $p->ci }}</td>
    <td colspan="4" style="color:var(--t3);font-size:.82rem">Sin notas registradas</td>
    <td>
      @can('crear notas')
      <a href="{{ route('notas.create',['postulante_id'=>$p->id,'grupo_id'=>$grupoSel->id,'materia_id'=>$matSel->id]) }}" class="btn bp bsm"><i class="fas fa-plus"></i> Registrar</a>
      @endcan
    </td>
  </tr>
  @endforeach
  </tbody></table>
  @endif
  </div>
</div>
@endif
@endsection
BLADE_EOF
ok "resources/views/notas/index.blade.php"

# ── notas/create.blade.php
cat > resources/views/notas/create.blade.php << 'BLADE_EOF'
@extends('layouts.ap')
@section('title','Registrar Nota')
@section('content')
<div class="ph"><h1>Registrar Nota</h1>
<p class="sub">CU-22 — {{ $postulante->nombre_completo }} · {{ $materia->nombre }}</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('notas.index',['grupo_id'=>$grupo->id,'materia_id'=>$materia->id]) }}">Notas</a></li><li>Registrar</li></ol>
</div>
<form action="{{ route('notas.store') }}" method="POST">@csrf
<input type="hidden" name="postulante_id" value="{{ $postulante->id }}">
<input type="hidden" name="grupo_id"      value="{{ $grupo->id }}">
<input type="hidden" name="materia_id"    value="{{ $materia->id }}">
<div class="card" style="max-width:500px"><div class="card-hd"><i class="fas fa-pencil-alt"></i>Exámenes — ponderación {{ $materia->pond_examen1 }}%+{{ $materia->pond_examen2 }}%+{{ $materia->pond_examen3 }}%</div><div class="card-bd">
<div class="fr c3g">
  <div><label class="fl">Examen 1 ({{ $materia->pond_examen1 }}%) <span class="rq">*</span></label><input type="number" name="examen1" class="fc" min="0" max="100" step="0.01" required></div>
  <div><label class="fl">Examen 2 ({{ $materia->pond_examen2 }}%) <span class="rq">*</span></label><input type="number" name="examen2" class="fc" min="0" max="100" step="0.01" required></div>
  <div><label class="fl">Examen 3 ({{ $materia->pond_examen3 }}%) <span class="rq">*</span></label><input type="number" name="examen3" class="fc" min="0" max="100" step="0.01" required></div>
</div>
<div style="display:flex;gap:.75rem;margin-top:1.25rem">
  <button type="submit" class="btn bp"><i class="fas fa-save"></i> Registrar nota</button>
  <a href="{{ route('notas.index',['grupo_id'=>$grupo->id,'materia_id'=>$materia->id]) }}" class="btn bo2">Cancelar</a>
</div>
</div></div>
</form>
@endsection
BLADE_EOF
ok "resources/views/notas/create.blade.php"

# ── notas/edit.blade.php
cat > resources/views/notas/edit.blade.php << 'BLADE_EOF'
@extends('layouts.ap')
@section('title','Editar Nota')
@section('content')
<div class="ph"><h1>Editar Nota</h1>
<p class="sub">{{ $nota->postulante?->nombre_completo }} · {{ $nota->materia?->nombre }}</p>
<ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li><a href="{{ route('notas.index',['grupo_id'=>$nota->grupo_id,'materia_id'=>$nota->materia_id]) }}">Notas</a></li><li>Editar</li></ol>
</div>
<form action="{{ route('notas.update',$nota) }}" method="POST">@csrf @method('PUT')
<div class="card" style="max-width:500px"><div class="card-hd"><i class="fas fa-edit"></i>Exámenes</div><div class="card-bd">
<div class="fr c3g">
  <div><label class="fl">Examen 1</label><input type="number" name="examen1" class="fc" value="{{ $nota->examen1 }}" min="0" max="100" step="0.01" required></div>
  <div><label class="fl">Examen 2</label><input type="number" name="examen2" class="fc" value="{{ $nota->examen2 }}" min="0" max="100" step="0.01" required></div>
  <div><label class="fl">Examen 3</label><input type="number" name="examen3" class="fc" value="{{ $nota->examen3 }}" min="0" max="100" step="0.01" required></div>
</div>
<div class="al al-w" style="margin-top:.75rem"><i class="fas fa-calculator"></i> Nota actual: <strong>{{ $nota->nota_final }}</strong> — {{ $nota->aprobado?'Aprobado':'Reprobado' }}</div>
<div style="display:flex;gap:.75rem;margin-top:1.25rem">
  <button type="submit" class="btn bp"><i class="fas fa-save"></i> Guardar cambios</button>
  <a href="{{ route('notas.index',['grupo_id'=>$nota->grupo_id,'materia_id'=>$nota->materia_id]) }}" class="btn bo2">Cancelar</a>
</div>
</div></div>
</form>
@endsection
BLADE_EOF
ok "resources/views/notas/edit.blade.php"

# ── admision/index.blade.php
cat > resources/views/admision/index.blade.php << 'BLADE_EOF'
@extends('layouts.ap')
@section('title','Proceso de Admisión')
@section('content')
<div class="ph">
  <h1>Proceso de Admisión</h1>
  <p class="sub">CU-27 Procesar · CU-28 Reasignar · CU-29 Publicar resultados</p>
  <ol class="bc"><li><a href="{{ route('panel') }}">Inicio</a></li><li>Admisión</li></ol>
</div>

@if(session('success'))<div class="al al-v"><i class="fas fa-check-circle"></i> {{ session('success') }}</div>@endif

@if($gestion)
{{-- Tarjetas resumen --}}
<div class="sg" style="margin-bottom:1.5rem">
  <div class="sc" style="cursor:default"><div class="si c1"><i class="fas fa-users"></i></div><div><div class="sv">{{ $resumen['total'] }}</div><div class="sl">Total inscritos</div></div></div>
  <div class="sc" style="cursor:default"><div class="si c2"><i class="fas fa-check"></i></div><div><div class="sv">{{ $resumen['aprobados'] }}</div><div class="sl">Aprobados</div></div></div>
  <div class="sc" style="cursor:default"><div class="si" style="background:#d1fae5;color:#065f46"><i class="fas fa-star"></i></div><div><div class="sv">{{ $resumen['admitidos_1'] }}</div><div class="sl">Admitidos 1ª opción</div></div></div>
  <div class="sc" style="cursor:default"><div class="si" style="background:#fef3c7;color:#92400e"><i class="fas fa-exchange-alt"></i></div><div><div class="sv">{{ $resumen['admitidos_2'] }}</div><div class="sl">Admitidos 2ª opción</div></div></div>
  <div class="sc" style="cursor:default"><div class="si" style="background:#fee2e2;color:#991b1b"><i class="fas fa-times"></i></div><div><div class="sv">{{ $resumen['no_admitidos'] }}</div><div class="sl">No admitidos</div></div></div>
</div>

<div style="display:flex;gap:.75rem;margin-bottom:1.25rem">
  <form action="{{ route('admision.procesar') }}" method="POST">@csrf
    <button type="submit" class="btn bp" onclick="return confirm('¿Procesar admisión? Esto sobreescribirá resultados previos.')"><i class="fas fa-cogs"></i> Procesar admisión (CU-27/28)</button>
  </form>
  <form action="{{ route('admision.publicar') }}" method="POST">@csrf
    <button type="submit" class="btn" style="background:#10b981;color:#fff"><i class="fas fa-bullhorn"></i> Publicar resultados (CU-29)</button>
  </form>
</div>

@if($admisiones->isNotEmpty())
<div class="card">
  <div class="card-hd"><i class="fas fa-list"></i>Resultados — {{ $gestion->descripcion }}</div>
  <div class="card-bd">
  <table class="ct">
    <thead><tr><th>Postulante</th><th>CI</th><th>Promedio</th><th>Carrera asignada</th><th>Resultado</th><th>Publicado</th></tr></thead>
    <tbody>
    @foreach($admisiones as $a)
    <tr>
      <td>{{ $a->postulante?->nombre_completo }}</td>
      <td>{{ $a->postulante?->ci }}</td>
      <td><strong>{{ number_format($a->promedio_general,2) }}</strong></td>
      <td>{{ $a->carreraAsignada?->sigla ?? '—' }}</td>
      <td>
        @php $cls = match($a->resultado){'admitido_primera'=>'bv','admitido_segunda'=>'bna','no_admitido'=>'bd',default=>'bg2'}; @endphp
        <span class="bg {{ $cls }}">{{ str_replace('_',' ',ucfirst($a->resultado)) }}</span>
      </td>
      <td><span class="bg {{ $a->publicado?'bv':'bg2' }}">{{ $a->publicado?'Sí':'No' }}</span></td>
    </tr>
    @endforeach
    </tbody>
  </table>
  </div>
</div>
@endif

@else
<div class="al al-w"><i class="fas fa-exclamation-triangle"></i> No hay gestión activa. Crea o activa una gestión en el módulo de Gestiones.</div>
@endif
@endsection
BLADE_EOF
ok "resources/views/admision/index.blade.php"

# =============================================================================
hdr "PASO 8 — Agregar rutas nuevas a routes/web.php"
# =============================================================================
inf "Añadiendo rutas de grupos, notas y admisión a routes/web.php ..."

php -r "
\$file = 'routes/web.php';
\$src  = file_get_contents(\$file);

// Verificar si ya se aplicaron
if (strpos(\$src, 'GrupoController') !== false) {
    echo 'ya aplicado';
    exit;
}

// 1. Añadir imports al bloque use existente
\$src = str_replace(
    \"use App\\\\Http\\\\Controllers\\\\{BitacoraController,CarreraController,DocenteController,GestionController,HomeController,LoginController,LogoutController,MateriaController,PostulanteController,RoleController,UsuarioController};\",
    \"use App\\\\Http\\\\Controllers\\\\{AdmisionController,BitacoraController,CarreraController,DocenteController,GestionController,GrupoController,HomeController,LoginController,LogoutController,MateriaController,NotaController,PostulanteController,RoleController,UsuarioController};\",
    \$src
);

// 2. Des-comentar módulos 5 y 6, reemplazar comentarios por rutas reales
\$src = str_replace(
    \"    // Módulo 5: Exámenes y Control Académico (Ciclo 2)
    // Route::resource('notas', NotaController::class);\",
    \"    // Módulo 5: Exámenes y Control Académico (CU-22 a CU-26)
    Route::resource('notas', NotaController::class)->except(['destroy']);\",
    \$src
);

\$src = str_replace(
    \"    // Módulo 6: Panel Administrativo y Reportes (Ciclo 2)
    // Route::get('admision', ...)->name('admision.index');
    // Route::get('reportes', ...)->name('reportes.index');\",
    \"    // Módulo 6: Panel Administrativo y Reportes (CU-17 a CU-21, CU-27 a CU-29)
    Route::resource('grupos', GrupoController::class);
    Route::post('grupos/{grupo}/generar-automatico', [GrupoController::class,'generar'])->name('grupos.generar');
    Route::post('grupos/{grupo}/asignar-docente',    [GrupoController::class,'asignarDocente'])->name('grupos.asignarDocente');
    Route::post('grupos/{grupo}/inscribir',          [GrupoController::class,'inscribirPostulantes'])->name('grupos.inscribirPostulantes');
    Route::get( 'admision',        [AdmisionController::class,'index'])->name('admision.index');
    Route::post('admision/procesar',[AdmisionController::class,'procesar'])->name('admision.procesar');
    Route::post('admision/publicar',[AdmisionController::class,'publicar'])->name('admision.publicar');\",
    \$src
);

file_put_contents(\$file, \$src);
echo 'rutas aplicadas';
"
ok "routes/web.php actualizado"

# Corregir la ruta de generar para que sea a nivel general (no requiere grupo)
php -r "
\$file = 'routes/web.php';
\$src  = file_get_contents(\$file);
\$src  = str_replace(
    \"Route::post('grupos/{grupo}/generar-automatico', [GrupoController::class,'generar'])->name('grupos.generar');\",
    \"Route::post('grupos/generar-automatico',          [GrupoController::class,'generar'])->name('grupos.generar');\",
    \$src
);
file_put_contents(\$file, \$src);
"

# =============================================================================
hdr "PASO 9 — Actualizar panel: activar módulos 4, 5, 6 con los nuevos links"
# =============================================================================
inf "Actualizando vista panel/index.blade.php para activar grupos, notas y admisión ..."

php -r "
\$file = 'resources/views/panel/index.blade.php';
\$src  = file_get_contents(\$file);

// Reemplazar los foreach de 'Ciclo 2' del módulo 4 (CU-17..21)
\$old = \"      @foreach(['CU-17'=>'Calcular y generar grupos automáticamente','CU-18'=>'Asignar docente a grupo y materia','CU-19'=>'Validar cruces de horario','CU-20'=>'Asignar horarios y modalidad','CU-21'=>'Inscribir postulantes a grupos'] as \\\$c=>\\\$d)
      <div class=\\\"cr2x dis\\\"><span class=\\\"ctg pn\\\">{{ \\\$c }}</span><i class=\\\"ci2 fas fa-clock\\\"></i>{{ \\\$d }}<span class=\\\"cpl\\\">Ciclo 2</span></div>
      @endforeach\";

\$new = \"      @can('ver grupos')
      <div class=\\\"cr2x lnk\\\"><a href=\\\"{{ route('grupos.index') }}\\\"><span class=\\\"ctg dn\\\">CU-17</span><i class=\\\"ci2 fas fa-magic\\\"></i>Generar grupos automáticamente</a></div>
      <div class=\\\"cr2x lnk\\\"><a href=\\\"{{ route('grupos.index') }}\\\"><span class=\\\"ctg dn\\\">CU-18</span><i class=\\\"ci2 fas fa-user-tie\\\"></i>Asignar docente a grupo y materia</a></div>
      <div class=\\\"cr2x lnk\\\"><a href=\\\"{{ route('grupos.index') }}\\\"><span class=\\\"ctg dn\\\">CU-19</span><i class=\\\"ci2 fas fa-exclamation-triangle\\\"></i>Validar cruces de horario</a></div>
      <div class=\\\"cr2x lnk\\\"><a href=\\\"{{ route('grupos.index') }}\\\"><span class=\\\"ctg dn\\\">CU-21</span><i class=\\\"ci2 fas fa-users\\\"></i>Inscribir postulantes a grupos</a></div>
      @endcan\";

\$src = str_replace(\$old, \$new, \$src);

// Módulo 5: notas
\$old5 = \"      @foreach(['CU-22'=>'Registrar notas de exámenes (3 por materia)','CU-23'=>'Calcular nota final (30%+30%+40%)','CU-24'=>'Calcular promedio general','CU-25'=>'Determinar aprobado/reprobado ≥60','CU-26'=>'Consultar notas del postulante'] as \\\$c=>\\\$d)
      <div class=\\\"cr2x dis\\\"><span class=\\\"ctg pn\\\">{{ \\\$c }}</span><i class=\\\"ci2 fas fa-clock\\\"></i>{{ \\\$d }}<span class=\\\"cpl\\\">Ciclo 2</span></div>
      @endforeach\";
\$new5 = \"      @can('ver notas')
      <div class=\\\"cr2x lnk\\\"><a href=\\\"{{ route('notas.index') }}\\\"><span class=\\\"ctg dn\\\">CU-22</span><i class=\\\"ci2 fas fa-pencil-alt\\\"></i>Registrar notas de exámenes</a></div>
      <div class=\\\"cr2x lnk\\\"><a href=\\\"{{ route('notas.index') }}\\\"><span class=\\\"ctg dn\\\">CU-23/24/25</span><i class=\\\"ci2 fas fa-calculator\\\"></i>Nota final · Promedio · Estado</a></div>
      <div class=\\\"cr2x lnk\\\"><a href=\\\"{{ route('notas.index') }}\\\"><span class=\\\"ctg dn\\\">CU-26</span><i class=\\\"ci2 fas fa-search\\\"></i>Consultar notas del postulante</a></div>
      @endcan\";
\$src = str_replace(\$old5, \$new5, \$src);

// Módulo 6: admisión
\$old6 = \"      @foreach(['CU-27'=>'Procesar admisión por primera opción','CU-28'=>'Reasignar a segunda opción','CU-29'=>'Publicar resultado final','CU-30'=>'Reporte aprobados/reprobados por grupo','CU-31'=>'Reporte admitidos por carrera','CU-32'=>'Comparativo histórico entre gestiones','CU-33'=>'Indicadores estadísticos del proceso'] as \\\$c=>\\\$d)
      <div class=\\\"cr2x dis\\\"><span class=\\\"ctg pn\\\">{{ \\\$c }}</span><i class=\\\"ci2 fas fa-clock\\\"></i>{{ \\\$d }}<span class=\\\"cpl\\\">Ciclo 2</span></div>
      @endforeach\";
\$new6 = \"      @can('procesar admision')
      <div class=\\\"cr2x lnk\\\"><a href=\\\"{{ route('admision.index') }}\\\"><span class=\\\"ctg dn\\\">CU-27</span><i class=\\\"ci2 fas fa-cogs\\\"></i>Procesar admisión por primera opción</a></div>
      <div class=\\\"cr2x lnk\\\"><a href=\\\"{{ route('admision.index') }}\\\"><span class=\\\"ctg dn\\\">CU-28</span><i class=\\\"ci2 fas fa-exchange-alt\\\"></i>Reasignar a segunda opción</a></div>
      <div class=\\\"cr2x lnk\\\"><a href=\\\"{{ route('admision.index') }}\\\"><span class=\\\"ctg dn\\\">CU-29</span><i class=\\\"ci2 fas fa-bullhorn\\\"></i>Publicar resultado final</a></div>
      @endcan
      <div class=\\\"cr2x dis\\\"><span class=\\\"ctg pn\\\">CU-30..33</span><i class=\\\"ci2 fas fa-chart-bar\\\"></i>Reportes y estadísticas<span class=\\\"cpl\\\">Próximamente</span></div>\";
\$src = str_replace(\$old6, \$new6, \$src);

file_put_contents(\$file, \$src);
echo 'panel actualizado';
"
ok "panel/index.blade.php actualizado"

# =============================================================================
hdr "PASO 10 — Limpiar caché de Laravel"
# =============================================================================
inf "Limpiando caché de configuración, rutas y vistas..."
php artisan config:clear   2>/dev/null && ok "config:clear"
php artisan route:clear    2>/dev/null && ok "route:clear"
php artisan view:clear     2>/dev/null && ok "view:clear"
php artisan cache:clear    2>/dev/null && ok "cache:clear"

# =============================================================================
hdr "PASO 11 — Ejecutar migrate:fresh --seed"
# =============================================================================
inf "Ejecutando php artisan migrate:fresh --seed ..."
php artisan migrate:fresh --seed --force

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅  SCRIPT COMPLETADO EXITOSAMENTE                      ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  Credenciales de acceso:                                 ║${NC}"
echo -e "${GREEN}║  Admin      → admin@cup.edu.bo       / 12345678          ║${NC}"
echo -e "${GREEN}║  Docente    → rmamani@ficct.edu.bo   / Docente@2026      ║${NC}"
echo -e "${GREEN}║  Postulante → postulante1@gmail.com  / Postulante@2026   ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  Datos poblados:                                         ║${NC}"
echo -e "${GREEN}║  • 5 gestiones (la activa: Semestre 1-2026)              ║${NC}"
echo -e "${GREEN}║  • 4 carreras + cupos en todas las gestiones             ║${NC}"
echo -e "${GREEN}║  • 4 materias (30%+30%+40%)                              ║${NC}"
echo -e "${GREEN}║  • 10 docentes con perfil profesional completo           ║${NC}"
echo -e "${GREEN}║  • 150 postulantes con opciones 1 y 2 de carrera         ║${NC}"
echo -e "${GREEN}║  • 3 grupos generados (CEIL(150/60)=3)                   ║${NC}"
echo -e "${GREEN}║  • 600 notas (150×4 materias) ~70% aprobados             ║${NC}"
echo -e "${GREEN}║  • Admisiones procesadas con lógica de cupos             ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║  Nuevos módulos activos en la interfaz:                  ║${NC}"
echo -e "${GREEN}║  • /grupos    — CU-17/18/19/21                           ║${NC}"
echo -e "${GREEN}║  • /notas     — CU-22/23/24/25/26                        ║${NC}"
echo -e "${GREEN}║  • /admision  — CU-27/28/29                              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
