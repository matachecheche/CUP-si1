<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Materia extends Model
{
    protected $table    = 'materias';
    protected $fillable = [
        'nombre', 'area_formacion', 'descripcion',
        'pond_examen1', 'pond_examen2', 'pond_examen3',
        'nota_minima_aprobacion', 'orden', 'estado',
    ];

    /** Valida que las ponderaciones sumen 100 */
    public function getPonderacionTotalAttribute(): int {
        return $this->pond_examen1 + $this->pond_examen2 + $this->pond_examen3;
    }
}
