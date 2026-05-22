<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Tabla de usuarios — Sistema de Admisión CUP
 *
 * Roles (nuevo.odt § 4 — Actores del sistema):
 *   - Administrador del Sistema  → gestión general, configuración, reportes
 *   - Docente                    → registro de notas de sus grupos
 *   - Postulante                 → consulta de notas y resultado de admisión
 *
 * Un usuario tiene exactamente uno de estos roles (Spatie/Permission).
 * Las FK docente_id / postulante_id vinculan el usuario con su entidad de dominio.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');

            // Vínculo a entidad de dominio (solo uno puede estar presente)
            $table->foreignId('docente_id')
                  ->nullable()
                  ->constrained('docentes')
                  ->nullOnDelete();
            $table->foreignId('postulante_id')
                  ->nullable()
                  ->constrained('postulantes')
                  ->nullOnDelete();

            $table->boolean('activo')->default(true);
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
