<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Módulo Registro de Postulantes (CU-05 a CU-09)
 * Campos según documento PDF sección 2 — Requerimientos Funcionales
 */
return new class extends Migration {
    public function up(): void {
        Schema::create('postulantes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gestion_id')->constrained('gestiones');

            // Opciones de carrera (CU-08)
            $table->foreignId('primera_opcion_id')->constrained('carreras');
            $table->foreignId('segunda_opcion_id')->constrained('carreras');

            // Datos personales (§ 2 documento PDF)
            $table->string('ci', 20)->unique();
            $table->string('nombres', 100);
            $table->string('apellidos', 100);
            $table->date('fecha_nacimiento')->nullable();
            $table->enum('sexo', ['M', 'F', 'Otro'])->nullable();
            $table->string('direccion', 200)->nullable();
            $table->string('telefono', 20)->nullable();
            $table->string('email', 100)->nullable();
            $table->string('colegio_procedencia', 150)->nullable();
            $table->string('ciudad', 80)->nullable();

            // Documentos requeridos (CU-06)
            $table->boolean('doc_ci')->default(false);
            $table->boolean('doc_libreta_colegio')->default(false);
            $table->boolean('doc_titulo_bachiller')->default(false);

            // Estado del postulante (CU-09)
            $table->enum('estado', [
                'inscrito',               // recién registrado
                'en_curso',               // cursando el CUP
                'aprobado',               // promedio >= 60
                'no_aprobado',            // promedio < 60
                'admitido',               // cupo asignado primera opción
                'admitido_segunda_opcion',// cupo en segunda opción
                'no_admitido',            // aprobó pero no alcanzó cupo
            ])->default('inscrito');

            // Resultados de evaluación (calculados automáticamente)
            $table->decimal('promedio_general', 5, 2)->nullable();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('postulantes'); }
};
