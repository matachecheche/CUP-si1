<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pago extends Model
{
    protected $table = 'pagos';

    protected $fillable = ['postulante_id', 'gestion_id', 'monto', 'moneda', 'metodo', 'stripe_session_id', 'stripe_payment_intent_id', 'estado', 'fecha_pago', 'comprobante'];

    protected $casts = ['monto' => 'decimal:2', 'fecha_pago' => 'datetime'];

    public function postulante()
    {
        return $this->belongsTo(Postulante::class);
    }

    public function gestion()
    {
        return $this->belongsTo(Gestion::class);
    }

    public function getEstadoBadgeAttribute(): string
    {
        return match ($this->estado) {
            'pagado' => 'bv','pendiente' => 'bna','fallido' => 'bd','reembolsado' => 'bg2',default => 'bg2'
        };
    }
}
