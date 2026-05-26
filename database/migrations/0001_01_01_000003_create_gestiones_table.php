<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('gestiones', function (Blueprint $table) {
            $table->id();
            $table->string('descripcion',50)->unique();
            $table->date('fecha_inicio');
            $table->date('fecha_fin');
            $table->enum('estado',['planificacion','inscripcion','en_curso','finalizado'])->default('planificacion');
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('gestiones'); }
};
