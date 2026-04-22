<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password; // <-- IMPORTANTE: Esta línea permite usar las reglas avanzadas

class StoreUsuarioRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Se mantiene en true para permitir la validación
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'min:3', 'max:50'],
            'email' => ['required', 'email', 'unique:users,email', 'max:250'],
            'role' => ['required', 'exists:roles,name'],
            'empleado_id' => ['nullable', 'exists:empleados,id'],
            'residente_id' => ['nullable', 'exists:residentes,id'],
            
            // Aquí aplicamos la validación robusta para la contraseña
            'password' => [
                'required',
                'min:8',
                'max:20',
                'confirmed', // Obliga a que exista un campo password_confirmation en tu vista
                Password::min(8)
                    ->letters()          // Al menos una letra
                    ->mixedCase()        // Mayúsculas y minúsculas
                    ->numbers()          // Al menos un número
                    ->symbols(),         // Caracteres especiales (!@#$%...)
            ],
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'name' => 'nombre',
            'email' => 'correo electrónico',
            'password' => 'contraseña',
            'empleado_id' => 'empleado',
            'residente_id' => 'residente',
            'role' => 'rol',
        ];
    }
}