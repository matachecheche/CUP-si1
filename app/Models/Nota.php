<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Nota extends Model {
    protected $table = 'notas';
    protected $fillable = ['postulante_id','materia_id','grupo_id','examen1','examen2','examen3','nota_final','aprobado'];
    protected $casts    = ['aprobado'=>'boolean'];
    public function postulante() { return $this->belongsTo(Postulante::class); }
    public function materia()    { return $this->belongsTo(Materia::class); }
    public function grupo()      { return $this->belongsTo(Grupo::class); }
    /** Calcula y persiste la nota final ponderada */
    public function calcularNotaFinal(): void {
        $mat = $this->materia;
        $p1  = $mat ? $mat->pond_examen1 : 30;
        $p2  = $mat ? $mat->pond_examen2 : 30;
        $p3  = $mat ? $mat->pond_examen3 : 40;
        $nf  = round(
            ($this->examen1 * $p1 / 100) +
            ($this->examen2 * $p2 / 100) +
            ($this->examen3 * $p3 / 100), 2);
        $this->nota_final = $nf;
        $this->aprobado   = ($nf >= ($mat ? $mat->nota_minima_aprobacion : 60));
        $this->save();
    }
}
