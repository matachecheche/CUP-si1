<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

/** CU-11 · Validación del formulario de generación automática de grupos. */
class GenerarGruposRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // el middleware permission:crear grupos ya autoriza
    }

    public function rules(): array
    {
        return [
            'gestion_id' => ['required', 'exists:gestiones,id'],
            'turno' => ['required', 'in:mañana,tarde,noche'],
            'capacidad' => ['required', 'integer', 'min:1', 'max:200'],
            'modalidad' => ['required', 'in:presencial,virtual'],
        ];
    }

    public function messages(): array
    {
        return [
            'capacidad.min' => 'La capacidad debe ser al menos 1 estudiante por grupo.',
            'turno.in' => 'El turno debe ser mañana, tarde o noche.',
            'modalidad.in' => 'La modalidad debe ser presencial o virtual.',
        ];
    }
}
