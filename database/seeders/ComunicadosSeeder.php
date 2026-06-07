<?php
namespace Database\Seeders;
use App\Models\{Comunicado, Docente, User};
use Illuminate\Database\Seeder;

/** CU-21: comunicados de ejemplo. Idempotente (firstOrCreate por título). */
class ComunicadosSeeder extends Seeder {
    public function run(): void {
        $admin = User::where('email','admin@cup.edu.bo')->first();
        $items = [
            ['titulo'=>'Bienvenidos al CUP — Gestión 1/2026','audiencia'=>'todos','vigente_hasta'=>null,
             'contenido'=>"La FICCT da la bienvenida a todos los postulantes del Curso Preuniversitario.\nRevisa tu horario y grupo asignado en el sistema."],
            ['titulo'=>'Cronograma de exámenes parciales','audiencia'=>'postulantes','vigente_hasta'=>now()->addDays(20)->toDateString(),
             'contenido'=>"Los tres exámenes por materia se rendirán según el cronograma publicado por la administración académica.\nNota mínima de aprobación: 60 puntos."],
            ['titulo'=>'Entrega de actas de notas','audiencia'=>'docentes','vigente_hasta'=>now()->addDays(10)->toDateString(),
             'contenido'=>'Se recuerda a los docentes registrar las notas de sus grupos en el sistema antes del cierre de la gestión.'],
            ['titulo'=>'Inscripciones gestión anterior (cerrado)','audiencia'=>'todos','vigente_hasta'=>now()->subDays(5)->toDateString(),
             'contenido'=>'Aviso de prueba vencido: no debe aparecer en el Panel de Control, solo en la gestión de comunicados.'],
        ];
        foreach ($items as $i) {
            Comunicado::firstOrCreate(['titulo'=>$i['titulo']], $i + ['publicado'=>true,'user_id'=>$admin?->id]);
        }

        // Vincula el usuario demo docente@cup.edu.bo a un docente si está huérfano,
        // para que el filtro de audiencia 'docentes' sea demostrable. Idempotente
        // (solo actúa cuando docente_id es NULL). No modifica UsuariosSeeder.
        if ($doc = Docente::orderBy('id')->first()) {
            User::where('email', 'docente@cup.edu.bo')->whereNull('docente_id')
                ->update(['docente_id' => $doc->id]);
        }
    }
}
