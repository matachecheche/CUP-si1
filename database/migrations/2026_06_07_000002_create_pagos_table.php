<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * CU-20: Pago de inscripción al CUP mediante pasarela (Stripe Checkout).
 * Flujo: postulante 'preinscrito' paga → webhook confirma → 'inscrito'.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pagos', function (Blueprint $t) {
            $t->id();
            $t->foreignId('postulante_id')->constrained('postulantes')->cascadeOnDelete();
            $t->foreignId('gestion_id')->constrained('gestiones');
            $t->decimal('monto', 10, 2);
            $t->string('moneda', 3)->default('BOB');
            $t->string('metodo', 30)->default('stripe');      // stripe | qr | banco (extensible)
            $t->string('stripe_session_id')->nullable()->unique();
            $t->string('stripe_payment_intent_id')->nullable();
            $t->string('estado', 20)->default('pendiente');   // pendiente | pagado | fallido | reembolsado
            $t->timestamp('fecha_pago')->nullable();
            $t->string('comprobante', 100)->nullable();       // nro de recibo interno (CUP-2026-00001)
            $t->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pagos');
    }
};
