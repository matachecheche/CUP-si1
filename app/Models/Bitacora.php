<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Bitacora extends Model {
    protected $table = 'bitacoras';
    protected $fillable = ['user_id','usuario','accion','modulo','metodo_http','ruta','fecha_hora','id_operacion','ip','user_agent'];
    public function user() { return $this->belongsTo(User::class); }
}
