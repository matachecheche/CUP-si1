<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('materias', function (Blueprint $table) {
            $table->id();
            $table->string('nombre',100)->unique();
            $table->string('area_formacion',80)->nullable();
            $table->text('descripcion')->nullable();
            $table->unsignedInteger('pond_examen1')->default(30);
            $table->unsignedInteger('pond_examen2')->default(30);
            $table->unsignedInteger('pond_examen3')->default(40);
            $table->unsignedInteger('nota_minima_aprobacion')->default(60);
            $table->unsignedInteger('orden')->default(0);
            $table->boolean('estado')->default(true);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('materias'); }
};
