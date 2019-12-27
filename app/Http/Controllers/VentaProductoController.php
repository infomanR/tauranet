<?php

namespace App\Http\Controllers;

use App\VentaProducto;
use Validator;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Response;
use DB;

class VentaProductoController extends ApiController
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index($idCaja)
    {
        $pedidos = DB::table('venta_productos as v')
                        ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                        ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
                        ->leftJoin('clientes as i', 'i.id_cliente', '=', 'v.id_cliente')
                        ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                        ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                        ->where('c.id_caja', '=', $idCaja)
                        ->where('h.estado', '=', true)
                        ->select('v.*', 'i.nombre_completo', 'i.dni as dni_cliente', DB::raw("nullif(concat(j.primer_nombre,' ', j.segundo_nombre,' ',j.paterno,' ',j.materno), '   ') as nombre_cajero"), DB::raw("nullif(concat(m.primer_nombre,' ', m.segundo_nombre,' ',m.paterno,' ',m.materno), '   ') as nombre_mozo"))
                        ->orderBy('v.id_venta_producto', 'desc')
                        ->get();
        $response = Response::json(['data' => $pedidos], 200);
        return $response;
    }

    public function indexMozo($idMozo, $idSucursal)
    {
        $pedidos = DB::table('venta_productos as v')
            ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
            ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
            ->leftJoin('clientes as i', 'i.id_cliente', '=', 'v.id_cliente')
            ->join('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
            ->where('h.estado', '=', true)
            ->where('c.id_sucursal', '=', $idSucursal)
            ->where('v.id_mozo', '=', $idMozo)
            ->whereNull('v.id_cajero')
            ->select('v.*', 'i.nombre_completo', 'i.dni as dni_cliente', DB::raw("nullif(concat(m.primer_nombre,' ', m.segundo_nombre,' ',m.paterno,' ',m.materno), '   ') as nombre_mozo"), 'c.nombre as nombre_caja')
            ->orderBy('v.id_venta_producto', 'desc')
            ->get();
        $response = Response::json(['data' => $pedidos], 200);
        return $response;
    }
    public function getPedidosCocinero($idSucursal){
        $pedidos = DB::table('venta_productos as v')
            ->leftJoin('clientes as i', 'i.id_cliente', '=', 'v.id_cliente')
            ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
            ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
            ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
            ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
            ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
            ->where('h.estado', '=', true)
            ->where('s.id_sucursal', '=', $idSucursal)
            ->select('v.*', 'i.nombre_completo', 'i.dni as dni_cliente', DB::raw("nullif(concat(j.primer_nombre,' ', j.segundo_nombre,' ',j.paterno,' ',j.materno), '   ') as nombre_cajero"), DB::raw("nullif(concat(m.primer_nombre,' ', m.segundo_nombre,' ',m.paterno,' ',m.materno), '   ') as nombre_mozo"))
            ->orderBy('v.nro_venta', 'desc')
            ->get();
        $response = Response::json(['data' => $pedidos], 200);
        return $response;
    }
    public function getPedido($idPedido){
        $pedidos = DB::table('producto_vendidos as p')
                            ->join('venta_productos as v', 'v.id_venta_producto', '=', 'p.id_venta_producto')
                            ->join('productos as pr', 'pr.id_producto', '=', 'p.id_producto')
                            ->where('v.id_venta_producto', '=', $idPedido)
                            ->select('p.*', 'pr.nombre as nombreProducto')
                            ->get();
        $response = Response::json(['data' => $pedidos], 200);
        return $response;
    }
    public function cambiaEstadoAtendido($idVentaProducto){
        $pvendidos = VentaProducto::find($idVentaProducto);
        $pvendidos->estado_atendido = true;
        $pvendidos->save();
        $response = Response::json(['data' => $pvendidos], 200);
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
