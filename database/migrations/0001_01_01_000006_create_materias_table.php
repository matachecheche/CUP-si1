<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Módulo Exámenes y Control Académico — Materias (CU-12)
 * Las 4 materias: Computación, Matemáticas, Física, Inglés
 * Cada materia tiene 3 exámenes con ponderación 30%+30%+40%
 */
return new class extends Migration {
    public function up(): void {
        Schema::create('materias', function (Blueprint $table) {
            $table->id();
            $table->string('nombre', 100)->unique();
            $table->string('area_formacion', 80)->nullable();
            $table->text('descripcion')->nullable();

            // Ponderación de los 3 exámenes (deben sumar 100)
            $table->unsignedInteger('pond_examen1')->default(30); // 30%
            $table->unsignedInteger('pond_examen2')->default(30); // 30%
            $table->unsignedInteger('pond_examen3')->default(40); // 40%

            $table->unsignedInteger('nota_minima_aprobacion')->default(60);
            $table->unsignedInteger('orden')->default(0);
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('materias'); }
};
