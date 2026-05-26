<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
return new class extends Migration {
    public function up(): void {
        Schema::create('bitacoras', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('usuario',120)->nullable();
            $table->string('accion',250);
            $table->string('modulo',60)->nullable();
            $table->string('metodo_http',10)->nullable();
            $table->string('ruta',255)->nullable();
            $table->dateTime('fecha_hora');
            $table->bigInteger('id_operacion')->nullable();
            $table->string('ip',45)->nullable();
            $table->string('user_agent',255)->nullable();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('bitacoras'); }
};
