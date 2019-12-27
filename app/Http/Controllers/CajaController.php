<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Response;
use App\Caja;
use DB;
use Validator;

class CajaController extends ApiController
{
    public function index($idSucursal, $pag)
    {
        $caja = DB::table('cajas as c')
            ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
            ->select('c.id_caja', 'c.nombre', 's.nombre as nombreSucursal')
            ->where('c.id_sucursal', '=', $idSucursal)
            ->whereNull('c.deleted_at')
            ->orderBy('c.created_at', 'desc')
            ->paginate($pag);
        $response = Response::json(['data' => $caja], 200);
        return $response;
    }
    public function allcajas($idSucursal){
        \Log::info($idSucursal);
        $caja = DB::table('cajas')
                ->where('id_sucursal', '=', $idSucursal)
                ->whereNull('deleted_at')
                ->orderBy('nombre', 'asc')
                ->get();
        $response = Response::json(['data' => $caja], 200);
        return $response;
    }
    //Combo cajas por Sucursal
    public function sucursalPerRestaurant($idRestaurant)
    {
        $caja = DB::table('sucursals as s')
            ->where('s.id_restaurant', '=', $idRestaurant)
            ->orderBy('s.nombre', 'asc')
            ->get();
        $response = Response::json(['data' => $caja], 200);
        return $response;
    }
    public function store(Request $request){
        $validator = Validator::make($request->all(), [
            'nombre' => 'required|min:4|max:50',
            'id_administrador' => 'required|exists:administradors,id_administrador',
            'id_sucursal' => 'required|not_in:-1|exists:sucursals,id_sucursal'
        ], 
        $messages = [
            'nombre.required' => 'El Nombre es requerido',
            'nombre.min' => 'El Nombre tiene que tener 4 caracteres como mínimo',
            'nombre.max' => 'El Nombre tiene que tener 50 caracteres como maximo',
            'id_administrador.required' => 'El Administrador es requerido',
            'id_administrador.exists' => 'El Administrador no existe',
            'id_sucursal.required' => 'La Sucursal es requerida',
            'id_sucursal.not_in' => 'La Sucursal es requerida',
            'id_sucursal.exists' => 'La Sucursal no existe',
        ]);
        if ($validator->fails()) {
            return response()->json(["error" => $validator->errors()], 201);
        }
        $caja = new Caja();
        $caja->nombre = $request->get("nombre");
        $caja->descripcion = $request->get("descripcion");
        $caja->id_administrador = $request->get("id_administrador");
        $caja->id_sucursal = $request->get("id_sucursal");
        $caja->save();
        return response()->json(['data' => $caja], 201);
    }
    public function update(Request $request, $id){
        $caja = Caja::find($id);
        $validator = Validator::make($request->all(), [
            'nombre' => 'required|min:4|max:50',
            'id_administrador' => 'required|exists:administradors,id_administrador',
            'id_sucursal' => 'required|not_in:-1|exists:sucursals,id_sucursal'
        ],
        $messages = [
            'nombre.required' => 'El Nombre es requerido',
            'nombre.min' => 'El Nombre tiene que tener 4 caracteres como mínimo',
            'nombre.max' => 'El Nombre tiene que tener 50 caracteres como maximo',
            'id_administrador.required' => 'El Administrador es requerido',
            'id_administrador.exists' => 'El Administrador no existe',
            'id_sucursal.required' => 'La Sucursal es requerida',
            'id_sucursal.not_in' => 'La Sucursal es requerida',
            'id_sucursal.exists' => 'La Sucursal no existe',
        ]);
        if ($validator->fails()) {
            return response()->json(["error" => $validator->errors()], 201);
        }
        if($request->has('nombre')) {
            $caja->nombre = $request->nombre;
        }
        if($request->has('descripcion')) {
            $caja->descripcion = $request->descripcion;
        }
        if($request->has('id_administrador')) {
            $caja->id_administrador = $request->id_administrador;
        }
        if($request->has('id_sucursal')) {
            $caja->id_sucursal = $request->id_sucursal;
        }
        if(!$caja->isDirty()){
            return $this->errorResponse(['valores' => 'Se debe modificar al menos un valor para poder actualizar'], 201);
        }
        $caja->save();
        return response()->json(['data' => $caja], 201);
    }
    public function show($id)
    {
        $caja = Caja::find($id);
        return response()->json(['data' => $caja], 201);
    }
    public function destroy($id){
        //Verifica si tiene cajero asignados
        $var = DB::table('cajas as c')
                    ->join('cajeros as a', 'a.id_caja', '=', 'c.id_caja')
                    ->where('c.id_caja', '=', $id)
                    ->get();
        if(sizeof($var) == 0){
            $caja = Caja::find($id)->delete();
            return response()->json(['data' => $caja], 201);
        }else{
            $obj = ['error' => 'No se puede eliminar, existen cajeros asignados a la categoria'];
            return response()->json(['data' => $obj], 201);
        }
    }
}