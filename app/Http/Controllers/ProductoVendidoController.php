<?php

namespace App\Http\Controllers;

use App\ProductoVendido;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Response;
use Validator;
use DB;

class ProductoVendidoController extends ApiController
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index($idVentaProducto)
    {
        $pvendidos = DB::table('producto_vendidos as p')
                        ->join('productos as r', 'r.id_producto', '=', 'p.id_producto')
                        ->where('p.id_venta_producto', '=', $idVentaProducto)
                        ->select('p.*', 'r.nombre as detalle')
                        ->get();
        $vproducto = DB::table('venta_productos as v')
                        ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                        ->where('v.id_venta_producto', '=', $idVentaProducto)
                        ->select('v.*', DB::raw("CASE WHEN c.nombre_completo isNull THEN 'GENERAL' ELSE c.nombre_completo END AS nombre_completo"), DB::raw("CASE WHEN c.dni isNull THEN 'GENERAL' ELSE c.dni END as dni"))
                        ->get();
        $pago = DB::table('pagos')
                        ->where('id_venta_producto', '=', $idVentaProducto)
                        ->get();
        $response = Response::json(['data' => $pvendidos, 'vprod' => $vproducto, 'vpag' => $pago], 200);
        return $response;
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        \Log::info($request);
//        $validator = Validator::make($request->all(), [
//            'cantidad' => 'required',
//            'importe' => 'required',
//            'descuento' => 'required',
//            'p_unit' => 'required',
//            'id_producto' => 'required|exists:productos,id_producto',
//            'id_venta_producto' => 'required|exists:venta_productos,id_venta_producto',
//        ]);
//
//        if ($validator->fails()) {
//            return response()->json(["error" => $validator->errors()], 201);
//        }
//
//        $pvendido = new ProductoVendido();
//        $pvendido->cantidad = $request->get("cantidad");
//        $pvendido->importe = $request->get("importe");
//        $pvendido->p_unit = $request->get("p_unit");
//        $pvendido->id_producto = $request->get("id_producto");
//        $pvendido->id_venta_producto = $request->get("id_venta_producto");
//        $pvendido->id_sucursal = $request->get("id_sucursal");
//        if($request->has('nota')) {
//            $pvendido->nota = $request->get("nota");
//        }
//        if($request->has('id_cajero')) {
//            $pvendido->id_cajero = $request->get("id_cajero");
//        }
//        if($request->has('id_mozo')) {
//            $pvendido->id_mozo = $request->get("id_mozo");
//        }
//        $pvendido->save();
//        return response()->json(['data' => $pvendido], 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
    }
}
