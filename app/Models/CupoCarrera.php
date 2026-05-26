<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class CupoCarrera extends Model {
    protected $table = 'cupos_carrera';
    protected $fillable = ['carrera_id','gestion_id','cantidad_maxima'];
    public function carrera() { return $this->belongsTo(Carrera::class); }
    public function gestion() { return $this->belongsTo(Gestion::class); }
}
