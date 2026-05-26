<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Gestion extends Model
{
    protected $table    = 'gestiones';
    protected $fillable = ['descripcion', 'fecha_inicio', 'fecha_fin', 'estado'];
    protected $casts    = ['fecha_inicio' => 'date', 'fecha_fin' => 'date'];
}
