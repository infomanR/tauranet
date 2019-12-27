<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use DB;
use Illuminate\Support\Facades\Response;
use App\Cliente;
use App\VentaProducto;
use Validator;
use App\Pago;
use App\Rules\UniqueCliente;
use Illuminate\Validation\Rule;

class ClienteController extends ApiController
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index($idSucursal, $dni)
    {
        $response = null;
        if($dni == -1){
            $listaClientes = DB::table('clientes as cl')
                ->join('restaurants as r', 'r.id_restaurant', '=', 'cl.id_restaurant')
                ->join('sucursals as s', 's.id_restaurant', '=', 'r.id_restaurant')
                ->where('s.id_sucursal', '=', $idSucursal)
                ->select('cl.*')
                ->orderBy('cl.nombre_completo', 'asc')
                ->get();
        }else{
            $listaClientes = DB::table('clientes as cl')
                ->join('restaurants as r', 'r.id_restaurant', '=', 'cl.id_restaurant')
                ->join('sucursals as s', 's.id_restaurant', '=', 'r.id_restaurant')
                ->where('s.id_sucursal', '=', $idSucursal)
                ->where('cl.dni', 'like', '%'.$dni.'%')
                ->select('cl.*')
                ->orderBy('cl.nombre_completo', 'asc')
                ->get();
        }
        $response = Response::json(['data' => $listaClientes], 200);
        return $response;
    }
    
    public function getClientesByRestaurant($idRestaurant){
        $listaClientes = DB::table('clientes as cl')
            ->where('cl.id_restaurant', '=', $idRestaurant)
            ->select('cl.*')
            ->orderBy('cl.nombre_completo', 'asc')
            ->get();
        $response = Response::json(['data' => $listaClientes], 200);
        return $response;
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {

    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $clienteIsNull = !($request->has('nombre_completo')&&$request->has('dni'));
        if($request->id_caja != -1) {
            $hcaja = DB::table('historial_caja as h')
                ->where("h.id_caja", "=", $request->id_caja)
                ->where("h.estado", "=", "true")->get();
            if (sizeof($hcaja) > 0) {
                $validacionArray = [];
                if ($request->ant_cliente) {//antiguo cliente
                    \Log::info('Cliente antiguo 1');
                    $validacionArray = [
                        'id_cajero' => 'required_without_all:id_mozo',
                        'id_mozo' => 'required_without_all:id_cajero',
                        'id_sucursal' => 'required|exists:sucursals,id_sucursal',
                        'total' => 'required',
                        'sub_total' => 'required',
                        'descuento' => 'required',
                        'estado_venta' => 'required',
                        'listaProductos' => 'required'
                    ];
                } else {
                    \Log::info('Cliente nuevo 1');
                    $validacionArray = [
                        //Datos del cliente nuevo
                        'nombre_completo' => 'min:4|max:100|nullable',
                        'dni' => new UniqueCliente($request->id_restaurant),
                        //*************************************************************
                        'id_cajero' => 'required_without_all:id_mozo',
                        'id_mozo' => 'required_without_all:id_cajero',
                        'id_sucursal' => 'required|exists:sucursals,id_sucursal',
                        'total' => 'required|numeric|between:0,9999999.99',
                        'sub_total' => 'required|numeric|between:0,9999999.99',
                        'descuento' => 'required|numeric|between:0,100',
                        'estado_venta' => 'required',
                        'listaProductos' => 'required'
                    ];
                }
                $validator = Validator::make($request->all(), $validacionArray,
                    $messages = [
                        'nombre_completo.required' => 'El Nombre es requerido',
                        'nombre_completo.min' => 'El Nombre tiene que tener 4 caracteres como mínimo',
                        'nombre_completo.max' => 'El Nombre tiene que tener 100 caracteres como maximo',
                        'dni.required' => 'El dni es requerido',
                        'dni.min' => 'El dni tiene que tener 4 caracteres como mínimo',
                        'dni.max' => 'El dni tiene que tener 50 caracteres como maximo',
                        'dni.unique' => 'El dni ya existe',
                        'dni.numeric' => 'El dni debe ser de tipo númerico',
                        'id_cajero.required_without_all' => 'El cajero o mozo es requerido',
                        'id_cajero.exists' => 'El cajero no existe',
                        'id_mozo.required_without_all' => 'El cajero o mozo es requerido',
                        'id_mozo.exists' => 'El mozo no existe',
                        'id_sucursal.required' => 'La sucursal es requerido',
                        'id_sucursal.exists' => 'La sucursal no existe',
                        'listaProductos.required' => 'La lista de productos es requerida'
                    ]);
                $validator->sometimes('id_cajero', 'exists:cajeros,id_cajero', function ($input) {
                    return !empty($input->id_cajero);
                });
                $validator->sometimes('id_mozo', 'exists:mozos,id_mozo', function ($input) {
                    return !empty($input->id_mozo);
                });
                $validator->sometimes('dni', 'numeric|min:999|nullable', function ($input) {
                    return !empty($input->dni);
                });

                if ($validator->fails()) {
                    return response()->json(["error" => $validator->errors()], 201);
                }
                if (!$request->ant_cliente && !$clienteIsNull) {
                    //\Log::info('Cliente nuevo 2');
                    //Almacena datos del cliente
//                    $idRestaurant = DB::table('sucursals')
//                        ->where('id_sucursal', '=', $request->id_sucursal)
//                        ->select('id_restaurant')
//                        ->first();
                    //$data= json_decode( json_encode($idRestaurant), true);
                    $cliente = new Cliente();
                    $cliente->nombre_completo = $request->get("nombre_completo");
                    $cliente->dni = $request->get("dni");
                    $cliente->id_restaurant = $request->id_restaurant;
                    if ($request->has('id_cajero')) {
                        $cliente->id_cajero = $request->get("id_cajero");
                    }
                    if ($request->has('id_mozo')) {
                        $cliente->id_mozo = $request->get("id_mozo");
                    }
                    $cliente->save();
                }
                $vproducto = new VentaProducto();
                $vproducto->total = $request->get("total");
                $vproducto->sub_total = $request->get("sub_total");
                $vproducto->descuento = $request->get("descuento");
                $vproducto->estado_venta = $request->get("estado_venta");
                $vproducto->estado_atendido = false;
                $vproducto->id_historial_caja = $hcaja[0]->id_historial_caja;
                if(!$clienteIsNull){
                    if (!$request->ant_cliente) {
                        //\Log::info('Cliente nuevo 3');
                        $vproducto->id_cliente = $cliente->id_cliente;
                    }else {
                        //\Log::info('Cliente antiguo 3');
                        $vproducto->id_cliente = $request->get("id_cliente");
                    }
                }
                $vproducto->id_sucursal = $request->get("id_sucursal");
                if ($request->has('id_cajero')) {
                    $vproducto->id_cajero = $request->get("id_cajero");
                }
                if ($request->has('id_mozo')) {
                    $vproducto->id_mozo = $request->get("id_mozo");
                }
                $vproducto->save();
                $listaProd = DB::table(DB::raw("registraProductosFunction('" . $request->listaProductos . "', " . $vproducto->id_venta_producto . ")"))->get();
                $nro_pedido = DB::table('venta_productos')->where('id_historial_caja', '=', $hcaja[0]->id_historial_caja)->where('id_venta_producto', '<=', $vproducto->id_venta_producto)->count();
                $ult_vproducto = VentaProducto::find($vproducto->id_venta_producto);
                $ult_vproducto->nro_venta = $nro_pedido;
                $ult_vproducto->save();
                return response()->json(['data' => $listaProd, 'vprod' => $vproducto, 'nro_pedido' => $nro_pedido], 201);
            } else {
                return $this->errorResponse(['apertura_caja' => 'La caja aún no fue aperturada'], 201);
            }
        }else{
            \Log::info("no se selecciono ninguna caja");
            return $this->errorResponse(['apertura_caja' => 'No se selecciono ninguna caja'], 201);
        }
    }


    public function storePago(Request $request)
    {
        $clienteIsNull = !($request->has('nombre_completo')&&$request->has('dni'));
        $hcaja = DB::table('historial_caja as h')
            ->where("h.id_caja", "=", $request->id_caja)
            ->where("h.estado", "=","true")->get();
        if(sizeof($hcaja)>0) {
            $validacionArray = [];
            if ($request->ant_cliente) {//antiguo cliente
                \Log::info('Cliente antiguo 1');
                $validacionArray = [
                    'id_cajero' => 'required_without_all:id_mozo',
                    'id_mozo' => 'required_without_all:id_cajero',
                    'id_sucursal' => 'required|exists:sucursals,id_sucursal',
                    'total' => 'required',
                    'sub_total' => 'required',
                    'descuento' => 'required',
                    'estado_venta' => 'required',
                    'listaProductos' => 'required',
                    'efectivo' => 'required|numeric|between:0,99999999.99',
                    'total_pagar' => 'required|numeric|between:0,99999999.99',
                    'mastercard' => 'required|numeric|between:0,99999999.99',
                    'cambio' => 'required|numeric|between:0,99999999.99',
                    'visa' => 'required|numeric|between:0,99999999.99',
                ];
            } else {
                \Log::info('Cliente nuevo 1');
                $validacionArray = [
                    'nombre_completo' => 'min:4|max:100|nullable',
                    'dni' => new UniqueCliente($request->id_restaurant),
                    'id_cajero' => 'required_without_all:id_mozo',
                    'id_mozo' => 'required_without_all:id_cajero',
                    'id_sucursal' => 'required|exists:sucursals,id_sucursal',
                    'total' => 'required|numeric|between:0,9999999.99',
                    'sub_total' => 'required|numeric|between:0,9999999.99',
                    'descuento' => 'required|numeric|between:0,100',
                    'estado_venta' => 'required',
                    'listaProductos' => 'required',
                    'efectivo' => 'required|numeric|between:0,99999999.99',
                    'total_pagar' => 'required|numeric|between:0,99999999.99',
                    'mastercard' => 'required|numeric|between:0,99999999.99',
                    'cambio' => 'required|numeric|between:0,99999999.99',
                    'visa' => 'required|numeric|between:0,99999999.99',

                ];
            }
            $validator = Validator::make($request->all(), $validacionArray,
            $messages = [
                'nombre_completo.required' => 'El Nombre es requerido',
                'nombre_completo.min' => 'El Nombre tiene que tener 4 caracteres como mínimo',
                'nombre_completo.max' => 'El Nombre tiene que tener 50 caracteres como maximo',
                'dni.required' => 'El dni es requerido',
                'dni.min' => 'El dni tiene que tener 4 caracteres como mínimo',
                'dni.max' => 'El dni tiene que tener 100 caracteres como maximo',
                'dni.unique' => 'El dni ya existe',
                'dni.numeric' => 'El dni debe ser de tipo númerico',
                'id_cajero.required_without_all' => 'El cajero o mozo es requerido',
                'id_cajero.exists' => 'El cajero no existe',
                'id_mozo.required_without_all' => 'El cajero o mozo es requerido',
                'id_mozo.exists' => 'El mozo no existe',
                'id_sucursal.required' => 'La sucursal es requerido',
                'id_sucursal.exists' => 'La sucursal no existe',
                'listaProductos.required' => 'La lista de productos es requerida',

                'efectivo.required' => 'El efectivo es requerido',
                'efectivo.numeric' => 'El efectivo tiene que ser de tipo numérico',
                'efectivo.between' => 'El efectivo tiene que estar entre 0 y 999999999,99',
                'total_pagar.required' => 'El total a pagar es requerido',
                'total_pagar.numeric' => 'El total a pagar tiene que ser de tipo numérico',
                'total_pagar.between' => 'El total a pagar tiene que estar entre 0 y 999999999,99',
                'visa.required' => 'Visa es requerida',
                'visa.numeric' => 'Visa tiene que ser de tipo numérico',
                'visa.between' => 'Visa tiene que estar entre 0 y 999999999,99',
                'mastercard.required' => 'Mastercard es requerida',
                'mastercard.numeric' => 'Mastercard tiene que ser de tipo numérico',
                'mastercard.between' => 'Mastercard tiene que estar entre 0 y 999999999,99',
                'cambio.required' => 'El cambio es requerida',
                'cambio.numeric' => 'El cambio tiene que ser de tipo numérico',
                'cambio.between' => 'El cambio tiene que estar entre 0 y 999999999,99'
            ]);
            $validator->sometimes('id_cajero', 'exists:cajeros,id_cajero', function ($input) {
                return !empty($input->id_cajero);
            });
            $validator->sometimes('id_mozo', 'exists:mozos,id_mozo', function ($input) {
                return !empty($input->id_mozo);
            });
            $validator->sometimes('dni', 'numeric|min:999|nullable', function ($input) {
                return !empty($input->dni);
            });

            if ($validator->fails()) {
                return response()->json(["error" => $validator->errors()], 201);
            }
            if($request->efectivo >= $request->total) {
                if($request->total_pagar >= $request->total) {
                    if (!$request->ant_cliente && !$clienteIsNull) {
                        //Almacena datos del cliente
                        $idRestaurant = DB::table('sucursals')
                            ->where('id_sucursal', '=', $request->id_sucursal)
                            ->select('id_restaurant')
                            ->first();
                        //$data= json_decode( json_encode($idRestaurant), true);
                        $cliente = new Cliente();
                        $cliente->nombre_completo = $request->get("nombre_completo");
                        $cliente->dni = $request->get("dni");
                        $cliente->id_restaurant = $idRestaurant->id_restaurant;
                        if ($request->has('id_cajero')) {
                            $cliente->id_cajero = $request->get("id_cajero");
                        }
                        if ($request->has('id_mozo')) {
                            $cliente->id_mozo = $request->get("id_mozo");
                        }
                        $cliente->save();
                    }

                    $vproducto = new VentaProducto();
                    $vproducto->total = $request->get("total");
                    $vproducto->sub_total = $request->get("sub_total");
                    $vproducto->descuento = $request->get("descuento");
                    $vproducto->estado_venta = $request->get("estado_venta");
                    $vproducto->id_historial_caja = $hcaja[0]->id_historial_caja;
                    $vproducto->estado_atendido = false;
                    if(!$clienteIsNull) {
                        if (!$request->ant_cliente) {
                            //\Log::info('Cliente nuevo 3');
                            $vproducto->id_cliente = $cliente->id_cliente;
                        } else {
                            //\Log::info('Cliente antiguo 3');
                            $vproducto->id_cliente = $request->get("id_cliente");
                        }
                    }
                    $vproducto->id_sucursal = $request->get("id_sucursal");
                    if ($request->has('id_cajero')) {
                        $vproducto->id_cajero = $request->get("id_cajero");
                    }
                    if ($request->has('id_mozo')) {
                        $vproducto->id_mozo = $request->get("id_mozo");
                    }
                    $vproducto->save();
                    $pago = new Pago();
                    $pago->efectivo = $request->get("efectivo");
                    $pago->total = $request->get("total");
                    $pago->total_pagar = $request->get("total_pagar");
                    $pago->visa = $request->get("visa");
                    $pago->mastercard = $request->get("mastercard");
                    $pago->cambio = $request->get("cambio");
                    $pago->id_venta_producto = $vproducto->id_venta_producto;
                    $pago->id_cajero = $request->get("id_cajero");
                    $pago->save();
                    //Ssaca el nro de pedido
                    $listaProd = DB::table(DB::raw("registraProductosFunction('" . $request->listaProductos . "', " . $vproducto->id_venta_producto . ")"))->get();
                    $nro_pedido = DB::table('venta_productos')->where('id_historial_caja', '=', $hcaja[0]->id_historial_caja)->where('id_venta_producto', '<=', $vproducto->id_venta_producto)->count();
                    $ult_vproducto = VentaProducto::find($vproducto->id_venta_producto);
                    $ult_vproducto->nro_venta = $nro_pedido;
                    $ult_vproducto->save();
                    return response()->json(['data' => $listaProd, 'vprod' => $vproducto, 'nro_pedido' => $nro_pedido], 201);
                }else{
                    return $this->errorResponse(['total_pagar_mayor' => 'El total a pagar tiene que ser mayor o igual al total'], 201);
                }
            }else{
                return $this->errorResponse(['efectivo_mayor' => 'El efectivo tiene que ser mayor o igual al total'], 201);
            }
        }else{
            return $this->errorResponse(['apertura_caja' => 'La caja aún no fue aperturada'], 201);
        }
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
