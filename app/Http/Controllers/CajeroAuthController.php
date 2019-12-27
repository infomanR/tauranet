<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use Validator;
use DB;

class CajeroAuthController extends Controller
{

    /**
     * Get a JWT via given credentials.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nombre_usuario' => 'required',
            'password'=> 'required'
        ],$messages = [
            'nombre_usuario.required' => 'El nombre de usuario es requerido',
            'password.required' => 'El password es requerido'
        ]);
        if ($validator->fails()) {
            return response()->json(["errors" => $validator->errors()]);
        }
        $credentials = request(['nombre_usuario', 'password']);

        if (! $token = auth('cajero')->attempt($credentials)) {
            return response()->json(['error' => 'Datos incorrectos'], 200);
        }

        return $this->respondWithToken($token);
    }

    /**
     * Get the authenticated User.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function me()
    {
        return response()->json(auth('cajero')->user());
    }

    /**
     * Log the user out (Invalidate the token).
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout()
    {
        auth('cajero')->logout();

        return response()->json(['message' => 'Successfully logged out']);
    }

    /**
     * Refresh a token.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function refresh()
    {
        return $this->respondWithToken(auth('cajero')->refresh());
    }

    /**
     * Get the token array structure.
     *
     * @param  string $token
     *
     * @return \Illuminate\Http\JsonResponse
     */
    protected function respondWithToken($token)
    {
        $idRestaurant = DB::table('cajas as c')
            ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
            ->where('c.id_caja', '=', auth('cajero')->user()->id_caja)
            ->select('s.id_restaurant')
            ->first();
        \Log::info($idRestaurant->id_restaurant);
        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth('cajero')->factory()->getTTL() * 60,
            'type_user' => auth('cajero')->user()->tipo_usuario,
            'id_sucursal' => auth('cajero')->user()->id_sucursal,
            'id_restaurant' => $idRestaurant->id_restaurant,
            'sexo' => auth('cajero')->user()->sexo
        ]);
    }
}
