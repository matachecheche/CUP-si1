<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Carrera extends Model {
    protected $table = 'carreras';
    protected $fillable = ['nombre','sigla','descripcion','estado'];
    public function cupos() { return $this->hasMany(CupoCarrera::class); }
    public function primerasOpciones() { return $this->hasMany(Postulante::class,'primera_opcion_id'); }
    public function segundasOpciones() { return $this->hasMany(Postulante::class,'segunda_opcion_id'); }
}
