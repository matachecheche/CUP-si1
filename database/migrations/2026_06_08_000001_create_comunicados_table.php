<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/** CU-21: comunicados institucionales dirigidos por audiencia. */
return new class extends Migration {
    public function up(): void
    {
        Schema::create('comunicados', function (Blueprint $t) {
            $t->id();
            $t->string('titulo', 150);
            $t->text('contenido');
            $t->enum('audiencia', ['todos', 'postulantes', 'docentes'])->default('todos');
            $t->boolean('publicado')->default(true);
            $t->date('vigente_hasta')->nullable();   // null = sin vencimiento
            $t->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete(); // autor
            $t->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('comunicados'); }
};
