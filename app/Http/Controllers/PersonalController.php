<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Response;
use DB;
use Validator;

class PersonalController extends ApiController
{
    public function filtra_personal($idRestaurant, $pag, $idSucursal, $perfil){
        if(($idSucursal == -1) && ($perfil == -1)){
            $personal = DB::table(DB::raw("function_personal(".$idRestaurant.")"))
                ->paginate($pag);
            $response = Response::json(['data' => $personal], 200);
            return $response;
        }else if(($idSucursal == -1) && ($perfil != -1)){
            $personal = DB::table(DB::raw("function_personal(".$idRestaurant.")"))
                ->where('tipo_usuario', '=', $perfil)
                ->paginate($pag);
            $response = Response::json(['data' => $personal], 200);
            return $response;
        }else if(($idSucursal != -1) && ($perfil == -1)){
            $personal = DB::table(DB::raw("function_personal(".$idRestaurant.")"))
                ->where('id_sucursal', '=', $idSucursal)
                ->paginate($pag);
            $response = Response::json(['data' => $personal], 200);
            return $response;
        }else if(($idSucursal != -1) && ($perfil != -1)){
            $personal = DB::table(DB::raw("function_personal(".$idRestaurant.")"))
                ->where('id_sucursal', '=', $idSucursal)
                ->where('tipo_usuario', '=', $perfil)
                ->paginate($pag);
            $response = Response::json(['data' => $personal], 200);
            return $response;
        }
    }
     public function filtra_personal_all($idRestaurant, $idSucursal, $perfil){
        if(($idSucursal == -1) && ($perfil == -1)){
            $personal = DB::table(DB::raw("function_personal(".$idRestaurant.")"))
                ->get();
            $response = Response::json(['data' => $personal], 200);
            return $response;
        }else if(($idSucursal == -1) && ($perfil != -1)){
            $personal = DB::table(DB::raw("function_personal(".$idRestaurant.")"))
                ->where('tipo_usuario', '=', $perfil)
                ->get();
            $response = Response::json(['data' => $personal], 200);
            return $response;
        }else if(($idSucursal != -1) && ($perfil == -1)){
            $personal = DB::table(DB::raw("function_personal(".$idRestaurant.")"))
                ->where('id_sucursal', '=', $idSucursal)
                ->get();
            $response = Response::json(['data' => $personal], 200);
            return $response;
        }else if(($idSucursal != -1) && ($perfil != -1)){
            $personal = DB::table(DB::raw("function_personal(".$idRestaurant.")"))
                ->where('id_sucursal', '=', $idSucursal)
                ->where('tipo_usuario', '=', $perfil)
                ->get();
            $response = Response::json(['data' => $personal], 200);
            return $response;
        }
    }
}
