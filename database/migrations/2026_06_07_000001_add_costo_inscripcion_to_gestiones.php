<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * CU-20: cada gestión define el costo de inscripción al CUP.
 * Bs 850.00 es un valor de ejemplo, editable por gestión.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('gestiones', function (Blueprint $t) {
            $t->decimal('costo_inscripcion', 10, 2)->default(850.00)->after('estado');
        });
    }

    public function down(): void
    {
        Schema::table('gestiones', function (Blueprint $t) {
            $t->dropColumn('costo_inscripcion');
        });
    }
};
