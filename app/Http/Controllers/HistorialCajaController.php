<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Response;
use App\HistorialCaja;
use DB;
use Validator;

class HistorialCajaController extends ApiController
{
    public function index($idCaja, $pag){
        $historial = DB::table('historial_caja as h')
                        ->where('id_caja', '=', $idCaja)
                        ->orderBy('created_at', 'desc')
                        ->paginate($pag);
        $response = Response::json(['data' => $historial], 200);
        return $response;
    }
    public function calculaMontoFinal($idHistorialCaja){
        $hcaja = DB::table('pagos as p')
                        ->join('venta_productos as v', 'v.id_venta_producto', '=', 'p.id_venta_producto')
                        ->where('v.id_historial_caja', '=', $idHistorialCaja)
                        ->get();
        $response = Response::json(['data' => $hcaja], 200);
        return $response;
    }
    public function updateMontoFinal(Request $request, $id){
        \Log::info($request);
        if($request->has('monto_final')) {
            $historial = HistorialCaja::find($id);
            $historial->monto = $request->monto_final;
            $historial->save();
            return response()->json(['data' => $historial], 201);
        }
    }
    public function store(Request $request, $idCaja){
        //Validar que no se registre con la misma fecha
        //Validar que no haya otra caja abierta
        $fecha_valida = DB::table('historial_caja')->where('id_caja', '=', $idCaja)->where('fecha', '=', $request->fecha)->get();
        if(sizeof($fecha_valida)==0){
            $estado_valida = DB::table('historial_caja')->where('id_caja', '=', $idCaja)->where('estado', '=', 'true')->get();
            if(sizeof($estado_valida)==0) {
                $validator = Validator::make($request->all(), [
                    'monto_inicial' => 'required|numeric|between:0,99999999.99',
                    'fecha' => 'required|date:dd/mm/YYYY'
                ],
                    $messages = [
                        'monto_inicial.required' => 'El monto inicial es requerido',
                        'monto_inicial.numeric' => 'El monto inicial tiene que ser de tipo numérico',
                        'monto_inicial.between' => 'El monto inicial tiene que estar entre 0 y 99999999.99',
                        'fecha.required' => 'La fecha es requerida',
                        'fecha.date' => 'La fecha no tiene el formato correcto',
                    ]);
                if ($validator->fails()) {
                    return response()->json(["error" => $validator->errors()], 201);
                }
                $historial = new HistorialCaja();
                $historial->monto_inicial = $request->get("monto_inicial");
                $historial->monto = $request->get("monto_inicial");
                $historial->estado = $request->get("estado");
                $historial->fecha = $request->get("fecha");
                if ($request->has('id_administrador')) {
                    $historial->id_administrador = $request->get("id_administrador");
                }
                if ($request->has('id_cajero')) {
                    $historial->id_cajero = $request->get("id_cajero");
                }
                $historial->id_caja = $request->get("id_caja");
                $historial->save();
                return response()->json(['data' => $historial], 201);
            }
            else{
                return $this->errorResponse(['valores' => 'Existe otra apertura de caja que no ha sido cerrada'], 201);
            }
        }else{
            return $this->errorResponse(['valores' => 'Ya existe una apertura de caja con la fecha '.$request->fecha], 201);
        }

    }
    public function update(Request $request, $id){
        if($request->has('estado')) {
            $historial = HistorialCaja::find($id);
            $historial->estado = $request->estado;
            $historial->save();
            return response()->json(['data' => $historial], 201);
        }
    }
}
