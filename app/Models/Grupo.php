<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Grupo extends Model {
    protected $table = 'grupos';
    protected $fillable = ['gestion_id','codigo','turno','modalidad','capacidad_maxima','estado'];
    public function gestion()      { return $this->belongsTo(Gestion::class); }
    public function postulantes()  { return $this->belongsToMany(Postulante::class,'grupo_postulante'); }
    public function asignaciones() { return $this->hasMany(Asignacion::class); }
    public function notas()        { return $this->hasMany(Nota::class); }
}
