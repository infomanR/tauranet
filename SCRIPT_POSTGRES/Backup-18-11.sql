PGDMP                     
    w            tauranet_db    10.3    10.3 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            �           1262    50221    tauranet_db    DATABASE     �   CREATE DATABASE tauranet_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Spain.1252' LC_CTYPE = 'Spanish_Spain.1252';
    DROP DATABASE tauranet_db;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            �           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    3                        3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            �           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1            �            1255    68044 ,   function_empleado_pedido(bigint, date, date)    FUNCTION     �  CREATE FUNCTION public.function_empleado_pedido(idrestaurante bigint, fechaini date, fechafin date) RETURNS TABLE(nombre_usuario character varying, perfil text, pedidos bigint)
    LANGUAGE plpgsql
    AS $$
begin
	return query 
		select c.nombre_usuario, 'Cajero' as perfil, count(*) as pedidos from cajeros as c
		inner join cajas as j on j.id_caja = c.id_caja
		inner join sucursals as s on s.id_sucursal = c.id_sucursal
		inner join venta_productos as v on v.id_cajero = c.id_cajero
		inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
		where s.id_restaurant = idRestaurante and c.deleted_at isNull and h.fecha between fechaIni and fechaFin
		group by c.nombre_usuario
		union
		select m.nombre_usuario, 'Mozo' as perfil, count(*) as pedidos from mozos as m
		inner join sucursals as s on s.id_sucursal = m.id_sucursal
		inner join venta_productos as v on v.id_mozo = m.id_mozo
		inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
		where s.id_restaurant = idRestaurante and m.deleted_at isNull and h.fecha between fechaIni and fechaFin
		group by m.nombre_usuario
		order by pedidos desc, perfil asc;
end;
$$;
 c   DROP FUNCTION public.function_empleado_pedido(idrestaurante bigint, fechaini date, fechafin date);
       public       postgres    false    3    1            �            1255    68056 *   function_fecha_importe(bigint, date, date)    FUNCTION     �  CREATE FUNCTION public.function_fecha_importe(idrestaurante bigint, fechaini date, fechafin date) RETURNS TABLE(fecha date, importe numeric)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select h.fecha, sum(p.importe) from producto_vendidos as p
	inner join venta_productos as v on v.id_venta_producto = p.id_venta_producto
	inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
	inner join cajas as c on c.id_caja = h.id_caja
	inner join sucursals as s on s.id_sucursal = c.id_sucursal
	where s.id_restaurant = idRestaurante and h.fecha between fechaIni and fechaFin
	group by h.fecha
	order by h.fecha asc;
end;
$$;
 a   DROP FUNCTION public.function_fecha_importe(idrestaurante bigint, fechaini date, fechafin date);
       public       postgres    false    3    1            �            1255    68053 *   function_fecha_pedidos(bigint, date, date)    FUNCTION     :  CREATE FUNCTION public.function_fecha_pedidos(idrestaurante bigint, fechaini date, fechafin date) RETURNS TABLE(fecha date, pedidos bigint)
    LANGUAGE plpgsql
    AS $$
begin
	return query
	select h.fecha, count(*) as pedidos from venta_productos as v
	inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
	inner join cajas as c on c.id_caja = h.id_caja
	inner join sucursals as s on s.id_sucursal = c.id_sucursal
	where s.id_restaurant = idRestaurante and h.fecha between fechaIni and fechaFin
	group by h.fecha
	order by h.fecha asc;
end;
$$;
 a   DROP FUNCTION public.function_fecha_pedidos(idrestaurante bigint, fechaini date, fechafin date);
       public       postgres    false    3    1            �            1255    59582    function_personal(integer)    FUNCTION     �  CREATE FUNCTION public.function_personal(idrestaurant integer) RETURNS TABLE(id_usuario bigint, nombre_usuario character varying, nombre_completo text, dni character varying, tipo_usuario character, nombresucursal character varying, created_at timestamp without time zone, id_sucursal bigint)
    LANGUAGE plpgsql
    AS $$
begin
	return query 
		select c.id_cajero as id_usuario, c.nombre_usuario as nombre_usuario, concat(c.primer_nombre,' ', c.segundo_nombre,' ',c.paterno,' ',c.materno) as nombre_completo, c.dni as dni, c.tipo_usuario as tipo_usuario, s.nombre as nombreSucursal, c.created_at as created_at, s.id_sucursal
		from cajeros as c
		inner join sucursals as s on s.id_sucursal = c.id_sucursal
		where s.id_restaurant = idRestaurant and c.deleted_at is null
		union
		select m.id_mozo as id_usuario, m.nombre_usuario as nombre_usuario, concat(m.primer_nombre,' ',m.segundo_nombre,' ',m.paterno,' ',m.materno) as nombre_completo, m.dni as dni, m.tipo_usuario as tipo_usuario, s.nombre as nombreSucursal, m.created_at as created_at, s.id_sucursal
		from mozos as m
		inner join sucursals as s on s.id_sucursal = m.id_sucursal
		where s.id_restaurant = idRestaurant and m.deleted_at is null
		order by created_at desc;
end;
$$;
 >   DROP FUNCTION public.function_personal(idrestaurant integer);
       public       postgres    false    3    1            �            1255    68049 6   function_producto_cantidad(bigint, bigint, date, date)    FUNCTION       CREATE FUNCTION public.function_producto_cantidad(idrestaurante bigint, idcategoria bigint, fechaini date, fechafin date) RETURNS TABLE(nom_producto character varying, nom_categoria character varying, cantidad bigint)
    LANGUAGE plpgsql
    AS $$
begin
	if idCategoria != -1 then
		return query 	
			select p.nombre as nom_producto, ct.nombre as nom_categoria, sum(pv.cantidad) as cantidad from productos as p
			inner join categoria_productos as ct on ct.id_categoria_producto = p.id_categoria_producto
			inner join producto_vendidos as pv on pv.id_producto = p.id_producto
			inner join venta_productos as v on v.id_venta_producto = pv.id_venta_producto
			inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
			inner join cajas as c on c.id_caja = h.id_caja
			inner join sucursals as s on s.id_sucursal = c.id_sucursal
			where s.id_restaurant = idRestaurante and ct.id_categoria_producto = idCategoria and h.fecha between fechaIni and fechaFin
			group by p.nombre, ct.nombre, ct.id_categoria_producto
			order by cantidad desc;
	else
		return query 	
			select p.nombre as nom_producto, ct.nombre as nom_categoria, sum(pv.cantidad) as cantidad from productos as p
			inner join categoria_productos as ct on ct.id_categoria_producto = p.id_categoria_producto
			inner join producto_vendidos as pv on pv.id_producto = p.id_producto
			inner join venta_productos as v on v.id_venta_producto = pv.id_venta_producto
			inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
			inner join cajas as c on c.id_caja = h.id_caja
			inner join sucursals as s on s.id_sucursal = c.id_sucursal
			where s.id_restaurant = idRestaurante and h.fecha between fechaIni and fechaFin
			group by p.nombre, ct.nombre, ct.id_categoria_producto
			order by cantidad desc;
	end if;
end;
$$;
 y   DROP FUNCTION public.function_producto_cantidad(idrestaurante bigint, idcategoria bigint, fechaini date, fechafin date);
       public       postgres    false    3    1            �            1255    68050 5   function_producto_importe(bigint, bigint, date, date)    FUNCTION       CREATE FUNCTION public.function_producto_importe(idrestaurante bigint, idcategoria bigint, fechaini date, fechafin date) RETURNS TABLE(nom_producto character varying, nom_categoria character varying, importe numeric)
    LANGUAGE plpgsql
    AS $$
begin
	if idCategoria != -1 then
		return query 	
			select p.nombre as nom_producto, ct.nombre as nom_categoria, sum(pv.importe) as importe from productos as p
			inner join categoria_productos as ct on ct.id_categoria_producto = p.id_categoria_producto
			inner join producto_vendidos as pv on pv.id_producto = p.id_producto
			inner join venta_productos as v on v.id_venta_producto = pv.id_venta_producto
			inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
			inner join cajas as c on c.id_caja = h.id_caja
			inner join sucursals as s on s.id_sucursal = c.id_sucursal
			where s.id_restaurant = idRestaurante and ct.id_categoria_producto = idCategoria and h.fecha between fechaIni and fechaFin
			group by p.nombre, ct.nombre, ct.id_categoria_producto
			order by importe desc;
	else
		return query 	
			select p.nombre as nom_producto, ct.nombre as nom_categoria, sum(pv.importe) as importe from productos as p
			inner join categoria_productos as ct on ct.id_categoria_producto = p.id_categoria_producto
			inner join producto_vendidos as pv on pv.id_producto = p.id_producto
			inner join venta_productos as v on v.id_venta_producto = pv.id_venta_producto
			inner join historial_caja as h on h.id_historial_caja = v.id_historial_caja
			inner join cajas as c on c.id_caja = h.id_caja
			inner join sucursals as s on s.id_sucursal = c.id_sucursal
			where s.id_restaurant = idRestaurante and h.fecha between fechaIni and fechaFin
			group by p.nombre, ct.nombre, ct.id_categoria_producto
			order by importe desc;
	end if;
end;
$$;
 x   DROP FUNCTION public.function_producto_importe(idrestaurante bigint, idcategoria bigint, fechaini date, fechafin date);
       public       postgres    false    3    1            �            1255    67874 '   registraproductosfunction(text, bigint)    FUNCTION     =  CREATE FUNCTION public.registraproductosfunction(cad text, id_venta_producto bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
	nro_elementos integer;
	row_cad text;
	col_cad text;
	i integer;
	j integer;
	
BEGIN
	i = 1;
    nro_elementos = (select array_length(regexp_split_to_array(cad, ':'),1));
    WHILE i <= (select nro_elementos) LOOP
		row_cad = (SELECT split_part(cad, ':', i));
		raise notice '%',row_cad;
		raise notice '-> %', (SELECT split_part(row_cad, '|', 1));--cod
		raise notice '-> %', (SELECT split_part(row_cad, '|', 2));--cant
		raise notice '-> %', (SELECT split_part(row_cad, '|', 3));--p_unit
		raise notice '-> %', (SELECT split_part(row_cad, '|', 4));--importe
		raise notice '-> %', (SELECT split_part(row_cad, '|', 5));--nota
		insert into producto_vendidos
			(
				id_producto,
				cantidad,
				p_unit,
				importe,
				nota,
				id_venta_producto,
				created_at
			)
			values (
				CAST(split_part(row_cad, '|', 1) as bigint),--cod
				CAST(split_part(row_cad, '|', 2) as int),--cant
				CAST(split_part(row_cad, '|', 3) as numeric(9, 4)),--p_unit
				CAST(split_part(row_cad, '|', 4) as numeric(9, 4)),--importe
				(SELECT split_part(row_cad, '|', 5)),--nota
				id_venta_producto,
				now()
			);
		
		--raise notice '% %', suma, i;
		i = i+1;
	END LOOP;
    RETURN i-1;
