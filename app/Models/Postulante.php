<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Postulante extends Model
{
    protected $table    = 'postulantes';
    protected $fillable = [
        'gestion_id', 'primera_opcion_id', 'segunda_opcion_id',
        'ci', 'nombres', 'apellidos', 'fecha_nacimiento', 'sexo',
        'direccion', 'telefono', 'email', 'colegio_procedencia', 'ciudad',
        'doc_ci', 'doc_libreta_colegio', 'doc_titulo_bachiller',
        'estado', 'promedio_general',
    ];
    protected $casts = ['fecha_nacimiento' => 'date'];

    public function gestion()         { return $this->belongsTo(Gestion::class); }
    public function primeraOpcion()   { return $this->belongsTo(Carrera::class, 'primera_opcion_id'); }
    public function segundaOpcion()   { return $this->belongsTo(Carrera::class, 'segunda_opcion_id'); }
    public function getNombreCompletoAttribute(): string { return $this->nombres . ' ' . $this->apellidos; }

    public function tieneDocumentos(): bool {
        return $this->doc_ci && $this->doc_libreta_colegio && $this->doc_titulo_bachiller;
    }

    public function getEstadoBadgeAttribute(): string {
        return match($this->estado) {
            'inscrito'               => 'b-azul',
            'en_curso'               => 'b-naranja',
            'aprobado'               => 'b-verde',
            'no_aprobado'            => 'b-rojo',
            'admitido'               => 'b-verde',
            'admitido_segunda_opcion'=> 'b-oro',
            'no_admitido'            => 'b-rojo',
            default                  => 'b-gris',
        };
    }
}
