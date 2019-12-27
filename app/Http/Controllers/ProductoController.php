<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Response;
use DB;
use App\Producto;
use Validator;
use File;

class ProductoController extends ApiController
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index($pag, $idRestaurante, $idCategoria)
    {
        if($idCategoria == -1){
            $producto = DB::table('productos as p')
                ->join('categoria_productos as c', 'c.id_categoria_producto', '=', 'p.id_categoria_producto')
                ->where('c.id_restaurant', '=', $idRestaurante)
                ->whereNull('p.deleted_at')
                ->orderBy('p.created_at', 'desc')
                ->select('p.*', 'c.nombre as categoriaProducto')
                ->paginate($pag);
            $response = Response::json(['data' => $producto], 200);
            return $response;
        }else if($idCategoria != -1){
            $producto = DB::table('productos as p')
                ->join('categoria_productos as c', 'c.id_categoria_producto', '=', 'p.id_categoria_producto')
                ->where('c.id_restaurant', '=', $idRestaurante)
                ->where('p.id_categoria_producto', '=', $idCategoria)
                ->whereNull('p.deleted_at')
                ->orderBy('p.created_at', 'desc')
                ->select('p.*', 'c.nombre as categoriaProducto')
                ->paginate($pag);
            $response = Response::json(['data' => $producto], 200);
            return $response;
        }

    }

    public function listaProductos($idSucursal, $idCategoria){
        $producto = null;
        if($idCategoria == -1){//Todas las categorias
            $producto = DB::table('productos as p')
                ->join('categoria_productos as c', 'c.id_categoria_producto', '=', 'p.id_categoria_producto')
                ->join('restaurants as r', 'r.id_restaurant', '=', 'c.id_restaurant')
                ->join('sucursals as s', 's.id_restaurant', '=', 'r.id_restaurant')
                ->where('s.id_sucursal', '=', $idSucursal)
                ->whereNull('p.deleted_at')
                ->select('p.*')
                ->orderBy('p.nombre', 'asc')
                ->get();
        }else{
            $producto = DB::table('productos as p')
                ->join('categoria_productos as c', 'c.id_categoria_producto', '=', 'p.id_categoria_producto')
                ->join('restaurants as r', 'r.id_restaurant', '=', 'c.id_restaurant')
                ->join('sucursals as s', 's.id_restaurant', '=', 'r.id_restaurant')
                ->where('s.id_sucursal', '=', $idSucursal)
                ->where('c.id_categoria_producto', '=', $idCategoria)
                ->whereNull('p.deleted_at')
                ->select('p.*')
                ->orderBy('p.nombre', 'asc')
                ->get();
        }
        $response = Response::json(['data' => $producto], 200);
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
        $validator = Validator::make($request->all(), [
            'nombre' => 'required|min:4|max:50',
            'precio' => 'required|numeric|between:0,9999999.99',
            'id_categoria_producto' => 'required|not_in:-1|exists:categoria_productos,id_categoria_producto',
            'id_administrador' => 'required|exists:administradors,id_administrador',
        ],
        $messages = [
            'nombre.required' => 'El Nombre es requerido',
            'nombre.min' => 'El Nombre tiene que tener 4 caracteres como mínimo',
            'nombre.max' => 'El Nombre tiene que tener 50 caracteres como maximo',
            'precio.required' => 'El precio es requerido',
            'precio.numeric' => 'El precio tiene que ser de tipo numérico',
            'precio.between' => 'El precio tiene que estar entre 0 y 99999999.99',
            'id_administrador.required' => 'El Administrador es requerido',
            'id_administrador.exists' => 'El Administrador no existe',
            'id_categoria_producto.required' => 'La Categoria es requerida',
            'id_categoria_producto.not_in' => 'La Categoria es requerida',
            'id_categoria_producto.exists' => 'La Categoria no existe',
            ]);
        if ($validator->fails()) {
            return response()->json(["error" => $validator->errors()], 201);
        }
        $producto = new Producto();
        $producto->nombre = $request->get("nombre");
        $producto->descripcion = $request->get("descripcion");
        $producto->precio = $request->get("precio");
        $producto->id_administrador = $request->get("id_administrador");
        $producto->id_categoria_producto = $request->get("id_categoria_producto");
        if($request->hasFile('image')){
            $producto->producto_image = $request->image->store('', 'imagesProductos');
        }
        $producto->save();
        return response()->json(['data' => $producto], 201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        $producto = Producto::find($id);
        return response()->json(['data' => $producto], 201);
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
        \Log::info($request);
        $producto = Producto::find($id);
        $validator = Validator::make($request->all(), [
            'nombre' => 'required|min:4|max:50',
            'precio' => 'required|numeric|between:0,9999999.99',
            'id_categoria_producto' => 'required|not_in:-1|exists:categoria_productos,id_categoria_producto',
            'id_administrador' => 'required|exists:administradors,id_administrador',
        ],
        $messages = [
            'nombre.required' => 'El Nombre es requerido',
            'nombre.min' => 'El Nombre tiene que tener 4 caracteres como mínimo',
            'nombre.max' => 'El Nombre tiene que tener 50 caracteres como maximo',
            'precio.required' => 'El precio es requerido',
            'precio.numeric' => 'El precio tiene que ser de tipo numérico',
            'precio.between' => 'El precio tiene que estar entre 0 y 99999999.99',
            'id_administrador.required' => 'El Administrador es requerido',
            'id_administrador.exists' => 'El Administrador no existe',
            'id_categoria_producto.required' => 'La Categoria es requerida',
            'id_categoria_producto.not_in' => 'La Categoria es requerida',
            'id_categoria_producto.exists' => 'La Categoria no existe',
        ]);
        if ($validator->fails()) {
            return response()->json(["error" => $validator->errors()], 201);
        }
        if($request->has('nombre')) {
            $producto->nombre = $request->get("nombre");
        }
        if($request->has('descripcion') && $request->descripcion != 'null') {
            \Log::info($request->descripcion);
            $producto->descripcion = $request->get("descripcion");
        }
        if($request->has('precio')) {
            $producto->precio = $request->get("precio");
        }
        if($request->has('id_administrador')) {
            $producto->id_administrador = $request->get("id_administrador");
        }
        if($request->has('id_categoria_producto')) {
            $producto->id_categoria_producto = $request->get("id_categoria_producto");
        }
        if($request->hasFile('image')){
            $producto->producto_image = $request->image->store('', 'imagesProductos');
        }
        if(!$producto->isDirty()){
            return $this->errorResponse(['valores' => 'Se debe modificar al menos un valor para poder actualizar'], 201);
        }
        $producto->save();
        return response()->json(['data' => $producto], 201);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $producto = Producto::find($id)->delete();
        return response()->json(['data' => $producto], 201);
    }
    public function destroyImage($id){
        $producto = Producto::findOrFail($id);
        File::delete('imgProductos/'.$producto->producto_image);
        $producto->producto_image = null;
        $producto->save();
        $response = Response::json(['data' => $producto], 200);
        return $response;
    }
}
