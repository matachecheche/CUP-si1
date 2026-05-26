<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Docente extends Model {
    protected $table = 'docentes';
    protected $fillable = ['ci','nombres','apellidos','telefono','email','titulo_profesional','maestria','diplomado_educacion_superior','certificacion_ingles','otras_certificaciones','area_formacion','estado'];
    public function getNombreCompletoAttribute(): string { return $this->nombres.' '.$this->apellidos; }
    public function user() { return $this->hasOne(User::class); }
}
