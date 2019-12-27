<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Requests\UserRequest;
use App\Cajero;
use Illuminate\Support\Facades\Hash;
use Validator;
use DB;

class CajeroController extends ApiController
{
    public function store(Request $request){
        $localRules = [
            'id_administrador' => 'required|exists:administradors,id_administrador',
            'id_sucursal' => 'required|not_in:-1|exists:sucursals,id_sucursal',
            'id_caja' => 'required|not_in:-1|exists:cajas,id_caja',
            'sueldo' => 'required|numeric|between:0,9999999.99',
            //'sueldo' => 'required|digits_between:0,9',
        ];
        $locaMessages = [
            'id_administrador.required' => 'El Administrador es requerido',
            'id_administrador.exists' => 'El Administrador no existe',
            'id_sucursal.required' => 'La Sucursal es requerida',
            'id_sucursal.exists' => 'La Sucursal no existe',
            'id_sucursal.not_in' => 'La Sucursal es requerida',
            'id_caja.required' => 'La Caja es requerida',
            'id_caja.not_in' => 'La Caja es requerida',
            'id_caja.exists' => 'La Caja no existe',
            'sueldo.required' => 'El Sueldo es requerido',
            'sueldo.numeric' => 'El sueldo tiene que ser de tipo numérico',
            'sueldo.between' => 'El sueldo tiene que estar entre 0 y 9999999.99'
            //'sueldo.digits_between' => 'El Sueldo solo tiene que tener digitos del 0 - 9'
        ];
        $allRules = (new UserRequest())->rules() + $localRules;
        $allMessages = (new UserRequest())->messages() + $locaMessages;
        $validator = Validator::make($request->all(), $allRules, $allMessages);

        $validator->sometimes('primer_nombre', 'min:4|max:100', function($input){
            return ! empty( $input->primer_nombre );
        });

        $validator->sometimes('segundo_nombre', 'min:4|max:100', function($input){
            return ! empty( $input->segundo_nombre );
        });

        $validator->sometimes('paterno', 'min:4|max:100', function($input){
            return ! empty( $input->paterno );
        });

        $validator->sometimes('materno', 'min:4|max:100', function($input){
            return ! empty( $input->materno );
        });

        $validator->sometimes('celular', 'min:4|max:20|digits_between:0,9', function($input){
            return ! empty( $input->celular );
        });

        $validator->sometimes('telefono', 'min:4|max:20|digits_between:0,9', function($input){
            return ! empty( $input->telefono );
        });

        if ($validator->fails()) {
            return response()->json(["error" => $validator->errors()], 201);
        }

        $cajero = new Cajero;
        $cajero->primer_nombre = $request->get("primer_nombre");
        $cajero->segundo_nombre = $request->get("segundo_nombre");
        $cajero->paterno = $request->get("paterno");
        $cajero->materno = $request->get("materno");
        $cajero->email = $request->get("email");
        $cajero->dni = $request->get("dni");
        $cajero->sexo = $request->get("sexo");
        $cajero->direccion = $request->get("direccion");
        $cajero->nombre_usuario = $request->get("nombre_usuario");
        $cajero->password = bcrypt($request->get("password"));
        $cajero->fecha_nac = $request->get("fecha_nac");
        $cajero->tipo_usuario = $request->get("tipo_usuario");
        $cajero->celular = $request->get("celular");
        $cajero->telefono = $request->get("telefono");
        $cajero->tipo_usuario = $request->get("tipo_usuario");
        //Campos correspondientes solo al Cajero
        $cajero->id_sucursal = $request->get("id_sucursal");
        $cajero->id_administrador = $request->get("id_administrador");
        $cajero->id_caja = $request->get("id_caja");
        $cajero->sueldo = $request->get("sueldo");
        $cajero->estado = true;
        $cajero->save();
        return response()->json(['data' => $cajero], 201);
    }
    public function update(Request $request, $id){
        \Log::info($request);
        $cajero = Cajero::find($id);
        $localRules = [
            'id_administrador' => 'required|exists:administradors,id_administrador',
            'id_sucursal' => 'required|not_in:-1|exists:sucursals,id_sucursal',
            'id_caja' => 'required|not_in:-1|exists:cajas,id_caja',
            'sueldo' => 'required|numeric|between:0,9999999.99',
        ];
        $locaMessages = [
            'id_administrador.required' => 'El Administrador es requerido',
            'id_administrador.exists' => 'El Administrador no existe',
            'id_sucursal.required' => 'La Sucursal es requerida',
            'id_sucursal.exists' => 'La Sucursal no existe',
            'id_sucursal.not_in' => 'La Sucursal es requerida',
            'id_caja.required' => 'La Caja es requerida',
            'id_caja.not_in' => 'La Caja es requerida',
            'id_caja.exists' => 'La Caja no existe',
            'sueldo.required' => 'El Sueldo es requerido',
            'sueldo.numeric' => 'El sueldo tiene que ser de tipo numérico',
            'sueldo.between' => 'El sueldo tiene que estar entre 0 y 9999999.99'
        ];
        $allRules = (new UserRequest())->rulesUpdate($cajero->id_usuario) + $localRules;
        $allMessages = (new UserRequest())->messages() + $locaMessages;
        $validator = Validator::make($request->all(), $allRules, $allMessages);

        $validator->sometimes('primer_nombre', 'min:4|max:100', function($input){
            return ! empty( $input->primer_nombre );
        });

        $validator->sometimes('segundo_nombre', 'min:4|max:100', function($input){
            return ! empty( $input->segundo_nombre );
        });

        $validator->sometimes('paterno', 'min:4|max:100', function($input){
            return ! empty( $input->paterno );
        });

        $validator->sometimes('materno', 'min:4|max:100', function($input){
            return ! empty( $input->materno );
        });

        $validator->sometimes('celular', 'min:4|max:20|digits_between:0,9', function($input){
            return ! empty( $input->celular );
        });

        $validator->sometimes('telefono', 'min:4|max:20|digits_between:0,9', function($input){
            return ! empty( $input->telefono );
        });

        if ($validator->fails()) {
            return response()->json(["error" => $validator->errors()], 201);
        }

        if($request->has('primer_nombre')) {
            $cajero->primer_nombre = $request->get("primer_nombre");
        }
        if($request->has('segundo_nombre')) {
            $cajero->segundo_nombre = $request->get("segundo_nombre");
        }
        if($request->has('paterno')) {
            $cajero->paterno = $request->get("paterno");
        }
        if($request->has('materno')) {
            $cajero->materno = $request->get("materno");
        }
        if($request->has('email')) {
            $cajero->email = $request->get("email");
        }
        if($request->has('dni')) {
            $cajero->dni = $request->get("dni");
        }
        if($request->has('sexo')) {
            $cajero->sexo = $request->get("sexo");
        }
        if($request->has('estado')) {
            $cajero->estado = $request->get("estado");
        }
        if($request->has('direccion')) {
            $cajero->direccion = $request->get("direccion");
        }
        if($request->has('nombre_usuario')) {
            $cajero->nombre_usuario = $request->get("nombre_usuario");
        }
        if($request->has('fecha_nac')) {
            $cajero->fecha_nac = $request->get("fecha_nac");
        }
        if($request->has('tipo_usuario')) {
            $cajero->tipo_usuario = $request->get("tipo_usuario");
        }
        if($request->has('celular')) {
            $cajero->celular = $request->get("celular");
        }
        if($request->has('telefono')) {
            $cajero->telefono = $request->get("telefono");
        }
        //Campos correspondientes solo al Cajero
        if($request->has('id_sucursal')) {
            $cajero->id_sucursal = $request->get("id_sucursal");
        }
        if($request->has('id_administrador')) {
            $cajero->id_administrador = $request->get("id_administrador");
        }
        if($request->has('sueldo')) {
            $cajero->sueldo = $request->get("sueldo");
        }
        if($request->has('id_caja')) {
            $cajero->id_caja = $request->get("id_caja");
        }
        if(!$cajero->isDirty()){
            return $this->errorResponse(['valores' => 'Se debe modificar al menos un valor para poder actualizar'], 201);
        }
        $cajero->save();
        return response()->json(['data' => $cajero], 201);
    }
    public function show($id)
    {
        $cajero = DB::table('cajeros as c')
                  ->where('id_cajero', '=', $id)
                  ->select('id_cajero as id_usuario', 'paterno', 'materno', 'primer_nombre', 'dni', 'direccion', 'nombre_usuario', 'email', 'direccion', 'fecha_nac', 'sueldo', 'id_sucursal', 'id_administrador', 'tipo_usuario', 'id_caja', 'segundo_nombre', 'celular', 'telefono', 'sexo', 'estado')
                  ->get();
        return response()->json(['data' => $cajero], 201);
    }
    public function destroy($id){
        $cajero = Cajero::find($id)->delete();
        return response()->json(['data' => $cajero], 201);
    }
}
