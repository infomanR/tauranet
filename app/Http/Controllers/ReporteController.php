<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Response;
use DB;
use Validator;

class ReporteController extends ApiController
{
    public function getReportesHoy($idRestaurante){
        $repHoy = DB::table('venta_productos as v')
            ->join('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
            ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
            ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
            ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
            ->where('s.id_restaurant', '=', $idRestaurante)
            ->whereNull('c.deleted_at')
            ->where('h.estado', '=', true)
            ->groupBy('h.id_historial_caja', 's.nombre', 'h.monto_inicial', 'h.monto', 'h.fecha', 'nombreCaja')
            ->select('s.nombre', 'h.monto_inicial', 'h.monto', 'h.fecha', 'h.id_historial_caja', 'c.nombre as nombreCaja',DB::raw('count(p.*)'))
            ->get();
        $response = Response::json(['data' => $repHoy], 200);
        return $response;
    }
    public function detalleVentas($idRestaurante, $fecha_ini, $fecha_fin, $idSucursal, $idPerfil){
        
        if($idSucursal == -1 && $idPerfil == -1){
            $dventas = DB::table('venta_productos as v')
                ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                ->where('s.id_restaurant', '=', $idRestaurante)
                ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                ->orderBy('v.created_at', 'desc')
                ->select('h.fecha', 's.nombre as nombreSucursal', 'v.nro_venta', DB::raw("case when c.nombre_completo isNull then 'GENERAL' else c.nombre_completo end as nombre_completo"), DB::raw("case when j.nombre_usuario isNull then m.nombre_usuario else j.nombre_usuario end"), DB::raw("case when j.nombre_usuario isNull then 'Mozo' else 'Cajero' end as perfil"), DB::raw("concat('00', v.id_venta_producto) as id_venta_producto"), 'v.total', 'p.efectivo', 'p.total_pagar', 'p.cambio', 'v.estado_atendido')
                ->paginate(15);
            //Totales
            $totales = DB::table('venta_productos as v')
                ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                ->where('s.id_restaurant', '=', $idRestaurante)
                ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                ->select(DB::raw('sum(v.total) as Total'), DB::raw('sum(p.efectivo) as Efectivo'), DB::raw('sum(p.total_pagar) as TotalPagar'), DB::raw('sum(p.cambio) as Cambio'))
                ->get();
            $response = Response::json(['data' => $dventas, 'totales' => $totales], 200);
            return $response;
        }
        if($idSucursal == -1 && $idPerfil != -1){
            if($idPerfil == 0){//Mozo
                $dventas = DB::table('venta_productos as v')
                    ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                    ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                    ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                    ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                    ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                    ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                    ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                    ->where('s.id_restaurant', '=', $idRestaurante)
                    ->whereNull('v.id_cajero')
                    ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                    ->orderBy('v.created_at', 'desc')
                    ->select('h.fecha', 's.nombre as nombreSucursal', 'v.nro_venta', DB::raw("case when c.nombre_completo isNull then 'GENERAL' else c.nombre_completo end as nombre_completo"), DB::raw("case when j.nombre_usuario isNull then m.nombre_usuario else j.nombre_usuario end"), DB::raw("case when j.nombre_usuario isNull then 'Mozo' else 'Cajero' end as perfil"), DB::raw("concat('00', v.id_venta_producto) as id_venta_producto"), 'v.total', 'p.efectivo', 'p.total_pagar', 'p.cambio', 'v.estado_atendido')
                    ->paginate(15);
                //Totales
                $totales = DB::table('venta_productos as v')
                    ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                    ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                    ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                    ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                    ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                    ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                    ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                    ->where('s.id_restaurant', '=', $idRestaurante)
                    ->whereNull('v.id_cajero')
                    ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                    ->select(DB::raw('sum(v.total) as Total'), DB::raw('sum(p.efectivo) as Efectivo'), DB::raw('sum(p.total_pagar) as TotalPagar'), DB::raw('sum(p.cambio) as Cambio'))
                    ->get();
                $response = Response::json(['data' => $dventas, 'totales' => $totales], 200);
                return $response;
            }else if($idPerfil == 1){//Cajero
                $dventas = DB::table('venta_productos as v')
                    ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                    ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                    ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                    ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                    ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                    ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                    ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                    ->where('s.id_restaurant', '=', $idRestaurante)
                    ->whereNull('v.id_mozo')
                    ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                    ->orderBy('v.created_at', 'desc')
                    ->select('h.fecha', 's.nombre as nombreSucursal', 'v.nro_venta', DB::raw("case when c.nombre_completo isNull then 'GENERAL' else c.nombre_completo end as nombre_completo"), DB::raw("case when j.nombre_usuario isNull then m.nombre_usuario else j.nombre_usuario end"), DB::raw("case when j.nombre_usuario isNull then 'Mozo' else 'Cajero' end as perfil"), DB::raw("concat('00', v.id_venta_producto) as id_venta_producto"), 'v.total', 'p.efectivo', 'p.total_pagar', 'p.cambio', 'v.estado_atendido')
                    ->paginate(15);
                //Totales
                $totales = DB::table('venta_productos as v')
                    ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                    ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                    ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                    ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                    ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                    ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                    ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                    ->where('s.id_restaurant', '=', $idRestaurante)
                    ->whereNull('v.id_mozo')
                    ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                    ->select(DB::raw('sum(v.total) as Total'), DB::raw('sum(p.efectivo) as Efectivo'), DB::raw('sum(p.total_pagar) as TotalPagar'), DB::raw('sum(p.cambio) as Cambio'))
                    ->get();
                $response = Response::json(['data' => $dventas, 'totales' => $totales], 200);
                return $response;
            }
        }
        if($idSucursal != -1 && $idPerfil == -1){
            $dventas = DB::table('venta_productos as v')
                ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                ->where('s.id_restaurant', '=', $idRestaurante)
                ->where('v.id_sucursal', '=', $idSucursal)
                ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                ->orderBy('v.created_at', 'desc')
                ->select('h.fecha', 's.nombre as nombreSucursal', 'v.nro_venta', DB::raw("case when c.nombre_completo isNull then 'GENERAL' else c.nombre_completo end as nombre_completo"), DB::raw("case when j.nombre_usuario isNull then m.nombre_usuario else j.nombre_usuario end"), DB::raw("case when j.nombre_usuario isNull then 'Mozo' else 'Cajero' end as perfil"), DB::raw("concat('00', v.id_venta_producto) as id_venta_producto"), 'v.total', 'p.efectivo', 'p.total_pagar', 'p.cambio', 'v.estado_atendido')
                ->paginate(15);
            //Totales
             $totales = DB::table('venta_productos as v')
                ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                ->where('s.id_restaurant', '=', $idRestaurante)
                ->where('v.id_sucursal', '=', $idSucursal)
                ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                ->select(DB::raw('sum(v.total) as Total'), DB::raw('sum(p.efectivo) as Efectivo'), DB::raw('sum(p.total_pagar) as TotalPagar'), DB::raw('sum(p.cambio) as Cambio'))
                ->get();
            $response = Response::json(['data' => $dventas, 'totales' => $totales], 200);
            return $response;
        }
        if($idSucursal != -1 && $idPerfil != -1){
             if($idPerfil == 0){//Mozo
                 $dventas = DB::table('venta_productos as v')
                    ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                    ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                    ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                    ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                    ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                    ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                    ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                    ->where('s.id_restaurant', '=', $idRestaurante)
                    ->where('v.id_sucursal', '=', $idSucursal)
                    ->whereNull('v.id_cajero')
                    ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                    ->orderBy('v.created_at', 'desc')
                    ->select('h.fecha', 's.nombre as nombreSucursal', 'v.nro_venta', DB::raw("case when c.nombre_completo isNull then 'GENERAL' else c.nombre_completo end as nombre_completo"), DB::raw("case when j.nombre_usuario isNull then m.nombre_usuario else j.nombre_usuario end"), DB::raw("case when j.nombre_usuario isNull then 'Mozo' else 'Cajero' end as perfil"), DB::raw("concat('00', v.id_venta_producto) as id_venta_producto"), 'v.total', 'p.efectivo', 'p.total_pagar', 'p.cambio', 'v.estado_atendido')
                    ->paginate(15);
                 //Totales
                 $totales = DB::table('venta_productos as v')
                    ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                    ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                    ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                    ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                    ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                    ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                    ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                    ->where('s.id_restaurant', '=', $idRestaurante)
                    ->where('v.id_sucursal', '=', $idSucursal)
                    ->whereNull('v.id_cajero')
                    ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                    ->select(DB::raw('sum(v.total) as Total'), DB::raw('sum(p.efectivo) as Efectivo'), DB::raw('sum(p.total_pagar) as TotalPagar'), DB::raw('sum(p.cambio) as Cambio'))
                    ->get();
                    $response = Response::json(['data' => $dventas, 'totales' => $totales], 200);
                    return $response;
            }else if($idPerfil == 1){//Cajero
                $dventas = DB::table('venta_productos as v')
                    ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                    ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                    ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                    ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                    ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                    ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                    ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                    ->where('s.id_restaurant', '=', $idRestaurante)
                    ->where('v.id_sucursal', '=', $idSucursal)
                    ->whereNull('v.id_mozo')
                    ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                    ->orderBy('v.created_at', 'desc')
                    ->select('h.fecha', 's.nombre as nombreSucursal', 'v.nro_venta', DB::raw("case when c.nombre_completo isNull then 'GENERAL' else c.nombre_completo end as nombre_completo"), DB::raw("case when j.nombre_usuario isNull then m.nombre_usuario else j.nombre_usuario end"), DB::raw("case when j.nombre_usuario isNull then 'Mozo' else 'Cajero' end as perfil"), DB::raw("concat('00', v.id_venta_producto) as id_venta_producto"), 'v.total', 'p.efectivo', 'p.total_pagar', 'p.cambio', 'v.estado_atendido')
                    ->paginate(15);
                //Totales
                $totales = DB::table('venta_productos as v')
                    ->leftJoin('clientes as c', 'c.id_cliente', '=', 'v.id_cliente')
                    ->leftJoin('cajeros as j', 'j.id_cajero', '=', 'v.id_cajero')
                    ->leftJoin('mozos as m', 'm.id_mozo', '=', 'v.id_mozo')
                    ->leftJoin('pagos as p', 'p.id_venta_producto', '=', 'v.id_venta_producto')
                    ->join('historial_caja as h', 'h.id_historial_caja', '=', 'v.id_historial_caja')
                    ->join('cajas as a', 'a.id_caja', '=', 'h.id_caja')
                    ->join('sucursals as s', 's.id_sucursal', '=', 'a.id_sucursal')
                    ->where('s.id_restaurant', '=', $idRestaurante)
                    ->where('v.id_sucursal', '=', $idSucursal)
                    ->whereNull('v.id_mozo')
                    ->whereBetween('h.fecha', [$fecha_ini, $fecha_fin])
                    ->select(DB::raw('sum(v.total) as Total'), DB::raw('sum(p.efectivo) as Efectivo'), DB::raw('sum(p.total_pagar) as TotalPagar'), DB::raw('sum(p.cambio) as Cambio'))
                    ->get();
                $response = Response::json(['data' => $dventas, 'totales' => $totales], 200);
                return $response;
            }
        }
    }
    public function empleadoPedido($idRestaurante, $fechaIni, $fechaFin){
        if($fechaIni == 'null'){
            $response = Response::json(['error' => ['ini' => ['Fecha ini es requerido']]], 200);
            return $response;
        }
        if($fechaFin == 'null'){
            $response = Response::json(['error' => ['fin' => ['Fecha fin es requerido']]], 200);
            return $response;
        }
        if($fechaIni <= $fechaFin){
            //Chart
            $empleadoPedido = DB::table(DB::raw("function_empleado_pedido(".$idRestaurante.",'".$fechaIni."', '".$fechaFin."')"))->get();
            //Table
            $empleadoPedidoTable = DB::table(DB::raw("function_empleado_pedido(".$idRestaurante.", '".$fechaIni."', '".$fechaFin."')"))->paginate(6);
            $response = Response::json(['data' => $empleadoPedido, 'dataT' => $empleadoPedidoTable], 200);
            return $response;
        }else{
            $response = Response::json(['error' => ['ini' => ['Fecha ini debe ser menor que Fecha fin']]], 200);
            return $response;
        }
    }
    public function productoCantidad($idRestaurante, $idCategoria,$fechaIni, $fechaFin){
        if($fechaIni == 'null'){
            $response = Response::json(['error' => ['ini' => ['Fecha ini es requerido']]], 200);
            return $response;
        }
        if($fechaFin == 'null'){
            $response = Response::json(['error' => ['fin' => ['Fecha fin es requerido']]], 200);
            return $response;
        }
        if($fechaIni <= $fechaFin) {
            //Chart
            $productoCantidad = DB::table(DB::raw("function_producto_cantidad(" . $idRestaurante . ", " . $idCategoria . ",'" . $fechaIni . "', '" . $fechaFin . "')"))->get();
            //Table
            $productoCantidadTable = DB::table(DB::raw("function_producto_cantidad(" . $idRestaurante . ", " . $idCategoria . ", '" . $fechaIni . "', '" . $fechaFin . "')"))->paginate(6);
            $response = Response::json(['data' => $productoCantidad, 'dataT' => $productoCantidadTable], 200);
            return $response;
        }else{
            $response = Response::json(['error' => ['ini' => ['Fecha ini debe ser menor que Fecha fin']]], 200);
            return $response;
        }
    }
    public function productoImporte($idRestaurante, $idCategoria, $fechaIni, $fechaFin){
        if($fechaIni == 'null'){
            $response = Response::json(['error' => ['ini' => ['Fecha ini es requerido']]], 200);
            return $response;
        }
        if($fechaFin == 'null'){
            $response = Response::json(['error' => ['fin' => ['Fecha fin es requerido']]], 200);
            return $response;
        }
        if($fechaIni <= $fechaFin) {
            //Chart
            $productoImporte = DB::table(DB::raw("function_producto_importe(" . $idRestaurante . ", " . $idCategoria . ",'" . $fechaIni . "', '" . $fechaFin . "')"))->get();
            //Table
            $productoImporteTable = DB::table(DB::raw("function_producto_importe(" . $idRestaurante . ", " . $idCategoria . ", '" . $fechaIni . "', '" . $fechaFin . "')"))->paginate(6);
            $response = Response::json(['data' => $productoImporte, 'dataT' => $productoImporteTable], 200);
            return $response;
        }else{
            $response = Response::json(['error' => ['ini' => ['Fecha ini debe ser menor que Fecha fin']]], 200);
            return $response;
        }
    }
    public function fechaPedidos($idRestaurante, $fechaIni, $fechaFin){
        if($fechaIni == 'null'){
            $response = Response::json(['error' => ['ini' => ['Fecha ini es requerido']]], 200);
            return $response;
        }
        if($fechaFin == 'null'){
            $response = Response::json(['error' => ['fin' => ['Fecha fin es requerido']]], 200);
            return $response;
        }
        if($fechaIni <= $fechaFin) {
            //Chart
            $fechaPedido = DB::table(DB::raw("function_fecha_pedidos(" . $idRestaurante . ",'" . $fechaIni . "', '" . $fechaFin . "')"))->get();
            //Table
            $fechaPedidoTable = DB::table(DB::raw("function_fecha_pedidos(" . $idRestaurante . ", '" . $fechaIni . "', '" . $fechaFin . "')"))->paginate(6);
            $response = Response::json(['data' => $fechaPedido, 'dataT' => $fechaPedidoTable], 200);
            return $response;
        }else{
            $response = Response::json(['error' => ['ini' => ['Fecha ini debe ser menor que Fecha fin']]], 200);
            return $response;
        }
    }
    public function fechaImporte($idRestaurante, $fechaIni, $fechaFin){
        if($fechaIni == 'null'){
            $response = Response::json(['error' => ['ini' => ['Fecha ini es requerido']]], 200);
            return $response;
        }
        if($fechaFin == 'null'){
            $response = Response::json(['error' => ['fin' => ['Fecha fin es requerido']]], 200);
            return $response;
        }
        if($fechaIni <= $fechaFin) {
            //Chart
            $fechaImporte = DB::table(DB::raw("function_fecha_importe(" . $idRestaurante . ",'" . $fechaIni . "', '" . $fechaFin . "')"))->get();
            //Table
            $fechaImporteTable = DB::table(DB::raw("function_fecha_importe(" . $idRestaurante . ", '" . $fechaIni . "', '" . $fechaFin . "')"))->paginate(6);
            $response = Response::json(['data' => $fechaImporte, 'dataT' => $fechaImporteTable], 200);
            return $response;
        }else{
            $response = Response::json(['error' => ['ini' => ['Fecha ini debe ser menor que Fecha fin']]], 200);
            return $response;
        }
    }
    public function aperturaCajas($idRestaurante, $idSucursal){
        if($idSucursal == -1){
            $aperturaCajas = DB::table('historial_caja as h')
                ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
                ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
                ->where('s.id_restaurant', '=', $idRestaurante)
                ->orderBy('h.fecha', 'desc')
                ->select('s.nombre as nombreSucursal', 'c.nombre as nombreCaja', 'h.fecha', 'h.monto_inicial', 'h.monto')
                ->paginate(10);
            $response = Response::json(['data' => $aperturaCajas], 200);
            return $response;
        }else{
            $aperturaCajas = DB::table('historial_caja as h')
                ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
                ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
                ->where('s.id_restaurant', '=', $idRestaurante)
                ->where('s.id_sucursal', '=', $idSucursal)
                ->orderBy('h.fecha', 'desc')
                ->select('s.nombre as nombreSucursal', 'c.nombre as nombreCaja', 'h.fecha', 'h.monto_inicial', 'h.monto')
                ->paginate(10);
            $response = Response::json(['data' => $aperturaCajas], 200);
            return $response;
        }

    }
}
