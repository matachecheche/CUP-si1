<?php
namespace Database\Seeders;
use App\Models\{Postulante, User};
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\{DB, Hash};

/**
 * Vincula los usuarios demo para los dashboards por rol. Idempotente.
 *  - docente@cup.edu.bo → el docente con más asignaciones (carga horaria real).
 *  - postulante2@cup.edu.bo → un postulante avanzado (con notas) para ver el
 *    dashboard completo; postulante@cup.edu.bo sigue siendo el preinscrito (pago).
 */
class DashboardDemoSeeder extends Seeder
{
    public function run(): void
    {
        // Docente demo → docente con más carga horaria
        $docenteId = DB::table('asignaciones')
            ->selectRaw('docente_id, COUNT(*) n')->groupBy('docente_id')
            ->orderByDesc('n')->value('docente_id');
        if ($docenteId) {
            User::where('email', 'docente@cup.edu.bo')->whereNull('docente_id')
                ->update(['docente_id' => $docenteId]);
        }

        // Postulante demo "avanzado": con notas registradas y proceso recorrido
        $avanzado = Postulante::whereHas('notas')
            ->whereIn('estado', ['admitido', 'admitido_segunda_opcion', 'no_admitido', 'aprobado', 'no_aprobado'])
            ->orderBy('id')->first();
        if ($avanzado) {
            $u = User::firstOrCreate(
                ['email' => 'postulante2@cup.edu.bo'],
                ['name' => 'Postulante Demo (Avanzado)', 'password' => Hash::make('12345678'),
                 'email_verified_at' => now(), 'activo' => true, 'postulante_id' => $avanzado->id]
            );
            if (! $u->postulante_id) $u->update(['postulante_id' => $avanzado->id]);
            if (! $u->hasRole('Postulante')) $u->assignRole('Postulante');
        }

        $this->command?->info('DashboardDemoSeeder: usuarios demo vinculados.');
    }
}
