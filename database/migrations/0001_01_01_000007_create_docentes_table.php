<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Módulo Asignación de Grupos y Docentes — Docentes (CU-14 a CU-16)
 * Perfil profesional: título, maestría, diplomado en educación superior,
 * certificaciones de inglés, área afín (para validar qué materia puede dictar)
 * Regla: máximo 4 grupos por docente
 */
return new class extends Migration {
    public function up(): void {
        Schema::create('docentes', function (Blueprint $table) {
            $table->id();

            // Datos personales
            $table->string('ci', 20)->unique();
            $table->string('nombres', 100);
            $table->string('apellidos', 100);
            $table->string('telefono', 20)->nullable();
            $table->string('email', 100)->nullable()->unique();

            // Perfil profesional (CU-14, CU-15 — requisitos de contratación)
            $table->string('titulo_profesional', 150)->nullable();
            $table->string('maestria', 150)->nullable();
            $table->string('diplomado_educacion_superior', 150)->nullable();
            $table->string('certificacion_ingles', 100)->nullable();
            $table->text('otras_certificaciones')->nullable();

            // Área afín (determina qué materias puede dictar — CU-15)
            $table->string('area_formacion', 80)->nullable();

            // Estado y límite de grupos (regla: máx 4 grupos)
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('docentes'); }
};
