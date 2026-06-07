<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class Comunicado extends Model {
    protected $table = 'comunicados';
    protected $fillable = ['titulo','contenido','audiencia','publicado','vigente_hasta','user_id'];
    protected $casts = ['publicado'=>'boolean','vigente_hasta'=>'date'];

    public function autor() { return $this->belongsTo(User::class, 'user_id'); }

    /** Publicados y dentro de vigencia. */
    public function scopeVigentes(Builder $q): Builder {
        return $q->where('publicado', true)
                 ->where(fn($w) => $w->whereNull('vigente_hasta')->orWhereDate('vigente_hasta','>=',today()));
    }

    /** Audiencias visibles para el usuario autenticado. */
    public function scopeParaUsuario(Builder $q, ?User $u): Builder {
        $aud = ['todos'];
        if ($u?->postulante_id) $aud[] = 'postulantes';
        if ($u?->docente_id)    $aud[] = 'docentes';
        if ($u?->can('crear comunicados')) $aud = ['todos','postulantes','docentes'];
        return $q->whereIn('audiencia', $aud);
    }

    public function getEstadoCalculadoAttribute(): string {
        if (! $this->publicado) return 'Borrador';
        if ($this->vigente_hasta && $this->vigente_hasta->lt(today())) return 'Vencido';
        return 'Publicado';
    }
    public function getEstadoBadgeAttribute(): string {
        return match($this->estado_calculado){'Publicado'=>'bv','Borrador'=>'bna','Vencido'=>'bg2',default=>'bg2'};
    }
    public function getAudienciaBadgeAttribute(): string {
        return match($this->audiencia){'todos'=>'bv','postulantes'=>'bo','docentes'=>'baz',default=>'bg2'};
    }
}