END;          
$$;
 T   DROP FUNCTION public.registraproductosfunction(cad text, id_venta_producto bigint);
       public       postgres    false    1    3            �            1259    50248    users    TABLE     �  CREATE TABLE public.users (
    id_usuario bigint NOT NULL,
    primer_nombre character varying(100),
    paterno character varying(250),
    materno character varying(250),
    dni character varying(25),
    direccion text,
    nombre_usuario character varying(25),
    email character varying(250),
    password character varying(500),
    fecha_nac date,
    sexo boolean,
    nombre_fotoperfil character varying(150),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    tipo_usuario character(1),
    api_token character varying(60),
    segundo_nombre character varying(100),
    celular character varying(20),
    telefono character varying(20),
    deleted_at timestamp without time zone
);
    DROP TABLE public.users;
       public         postgres    false    3            �            1259    50277    administradors    TABLE     �   CREATE TABLE public.administradors (
    id_administrador bigint NOT NULL,
    id_restaurant bigint NOT NULL,
    id_superadministrador bigint NOT NULL
)
INHERITS (public.users);
 "   DROP TABLE public.administradors;
       public         postgres    false    199    3            �            1259    50275 #   administradors_id_administrador_seq    SEQUENCE     �   CREATE SEQUENCE public.administradors_id_administrador_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE public.administradors_id_administrador_seq;
       public       postgres    false    203    3            �           0    0 #   administradors_id_administrador_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE public.administradors_id_administrador_seq OWNED BY public.administradors.id_administrador;
            public       postgres    false    202            �            1259    50952    cajas    TABLE     >  CREATE TABLE public.cajas (
    id_caja bigint NOT NULL,
    nombre character varying(20) NOT NULL,
    descripcion text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_administrador bigint NOT NULL,
    id_sucursal bigint,
    deleted_at timestamp without time zone
);
    DROP TABLE public.cajas;
       public         postgres    false    3            �            1259    50950    cajas_id_caja_seq    SEQUENCE     z   CREATE SEQUENCE public.cajas_id_caja_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.cajas_id_caja_seq;
       public       postgres    false    3    221            �           0    0    cajas_id_caja_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.cajas_id_caja_seq OWNED BY public.cajas.id_caja;
            public       postgres    false    220            �            1259    50320    cajeros    TABLE     �   CREATE TABLE public.cajeros (
    id_cajero bigint NOT NULL,
    sueldo numeric(9,2),
    fecha_inicio date,
    id_sucursal bigint NOT NULL,
    id_administrador bigint NOT NULL,
    id_caja bigint
)
INHERITS (public.users);
    DROP TABLE public.cajeros;
       public         postgres    false    3    199            �            1259    50347    categoria_productos    TABLE     |  CREATE TABLE public.categoria_productos (
    id_categoria_producto bigint NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    fecha_inicio date,
    id_restaurant bigint NOT NULL,
    id_administrador bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone
);
 '   DROP TABLE public.categoria_productos;
       public         postgres    false    3            �            1259    50345 -   categoria_productos_id_categoria_producto_seq    SEQUENCE     �   CREATE SEQUENCE public.categoria_productos_id_categoria_producto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 D   DROP SEQUENCE public.categoria_productos_id_categoria_producto_seq;
       public       postgres    false    3    209            �           0    0 -   categoria_productos_id_categoria_producto_seq    SEQUENCE OWNED BY        ALTER SEQUENCE public.categoria_productos_id_categoria_producto_seq OWNED BY public.categoria_productos.id_categoria_producto;
            public       postgres    false    208            �            1259    50425    clientes    TABLE     (  CREATE TABLE public.clientes (
    id_cliente bigint NOT NULL,
    nombre_completo character varying(100),
    dni character varying(50),
    id_cajero bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_mozo bigint,
    id_restaurant bigint
);
    DROP TABLE public.clientes;
       public         postgres    false    3            �            1259    50423    clientes_id_cliente_seq    SEQUENCE     �   CREATE SEQUENCE public.clientes_id_cliente_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.clientes_id_cliente_seq;
       public       postgres    false    213    3            �           0    0    clientes_id_cliente_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.clientes_id_cliente_seq OWNED BY public.clientes.id_cliente;
            public       postgres    false    212            �            1259    50318    empleados_id_empleado_seq    SEQUENCE     �   CREATE SEQUENCE public.empleados_id_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.empleados_id_empleado_seq;
       public       postgres    false    3    207            �           0    0    empleados_id_empleado_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.empleados_id_empleado_seq OWNED BY public.cajeros.id_cajero;
            public       postgres    false    206            �            1259    59734    historial_caja    TABLE     x  CREATE TABLE public.historial_caja (
    id_historial_caja bigint NOT NULL,
    monto_inicial numeric(10,2) NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha date NOT NULL,
    estado boolean NOT NULL,
    id_caja bigint NOT NULL,
    id_administrador bigint,
    id_cajero bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
 "   DROP TABLE public.historial_caja;
       public         postgres    false    3            �            1259    59732 $   historial_caja_id_historial_caja_seq    SEQUENCE     �   CREATE SEQUENCE public.historial_caja_id_historial_caja_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ;   DROP SEQUENCE public.historial_caja_id_historial_caja_seq;
       public       postgres    false    3    227            �           0    0 $   historial_caja_id_historial_caja_seq    SEQUENCE OWNED BY     m   ALTER SEQUENCE public.historial_caja_id_historial_caja_seq OWNED BY public.historial_caja.id_historial_caja;
            public       postgres    false    226            �            1259    50606    mozos    TABLE     �   CREATE TABLE public.mozos (
    id_mozo bigint NOT NULL,
    sueldo numeric(9,2),
    fecha_inicio date,
    id_sucursal bigint NOT NULL,
    id_administrador bigint NOT NULL
)
INHERITS (public.users);
    DROP TABLE public.mozos;
       public         postgres    false    199    3            �            1259    50604    mozos_id_mozo_seq    SEQUENCE     z   CREATE SEQUENCE public.mozos_id_mozo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.mozos_id_mozo_seq;
       public       postgres    false    219    3            �           0    0    mozos_id_mozo_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.mozos_id_mozo_seq OWNED BY public.mozos.id_mozo;
            public       postgres    false    218            �            1259    67885    pagos    TABLE     X  CREATE TABLE public.pagos (
    id_pago bigint NOT NULL,
    efectivo numeric(9,2),
    total numeric(9,2),
    total_pagar numeric(9,2),
    visa numeric(9,2),
    mastercard numeric(9,2),
    cambio numeric(9,2),
    id_venta_producto bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
    DROP TABLE public.pagos;
       public         postgres    false    3            �            1259    67883    pagos_id_pago_seq    SEQUENCE     z   CREATE SEQUENCE public.pagos_id_pago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.pagos_id_pago_seq;
       public       postgres    false    3    229            �           0    0    pagos_id_pago_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.pagos_id_pago_seq OWNED BY public.pagos.id_pago;
            public       postgres    false    228            �            1259    51315    perfilimagens    TABLE       CREATE TABLE public.perfilimagens (
    id_perfilimagen bigint NOT NULL,
    nombre character varying(250) NOT NULL,
    id_administrador bigint,
    id_mozo bigint,
    id_cajero bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
 !   DROP TABLE public.perfilimagens;
       public         postgres    false    3            �            1259    51313 !   perfilimagens_id_perfilimagen_seq    SEQUENCE     �   CREATE SEQUENCE public.perfilimagens_id_perfilimagen_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.perfilimagens_id_perfilimagen_seq;
       public       postgres    false    3    225            �           0    0 !   perfilimagens_id_perfilimagen_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.perfilimagens_id_perfilimagen_seq OWNED BY public.perfilimagens.id_perfilimagen;
            public       postgres    false    224            �            1259    68008    plan_de_pagos    TABLE     '  CREATE TABLE public.plan_de_pagos (
    id_planpago bigint NOT NULL,
    cant_pedidos integer,
    cant_mozos integer,
    cant_cajas integer,
    cant_cajeros integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_suscripcion bigint NOT NULL
);
 !   DROP TABLE public.plan_de_pagos;
       public         postgres    false    3            �            1259    68006    plan_de_pagos_id_planpago_seq    SEQUENCE     �   CREATE SEQUENCE public.plan_de_pagos_id_planpago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.plan_de_pagos_id_planpago_seq;
       public       postgres    false    231    3            �           0    0    plan_de_pagos_id_planpago_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.plan_de_pagos_id_planpago_seq OWNED BY public.plan_de_pagos.id_planpago;
            public       postgres    false    230            �            1259    50467    producto_vendidos    TABLE       CREATE TABLE public.producto_vendidos (
    id_producto_vendido bigint NOT NULL,
    cantidad integer,
    importe numeric(9,2),
    id_producto bigint NOT NULL,
    id_venta_producto bigint NOT NULL,
    nota text,
    p_unit numeric(9,2),
    created_at timestamp without time zone
);
 %   DROP TABLE public.producto_vendidos;
       public         postgres    false    3            �            1259    50465 )   producto_vendidos_id_producto_vendido_seq    SEQUENCE     �   CREATE SEQUENCE public.producto_vendidos_id_producto_vendido_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 @   DROP SEQUENCE public.producto_vendidos_id_producto_vendido_seq;
       public       postgres    false    3    217            �           0    0 )   producto_vendidos_id_producto_vendido_seq    SEQUENCE OWNED BY     w   ALTER SEQUENCE public.producto_vendidos_id_producto_vendido_seq OWNED BY public.producto_vendidos.id_producto_vendido;
            public       postgres    false    216            �            1259    50370 	   productos    TABLE     �  CREATE TABLE public.productos (
    id_producto bigint NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    id_categoria_producto bigint NOT NULL,
    id_administrador bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    precio numeric(9,2),
    deleted_at timestamp without time zone,
    producto_image character varying(250)
);
    DROP TABLE public.productos;
       public         postgres    false    3            �            1259    50368    productos_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public.productos_id_producto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.productos_id_producto_seq;
       public       postgres    false    3    211                        0    0    productos_id_producto_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.productos_id_producto_seq OWNED BY public.productos.id_producto;
            public       postgres    false    210            �            1259    50261    restaurants    TABLE     �  CREATE TABLE public.restaurants (
    id_restaurant bigint NOT NULL,
    nombre character varying(50) NOT NULL,
    estado boolean NOT NULL,
    descripcion text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_superadministrador bigint NOT NULL,
    observacion text,
    id_suscripcion bigint,
    tipo_moneda character varying(10),
    identificacion character varying(10)
);
    DROP TABLE public.restaurants;
       public         postgres    false    3            �            1259    50259    restaurants_id_restaurant_seq    SEQUENCE     �   CREATE SEQUENCE public.restaurants_id_restaurant_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.restaurants_id_restaurant_seq;
       public       postgres    false    3    201                       0    0    restaurants_id_restaurant_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.restaurants_id_restaurant_seq OWNED BY public.restaurants.id_restaurant;
            public       postgres    false    200            �            1259    50299 	   sucursals    TABLE     �  CREATE TABLE public.sucursals (
    id_sucursal bigint NOT NULL,
    nombre character varying(20) NOT NULL,
    direccion text,
    descripcion text,
    id_restaurant bigint NOT NULL,
    id_superadministrador bigint NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    ciudad character varying(20),
    pais character varying(20),
    telefono character varying(20),
    celular character varying(20)
);
    DROP TABLE public.sucursals;
       public         postgres    false    3            �            1259    50297    sucursals_id_sucursal_seq    SEQUENCE     �   CREATE SEQUENCE public.sucursals_id_sucursal_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.sucursals_id_sucursal_seq;
       public       postgres    false    3    205                       0    0    sucursals_id_sucursal_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.sucursals_id_sucursal_seq OWNED BY public.sucursals.id_sucursal;
            public       postgres    false    204            �            1259    50224    superadministradors    TABLE       CREATE TABLE public.superadministradors (
    id_superadministrador bigint NOT NULL,
    nombre_usuario character varying(250) NOT NULL,
    password character varying(250) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);
 '   DROP TABLE public.superadministradors;
       public         postgres    false    3            �            1259    50222 -   superadministradors_id_superadministrador_seq    SEQUENCE     �   CREATE SEQUENCE public.superadministradors_id_superadministrador_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 D   DROP SEQUENCE public.superadministradors_id_superadministrador_seq;
       public       postgres    false    197    3                       0    0 -   superadministradors_id_superadministrador_seq    SEQUENCE OWNED BY        ALTER SEQUENCE public.superadministradors_id_superadministrador_seq OWNED BY public.superadministradors.id_superadministrador;
            public       postgres    false    196            �            1259    51055    suscripcions    TABLE     W  CREATE TABLE public.suscripcions (
    id_suscripcion bigint NOT NULL,
    tipo_suscripcion character varying(20) NOT NULL,
    observacion text,
    precio_anual numeric(9,2),
    precio_mensual numeric(9,2),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_superadministrador bigint NOT NULL
);
     DROP TABLE public.suscripcions;
       public         postgres    false    3            �            1259    51053    suscripcions_id_suscripcion_seq    SEQUENCE     �   CREATE SEQUENCE public.suscripcions_id_suscripcion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.suscripcions_id_suscripcion_seq;
       public       postgres    false    223    3                       0    0    suscripcions_id_suscripcion_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.suscripcions_id_suscripcion_seq OWNED BY public.suscripcions.id_suscripcion;
            public       postgres    false    222            �            1259    50246    users_id_usuario_seq    SEQUENCE     }   CREATE SEQUENCE public.users_id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.users_id_usuario_seq;
       public       postgres    false    199    3                       0    0    users_id_usuario_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.users_id_usuario_seq OWNED BY public.users.id_usuario;
            public       postgres    false    198            �            1259    50438    venta_productos    TABLE     �  CREATE TABLE public.venta_productos (
    id_venta_producto bigint NOT NULL,
    nro_venta integer,
    total numeric(9,2),
    descuento integer,
    estado_venta character(1),
    id_cliente bigint,
    id_cajero bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_sucursal bigint,
    id_mozo bigint,
    sub_total numeric(9,2),
    id_historial_caja bigint,
    estado_atendido boolean
);
 #   DROP TABLE public.venta_productos;
       public         postgres    false    3            �            1259    50436 %   venta_productos_id_venta_producto_seq    SEQUENCE     �   CREATE SEQUENCE public.venta_productos_id_venta_producto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.venta_productos_id_venta_producto_seq;
       public       postgres    false    3    215                       0    0 %   venta_productos_id_venta_producto_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public.venta_productos_id_venta_producto_seq OWNED BY public.venta_productos.id_venta_producto;
            public       postgres    false    214            �
           2604    50280    administradors id_usuario    DEFAULT     }   ALTER TABLE ONLY public.administradors ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);
 H   ALTER TABLE public.administradors ALTER COLUMN id_usuario DROP DEFAULT;
       public       postgres    false    203    198            �
           2604    50281    administradors id_administrador    DEFAULT     �   ALTER TABLE ONLY public.administradors ALTER COLUMN id_administrador SET DEFAULT nextval('public.administradors_id_administrador_seq'::regclass);
 N   ALTER TABLE public.administradors ALTER COLUMN id_administrador DROP DEFAULT;
       public       postgres    false    202    203    203            �
           2604    50955    cajas id_caja    DEFAULT     n   ALTER TABLE ONLY public.cajas ALTER COLUMN id_caja SET DEFAULT nextval('public.cajas_id_caja_seq'::regclass);
 <   ALTER TABLE public.cajas ALTER COLUMN id_caja DROP DEFAULT;
       public       postgres    false    221    220    221            �
           2604    50323    cajeros id_usuario    DEFAULT     v   ALTER TABLE ONLY public.cajeros ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);
 A   ALTER TABLE public.cajeros ALTER COLUMN id_usuario DROP DEFAULT;
       public       postgres    false    198    207            �
           2604    50324    cajeros id_cajero    DEFAULT     z   ALTER TABLE ONLY public.cajeros ALTER COLUMN id_cajero SET DEFAULT nextval('public.empleados_id_empleado_seq'::regclass);
 @   ALTER TABLE public.cajeros ALTER COLUMN id_cajero DROP DEFAULT;
       public       postgres    false    207    206    207            �
           2604    50350 )   categoria_productos id_categoria_producto    DEFAULT     �   ALTER TABLE ONLY public.categoria_productos ALTER COLUMN id_categoria_producto SET DEFAULT nextval('public.categoria_productos_id_categoria_producto_seq'::regclass);
 X   ALTER TABLE public.categoria_productos ALTER COLUMN id_categoria_producto DROP DEFAULT;
       public       postgres    false    208    209    209            �
           2604    50428    clientes id_cliente    DEFAULT     z   ALTER TABLE ONLY public.clientes ALTER COLUMN id_cliente SET DEFAULT nextval('public.clientes_id_cliente_seq'::regclass);
 B   ALTER TABLE public.clientes ALTER COLUMN id_cliente DROP DEFAULT;
       public       postgres    false    213    212    213            �
           2604    59737     historial_caja id_historial_caja    DEFAULT     �   ALTER TABLE ONLY public.historial_caja ALTER COLUMN id_historial_caja SET DEFAULT nextval('public.historial_caja_id_historial_caja_seq'::regclass);
 O   ALTER TABLE public.historial_caja ALTER COLUMN id_historial_caja DROP DEFAULT;
       public       postgres    false    227    226    227            �
           2604    50609    mozos id_usuario    DEFAULT     t   ALTER TABLE ONLY public.mozos ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);
 ?   ALTER TABLE public.mozos ALTER COLUMN id_usuario DROP DEFAULT;
       public       postgres    false    198    219            �
           2604    50610    mozos id_mozo    DEFAULT     n   ALTER TABLE ONLY public.mozos ALTER COLUMN id_mozo SET DEFAULT nextval('public.mozos_id_mozo_seq'::regclass);
 <   ALTER TABLE public.mozos ALTER COLUMN id_mozo DROP DEFAULT;
       public       postgres    false    219    218    219            �
           2604    67888    pagos id_pago    DEFAULT     n   ALTER TABLE ONLY public.pagos ALTER COLUMN id_pago SET DEFAULT nextval('public.pagos_id_pago_seq'::regclass);
 <   ALTER TABLE public.pagos ALTER COLUMN id_pago DROP DEFAULT;
       public       postgres    false    229    228    229            �
           2604    51318    perfilimagens id_perfilimagen    DEFAULT     �   ALTER TABLE ONLY public.perfilimagens ALTER COLUMN id_perfilimagen SET DEFAULT nextval('public.perfilimagens_id_perfilimagen_seq'::regclass);
 L   ALTER TABLE public.perfilimagens ALTER COLUMN id_perfilimagen DROP DEFAULT;
       public       postgres    false    225    224    225            �
           2604    68011    plan_de_pagos id_planpago    DEFAULT     �   ALTER TABLE ONLY public.plan_de_pagos ALTER COLUMN id_planpago SET DEFAULT nextval('public.plan_de_pagos_id_planpago_seq'::regclass);
 H   ALTER TABLE public.plan_de_pagos ALTER COLUMN id_planpago DROP DEFAULT;
       public       postgres    false    230    231    231            �
           2604    50470 %   producto_vendidos id_producto_vendido    DEFAULT     �   ALTER TABLE ONLY public.producto_vendidos ALTER COLUMN id_producto_vendido SET DEFAULT nextval('public.producto_vendidos_id_producto_vendido_seq'::regclass);
 T   ALTER TABLE public.producto_vendidos ALTER COLUMN id_producto_vendido DROP DEFAULT;
       public       postgres    false    216    217    217            �
           2604    50373    productos id_producto    DEFAULT     ~   ALTER TABLE ONLY public.productos ALTER COLUMN id_producto SET DEFAULT nextval('public.productos_id_producto_seq'::regclass);
 D   ALTER TABLE public.productos ALTER COLUMN id_producto DROP DEFAULT;
       public       postgres    false    210    211    211            �
           2604    50264    restaurants id_restaurant    DEFAULT     �   ALTER TABLE ONLY public.restaurants ALTER COLUMN id_restaurant SET DEFAULT nextval('public.restaurants_id_restaurant_seq'::regclass);
 H   ALTER TABLE public.restaurants ALTER COLUMN id_restaurant DROP DEFAULT;
       public       postgres    false    201    200    201            �
           2604    50302    sucursals id_sucursal    DEFAULT     ~   ALTER TABLE ONLY public.sucursals ALTER COLUMN id_sucursal SET DEFAULT nextval('public.sucursals_id_sucursal_seq'::regclass);
 D   ALTER TABLE public.sucursals ALTER COLUMN id_sucursal DROP DEFAULT;
       public       postgres    false    205    204    205            �
           2604    50227 )   superadministradors id_superadministrador    DEFAULT     �   ALTER TABLE ONLY public.superadministradors ALTER COLUMN id_superadministrador SET DEFAULT nextval('public.superadministradors_id_superadministrador_seq'::regclass);
 X   ALTER TABLE public.superadministradors ALTER COLUMN id_superadministrador DROP DEFAULT;
       public       postgres    false    196    197    197            �
           2604    51058    suscripcions id_suscripcion    DEFAULT     �   ALTER TABLE ONLY public.suscripcions ALTER COLUMN id_suscripcion SET DEFAULT nextval('public.suscripcions_id_suscripcion_seq'::regclass);
 J   ALTER TABLE public.suscripcions ALTER COLUMN id_suscripcion DROP DEFAULT;
       public       postgres    false    223    222    223            �
           2604    50251    users id_usuario    DEFAULT     t   ALTER TABLE ONLY public.users ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);
 ?   ALTER TABLE public.users ALTER COLUMN id_usuario DROP DEFAULT;
       public       postgres    false    199    198    199            �
           2604    50441 !   venta_productos id_venta_producto    DEFAULT     �   ALTER TABLE ONLY public.venta_productos ALTER COLUMN id_venta_producto SET DEFAULT nextval('public.venta_productos_id_venta_producto_seq'::regclass);
 P   ALTER TABLE public.venta_productos ALTER COLUMN id_venta_producto DROP DEFAULT;
       public       postgres    false    215    214    215            �          0    50277    administradors 
   TABLE DATA               B  COPY public.administradors (id_usuario, primer_nombre, paterno, materno, dni, direccion, nombre_usuario, email, password, fecha_nac, sexo, nombre_fotoperfil, created_at, updated_at, id_administrador, id_restaurant, id_superadministrador, tipo_usuario, api_token, segundo_nombre, celular, telefono, deleted_at) FROM stdin;
    public       postgres    false    203   �       �          0    50952    cajas 
   TABLE DATA               �   COPY public.cajas (id_caja, nombre, descripcion, created_at, updated_at, id_administrador, id_sucursal, deleted_at) FROM stdin;
    public       postgres    false    221   �(      �          0    50320    cajeros 
   TABLE DATA               L  COPY public.cajeros (id_usuario, primer_nombre, paterno, materno, dni, direccion, nombre_usuario, email, password, fecha_nac, sexo, nombre_fotoperfil, created_at, updated_at, id_cajero, sueldo, fecha_inicio, id_sucursal, id_administrador, tipo_usuario, api_token, id_caja, segundo_nombre, celular, telefono, deleted_at) FROM stdin;
    public       postgres    false    207   �*      �          0    50347    categoria_productos 
   TABLE DATA               �   COPY public.categoria_productos (id_categoria_producto, nombre, descripcion, fecha_inicio, id_restaurant, id_administrador, created_at, updated_at, deleted_at) FROM stdin;
    public       postgres    false    209   �4      �          0    50425    clientes 
   TABLE DATA                  COPY public.clientes (id_cliente, nombre_completo, dni, id_cajero, created_at, updated_at, id_mozo, id_restaurant) FROM stdin;
    public       postgres    false    213   �7      �          0    59734    historial_caja 
   TABLE DATA               �   COPY public.historial_caja (id_historial_caja, monto_inicial, monto, fecha, estado, id_caja, id_administrador, id_cajero, created_at, updated_at) FROM stdin;
    public       postgres    false    227   .A      �          0    50606    mozos 
   TABLE DATA               ?  COPY public.mozos (id_usuario, primer_nombre, paterno, materno, dni, direccion, nombre_usuario, email, password, fecha_nac, sexo, nombre_fotoperfil, created_at, updated_at, tipo_usuario, id_mozo, sueldo, fecha_inicio, id_sucursal, id_administrador, api_token, segundo_nombre, celular, telefono, deleted_at) FROM stdin;
    public       postgres    false    219   BD      �          0    67885    pagos 
   TABLE DATA               �   COPY public.pagos (id_pago, efectivo, total, total_pagar, visa, mastercard, cambio, id_venta_producto, created_at, updated_at) FROM stdin;
    public       postgres    false    229   lJ      �          0    51315    perfilimagens 
   TABLE DATA               ~   COPY public.perfilimagens (id_perfilimagen, nombre, id_administrador, id_mozo, id_cajero, created_at, updated_at) FROM stdin;
    public       postgres    false    225   W`      �          0    68008    plan_de_pagos 
   TABLE DATA               �   COPY public.plan_de_pagos (id_planpago, cant_pedidos, cant_mozos, cant_cajas, cant_cajeros, created_at, updated_at, id_suscripcion) FROM stdin;
    public       postgres    false    231   �c      �          0    50467    producto_vendidos 
   TABLE DATA               �   COPY public.producto_vendidos (id_producto_vendido, cantidad, importe, id_producto, id_venta_producto, nota, p_unit, created_at) FROM stdin;
    public       postgres    false    217   =d      �          0    50370 	   productos 
   TABLE DATA               �   COPY public.productos (id_producto, nombre, descripcion, id_categoria_producto, id_administrador, created_at, updated_at, precio, deleted_at, producto_image) FROM stdin;
    public       postgres    false    211   �      �          0    50261    restaurants 
   TABLE DATA               �   COPY public.restaurants (id_restaurant, nombre, estado, descripcion, created_at, updated_at, id_superadministrador, observacion, id_suscripcion, tipo_moneda, identificacion) FROM stdin;
    public       postgres    false    201   [�      �          0    50299 	   sucursals 
   TABLE DATA               �   COPY public.sucursals (id_sucursal, nombre, direccion, descripcion, id_restaurant, id_superadministrador, created_at, updated_at, ciudad, pais, telefono, celular) FROM stdin;
    public       postgres    false    205   �      �          0    50224    superadministradors 
   TABLE DATA               v   COPY public.superadministradors (id_superadministrador, nombre_usuario, password, created_at, updated_at) FROM stdin;
    public       postgres    false    197   �      �          0    51055    suscripcions 
   TABLE DATA               �   COPY public.suscripcions (id_suscripcion, tipo_suscripcion, observacion, precio_anual, precio_mensual, created_at, updated_at, id_superadministrador) FROM stdin;
    public       postgres    false    223   {�      �          0    50248    users 
   TABLE DATA                 COPY public.users (id_usuario, primer_nombre, paterno, materno, dni, direccion, nombre_usuario, email, password, fecha_nac, sexo, nombre_fotoperfil, created_at, updated_at, tipo_usuario, api_token, segundo_nombre, celular, telefono, deleted_at) FROM stdin;
    public       postgres    false    199   6�      �          0    50438    venta_productos 
   TABLE DATA               �   COPY public.venta_productos (id_venta_producto, nro_venta, total, descuento, estado_venta, id_cliente, id_cajero, created_at, updated_at, id_sucursal, id_mozo, sub_total, id_historial_caja, estado_atendido) FROM stdin;
    public       postgres    false    215   ��                 0    0 #   administradors_id_administrador_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.administradors_id_administrador_seq', 68, true);
            public       postgres    false    202                       0    0    cajas_id_caja_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.cajas_id_caja_seq', 35, true);
            public       postgres    false    220            	           0    0 -   categoria_productos_id_categoria_producto_seq    SEQUENCE SET     \   SELECT pg_catalog.setval('public.categoria_productos_id_categoria_producto_seq', 31, true);
            public       postgres    false    208            
           0    0    clientes_id_cliente_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.clientes_id_cliente_seq', 128, true);
            public       postgres    false    212                       0    0    empleados_id_empleado_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.empleados_id_empleado_seq', 25, true);
            public       postgres    false    206                       0    0 $   historial_caja_id_historial_caja_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.historial_caja_id_historial_caja_seq', 34, true);
            public       postgres    false    226                       0    0    mozos_id_mozo_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.mozos_id_mozo_seq', 14, true);
            public       postgres    false    218                       0    0    pagos_id_pago_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.pagos_id_pago_seq', 331, true);
            public       postgres    false    228                       0    0 !   perfilimagens_id_perfilimagen_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.perfilimagens_id_perfilimagen_seq', 63, true);
            public       postgres    false    224                       0    0    plan_de_pagos_id_planpago_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.plan_de_pagos_id_planpago_seq', 3, true);
            public       postgres    false    230                       0    0 )   producto_vendidos_id_producto_vendido_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('public.producto_vendidos_id_producto_vendido_seq', 1613, true);
            public       postgres    false    216                       0    0    productos_id_producto_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.productos_id_producto_seq', 112, true);
            public       postgres    false    210                       0    0    restaurants_id_restaurant_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.restaurants_id_restaurant_seq', 43, true);
            public       postgres    false    200                       0    0    sucursals_id_sucursal_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sucursals_id_sucursal_seq', 20, true);
            public       postgres    false    204                       0    0 -   superadministradors_id_superadministrador_seq    SEQUENCE SET     [   SELECT pg_catalog.setval('public.superadministradors_id_superadministrador_seq', 2, true);
            public       postgres    false    196                       0    0    suscripcions_id_suscripcion_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.suscripcions_id_suscripcion_seq', 3, true);
            public       postgres    false    222                       0    0    users_id_usuario_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.users_id_usuario_seq', 108, true);
            public       postgres    false    198                       0    0 %   venta_productos_id_venta_producto_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.venta_productos_id_venta_producto_seq', 464, true);
            public       postgres    false    214                       2606    50286 "   administradors administradors_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.administradors
    ADD CONSTRAINT administradors_pkey PRIMARY KEY (id_administrador);
 L   ALTER TABLE ONLY public.administradors DROP CONSTRAINT administradors_pkey;
       public         postgres    false    203                       2606    50960    cajas cajas_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_pkey PRIMARY KEY (id_caja);
 :   ALTER TABLE ONLY public.cajas DROP CONSTRAINT cajas_pkey;
       public         postgres    false    221                       2606    50355 ,   categoria_productos categoria_productos_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY public.categoria_productos
    ADD CONSTRAINT categoria_productos_pkey PRIMARY KEY (id_categoria_producto);
 V   ALTER TABLE ONLY public.categoria_productos DROP CONSTRAINT categoria_productos_pkey;
       public         postgres    false    209                       2606    50430    clientes clientes_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);
 @   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_pkey;
       public         postgres    false    213                       2606    50329    cajeros empleados_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT empleados_pkey PRIMARY KEY (id_cajero);
 @   ALTER TABLE ONLY public.cajeros DROP CONSTRAINT empleados_pkey;
       public         postgres    false    207            '           2606    59739 "   historial_caja historial_caja_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_pkey PRIMARY KEY (id_historial_caja);
 L   ALTER TABLE ONLY public.historial_caja DROP CONSTRAINT historial_caja_pkey;
       public         postgres    false    227                       2606    50615    mozos mozos_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.mozos
    ADD CONSTRAINT mozos_pkey PRIMARY KEY (id_mozo);
 :   ALTER TABLE ONLY public.mozos DROP CONSTRAINT mozos_pkey;
       public         postgres    false    219            )           2606    67890    pagos pagos_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_pkey PRIMARY KEY (id_pago);
 :   ALTER TABLE ONLY public.pagos DROP CONSTRAINT pagos_pkey;
       public         postgres    false    229            #           2606    51322 &   perfilimagens perfilimagens_nombre_key 
   CONSTRAINT     c   ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_nombre_key UNIQUE (nombre);
 P   ALTER TABLE ONLY public.perfilimagens DROP CONSTRAINT perfilimagens_nombre_key;
       public         postgres    false    225            %           2606    51320     perfilimagens perfilimagens_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_pkey PRIMARY KEY (id_perfilimagen);
 J   ALTER TABLE ONLY public.perfilimagens DROP CONSTRAINT perfilimagens_pkey;
       public         postgres    false    225            +           2606    68013     plan_de_pagos plan_de_pagos_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.plan_de_pagos
    ADD CONSTRAINT plan_de_pagos_pkey PRIMARY KEY (id_planpago);
 J   ALTER TABLE ONLY public.plan_de_pagos DROP CONSTRAINT plan_de_pagos_pkey;
       public         postgres    false    231                       2606    50472 (   producto_vendidos producto_vendidos_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY public.producto_vendidos
    ADD CONSTRAINT producto_vendidos_pkey PRIMARY KEY (id_producto_vendido);
 R   ALTER TABLE ONLY public.producto_vendidos DROP CONSTRAINT producto_vendidos_pkey;
       public         postgres    false    217                       2606    50378    productos productos_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id_producto);
 B   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_pkey;
       public         postgres    false    211            	           2606    51052 %   restaurants restaurants_nombre_unique 
   CONSTRAINT     b   ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_nombre_unique UNIQUE (nombre);
 O   ALTER TABLE ONLY public.restaurants DROP CONSTRAINT restaurants_nombre_unique;
       public         postgres    false    201                       2606    50269    restaurants restaurants_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id_restaurant);
 F   ALTER TABLE ONLY public.restaurants DROP CONSTRAINT restaurants_pkey;
       public         postgres    false    201                       2606    50307    sucursals sucursals_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.sucursals
    ADD CONSTRAINT sucursals_pkey PRIMARY KEY (id_sucursal);
 B   ALTER TABLE ONLY public.sucursals DROP CONSTRAINT sucursals_pkey;
       public         postgres    false    205            �
           2606    50229 ,   superadministradors superadministradors_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY public.superadministradors
    ADD CONSTRAINT superadministradors_pkey PRIMARY KEY (id_superadministrador);
 V   ALTER TABLE ONLY public.superadministradors DROP CONSTRAINT superadministradors_pkey;
       public         postgres    false    197            �
           2606    50499 6   superadministradors superadministradors_usuario_unique 
   CONSTRAINT     {   ALTER TABLE ONLY public.superadministradors
    ADD CONSTRAINT superadministradors_usuario_unique UNIQUE (nombre_usuario);
 `   ALTER TABLE ONLY public.superadministradors DROP CONSTRAINT superadministradors_usuario_unique;
       public         postgres    false    197            !           2606    51063    suscripcions suscripcions_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.suscripcions
    ADD CONSTRAINT suscripcions_pkey PRIMARY KEY (id_suscripcion);
 H   ALTER TABLE ONLY public.suscripcions DROP CONSTRAINT suscripcions_pkey;
       public         postgres    false    223                       2606    50503    users users_dni_unique 
   CONSTRAINT     P   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_dni_unique UNIQUE (dni);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_dni_unique;
       public         postgres    false    199                       2606    50497    users users_email_unique 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_unique;
       public         postgres    false    199                       2606    50507 !   users users_nombre_usuario_unique 
   CONSTRAINT     f   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_nombre_usuario_unique UNIQUE (nombre_usuario);
 K   ALTER TABLE ONLY public.users DROP CONSTRAINT users_nombre_usuario_unique;
       public         postgres    false    199                       2606    50256    users users_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_usuario);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public         postgres    false    199                       2606    50443 $   venta_productos venta_productos_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_pkey PRIMARY KEY (id_venta_producto);
 N   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_pkey;
       public         postgres    false    215            .           2606    50287 0   administradors administradors_id_restaurant_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.administradors
    ADD CONSTRAINT administradors_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);
 Z   ALTER TABLE ONLY public.administradors DROP CONSTRAINT administradors_id_restaurant_fkey;
       public       postgres    false    2827    201    203            /           2606    50292 8   administradors administradors_id_superadministrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.administradors
    ADD CONSTRAINT administradors_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);
 b   ALTER TABLE ONLY public.administradors DROP CONSTRAINT administradors_id_superadministrador_fkey;
       public       postgres    false    197    203    2813            E           2606    50961 !   cajas cajas_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 K   ALTER TABLE ONLY public.cajas DROP CONSTRAINT cajas_id_administrador_fkey;
       public       postgres    false    221    203    2829            F           2606    50971    cajas cajas_id_sucursal_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);
 F   ALTER TABLE ONLY public.cajas DROP CONSTRAINT cajas_id_sucursal_fkey;
       public       postgres    false    2831    205    221            4           2606    50966    cajeros cajeros_id_caja_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT cajeros_id_caja_fkey FOREIGN KEY (id_caja) REFERENCES public.cajas(id_caja);
 F   ALTER TABLE ONLY public.cajeros DROP CONSTRAINT cajeros_id_caja_fkey;
       public       postgres    false    207    221    2847            6           2606    50361 =   categoria_productos categoria_productos_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.categoria_productos
    ADD CONSTRAINT categoria_productos_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 g   ALTER TABLE ONLY public.categoria_productos DROP CONSTRAINT categoria_productos_id_administrador_fkey;
       public       postgres    false    209    203    2829            5           2606    50356 :   categoria_productos categoria_productos_id_restaurant_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.categoria_productos
    ADD CONSTRAINT categoria_productos_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);
 d   ALTER TABLE ONLY public.categoria_productos DROP CONSTRAINT categoria_productos_id_restaurant_fkey;
       public       postgres    false    209    201    2827            9           2606    50431 "   clientes clientes_id_empleado_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_empleado_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);
 L   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_id_empleado_fkey;
       public       postgres    false    207    2833    213            :           2606    50631    clientes clientes_id_mozo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_mozo_fkey FOREIGN KEY (id_mozo) REFERENCES public.mozos(id_mozo);
 H   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_id_mozo_fkey;
       public       postgres    false    2845    213    219            ;           2606    67862 $   clientes clientes_id_restaurant_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);
 N   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_id_restaurant_fkey;
       public       postgres    false    213    201    2827            3           2606    50335 '   cajeros empleados_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT empleados_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 Q   ALTER TABLE ONLY public.cajeros DROP CONSTRAINT empleados_id_administrador_fkey;
       public       postgres    false    2829    207    203            2           2606    50330 "   cajeros empleados_id_sucursal_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT empleados_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);
 L   ALTER TABLE ONLY public.cajeros DROP CONSTRAINT empleados_id_sucursal_fkey;
       public       postgres    false    207    2831    205            L           2606    59745 3   historial_caja historial_caja_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 ]   ALTER TABLE ONLY public.historial_caja DROP CONSTRAINT historial_caja_id_administrador_fkey;
       public       postgres    false    2829    227    203            K           2606    59740 *   historial_caja historial_caja_id_caja_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_id_caja_fkey FOREIGN KEY (id_caja) REFERENCES public.cajas(id_caja);
 T   ALTER TABLE ONLY public.historial_caja DROP CONSTRAINT historial_caja_id_caja_fkey;
       public       postgres    false    227    2847    221            M           2606    59750 ,   historial_caja historial_caja_id_cajero_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_id_cajero_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);
 V   ALTER TABLE ONLY public.historial_caja DROP CONSTRAINT historial_caja_id_cajero_fkey;
       public       postgres    false    207    2833    227            D           2606    50621 !   mozos mozos_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mozos
    ADD CONSTRAINT mozos_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 K   ALTER TABLE ONLY public.mozos DROP CONSTRAINT mozos_id_administrador_fkey;
       public       postgres    false    203    219    2829            C           2606    50616    mozos mozos_id_sucursal_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mozos
    ADD CONSTRAINT mozos_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);
 F   ALTER TABLE ONLY public.mozos DROP CONSTRAINT mozos_id_sucursal_fkey;
       public       postgres    false    2831    205    219            N           2606    67891 "   pagos pagos_id_venta_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_id_venta_producto_fkey FOREIGN KEY (id_venta_producto) REFERENCES public.venta_productos(id_venta_producto);
 L   ALTER TABLE ONLY public.pagos DROP CONSTRAINT pagos_id_venta_producto_fkey;
       public       postgres    false    229    2841    215            H           2606    51323 1   perfilimagens perfilimagens_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 [   ALTER TABLE ONLY public.perfilimagens DROP CONSTRAINT perfilimagens_id_administrador_fkey;
       public       postgres    false    203    225    2829            J           2606    51333 *   perfilimagens perfilimagens_id_cajero_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_id_cajero_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);
 T   ALTER TABLE ONLY public.perfilimagens DROP CONSTRAINT perfilimagens_id_cajero_fkey;
       public       postgres    false    207    2833    225            I           2606    51328 (   perfilimagens perfilimagens_id_mozo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_id_mozo_fkey FOREIGN KEY (id_mozo) REFERENCES public.mozos(id_mozo);
 R   ALTER TABLE ONLY public.perfilimagens DROP CONSTRAINT perfilimagens_id_mozo_fkey;
       public       postgres    false    225    219    2845            O           2606    68014 /   plan_de_pagos plan_de_pagos_id_suscripcion_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.plan_de_pagos
    ADD CONSTRAINT plan_de_pagos_id_suscripcion_fkey FOREIGN KEY (id_suscripcion) REFERENCES public.suscripcions(id_suscripcion);
 Y   ALTER TABLE ONLY public.plan_de_pagos DROP CONSTRAINT plan_de_pagos_id_suscripcion_fkey;
       public       postgres    false    231    223    2849            A           2606    50473 4   producto_vendidos producto_vendidos_id_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.producto_vendidos
    ADD CONSTRAINT producto_vendidos_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.productos(id_producto);
 ^   ALTER TABLE ONLY public.producto_vendidos DROP CONSTRAINT producto_vendidos_id_producto_fkey;
       public       postgres    false    211    2837    217            B           2606    50478 :   producto_vendidos producto_vendidos_id_venta_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.producto_vendidos
    ADD CONSTRAINT producto_vendidos_id_venta_producto_fkey FOREIGN KEY (id_venta_producto) REFERENCES public.venta_productos(id_venta_producto);
 d   ALTER TABLE ONLY public.producto_vendidos DROP CONSTRAINT producto_vendidos_id_venta_producto_fkey;
       public       postgres    false    2841    215    217            8           2606    50384 )   productos productos_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 S   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_id_administrador_fkey;
       public       postgres    false    211    2829    203            7           2606    50379 .   productos productos_id_categoria_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_id_categoria_producto_fkey FOREIGN KEY (id_categoria_producto) REFERENCES public.categoria_productos(id_categoria_producto);
 X   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_id_categoria_producto_fkey;
       public       postgres    false    2835    209    211            ,           2606    50270 2   restaurants restaurants_id_superadministrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);
 \   ALTER TABLE ONLY public.restaurants DROP CONSTRAINT restaurants_id_superadministrador_fkey;
       public       postgres    false    2813    201    197            -           2606    51069 +   restaurants restaurants_id_suscripcion_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_id_suscripcion_fkey FOREIGN KEY (id_suscripcion) REFERENCES public.suscripcions(id_suscripcion);
 U   ALTER TABLE ONLY public.restaurants DROP CONSTRAINT restaurants_id_suscripcion_fkey;
       public       postgres    false    2849    223    201            0           2606    50308 &   sucursals sucursals_id_restaurant_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sucursals
    ADD CONSTRAINT sucursals_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);
 P   ALTER TABLE ONLY public.sucursals DROP CONSTRAINT sucursals_id_restaurant_fkey;
       public       postgres    false    205    2827    201            1           2606    50313 .   sucursals sucursals_id_superadministrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sucursals
    ADD CONSTRAINT sucursals_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);
 X   ALTER TABLE ONLY public.sucursals DROP CONSTRAINT sucursals_id_superadministrador_fkey;
       public       postgres    false    197    205    2813            G           2606    51064 4   suscripcions suscripcions_id_superadministrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.suscripcions
    ADD CONSTRAINT suscripcions_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);
 ^   ALTER TABLE ONLY public.suscripcions DROP CONSTRAINT suscripcions_id_superadministrador_fkey;
       public       postgres    false    2813    223    197            <           2606    50454 /   venta_productos venta_productos_id_cliente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);
 Y   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_cliente_fkey;
       public       postgres    false    213    2839    215            =           2606    50459 0   venta_productos venta_productos_id_empleado_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_empleado_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);
 Z   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_empleado_fkey;
       public       postgres    false    207    215    2833            @           2606    67896 6   venta_productos venta_productos_id_historial_caja_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_historial_caja_fkey FOREIGN KEY (id_historial_caja) REFERENCES public.historial_caja(id_historial_caja);
 `   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_historial_caja_fkey;
       public       postgres    false    215    2855    227            ?           2606    50626 ,   venta_productos venta_productos_id_mozo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_mozo_fkey FOREIGN KEY (id_mozo) REFERENCES public.mozos(id_mozo);
 V   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_mozo_fkey;
       public       postgres    false    215    2845    219            >           2606    50491 0   venta_productos venta_productos_id_sucursal_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);
 Z   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_sucursal_fkey;
       public       postgres    false    2831    205    215            �   �  x�}VY��:}N�
���z4	�.�����X���(
��oP{P�|U4�ͦ:k���A`��.0A=�#�oB$I��L�tR�HHA�o�l� ,�����/)�t��y���z�%�����$gb�l��7zY�+�e��o��9V�-@����x`��#��_������%�ᬱJ��N����x�(�m���]`��oHC����$W����UA�B$	 �w ~�C,������99h�]�E�QY�n��8�;,��/�5v��pJ��ڮ�׺��i���%��R���zKK4��eOSo<�q�~"'-ج��N"��~�92Y}yXO[���rN���2�����U9�Ϙ\��*�*�-� ���o���!���Q�<�i:5�]�.n/�M8��(�u^v+���^���O�4��M��k� hG���4R�-���̰���n.Y����8���h�^_Y���?��u��Zm�*�*~�,T���c��
�|�ca��ga���=�/?�Nz��&��DQ�n=f�Z,��r7׳�T:�<��e.D�7.�����m��c$�y��S��C�C5�Z�~���d��˼�R����	�rYU ?�x��%��/P]ɡ_���L��7o���o��rj ,~�N�3���'���a��i^6�w6N$;{{T��4�8���N�Y��ٰ�9�ӕ%iA]��c����u�Wd����`��0�
���j �_褉���`k����@e�;y�	#�U�vT�k�!����ȃP*�u�=�҉>k�����������Δdf��ppv2{<���l>��M�t�V�E푧FK�[!�u��a\�] �*���F��6d02�A}��a��c(�������MK�+	b��������E6h�[�.;�Ѻs��3����i�Y�ߚ�7g!:M�W����v@ךR���6q�������IvQ�c���uѵ��~�K%̝Q�"��A�r&>���w(E67?�L\6�?"K����`��'�s���z�~`�&H��?�맯�,�Z�׬M��]��͒tJ]����@h�wdm�D���Ϛ{R�m��(8�I���B����l�$L�g��Y���'F���B�9&Wy!���L	B)o���ܰ����&����ݹ�;a��;-%�4�$�$pr�r���#���V|�*��0�T�Zy,ǚ�t֨��y���5��#���z����#���*�&sN��5��ܳڬ��%����&hL)�kb��-���p�`�C��O>�x �Rԃ]��M7|<`B(e�J�(	R0��v�5N�;+��I!���s��=<�6�%�EmӬ��֩���i"�ed}k֫�x��g���*�t$�^�a�L����F�|�2��OV��@�1FD |�>e���E2jfb����6���6�����'XE���)�i؛�#�;B{ԋdx��C>�̼�,JTk���"z��p��?߮�K�ҭ�~��1��/����������3�(8r\�������ř�vԿ���+�w�����2I{�o7�&]���an"i�E�T�#R<�4�)�*��P?抲�Տݺ��CK��S-5�w��O�z�iU���,]��]H��_'�6�ks��$Yp���DBe޷e�jIv59��g��*E��gJB�y~�'��r��7Ǖ�Ky=sNA]X}C�ny����G���Z���W>�-��ÐK��?ω��oKL>p0v������b�c/�L�
�Y�ah&I�Z��7}.^
_1���6:�}��h./��J�}���mf�$��<Ή�o����꽊�#*�H�
���2"~�gQ� �^~C�|�&�=�xǽ�`������سOá-lF�P':H��NZQZى�b�]
�J i}Ϲ����c��Ͳ�9�����;�U���������      �   `  x�uU�n�0<�_�p�]�y+ڳQ �-�Q��u��}�MS4�00��cv�����A(��g(��ۡ�e�p]L;&�}j�����}b��֏l�t�¶�mWl; �b+��N�2hh�����~�~=]:M�$͊M����r�}~=����<��l��=�����$:�e�]�V�2���}�S�I���5iItK��_� `)��4Ǥ��N�#�X��zU�GL�VB�%f�~;����6���0 @���*�T�������~6q(],�4YS&�X�L!��nt����ʮ�T8���dǣ�nM&y��z�U��,E�O����
K���t��խ�-�1�EI�N��d[��J�!/�����4�=�Aa#��j�ĭe��z����nHˍ�*iө��B6�&]q��O$��ﻨ.{Ys��Պ��[���A�=P]�(:U�6�%�Ⱥ�3��I
~k�й�y�.f,�x��\V���U2��������;.� \��8O�r�R�##ھ\�p��i:��/����h��尡(�K��������A}���b_0E8�mA� D��6�y��_W*�.
�J6�};si5Muq�ϟ8��}=�	      �   �	  x��X�r�:}V�����1�<���2�y6Cݪ.alc� �������I&}�R6��Z{�AP���w���������H�u��DB�cn�v,a��$E̷�KDy���3���G��_X�K8퉯u���*�y�[h��R���7kM�ى]E���mǬ��Q�C���.j�XC	?����pN�|����\P䂬 EQ�t�h�V�;�DVT �����(Es+���rx	Q�`�#]U1�,"��<���^Y1����MF���Aߜ����C���M�ٶ-��6���ǠVw�Aw����~�_k�f�դ��u���O�1.`� �D�$��� ��_�o�����o~���&�Pيw�ʺb�a>\�4M��K���^��	_J��F"��D꟮�f����䰚n���j�������RKq�Xٌ�v��_ƚ�}O�Ep���=!����T�(���/��9!��o$BY�_=�M����Cm�g��Em��;���=:!��-��!��!C�^�����km�ѓ����NCm�����6ZI���L��R��17/� �^?I ?�<��S.�7>w���������
Vdܳ�W$�:�SF,�����b�ț�� ���E��Nh;A�&��qvʷ/mc��}]ǉQ�l��c�J��s�TOW���( )�#��*�� ��@+p��1~r�3	Tf��U	h�;h ��oTB�p�N��@���W�TE����-�k,Q� ����ԩ~l[�R�<:Gc�^;W(i�|C��sj�	��`�����`.�=���+��!P�~���m�VP��ԯ<��ь]+��%D��T��<��!�׬(`�����q*t!w�]���Y�t�o��]����Лm��U�$T�=�n��M8ʛ�e�nE�46jqrవw���lY/��͆���"VB��/��	�I�?�) s��!��̎�0��-�����ڰCG�Fn$~�2���ߨ6.�E�������aڛv�v}�7�q�|%S�v&��V��rk�(W;�p}x~T9�IA���O6Y,�:�Z��H���k�Y�R���'�Q=���&+P��:�?u������g��G�%Û$�ݣcGF�	���N�#	�r-�mܮ�#PB��A4&�(<bH�2�9�|�H�P�'V��������3�t�#7����'u���3�A8,��h�W��d�0͐�ouNJ{�k@�Ɇl�g�H�2"����O�IO�M�jS.�I���0�
'�i���zJ���������zl^�$LӤ��"�xe��<N5
R���}̀��ip9H��ڟ,��m�����C5�鬹ۑ�l8�����y�A����M3�a-G��*L�mz��A/a�\�]�a�J���뚞	��@A��%6g�o֟>Z�\ʏ�v�i�+N����chF͕	��Z�oΣ�%\GNk�1�M|u�i=��3�O4�gVį�6��d�j2� �N���� H���#�
�<k�� Ã-+ӌV#�2��SU�VEc��Ǩ[9ؚ�>�����٦�.��V(������ݔ`�P���Z�����c��*��_�2*��A]�j%k���d��a�'0�Lm�ĥz5�zw�o���-Ń٤��a���5ЎBϞmco>؋Ҡ�MӐ��~����k��#��!}��4��V\�)I�+t*�Z�۽�c�����bP�<׺�I6���X/↙/]�瓃+��a�e:�y�ם�RY��:�o�M'�>�	��<�b�Ս��΁�Y��,�ҒcT��a7�/��29Z�ހ,r@؟}��ߺ��\[ל��m��߇�8�zw[�c7h�B͕V۴����RSV8�v�km.��xd��&+�8 Z�;�/����"�������
����7H�3׷���{p����t�"��}� �����@���DXz�Ӷ(�siP�&y;r.Mk��r�_�U��7|���~Q�H��ܝ�3K�X�1Ζ#�`�2 Xg�2d_��#�V�-�8��\��@����{6���[6G@�S���fyI�2���`�-��+�jH�k����v� ���>����O��K��B*��=d�{=����IqS����ݮ�_!����Fu�@���,�}�*M��%\Ӻ����`����0_�J��P��y"�Ӽ�?��իX7�e�}�W�Mբ����sR~�xe����%�\���s�9��[�]�J����\X�77{c����cǑ6��U��Jke����X5U�*���<�׻N���K����d,�b�>^W��EEoiE����Ձ�B�[��+Y���z�3o�/;�Y��q�3�/_�]�j���TU�C�S덅&�[��~M	|��Ӱ��
%�M��.h_��ǟ�������"b      �   �  x�}�ˎ�0���S����6`��\Z��j4���!��#L"���� ��HQ@��s?@N���B���ql����'~$�L��\�r%8����@qԀ��d ό�SN}U��=ڦvm��Kc{X_��
�װ��o�C&r��Q*�Q!H�M�	�?ixaDB�*�Q��'��uv��z�ݵ.�GC�ɄQ�J&��*8ypk�f���������B�\��X�����pa�ndy}
F!N���8X4w)�QJ�"RXYR���Emh��=�1(�렓Z4*#�lp�,9i�(�ZD�S�F���
�P0�@��"���@r*�E@I^ݶskwL��Q����s�`����2�����9�\U��;�E�i�k���[+�5Ģ7��3���N^�`�!�;�"���o����b����r���]o�7���=�x�������\)f�m�PJ ���}J��x�Z��!�˃$�NĂq�8�"Q�'�׾]~�j�푁qύ)��7��o�wL�m؇�Z��Wc�������F��3l�l�f{�-dJ�jƮǱU����,Ί,��,a7h*���8	�u���9ؒ2ሸ�E�(�w?��v�����b��yyu��Tm�,%�Zd7��rDcG������z2ǝ��K�u��Zd�s�/��:1�!K�۱��u�O����Črq�{N��-�����v�7X4���lW;|�Y�1���Uq���Fш�5 ��`qI�G��sj�K��}���m�.�      �   h	  x����n9ǯ���Ȫ��g�XF�B��f57���У�i�-y+��۲]���0�@���/e��\-���8�����#��i���-w�;]�U/E�u����g{�?���� �~<x���
M�d�5�Eg�?���0]G����|O��^:R�$ɾs���|b�0J0�mE6��E�KZ��8�J��t}���I� ���Ѣ�x\�?眵�2��m�sKje�c��֤��I��~������~N? �wB)Y�\�ɾ�Y�}��é�k�r8|g�Y�4�Q�p��NВ����@�^U&Q�tS��w�$5$���3����]QCZG��EW�8�y׋��F����& �z�Iaj��y�Ȓ�4y��~� X��.����{�D/�!�R�9�oj�%5d9�e-E�~e�ӤE� C h� �&B�Ѥ�D2�&�0�D�׮�1jHۙ��X~�I�ec�e��`%�ֶ�/jH�d>�Y�`���(����.Lϡ�RC�&-���(�!i3t*$3}+Hav�a�-�ޢ!����X���>IEj�i��ƕUV�ŎԐ�Q<�Z����&5�͔N܅_�zQn7j�6����L���KS�IjH����"�yt����?+�j�r�+Kj�z�`=��.���Ԑh�K�[ӄZyt�!�n����u�i���m������oG|KiHqt/>}=�]]5y�Hyb;���v�ї~ZCb�ْU�~X�+�~��@���\e��X���LC Y6�J�q���W�h�ۮ�/�����#5ęgp�y����Hy�}��ݗq�v���&q�����[H#�*D2s�sHgI(oW�?�ʟ�rAb�I��+~��b�Wo�LCp�kph
I8(�!\�p��KR��x��0��TpE��iH+�	mΘQ��P�!x�'��*L-xi����|�@A��׭6��<G4�]�wuaH����8���(t�*RC��(���T�V��LC*Y���Dr��Nr�GKɭ��G�jI�򟑩�d|�w�Ԑ��M���^Z�{����!Ko�ڭ���X���������>y(�4���j�iȴ�bnN����.�0�|��e����-M�I�a��*}��we�:xy�QC,ߌ[�	J���2~DQpԐ��b,zl����O|��Qßб;��0����iNVW��/�%5D-���n�|��T��l�7&I�&q���!K�s��珂��_N�Ԑ�4x_�G��#Xw��<�G�3�8nӤ�����m����s��b�~Na��l��ث� ��|���~�8(dγ�d��p5�Lov����k��%a�i�!��x����ڮ���_�-�!T��h��n���i� W�����3�\CTǞC�e���Y���{cT��
������qn�&�K��z�]���%2.�n�0�nW����������(�^��r��k�[�K]<:]�:�<�
i��9W��y?�o�n<�mУ*m]����Hq�;Bf������)�����+��i���R�V�a���פ��bZ�)$IL����q%.4��J��BCg�9�"K�B�|�)4D�$����\��q)b��i������M�a�������`��e�K�E��%�M8��k?%�����e�3�n��@Rl�?A��@�OP���y�eWV��}�ihPhh��L����d��b��3��2��]Kj�2�>��߼�f8������2�*?6�R�I�fϜe��8<���c�,V<M�
�����^���*-~2�r�L��M~�ܝ)L�oj�J��"����Q��a��!��3r���D��l�t)ؗ�[����?6�p�GH����x�&(!+�Z�����r$��ܯR�O<�|����[?h�KP-�F
�O��mr̎Ԁ%=K�?���Ò��2렃ԫ�!�����o#N��i��b��o>zbhHW������k�<�^��û��`�R��ؼ��Z�X���q�o�׎�� �]Ŗ�b�e_h��؛	XH_�煦;�WhaK�+��4��4�bք���V�����C�y� g��!�C��E0)xlEs�S��M���K��nΐ(�®4,j	ձ�=8�m�������kqۑZB��V����w#R����Z"��>��0��1��|7@`Hj]R�	en�k���8}:P_�p��q���$g_.-���_���<�A���)W�`���S5�!���Ň�.>��r��7�@��p�!�� �]������Es���GA`�U(��k	�}/f��k�����`��|CO�/�)i!�EKj���>�<� �ΐe��#����H-��{�'���Q6/P��P���Pt�X���4��z�%�Ї�#�����j}��x��R������[|�      �     x��Vۍ�0�����м�*"�;�����dk/	p����ph�&�����ʞ��_��_����F2T_
�By�1	E���a���hX�e�Y�@2?��wL+������F���y�<ᢴ�K�6;Z��8"0����Ņ�p�`��w�%��T������g��x8��^Ôȥ�x����F<�Qlo�.`kX+��%�|���N5��!y����.�����V=��$�������x�?�j���p��z���[��A��� :pt�#���86�8T_����k�$�c��'�ff�\��Pmf��|����2<�(]n�&���o'7{��j�E hu;ڭ1�GTY�wh��6����Q�/���A�h9���'=��Q;���������;����glnas`fn�G!�����;��5s���s.��<�g����H� �ks?�&��O?_�V�Ik;�t�RJa�A�j�^o�!Q�&�M����lP��{�O��IO�Ҟ�~eٯT��@��;��p��LӰ��<<̆a��C���gX�f�~�n���Ꭳ���jN�_*N<�Y�v~[W�F�oOC��-����04��)�űV�j���쐁��^.���LB���Y�PZ}aq詇_߹A��U޶�A���ys"�N�30:;|� �mrm,5�ib'�}�8�~�`%J;MI���������zCT�m��©��������+bk�־��O`��av�|����;�� C��      �     x���[s�<���p�{Nk�@���)n�uok��{%*��*��w��������	r�{�;h9r#CO�r�E���0�dpN�����(V� ����"�)�A4(��w)��4������'�/d�˛v�`׎ؽO�"m><����$��,𭒨�5���m�WkD�=a��h��i#����'�	1�b*Ư1�����2�"��'ph���S�tY�0��Г��#o)C �h����mъ�� ReǩD��p����ԝ:m�a�j_��˪۩0}1h���`�k�����h���WӜ�>�D�-#ՋD7�a*�9-n*�I4`��0~d��A�*g�\�rכ;4�E�-�	��)6�T�uX�Y��.���蔀���qxH�~�-i�j��0Y}qb,�N(�5ШV?��Z�_;�IM���^u�~�	��<���^dl2�d���U�T1$@���]�"WY9i��ʂ��H]@�d��"�gr��!G�s&�\E�i�����y��Fvc1��i�ou}ғ�����[w�쥿KJ�����:,}�o�������Lơ�/1�H��!
 sD0�aV��A]����.K:G[o�P������s�75���+�v�)�8Yy�u\��س��}c�R��hɇ��������X-�8&��tgku{ڈT�D�'����x���
7)����|���$>>
�ȱ��G/BQ�t�X�?���[�,Xɮ����Y��;�͂t��:��U��R������(�$�o��<���&˼��Y�Q[4�Y��ʹ���i�\b��
F�Xz����gr`@UC桬����Y>U&�焳�d�4.�+ՕS��a˲6_vf�F�Q�L����Oۥ��E4�{^���3!wb�"1L�A���L�Ŵ��6�Sq�ںv���yU]3C�7r��܋(?hk��~���m�"��n�ֽ���Z�γIk,�ዿ�z�	���Z�����Z���S&<�w�༗@〦_�)��u�G�J7�X��Jd��'��]c�j���~���������8���;��{d{����n_����}�-��sZm�߳��=���6pԽ��eS�v�&���`UD/��DuSU�a0*D���q~m@Nt�,k�`��;Ϳ'Ȁ.��d���n�����A��&�q���ګ��ֲ\t0�
_�	�[�A?q�ͻ��J!?�Cz�2n�&F�S�\����Bȝ���\C\�w����ZH��#��y[�Wat^���#z�3[{�U�ͦU-m]�S�Z�г�g#���/J_Wʶb%�в���5�-����3h&�&5~��J�����Q =�,��,���2����61��5��@3fC��ǿ��GQ.\	z����JY_u�Ն�G�a0jƒ��(��ȵgWuڶ���u|-���V3���;�S��ߜ��<�eLN�T`Z�E��k�{/eL�t�T�:�M�~�����q����F�rS��d����0��+b������_��7��ҨSo��}�)�7g8	�en=
쟷��ъ�2aS���p��{]�H�ً
��
�¿\��      �      x��}m��,����(�	<�ⷮA����4�Cz�Tu��* "I������	!�^���!�H��O�?�
���_����'�O����Z�Ѥ@"�s�>���a�~b%�X�o��(J��f�\�'� ZH��s�G����2��e�&� /b�S����P���N�4<�-���+!U+.I��U�'�!�7�o���oW��o��E�>)��A�	e�,N����.���ϴ��<�OZ�8עУ*+,8���yL}n%� �|Tm�)#-ð��H� kņ;�2Y�|� �YK�S���?j��\a.�r�in������bX��+�0����K�$4�{Ӌ�?�Y����OZGm���m������UgL���a&�t�WGe��e�@:&��>%>�Fc�_��f��cJ��q�]�0���pR�04�Y��	�� ��˜���p�����*�9����A����`�h���~�=���f���<C��0�Q��c2Gc�3T�n��'Y�	���;hWcj��[m�y�����{�JZTʛ:.��y��3����b��d�ߑP?�w$���hW�0��1@�iu���8�7_��qs�'MZ\��oY9Hk���������1z�o~�����(��A
�jw�9�1�{G�l&%��������dY��K����y���QO�4��O��ȋS��}�K��a�8�"�����S�0_.���;��lN��F���ɀ5�ɷ�ށ�G����甎l�S�<ҳ��{R�y�ҳX�9��a@y��t)��4��Q-�����J���
>��d
\�1��9y��?ZRX�fi�'F7�3�
.3��w;2�EE�!k29��3�ia����p%�_ړ�j2�L g�1��3�*���3$��a��!�!�^X��f�Q��a��7W���9Wh�Z��s��Yq�C�
a�'��g��:4>;�5���6劌�L�9��7h�AsG���Dl0?�C���6��,'$�/c�7s�HK�y�+H�y�u=U3k*22�ۈҦ��rh+��4����
�7����E�I�����1(O�U������v��8�Ѧ|
OS�^[��=��4 ƠTm�MU�AefN�����Ai�T��F;
��'LMzdzD�����1(�rS��4�dx����a@��&�!2#��&36��aP�:�11�i���|�bP�=T���J�h���Vuvb�FDJ,�N]*ȴ�x���1����k�{]�,��E��]�#�K�a8�>�]n ����ٖ�TU4��#��l~_�6爉���1��^��Ԏ9]�W�>�:XǼ�1��9�6�Xز2	��.R69f1Y�b�A�O�)1U�)�Uih�9{���i�$�n���MU�	��̩�.G]�Kzp����0h�뮔�����6tX�9U��w?����a�;�B��rc@'V�F�c-o����&��N��:< �c�&q1h\�C<l�1�JU��P1hCl�J�ɢ�.�8aЯ;���@��	3Δ�U�b�S���7{Ő w�śԙ�1���F\UB��E��2�.�i�U����2ܙZ�o��<�1�s���ɛyi�+\c)7����+�1��'�x�ċ��'�S&a��L�����`9��<9x�gc)LY����]<���bf*�N$/��њa0���c�pE�J��|�*�2#<�\�
�{��p�kU����y��?���{�D�9a0�+-��8�j,y�|/�`j�b����`�atE����F)�}$��3�����Z�i�ɫ��1�/%2�����TG��țY���hb({���[��(s�C�Ԏw˫�W���p]�L�^V�d� +P}I�Lm���d��æ��"ծ�d��� �Y/V�U��)0s�]n*݄�E%�U�� r,�a�3���ؔV�E�cA���,�m�5bl]T�|m�����*e��S*����Lw��X>řƂ�8^n���sL�����ܴF	ax`oZ*S1�T�܃��������OP!r�Z�HU��<���B�-wT?�`���<�Ɖ~Y�yj<�F���Ofj7�^�ܘ.+�0�zޛ1'��L���)��s/�]��-s7�ߍ	��EA&���GbMUϒ���1S��o�B?������413�9���n��E}�f�@(��!|pY��GT���`�0܋�o(�mAކ����R�>�Kzd;�BC]�2�X�b���^z"o�o���(��2$�C�|rGZAi�W��T
�	L�9U>e�^V�[X�n��w�*9�#Z%	,�c/�f����U�d��ߜ���'�i�X�{Zy�x�]�<X~n��`-�{�|J��`!r�{9���~�it�������<���T�*m��얹��%c���g2�x��&^��/�Z��`U��u!3-�z���,K�'�I�:�%y��ߎe����U	q���C`�*�Q�i&�ļ��{�*��X�{��EQ̙�h'U�[	���5����`1�E,u�#fcj1�`�o�0�"b&��(.2f���������Z�ß��XG�~D=svb�'�iM+S��Q�=�����A�;�F�4�1���(�}���^`���7.�y;�S]���Z��*-�U�g�3U9c�ʝ�[�~�y��� P!fo��v�N,j�"�C�D)c�0�b��42�H�����X��Z
��0�0'G n4婖u�n�f]aƘNv��	VEq0��Zo�s(7?�C<�>�W�<ҕ3]Dd�9+0�z�/Ҭ�U�Pv��8��z��=���q�0�b�s�Wn*�g]��T��3�`)�u`*F����PH]F	���02����]����H`��1�rS��Ѡ�l'�0|���/�K凹�i ���}�M�2�O��O�Z /i�
*Qd�Ȍ����.0�j%[w��P1P�͗e��z`M�ka8�V�P�-�";�A���(B˾h9�t�1���#tw\�};Q�2�0x]�=��C#�s3��m���0��'���Ve���A|�X����*�{��{Mv���!kڋ-f�Y
� �{�d��5q���`Q����27儌�_<���kG��^�,�7�W�J{�@��+M%)��?ߘv9���z�� ��/tt�-UƷ��j�/1o����6t��T�N#�s���E�:��ɖK����~�;�*�/ʪ�A������dn6�ml
���P�M���3H�;Ht>��j'$�ݲwGd_"eG����k[�c6���H?wl��.Þս�� p�_��d6Ҏ{^9D���e�T������.�h,Q�8���;&wv�	,�>w��2l��l���`u���6QI�`W�G�����Tnz�-p`˛���*E�*S+��aS����a�*�+ 1&�v�\Tq�1��%���P��[���U��`Y����!�az�����G��^��1��3�M��r�$ �^�V�u�US�)�w))���Ŝ�������d��c�����535�c:��z/0�Bmh[�*���?���6eVzY���î�,�,~բ.0XuK�%��va����G,'��h~�IB��+�v�	�������T�r;oE�B&0����� ;�\�5R�(��Ҋe�v�7X[}!�Z�vmƦ��.5��x3=l��w�ILMЍ���:��`������aNX��������#��4�!ͪ�/m����.�"�m��Z���1a� ����P3��u�'0��������Uyel�J������4���^��;�����8!:��cR�{��Z���#��/��Ǐ�u�.����ǋ���<�q��Id=���@��פ��7Y����n��u��_w�uF�sq�Z��ޓ�]��~�E�O���m�Xe�zxHQ�v� ���K���������~M�c=�u��c�U����C�Jr��U/�� k�_��d"M�h�<����aӳ-R� � ���>%�˰c.�<�D|΅҄Hf�����ȯ� �  �y*6�V�$� /K�k�rSc�)9��N/a��u��jbo�K�$����|���MqX���������x�Ǹ�]����
�c��ɜ��A�����.In���(�*`0X�.h������,x���%�z�WK�1����d%��w��� rS����w�\�I�����U-�����z��H�d�V\Y�c����U�$/n��b�uor3&�� �wq�a���
 w��9�@� ���^ч��>�c���8�U��&�\'srb�W^yK��Oͽx�{���.A�x�{�c��;~��%"��O�W����씙V$� ��Ǡט����H�A���4���4;@|�3x`b�_�z�5J�z����� r@d*�pX3��{`f��z��_z7ܩ�
;cS�s�郩0��2}�|��s�M�ܨ9�C]���(���M���T�u��';1q� 9��!3Y~]`l�|q���{]a����,݆�)�yIswdh�+)�e b��j�0���a�w���"�bN�-n�M��]�<~�&���L�fa@kmDq!����aS��2M�L��C�6���
l
d��L��{2�e���!�)���@Y�u����>&�)��Q2��{�g�6E6������O`S`���Yd�yƯ�aS�x7�]��
"���2AqSQ��M�ov�,�F���w�6%�7/�;9�����-M<�T�%����lb�ϕ� �Л�� +0���7�i���]2�`����A9���o˸`�;�=o]<L �f�;m.X���:��e8�l���j��������~@fjBo6KK������O��&�]�����ψ��2f˯n��������d��� ��������/�錣��5ͱ[�"��}�	��X�a��� K�/rԜ���(��X�~���ZeR��
��L�O�rI�������dQ���q��M�� /X�/�<�.{��X����`23x�B�b��
�� o����,"��B�F_~���A�.N�8}Ĳ��y]ص�J�0�s�.�շFC�w}3g�~�(x��ɀ�1�ϲ�]�Nf�YI�RE��	�1HW�ۊ#��Ưf�\��d�L_����a�«d-k]�� yx`Ϛ��(?X��&Q�}��#�������daӥ�vg�A��4��^��č۾�ػ� qo�{�K����3~Æ"د�B���VRa��j�����DNm�aDa��j__��Ͻ��ܸ8�0�~��5��5s�6��a��jϷ^�M�����ɜ��A�ր?����~����� ���=O{���*Va��ewǳ�E�M�(�O�r�� {�^ĉ"֦���#Ul�zw`��w���`�������>�/��c��3z)�J��æL�-M�h�����1�o��m�ò�*�1H�倿ּF�Mel�d�u���YW����Ε��h�j<P��u�\y��a��(���/ �}�t      �   x  x�}�ɒ�J�����9QŸ�et���Z����q��}mnG��[��%��j	��;�˓�sJ�*i��m��ϥ�F�(�׏�y%��gQ 
� ��3�iVd�wƉ�"$�G�:�g�ש��� c��{(q�L�c�t�X������E
�45�XQ��]d�8.�Bq�%7J�Υ����'���Z������`U����U��ʔ��0?��a0\ٟ<v�<�	����4Дȼ�!PF�)��.'A3� �^�a���6���f�r�J~д�!;�1Dxh�֥t��A������Vq|�r�+�u�_~Ҁpq�H���+U;V6��ZY��z��`MږX+�F};�8#� ~gx���{R�vn��u���斲���U���J�&�k`����AF|.�}g,�by��h�`f�.�,�L����l��`���D{���bf8���dI˻(���_t;j5ݛz�����֟�v��N��y����W7�<��=|a$�p}�*a�d�mPY@�����
V�n5ՠ5������/cH�]�pt/�5��7�n,�JI��[�X�##��x��pQ�nx�}g"�����-�RQ�����}�4<Rξ�]$+�NNIx&o�不��@�Q1_Y>���a��lIq��|R�h>8]�ـs���@^���hŷ����z_��ъ��կ��M�ơ�+>�)F�x�;���I���.�ˍ.�����KW󰼝�d���L��b$��n3��3��uef��#V��E�	�ܾ	�����F��#q�l	^���6
̴U�壼��[_��x3f)�c�4 ���)F��M��?���      �   N   x�u���0��,7-����� ������Q�I抱+Myn��yX�d����Ҳ�r�sd�f�����cpS@�      �      x���I�G��ׁSī�e���C��u��D��$�A����u���~��閕C���:�ɤ��)�ė��^Z�������R�?�i�G��h����SE��]���Q�?�uk�G��h����S���J]~�ݻ�nt�ڑ�V;�5_�K)�G�J�?(�}l�(���1�j�G�?~����>������3L%�n��Ĩ�`��G���O�����ۿ��������O/u��?_ퟏ[�G֯#K!ο����^c{K�-�-�����z�Y�����Klڨv���[�\���g�>ח��z����_�_���y��~Y����	s7�s�H�oU~i�^�`����b;�b�WH�/t,�d�����r������V��F�2c���������/���F�� OZ��R?��՗U�Ïo�o%��
��> ���V���տ OZ��W�\��`��-�m��[�Pq�Ӄ����\��`�����W??�|/e��㇆��������? ������~~8���_?�����g��~y0|@p�˃���_\��`����ׇ�u{"0W�>��կ�@p����\��p�W�=�|g �S��+��= :�t�~���ul�X:Grz�]����OXJ�,� ��T+#�Rv���$�1ꀭ�byǊ
m!���?\��W���U+A��s+␌�POiE���'[�o�R�g���ÖS-c|���W����~�>̊$�uH��-�:��03t�:$+R��\�C�"BUꐬ���
�-��m�>c�0�Q������/��������?~����|�u8Vd��d�#����ӏ�kDq�<�X~0���V����R�,�x�}m�؄A��fl������<r,�d-�0�9؋x��
sp��Q��/F��Z�8���:HS��Q��T&���}Ӿ���������_����&�1��2*�m��� �C(L%
��[̢���E�"��z	�֞AM�[πQYd�~���t�2C"�m��f�ȈĀ퓠���G|����|J�'�qJ�u�@Wȿ-�#2�~��	�LcV�3�d4*{���L�0%��^F���ٮ�)=}�����o�~�*��N���u�/�E�������]�ӻ�F�b��3]��V�=�-�5�ם�)��)V��OiTw�&܊�_88*I��'L36�j(�Z�f�ytaP�X��t�'�A!:���sL���]W�0�-$��$J37X-vz��ۉg���If}�s��)�9��=�rP/yYC��'|�,��������x�y_��Fq����C�@���x�1�,�o�p[��3�+=7�yL���.� ���x"�$������^T��x��Ù����u.������5�pE.��M|��gz��̝��`W�hnck�� �]-�kt3���	g�i���1t�9f�p�q��y���J�W�Cy+s+ej
!� ��<�4���>mi�������r#C��V�bt��)"�j:(瞲2��w�Qb�����j�d�-�΍ڙ��+���&��ݼ�tw!>e��.�gL��\�:x�9W�����
ʠ8OHj���zB��Pw�ru���L=|:���C�v�N�R�����k�oqjd�gi:��)��<�A]'��p�N�!���!�-	%c̵1e��;� ��r��&�1�vtO1���O���F��f��6{�QH[�J��3�����t��D_cK=�,�9�u�̴g���`4Ƞ"��)i�i�*
tB��3���?XdP
�1������������D)���@򪏇};2���1�=�aTi��)@һO�7���W�lN��Vߤ��R�M"Fx�7d�1�Ɏc�QFG`2��#>��:[--�$���"N�3�r}����H�o��#�In#Fa"�[b������������1`Fb2�pO��Se,�]M�0(�5���,֞hϢ{Ko����,�c؅�,�g�Q���[B9��t�&h��-5�0(Ԛ:�r9X��s}�� V�1�T��\#�r�����!.�|�";	��핹�/���2(��`�IG�U��W���T����`7�4�Ly���G�1���C��Ӡ�v���71i1˷�!�4�]w���s�0('�����&ύ��)�X?�s��Dmn=����/�R���t:䜞��ͤ�0M��bG\�|��N�8�U��v�q�O2`F&5��5=1�1�������@p1��ء8׷
ɦ�L���:H� j
�c2�3�n:�N>K3y��	.N���I����A����y��O4���.���G�����G���.�Wu���d�I������%�KuB�+�VDؘ�l�2��-�����|���VϠ�0���A'�e�)���$a�G*�$�� *W�8o���.g����Cj�@Nr�P�1���ݙ7�@N��N�ks������<ɀ�9�y3�=>]slC�֎b��5c�Q��U
Q��!i�x������O��!Zo�����V@�`o����9٨��v�q��#�n��\�+S�0��ԃY��d�9�����A^��pm�N���qj8�V�Pzzf�*:ht�w
4pL�Z:�)�q�Ɗ̀�p���ȃ7�IDZ�Vf�Q"��ȃO30h��0��5��*N��15S�c��-L��B�"Ds���`��1��A�qmɍ	��8E��sPq-T\�S�5��(y>w�t�?D���|�i
Tp�}�A'�;ij8w��q��A�ι��8"���P�3k!�Z?�P�}n�0�h����&�y�0���v�����e����Rf�bߘ阆�év����)��S�L�������S��ȷ�N��<AH��摄:׹�_�9h��AF4������!
N�;5\V�qy��:���@��vHㄨ-i���-�mH�Bi��rf/�PyALq�%��=��xI�����m�}"��9H�!�Ok�#Jl���:�$���ع��s�<Ġ��އ�w��#�T�j��c��<ȏ���+����E�-��� �AIS��s��n��qE�tm?(i�
��o>�����|y�3�����G=G~H}�-�X�|�vz���lI���?��N��l�~g;�w��z��d��1�4t!�dZ4͕[�:O����׊C�\Φ�ǅq�� ;��S��U��Թ��G���/��v�ˬd<I0ѧ��։�vj'����K�M�[&Bs�%�R��AZ��և|s��4�K>Jŵ�L�o�Aڙ�=��8KQ������3y;4a
�A$��%�!aG�S$�r�u9������Z�U��!�An�8E�X������l��Q��!�Y�)�������f�I��]��k0.����[U�vҳv���m<N���1Y�q<��g�Lu�S��)Ӯ�M8�($v�M�E
2���-HNK�^M٦��Yg��글�!�R�)oE�1{�a����9�ɐ��L@SG(���B�~o��v�0�NG��F��������A=භR`1;˂�8�ܵ��Kv|�QoO�6�H��б�[AD���u�UA���������B��N�	Z >�񦱅x]$�R����D�{$�3��|��L4�G
��k�:4YNI�
_M~�����m�eV��ZJz�J�&���h�KV1���Ή)iG�[С��>�`Єy`�3���K<ѹ�e�fꎰV�ص»�u�v�#m�p�
��ʸH�-��
�D��t/P�i�d4}��d�!�&�nh�p����~�~�s�r�@cߐK72fb��(�"�wL	�?�6!3����!HffF�}vu�)�0���Mp؄�T�ծ�������1+n20���o߾|���������`� �2�����yk��b&��G&��$"�")�,��#������:��)�F�$�źRZ��r�!���cv�A��Q�*���[�v6��\LV;�/��|�½��w��b�v�5w�9    �� ��ܨ�2Cz�SgB�Cڅ!���+d��l��\V>�L������6�X\�:}y���-xV�)���]�sH9�b��SDu�9Z�u7�5zH��e�D�r4oL�'E�S�ߴ�*��,���[=׵	��=k�x&R۩z����_������䷢<����#`6��r��9���J�5V�\/[�Ih\
$��K*1<�	OH(g�U�|�T�De?y�3�бN;� �N0&=�*��b)�DS�ᦉ}Z��Zf@U]�f�z�t���θ��Q���@0Q\��'�E������$�۠c��f`�����`��t��.�>kOZiG�+1�L���y����3(�^{DKw�ؑ��'��չ^��Z��#�:�R��sh���x3��2��_�����]:5"K/F�y0��ݞ�� U�В*a�ل}Hׯ���
l�\��lL���QO~C�<�z����8��Ǡ���Rx�=�.��H�#�1��e=n������*A��E�h���>0*&͝˗��p��ƛ�W�)zd �X���N��'O���Q�1�k�Z0�,�a�Q!�-Bu�h�涕0�������Uw1�!�:�^�t����g�
�.�:�4ۑ��KHm��Y���.�`L�f�^r}�`��xG";����S�Kϐ~C�Yd�}u�7��T����j a����G�]]���l8�0"��6j)Z�iK���D
�%�R�3�L�5�j�iϠ�V�-����E�SdB+�Q+b�Ss��Z��8�/2�Zwjmg��?[��~�����|�Sag*YD
xUV��9TqD��B�m=��j8"�W1�È������4���Ed�,bg>��s��3$�$���P�Ϡ�-e��~�A��:�� 8���>\�k1���\S���������(�C��t0��,ƔA�Ah���C�5h�5ؑ�g��h� �Gl�l�`3�9�mH�v�O��8|5'l�`�@5��CI��O�����i�ƌ�C0�`Y�j�>.}��#5f�2�k�um�Q�Է<RP��p4�1�"v"�ۂcH�ڨEuOk.�����$�˵�4�Vg�S�kh�T� ��\.�!d���1���K?��ݫ�7���<��:�M�K�¡��ro��;}��ٺ &4�{cċ�����l�CP��C=0��h�{�"�@�Il.�eH�/g�/g��0�����H�z��JU�=ƞ{6��AdH�	��� GS�;���&wf�����W	䟖���tj�2���A�t�b;��iݝ�ۑ��	!���LAw�?A,�xXb�A��t�k]�Ku��i6=-��ms�,��3̂;Jΐr��;�	IZ���i�z� ��z9�"�������tbC=ҏy�Nb_�L�ufܔ�����ŏ���A�kY=��Fug�_�b�ql�${lX�=�@.L��K���Ģ�v�� �J�U<�Y�@ڠ���	:�;�hz�h�n+��5�J�A�.v3B�S�^�E�q���� ����� �^�ACÞzʹE��yKiCV��)��vد�k���_(u=���K��|�0O�aD�;�eL�����E_�A�M�p�vRoY�ε�n+��.s�Εl�䨙�"�{�NF0d,3^��둊�����9��U�=1BA_��%�M�� �'�U$*��Bͣv���޶x����S���+z�^(���>��P�MI\~���/�X���Q[(kϪ��}�MخWN;�?x5EM(�oE^�A��S��I�KQ�o���O?�-ڊ�@��V2���>~����)���?~�-3�{U\��z/Y~�]��M���)?���\-��(�V)��'��7K�ݓ~9�Y!K�ݳP
-Y(��L�	�ףU�)%����}��q�/h��-�`T<}�g���NUӈu
~�/jŐ�?��� .�.w�p���9�0�ۡ"�e��ς3(���Ln�A�M�V3D��m�X�,i�ùӝ�c���v����y�iw/P���Ծ���^'�[l�����z�BjX��ƍ۔k�4����-�>�G�y��vCj|�s��f}.U��l����xJ��}�3�@�d��!$O�_���&ZN/�[����!� q>]�k�S�z�\�����b���b��ȵ��Cӟ�0��Ci9O�ۛ��n�v�Rb�=J��f�"��hze��Ҵ;"Qg�̒��o��I�-!�~���]�����_�����럯?�����?�{E���Ky���M��àz��δ3����Y�㷏�꾼~���_����� �����}����q�n�M�̦8(����y���� דȵC�q3Z��SPa7ں���j�����弞1O���s����=��	���>�`�r�ПA�R�;� ܇�~�A7�B� �TO�J��v��d���w^j5�&1Q��C��Cx�����o�~����K{*���>`@���Z\�F����a�� �r�z�-��!4�nG
.�=/i�:$��*I����PukcT��Z�rQ��C��sHƉ�Q����im����gFm���5��k��$�,)�d��;f��sܴ� ~0�L�Yy������*��z?�j��O|�������7���7�I0\�'ΐc����zM@�	vx����J�^�X+���U�/A�g�5�&:o��?��>������޿xK�~����t��#�������:��]�t�M.��,�W�碃\tA�	˻����@�a�<5U;F/�
Q]�@�ұ^	�H\��H���[r�M����{(Rq�;��j0�kdB��&��:
�7{g�%�)̀eZ7S1q4._I���#OZ��jrE��p����)z2�}�J��_O�S�ܝ7��/��s�ZgG��D��7N�Y'�#V5�����x�x�И��8:�g�s�*�'x���St]KD�YK*z:�� �kV���JAt�Q
�����e�=�-	#�%H���!�0e`�<�p0� �0qLo%�
lB\����5gG�	��:+�dfu�(>�+���Z���vYK��l�k�!`��PJW�Lz
k%Wq�"�T&C�ᥩ��1�:,���A� z��A�-���A���e�ݠTtkTD}����5�H�S���Ȣܩ
�7�j�Q�Bלa�"��4KR�a׼��R�|���m����iC�>8�o-�(u����H�	�>� ���y�dO�C�P��a�J6*��k��"���(�`���
E����������ITT�,'V7L�R�@\E@�4�l7�-��p���Z	#j%�{Cw�����q����)еuGrGԼ����E��Ac�8� �;�k���Qd���K!�E�����>h��CL�C�d7�� 97�!�	�sV�2�\"��5�1�¬9���X�G?sm�����$���X��|��5pu)��a�nD�<b�%ek����S+��,ƸvV$�`֍KF����U3i�鉧�%�yޯ[�fƝiO�rܨ07*(���\��ԃ-5��� ҋ��"e:�7��d;�Է9G��؆�^�e�� �u��9�B��!�;�2�57�/�޸���Rx��94(���A����Q��\��j��X�ӝ�r�{Cϡ�ĺ'M�qػۗ�)2�pe@4���>O�z8EsN��^�𺷺C�u�[�]?���`��\m
�N���4<�tT�޵f�8n�%�c�>��W��A9���h��sM��g�򟃃"N��ʦ��ٻ��\R+�F��N ��ڬ9��ڛy�
$\�U�4���v)����Vj���%��E"z��8+c�Q��W�/��fBkI��#a� {��A�=���eH��9�^j��q qvjC��>Au����A�8�.}tE��)�]��@�ʱP��ǿ~��=���.��\�����L��Z}%Ǧ�q�4�t�S��y}�_�?|������j;|���ߊ�}�7������}r�m�)"�1͔}��A�f�.��H1���*E���    >����jQ����4E*o��	5hm�C�h߳sy[��N�фΖD`EF��[6�@d�/g��e��it?�@Y��hF!��aP"\:�j2]4�ސ���)����:.��7���dZ�z�E�0�X�}cȱ���VЭ�eed�Ǜ���o�@Ω��%��=���Y�"�H�����m�1��6�نBL�"U��">�"�RbE=�.e�-�Ft!�W#�`�bYTBE��0��%�X�����e�����N��қ@��AW���� ���RL�+&K8U�Vώ����b;Eu��*��� �R@��He��>�-Rු�ѡ,�x�/�F��\��_�xt�]yGWؕO���"뭬�{���,iG_��B�ܹ���Ʉ�$f}�@�@<Q]t�v֮�T :�Ga���2%���~�D>���B�L�+�����\Dg������C�!�rz5P��vȀ+�wA���ΚN
A��A(L���Ѻ����c��	�R�tT�mݽ��J��c�*jeP
��*Z�&(���P� �u�sAĄ��#JZ}��R�� ܆�~o�A�T�����ي
�����7e8)���A�Y]v�#3�������2r�z,�%A Np%�(�+�H׺�}w�֊ �4����dC�!h�ew8������$�N3dsqYW׌"'6�yK�\)��R[b����#4��W&5�uK8�������gV`%���l;Q��N#��!&ln�!6��8�֘���}�8%\|f��]+�[�N�)�N���(��?�NzqTC�2�>�<��b���Ap�U@� �vKiR�j��
��'=4j�kR,�h�0"��(�+4��e
�:6U� �x�A�G�]	0��p��(�R��nC����͑CȂ,R�o�"pg����/hF!��!Eߵ�j�-��Q
�7j)pŹ.H�t�%�(8��C
�@w��!����{r�S;�,m�r�"�"��%+�� t�`�\u.��[n�_�����Y��\dË `���SI�0E��Έ0B��{�"��iA�*@��W�	�W�����Fp��Sa����|�a�q��k�A�G�b*���Sw["AYp�8�Р;�eH���"��fװ�C���{3�Zi�&�n��!P(��k:V�O�j��{Z�G/t�?��yiJ��M�V�M���Ji�ݗ�d���/��Q6/�}���T3.Pe�"Z�Ka���j�Z�pʥ�]0��p���}©nb�E����D����7 q��(Hg��C��0���B&���<+��ƅ��X��Н!�t�M9�k�Id�^v��V���i��6ZN�-9�A����ݩ�6��?\�����x�.<JlPS��`཈��R�����c�4C���J����s��elQ־�[�׮�����f�����.C��Cs#�,�^��u*���[s0���0
���0��7uCS�S�������H.P���-�ġ���Q���Q6+u,�|j�A�s0�S�2g}y#�:�B�x�xz܅�N1U�U=2��2Ug�~���T��=�I,�1\|a~r�xGj�Z�}e�Q�%lW���I�S����]Ba�j0�L���]�Q)HP����#�����Р[�Q��jk�
��;�AA|���i�Ri�i�_,KC(�X�C"z
�y
B��}�/�R`+&�H��$�a`�b�Mʀ��ď!�|��e/��<K�JA�jo�0 �F��z\ ��k&�<����By��=9�ȃϯ�TѪ3̘t�2hW�3�!&��$�e��1(M���.�/��)���㍩�X���z�W�}YGN�L0C��9�\�Ɲ��JC�v֩��,�*�BgrRM�)�������g�1-ᷩ)�:���ޭ�Xe��_�Tk�������3�����%ೃ����~;/�S��{�?}}��������k��d)B���.)��3���:��_?������U�'��_*κ������Պp������^�鹋:������ՙ�4.�n��v����p�nݶ���|��W�(g���[E�e&�Q�TC=4^n��z�/��mm�����e����b���;���4����z7�vx�ѥ�!�3l�L��R�`-�ya���{NG����J�r������1{fU/B�R��!���u���ׅ"_������S�n��_)��7Efo��a�.�����@�K��|uM�Ve�G�/�oga*�K~�Xx����t�2����?����Rk���*5�-2^+��/P*_��V
�|9iŸ��K)x��(��ʩ|T�{[d�W�]�Ȥ�P�o���M�H��[k�4�%�o{
傤�3��Z,������1|.[�p#���dj$�F�_!ɣ&�l��a��ٟ�x��SP�����(v����~N�efNYLt�����:X[I�=T.�P�8o��`1���C2G	�ї�"�ERv�'�M$[�1�Ih�h$婌�����
R4*��mc�	b��m���i�m�H�3�ε3pD���N�Z��)5aD��vL0"��I�X�C��]��p�w$��ꉼ(���5�N���J�
�@vC	���cyK�,>%�[z
��=3QSR?�Q)�����!2��JX-�=z�uM�c?92/�3����zR5C�>��Ч�ԧ��S�VKk%*�A�K E���ǭ��+|Rh���Q���I���1Q��U�{��Z^e��R/TO1RO�S	�����lZ|]1�8!4/�3��D����5?�@ܙ������7�
ݑ�%��6fbC4���'�|��?���9J�t���Eu�y�󕽖t���G�K%u����Z�_~��ϟ�]_L��P�3`��8��q�G_�Q�0�>��e�zS�B�rh�	�g�����(cj�Y!;�)��3���"�Er�I�l�C��0|P��3Mv�;�-K\�U�+���v(e����0�F|)e��7�	�����!��C8Ηf_�!����϶�=vfu�<t̩g_֔!p�#���r�@��sF]�	�䒀����J)_�2�p�6���;���6JY��6�F$�dPА��r?��w���k\K<��"��?6�F��������ܚ��p&4�����e~����0���r��������/?V��/����K��5c�׶o�f�9�N�?^ʅ�)�w�������Α��0��*�������"s�g�(�krْ�;wZ^ĔD�&�}���;��yM��e0�I>�B)!g����b�꧈�P���&os)�'��'e&,���03��|ᕑ/��T���.C /�+2d��� �;��;r��w�k���0��s;��c�f����{&%����GR@p>C"
�����gff:v-��6F�c*�gv9�����Hp<|YE�`<B�DR
D�V4&�����v�;�RZ�R��f�yx&�*���SV���VjU*?#_^�2�f�b��Ww�yK�|%GcR��U��V)�� U)煔����\ ����ؙf��şS��"(�'/(���v��|%n��2�'��t9�mQ_>}����?�_?���/����A�oƄZL�ϼ��YS���OήD�1zO�������1���ʴ�{�t׎=rZB�~8xnkja�LS
�ɹ�r@�1����?_�En֪��P7��MK��o�j��J��sv��F{�>d; 9B�C�|��x��zJ	�S��K��K�G�zӯDW�6�0�j7=z��*V��.����1("�X!�`G����>��[�@:�9���ǳ�
(�����f���<����"��ַ�dB�b���G���UH[:wAUMC������)�R��L:���w��.*�
J��dظ�D�PkS�8}NdE��.�PO�hu7=_�S�B�+L�[�޽-���PU�ͣ�q���>C��t>r���E�*�m5/�W �  2��t��&�굪lܟ�{��*.�9�ak`�(P
�bя�v�`u��B:x�K�j���ђ�w���nw�B;x��`�h�D��&��h�����"�*MK����_ޏ2�*�Dy�x#��<m2����1ي�q.��d�3���9�=d�eH��4ۡn���,ˣP<�����g ��+	S����k(��:f/H-AJA"�2U�؆��#e`������4V�G�(��I�i�a��w��q�FA`R�c0�Y�Fe���.ave���E�n@n���eTn�X�{(eh�d7�e�l&2h9vG�z[�{Ņ2w��q�NWF��0�f�p�/�Pr_��L�i}�ɪJ�X�<j�-�y{	Ƞ�% MS}�?C��R�F�zDo�C��O�0(��/h���U_Ś!Y�20LC6-K�:h������X�UT}�<
Uh�evf��m�mX�0�\R�Bj�jvÒ`Q�M���fX�����&:�Z�����RT��!ˤg���hc���"���?f�cZ&�H��9$p9�G=���9	-�F��q]�R6q�RS��w��%F5|������������R_�c'^�����QE��[zL�ȝ9��K�ѩ�gX�G
�P�cf�����(�ĢV��OG�[�c�]�X�3w�CeW��*�w[gT���"q/�B̫�#���䎘�𙜄V��G�)�D���s��/�*��֦U9�b�T|S�o��I��st������0UNg�+�*�tt>5�هRb0j���:\�E6�b[����U�ƕ%Ϊ��u�I��G!�[?�jZa�߾������Y��G��G5�%;�_���xtb�_���F�z�[_��S�{��6������Š�w�C{U��䡪+/"3�.�@�zG�h��3�|I"
�?zY~�b��OX۲r�A����ךUjFٱ�c�9���7zo@��$�	rO{*)V$w{�A���ʛ�=Z5�8!���Cw�˿S�R�}p���,]��.Q(/�_�����^t�P��-ֽ���-�*�a�P
V��9�{)��4���'OÁ�=H�6z
Ʃ^��d�/ي��������+T�6��G�r�Ƕ�ö �����J�LM.S�,�]�|�2����A����|0����-�5e�T�Z�Gt;Bc�R���C�ul+>�N��I{*>B�6�pNx�;��Q�ӯa��
Ø�Էğ�������~ k��Tħ�)�K�ٗ������LFu<�:NIFJ��B�;V�0�>��Ky7���.�ТG���V�L��gU��%�\�*�~lZ��N�ֱ�J�C���6�c��R��eF�Sߴ쯟����o__o�,i��Ҩ�h�;*���g�$�֧ӗJ�~�&�J�CS)�R���l�<V��k�TU��'�����͊��gn���S���Cc�C�/w����P$�Tl.s�T:�F@)[U:�"��ڜ"��v0�DM��!�J� �c�	m��V}�U�z���]�k±�mdmi-��<�qd���C�8�g��P��jKX*f^���Q��Z���:��*���/X^0oh�@���e��g�:����L��M�j8�Z�˘���TѤ���j��	y.r�,��Җ�L;��c���pԏ	��&��e�*�?G�b���h3�xS��s�,�V���p���Eo��3fm�=G�ѕ�p��P�q��x:F-���2ޒ3�N��c���AKÖ؛�*)qo_)�����4��>�!���=��4�}γ�b�K\��g�U\qg3)�(�sТA"5��nD�mԔT��~ǎ�q-��%2��`\'�EH"5���zDz����m1��!�:NBe�x�>xlQ!��b�C����I��P�Dfh=�*�$�J�<6ћ��:��s�Z�0\�Ò��>.f4=QD��U}ݝ/9�r��Byi�%�.Xӷ�BN�\p��\��P�g��)8���hA���h/������_ΰ}Y�fw����<�[�z�yZ��)�,V&R��U�P����DjA=���HM��W�Q��jY-hY�K�m���~����vw���ߏ:)Ԗ�R[��"��k�1v��w�uq� �^"3kBII�f���g�5�?���9&������ǧ��~�I�s!�D=�~��y/��e��D����1�q���m7��@����&�����a\�vx�#Ĵ��R���ު��.u��A��I��8l�x���ıE�$zl�h����$�qi�$f�<��$��5�[R ��mql�����MX��Iz��A��RӸ�c�)6�9ԗ4H�qa�sQun]�*�����Ԇz����0^F�Z�!�wOBe�zr;�R�ZG�U�4�u�P[֋Z��E���ғ��/���	a�]�I�V�-���~��Kf��Ac��LC&�-��i�0���6��W(e#3]�!�����dj�<���t�t��ڂQs��9j�V�D��Q,}z�$�J<����<��3~��~��V��v�\^�]����+�H�����z�}�����s�вdgY(����+��*J�jA�m�֦ꎉ�LvJ�BK
D�!=���?�I�Q��Q�=Mv�,����Zf��	�Հ�T��NF<�P��Kv�ꭡZHY��zWP�����O�-�����\�H�x�Ec?��Vfڑ���6��Ja�ʋA�M���W^��[�{��_"�T����;��x�كi1`&����0��H-e,�z�+���x8	��3띞H��i+՘t<rn���(��J�kR�[�ݡ���������rd��gq9��Q�iN/D��{���dȅy���ȓ#�k��7;�s�~���%�!���I��zq;Kq��.'�Ub�՞7u�z^�<>���5���}Tpy�S*�k:��J��1�9sl�^]s=����)�Aa�ҽ��ި�a?d�Oz����F>~��������G��ǅ�b��z��*:=���ԑn���-�[=V��j7	�A�n_�J'�u����|+5��/3�+��z�s�.>�)��d{�E[*�v�ko,<�bY���ކ��gKӃ�-^j�>�
������,�i�z��y�;��ء�I��Up3�$��/�g���*�M>�1{��-�i�>�*���y��8�sP�/�ſs9j����i�M�hɗ�������>b*Xr�j��i��7���LY3����u�:|����0?���#jw?�W��!�v����қ�\�:2���x�h����B=<�;i�Y�ay F%e>�_�[V�U�fZz���oa�s>��Bk�����vO�N���8�h�!��B��^Fљ@��z�E�j�rd{�%u�C�����@/`����^���@y�Jϩ�cJ���{���k��e)����0��Ǵ0�ݨKZiǴ��f�5��c�ݨ�>��������d�jy�Ť�Ԕ��
TGZ�Xtq��m��l���x��y�B���܁��Z��<��NB˞lmn:��u	��)/y��S�c���mQh�����ٚg�zARU�r��vҖ�փ�����,=���q���U/g0[�Ri�-g��[<N���cKf�N�ɦS��E��s�s��u�c�|L2��4l�C{��\�0h.J��|�\�??n��`>��U�R�E����a'�Eu��`\��k���k�X-<�C�b�-,g�[b��1ܮo���C�џ歄���pDU�lyZ�{r;V�c��Ҝ�`P�M��P���A2+Zۢ���S5{�'N�PY��(��2l���t�@��}�����2��      �      x��Zے�ڒ}f��{�;�)�P.��  "(��c����P`)����b��\�#gΑ��3����7,B2��o�����Q��.T�>�"�G;5�Z�E��i���-:M�}�a �b�Cv+�e���}�ig�}��A�~wZ�+���%,�<Ӈ�|)σ�A;�CMi���j?��N�A��@�/։�:�j�+��/��8�'�4²��"C�F��ox�O�O�O#(�ejJ�2X�B���M����?��_�����.�_�AqF���8PS`��<G!F��sB��^Q� e��>,�_Y�W��K3Ȝ���k�=��}H��V!;]�
h�$��6���8u%��@��/ރvH�N�ׂ�)A0h�"<����}�?���fjvW	���M��|����y�4�}�(�َ����vN����d���l�w3��Y|�7����J���͉JSrEI=zf/0!R���g�/X�'S�#�"��*�9befy&%
����)<�G`�X7S*EY�qx�5H\�|����a�
����M*ukJ���jS��cvT��2d�?��i�E�J�E��p�C�s4OK���'�|�in��rpcN�(?��a�kb>�I�^�%7��Ev���e{�� |:��n!����E1���Y97�#�!/�,%��$�w�7��}�%����? \d�=+�L$�;��@�F�^ٜ�>Ju�@y��O�Żs������D�D�6�A�as��qk���ѐ����6렉w*`h���m`����zE-��/�|t�H]Sb�G�w��,B.�����&��+���
�sj���%N:o�U�ݝK.�)��>��+m".9Z�-I�1GT���/V�*�$e�9�=�_4e26����'�8����n�/��:�x��v �IV��FJ�u��3L4"yV� ��ӷ-�͌zkč�kX�Fg�m��g�W$���[7j�:�qvϏm��T�c?�DP?YÕYS��3����M�'�Ej��0!�������yn}F�q��#�&�i��`Q;B"q`fQ/6-؆����}�#0�]�*MYVٗ)���=�WE����R/��R�؎�8_B�2C�X�*,�˅d;8��7�l��[��8R%�OK�'��fN�5U��To�e�x�Z��'c�I:���=���Ӆ�$]I���V<���fd�?�8������k�����" ʺN�h��h~�`�1���|��N�S͟��t���#n��t"q5~�  Q��L~�9�(s{��h�e����׋��Y^�_�4��s�$t�Nt8��� �7tɴ`<���݀��o�Oz)+#�!�~�������C3�L$v�4
ͮV�kh��Fִ2�I'����x���� ���]7����vx�q[�'5HD)O��y���'K���B�l��E�?��Cux5<��0�p�����ɓby��<���`<�-:9웁�����:k}��@�UW�1�rn묖�F��Tޕ2�sHp����LV�y�`Z(���`��.5oײL6��轔`=xd��۰ߪT�)��8�c?Y��u��V�Iͧ;�%��>�j���9�n��)��#���eATݱ��W�vs�O��hl���f�"{���,F|��nj��tV{D�y�9t���;�}��|=��Xi�S,`>�XNi|�%X!���g,7��n�q�f���T�����YU�.�c�X�����N��+��1B�t������O��I�[yטּ�y��ھ�r�WX��{����=_�mYy]��.�团s�T|l/����>��uf6�#��R�H <,'L(���r�t���w�Ⱥ��� ��w����>�ϰ`6�&�MƄ�ϭՖ>϶5.��Q3�X�:���|�Z2@�ǍxL٩����3��R)7^Ԭ���ǃ����56jX��A�4�'6Cx꺦1����+��^ִ|a�E;�"�`�/�y���.�L9�Z^�Gw��|�T����<���kȮ#SՐۆ���;��R�����Z�).�h���c����Vp�R#���iY1-����X؞�LkɚαF���Z�+h���Ϣ����.gn<���Ȼ&�ihE�k�^�ɭ��;0�竾%hzf(n'ܥ�6gTgMJ�;9�t��CvH�@��5(�̣ЎB����$�*_�dM|�u4�|ͽ�!W�R����nv�2.�p&Ji]ޘrX��dT�2��ۼv[2�a�l,붩����d�띙�����#9	�>-Q��W��,�p*��H�r��z�x�mH4�m�}Q�ሢ!�f�c����?7ʯ?�,��OM6���e��l����s��zk�zX�ZNV�*>�u9��z�ы��D���SpBX��^f&6��0�yL8�o�r��ro��`�.+Oĝu�SCԇV2K��o�D@s�2�L3�R���ل�b9-�:S�>!hdD��LR�����=F��*�y�_��Īh�&-'���%�Ҧ~+�_�e�ZV�\�>�ag�%�)��^�q+��7�-���}��G��`��e�<Y�R�|.0��U!�j�g�l���_�S��N�Lܳ�Y,y�v�H�urs���,Ȕ�,�u���d�yNu�ȦU��å���=ca��]�0!u0��Q ;,�UCR���`u��g`����S�;ZV5�q�;�c��@�۔~ȏ�� x\/��Ϸ����-�q����[��0��H�_�-\���_Ɓw6�SqO�$��-�!o�b�m����<�����{-����z?�)�H�##�s. {㵃�sWΖR���39�g���,�6᛫�VHg�"U2���ܘ]Z��Ѝ\U��j�+��|��Y�aJ���[eQD�C�F��k�z{ؼȚʽV[]_-���D���XYE+5/��u�z/�XT���u��`��)c��a8�Ǉ�4����ik�7�����Le������F�uPY���
�v�%#�?է-��K{�%�t�E?�P����8]��h����!����Z�T'l%IeC�뚖4�I\�3�ïz�7��M�\ؼ|���D�����ڊ%��ㅎ�_1�>Jtʞ�$:����>����zVEvr3��	k��������^c����{����꤭-�/�|��d.7�bwX{�:+��`�F��$�m��N�_�G'������|��2��C��(��}��9mH�;e�BFЁ�8*����>�Fa��uLC�\��u�*je�q�ԯ�&Ǔ.�J҂{�����	k���B1�[=��{�����~�Y�Lw 3�5@K@�LS7�<S�G&2f,���w��6�7�X-�Y6ֽ����L`�]8u��1%��j#��9��$���=|Z�/s�tI��Cf,��1!��=
�%�.�x�M�j��e�P0��em���t���,߯��g>�������|�m�{ahR�J������$n�,���V�D';�_��UV���pG����t�f��UדC��y����-�ը~G�C��%Nb~�|���4}���lJ3�~eN�����_HQ���ь�$r���C�	�Q{�}2U��d� Ss9��좹ǮUm5!s��)���pnH��f�W"����A�)_��WY�n��E�_y��*F�h���+�?'#\����I��_���A_F�WY��y��t�᳡�-��̝�JP�xq��$g ֣�x�/݁��|y�=C�y��'� �ȱ���tB�Z�o�#�����h<P������[�gӐm "����;J�S{�`�f�+=�)��7z@?�K�� *X�ޢY~~�=��%#��Ay3��r���[����lG�0_�G��U��&s��}�;1��%#���"�}�V�,��哶�O�1gyp�Sw�vJL������}�UF6y
� e[�d;M�X�����ܴ�0�x&Nգx��ë͏��޽�ۮ9,^�! ��7�� �> ݲ�
MS��J��^��]Y��toL�^Mѕo$�?c @'���v�:����p��]�˚\X3������\nl5��+r�Ȥ�X�� C   ҿ����p�0c��':e(��9w�1��4�c��Bg�#��?�Ȕ$�����믿�K��a      �   �  x��WMs�6=ӿ�k� I}���;���39����"��4�O9�֫�X߂%��;#��%��}���*������2h�{��J��/���5Y�b���gK�4
|,X[��jì�p��rkUm������j<�Lf;Y"�Ǻ�[�й�^�XM�Lݻ9��4Y�|9i���{�t�9~oeɾ�"W?@����\a�EʣI��P����rk��J�2�5�Lɾ����$I���m�8��rtOO���e�o���ʲA}N��uNk�rU�����?�_�W�oּ�����<�q�I�̒j��*������m���d(��U4O>i�!p/�^�e�2U3�
�*i�.��E��L�<�D�/��E�p�|�sɪB6�e�ڽj��4L<�6�0x�{m��6���$z����lDjx�}"T5k�kKP�����5G;p:�i��HtBaF�?*U뒘�r��O���(���/�}g�]��յ���i�}�� ��z�`�)h&�B��~;�Kh�߭ I8
#��g�������~��)ۡZ�E�z��ֳ�V�1C��漺����-�^սzEq�(��X��&^��ݒI���29�|�gfG��'���{$���������3��J�iB�}0�>h�+ˇ-} �t���̱-��EC!X8ws���V�Nʢ�N�$���]8G'z��m7�
SjR1F򻲺n�Zcx(�b
�����቎:yP�tA>��2�WV��>�ۮ��"O�uyƘ�8qij)�H�1��&��V2�k����~��%?������QW���j�.�1�s�=3;6�lx�I"�U�N�0V�qb��x�8zպi1���J���� �|��Z�+S�P�qb�T�U𻵲������0��d*���([젶�A1L!W���j�h�B�r=�f(U2M�9�T�wW���@���[6M�=d�2��D�+K����BY��Fˎ��7gq�<>���A2'zw��}�v��t�[Y���G;�����$��of��w�;O���Y����(����K=<�YWD��($z����{�r��w�x�J����Ѭ��)tC�w���>����)@2�)r��@������gk��C��<�X���m��):��$��V@��6��?H9O�x |��M���\�1�hz����YhG���m���%`ݤu���̍6A�m?�pjGZ��í�5ۅs����P-�j؉�B�4wr�{g���Y�d*��'|�i�R�v��@X�}�缦-HݱtDKφ��rx�����"�����X�uE�h��;G�َQ��ex�vr1�g]����U�����,��=�
��KfֵB�h���	�.�%�m�[NQ�<`�@�h��~y��;p܀8?�ʸ�� �\}�����J�      �   �  x����N�0��ާ��q�M�[Y*q��J�K��$LC���C��c�%�M�D��4����7c'�{Ewη�"ߞ������]:���c���z^��j���������g�n�.� ��G,=b��bL�l2v��N�!'���V���k����J�3[�z&P�*G��5�u�p�V㗡Oڷ�t$�q�P0���≒<�&���L�ˮ�|�+ژ��K|_#RE7��̃�	�*�)����b����es���f򽽍��@9�\�\11���Ï��1�\�B�
�hKM���P�Z a}�ܫ�����S�~�ͷ����H�QL)@%�d,B=	_�'�a�~�e��Daa��:H�y�y�WOb��Tn�q��o����Mv���(����/CH��������,�W�x�Ha�]둫5�ڸR�ô�p4!R���,֓�X��L��	I>�rI9j#���X���,���;S�V�z;����9�w(�0�H�$��`
��X�A�W�����[Z�dT�4��{*��=��k��d�0�B�C���XfM�24�#G����s)�e2���S��7�� .(f�1�JO�bC�-�#��0{��0�e�I��D��l�������!A��� x"Wh��μM��%S���U�6��W�Ц}opʲp{I�}&D��ϐ���@�/����A��x��g$^9��0@di��#W�ǫ��/[�1      �   �   x�3�,JLKL��44261�420��50�50Q00�#lb\F�^�y�%�y�*F�*�*&9~I��Ii�~F%UN9a����U9!%���>�9z��>����!>�9>�p��,����������q��qqq p9*r      �   �   x����
�0E��+����1��*�uy�	Ԧ�D�\]�c���;�3�U�\hH�%��P�@�u��Ba��İ~~�K�1e���0��g,�RZ�I�'e��ʢ�7�kZo�w�ʌ��Yҿ���b��|WgFu�CR�	[/����]��Mj�R���2��Vk�3TU      �   �   x�m��
�@EןO!�Vs�t�U`�Ff�����5F#��Z����A҂�Ltx�e#|�_viEaIL�a6e,�����k�E����*�SX����vHx��*=�K�O��z���'{��I�xѝ���zx~�Q5z����al ��.��� �V�)���D�-�[���/B���D>�      �      x��]I�l'��W�6��hs�6P�/�Ƶ���Q��[�
��I����x���+�������R�����Oox�)���xC���Q�!���\�+�b�p1�W�7�?	�%�Krh�x�_gvȈWڃ7�ƋV��	e1�7<��|����j�?���o�<�( 0s���F�M�����!���K�I��l(_��m����#,K����+��X�1�s}$yO�7��S�/���SH)��0 �0�
��5-�wn�K��x�yŠ��.�Cvi���������Y����(I�E��{4ؼ�>^EZ��U���W�&�1;�_ ܣ����o�?h{�C�܉���g�Z�I�0���a4��~T��3��%<��!������6`M�s�yK؊��K�������:4-%T��yCZ���\��� B�Ibm̀=H�Z0@ኀE��H�<~ƴ]��Y8(��
XY�O�p�l_�=�ҟ�߹.W�i�v å~ƃ��2;��S���}L�����k��41���/�u-�<6B���|�iQ���?y�������;ޥ᧺hi�Ƴ�e�3Md8��7�H���<}i��e@v^�/ �w���0�%��1�HM?xC�D���{�"�Zo���r/�"~+G4H"^߫���k7 ,ܳ���-t-bXK8�O����X����oZ���bF�Tu� 7У�P9�'<�#Z��UH�*ƭ�6-�cEz���n� �ssiF0�?�Xw��r��F`�XRe82�1��_���"g..M�2N�AK�AkK1͢5�o��J'͢q z�^��=�Iti���D�=���pO(٥1ܳ��p1�쮉�����l�'�����1?�eW���\��5��}�vH�2����lƤ�A�"����2���t�v�;U$42�1����&0X˟�]&\��x��d���2U<44���!�ՙ�ʷk+r�63���,�5�Dy4�f��\��'`�Yz5��b�T6��~��f��\�U���'� �Y�xxKZ���X�����),ן8�k#Q�V>���L}����#�88�`N�(�{4���n"B~r)Q=h�9�u}��4��n e��'����K��dE�i�Q��wi˸� ֩��V�)ڒ�e��2��pq.��rj�)�x�=�<�f�r��)�����f�r^r�Ѝ�4�W�(��=ǧ]x���^>lM�.�d�����<1y4� ^u����څ7�F��m7\�lh�P"pź�����4�J�չ��&�[�uD�6ߡ�49��4�gZ/e~�W9 E;�P�T�^�L�f+&ͪJ�T�^��ЬJpiޥ��R�f����]x�»T�r�P\څޥ��k�ߤ]x�»t��٧��.�r�]�L��~��U�?3�ÁV�&fR!����
^�L��Gz�hW1��8�.�hT��_�i&�!��<j��6�+�fr+�������u�����TY��.=nU-��ֻ��.��X�(ͥI>�КI~�5�G�1�.�$?���Q�2��̩"�|�V����΢Q(��(��;�R�����E<�l������51<;=���
.��re��&��d��kb�:6.8��=g1�ʅ���I9����8n6cҞ����m��J�"�#�L�C^�1C��)�����'�ԟ�諺���|��g�,b4�`][_-w��"X�������驂|������
6AVPӊٕ-$�;����gm�<�~=��t��m�ìs��ɐ��Q�z{Y�tu�g�Rֶ����y؀�霭�ZݹT*Y��KrV)E��_.�cP��#����*�يZU���D�s��_Ӧ���-�9ht �ѥ�Z<���P8<]K���N;����"Z�Mf�d���w퓚S�]\�'<ID��>��07��lh��桱��Mi+ٙ�j��b�4���I�m1��u��*���d��hw��I�xg6qtj5^��Y,�u6�p����b�6�NW�gc+�x�̂�z5�3Z��@9�����!;"��
Գ�C��t�e�D_ը�Z��t�{V�<0��\���e��Jx'+_ٝ�'�;;��'\r��
���ԁ6\4��=����6s;�x��{9��c8^�,��.���x���t�V����x�q���Fk{�Bi�<���c�d���x�/�7��N�Kcd5�cp��r�/�mΫ{�gi!��%�@�ђ�,��-v��Ѧu>�x�Y����?�l��\�����1��)�m�C4f���ڋ|`�:#H6�۬�VDK�+���'�����Qk�I�YZQf;T���,����������lw�=�u*���xI8P_Jti�8+�٤���+㈐���mA��EB�ێ~�h��L�����s���K2ޔ��qC��GV�> v�#F����nt�q&Au��P--��4j\_x|�j��r(S���Ʋ8�8vM�q����c<�i����| m�=2(?L�/�l���ՠb�j�k��dh�y��������h�̕:h&qT4ؼ��ͩ�l�F�+�`�
ڪY�p�<@	.��H:\�@��d٥��487n4,���7�����av�����`�
OWM��`�	C��*Xܑ�s�)9h�ȵ6��Ij�9�A8�YE��+h�Xh�ڋ��R�k�R
X�`2f=�+57r�賥b�#P�v)�4��tt���u)�K�-�#�5�b[�p�`��b����x�k0ե��@��	g}	����p;E��J6+k�֢�]���Y���֧��g��;�A]�:�oGj���Y4*^77i�y���rK�4�X��,LI&m�1p�6�u�#�Q4P�(}������;fI`�S�˧��vp1�w�6ZLp3�a^ouh��x{q-�W9� �gT�+���|��42��f�ӹ��2�pL�2-���V�c5�QZ�8!��`3�q}�0��Mg=j�K��dL�ǵ����,����ô���+h��/ ���M�n�@�59���=KQ7�m�?��Ѹ���t~�I��ή� �ᆥȗ|Ss]�R4P̂'G*�̈?�].z���Uh|�"���*�g�Ƶ��|ԁV��IB�`�
iq��R�����V4ؼ��I��J̬�(+(f�����Z�A��vIǥ�]q��Q�R4��G���24�K����>��LXo�#s?	�#5��8��#�Y�*2�L9@^�n^O��9k-FMl��*���]*��o��f'%�]X�����Vx�E��ek���5,�����r�[t����'���n�Bmˡs�L�Q_&8�Q����]�,�	Fs^���+��Z2��%;���ԶZ��9DV�.��o�z��'5':s�3j��/({pB�6ֳ4ݮ�G�5�VL�풢��_����7�<�
��#R������~���g��I��d�&*<�d`��C0�s�c%�\�U�4
��06�.�<=���$������"k:N^�v��n��x���t�x4�J�1����
��Q�`�����\�>�̱w�����;��'ׯ��)y�pTQ���� #K�O�R��p����F4��-mE��+hrK�w MF%u|V4ؼ�6�J��ddP�UE�,x�w��\IoD�s�>�O���[����k_m����h��׺�
X��/��Y�H7Z^c"J6�>��$�0��������I|ؽ..M�ҥ�(����8��;�͊�[ ���r��n<�9����x4a��밟��t�{�tR�W��<�w3�������x\e48�W�Lwjs���M�4.%�L?�y�nG��q�U4P̂7�L���{�h�.�ua%�Vg:�zKW��ʋVf�O��/i�����).���#k��Sy�F+��&����}���l�U���MG�� b�z�:�k�:H�9$nDV�WƏu
�Љ��Q��͓��I�u��㠦��eѸ��l�耯;K���9Y([����{�xk���W"���-5��"�~�B��TX��˭{;�J�b�� ���U�� �  ����n�Y�d^Ac˪n�� �y�f����4����E�-�4�+hY��0�%�KSE4A�T1��=V)��������ϥV6���p��߳Ŀ8��6ݥV_����_�! �˴�(���	�����֏�K��Mz�y��ke٥�J�-�ꬔ�����T�VВ�SG6���y��]{ʭѶ�G�*�s�}�.6/�w��3Zv|�ц��i���Sf��oF@0M�.��<���W[��r�W�EGf86�L��ɼ�6��4˝�щ����'��Z�<>(���tmݴ����*!�8�&V�b��\��f`�]�YL;;s��s���i���j�b��9�.p<4i�%yA#e�U��9�V�B�a�y������!|lf��3�l����0ZQ��B��8O�ŁK.�<2����|�a���h�tx�fF��F�]��u�V2��̘��F�dΨ{4�����֧�_9��6/�quy�Ն
��]�QѮ��r��}��W�v���e�sW��}GKtB���n4n�~�U$5ݡ�4����6�!N���hLSoFk�\)�h8L]ڵRnw?�d�|���b�99��|�\� �h��mG�x4a��.N�t��싫!��TJpi�y���֏تh7Zձ�ѷ���]���;tqµ��Q��K�-�\6�l4��ohl^A;f��X�z ﲮI��;Nr�Մ���J�>>J7ݹ�����߱��5�AK��|xL3�$h�an�y^)���1)�=��ͨz��F�(�j �h��¼�fFp��FYt��[[q�ͼ�x�)e�:O�hщ[%�.�QG[hɉ4%��v�E8���>Z��o�Ťࡍ[{��o�#ԧf����/��ߡy�D+Z��ez�F�5Z�>h��FÍ��v��@3%tg��'�h�UJ�.p� �'��D�����I2.��]�he��Tl�f���n�����o��d6Q�h�Nu��V�mry�`Ϗ\�4=z�V�̧�H�(�9�4}jo�hc�pTn����$�YXjm.풭K�|�6WD���]lf���C;��v��s�AC��ϴ�8�����������ӯz,���t
�#�����z�<�[��`��9�.抃���l$}+Y1Z9l�M��%+2A�9�H��#.���o��c*��#�vKW�c�=��S|ݥ�S>H;ÿ����y4ؼ����^K���h}�������I��\uW_�`�2��҇�J�+X4�ٺpk�S��9��ғ�K����>�:�/���͇��Lґ�>åٓ����B�,�êi�ym6Gf�ۃkG	B�`3ܼ��I�A���4p@�#;�[8��J?i֩�|���r�YL�X4ؼ�F��?d8�=���h�ym]��Fp��̵m]�f�/H�'@���E�����'����gY�z=��n�L�����hO5c��w����6�G�G_i����ß@�U&�����:���3���SZ�<"�n+W�V6��!s%�xL�	�J����D>9��
j�S����%��a�DsWKpx�ު	>��nRD��{��ҥ~�n ������I��ݾ�o��1�/��� GT��n.�^!�|:�x��~^X��f�+�W�֌�:��ٶ�,D}�F��z��*�x�n;t-ǣ�<����ӈ�~���y�W7�A���l�^���J�m{�~�nX�Θqm&Y�ǘ_�Rs�4���t��r�"3J�J�Ux���A3�BF}�j�&o~�+���:�h˒g(�?)+�z���4�i�cnG�CQSW��t���Ŵ+��J�������b�4%�)�
�ȯ*%��"r�{�N����ЧJ
a%�w�I^�G���	M�lFVxϿ�fr���F~14z���of�L`��}��n�|\@�4��d^x@��w>D#�Α�Of�_�<��##Nl5�K�Q-%�D�>�x�գ��擛���0�r!)��R����C���V�+`���W��8��7mgK���w5u�7��������Ͱp������� �ur<�=I�~�;�a�����n��5X�9
��v꾧M��ɁўТ�W�NV�Jg��X�e�����4>�Y��q�g���,\�)�p��^bUϨnZ�0F(�]� ؖeW��'mBE�ꆾ �^|�|̜=�p>_��P�/�h�! N�C��؍BG�D����/o�p4>���h�_өG
�h:��ŧ��2��A��c	ե]��/�G5i|���i�e��y�X)!�V�'MWJ�n1��N�~���kѯ�1��5��v	G�ف[�����N�� �_;����|o+1� %۳>\
.m��t��.�>�1Z�T�=ĸ�������y��1ɥ�p*�Ԅ��K�����[0������Bisp�J���z(_�ez{�N43Ŭ������1�9=����ёF?�7_��aV��8�=��R�Ƌu�)W���R�Op%[8j[3''��)9���#=	e�p��bU_��0���+v}ˍ���xC�a�(��%�`w�F�S؍W����w2g{�v�J��y��x<|�iw�ŷ����5vǣ��h��H}/Pi�'a:�����nz���"�Mf��]`�S��ps��nR=�M�����&�v�޸��iK�7^�__]x�Ń��<4a��8x%�?Ўd��Ј�
:�-�6���TC#V׿�p�챨�Q.�^G#�
X���:���T�å2&{��;.�Q��ZH!��x��O*�_N�z���h���ǀՓTf<�{���?E��"����~�;2g�O1�v�X*�������,��_�!��C�(i��n��ƷK����6����E[���r������4�)�m
(�"!ڇ�-�hՅ^�v��a����삇� �7��j�0�_��g=�ޓ�L��0�/2{{�ǵ��Β��=W!�O�|9?c��M8�A����To�F|�y���->ZY�<�k��|:}�2��p�B�A=Rg�.c�`�{<�]��rl��v�.�J������4��l�r���oi����ahrE�d�PK.��OE�M�-���c�^4>
{�_�4����f�ǧ%�|�'9����0���2�y��o�KfȄT��� =L�i΢IO���o���Cs�&S�Q��]��4�V<c�MI�'į�#��݀�}��3�W0I�*f�.��o�'E2� MEco�%��h��	:�~��� �k��2v,���	�c0G�.ߟ��>xa��Y�M�`���^��	�n�nZ�V�������@��s����=�E�����N�U��������U�u~m�}��G��aC����TJ#6��E�8�~��S��N�Xk���F�9^qPү-Ov��;_?"�n7�i�#����i}B5J?�͏���������Ohg4m��lY_�o�-���	3��i{'�:_���;aen�{��̀S�����������nt��⟙�
�7 �C�'x�����&��X�EL(��om��R�\
S��z�,+���<��^�e- `N��;�{��jIp �d~A�x�S�.9�����Hg�;ҡO}i���N#���nZKظ��Qe�eG�\�-����Qc��ћni�79<�E5��f
1Y�!Ie�J@��󡺔Ù��VE�!=�z@��ѿM����:h�����>�z�B�����gX��3lȟ�����y:CW4ѿ�� ��= y�����ѿ`�Ə��k���1�8V0\څF��]A�а�]��`��������T��Jt�h<v���qDe��xQ�[Ûѥ��*�t����Suv���|����D^���ě��G5PX��?%�b[�<�d��fg����Z�s��s�y71�����҄n>�#�=�����SV�L���U�⭥�����׭x��N�}D��B��uݭ��מ�-��]:Վ�U�IC.`�h�+\�W;�z!�+8L�t�.;9��x��!���ž�?����%ڄ����*ETS_I=k�0wy�$n�H?o�w�09Γ������?��R:     