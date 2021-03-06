PGDMP     4        
        
    w            tauranet_db    10.3    10.3 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false                        0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false                       0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false                       1262    50221    tauranet_db    DATABASE     �   CREATE DATABASE tauranet_db WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'Spanish_Spain.1252' LC_CTYPE = 'Spanish_Spain.1252';
    DROP DATABASE tauranet_db;
             postgres    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false                       0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    3                        3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false                       0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
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
       public       postgres    false    1    3            �            1255    68056 *   function_fecha_importe(bigint, date, date)    FUNCTION     �  CREATE FUNCTION public.function_fecha_importe(idrestaurante bigint, fechaini date, fechafin date) RETURNS TABLE(fecha date, importe numeric)
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
       public       postgres    false    3    1            �            1255    68088    function_personal(integer)    FUNCTION     G  CREATE FUNCTION public.function_personal(idrestaurant integer) RETURNS TABLE(id_usuario bigint, nombre_usuario character varying, nombre_completo text, dni character varying, tipo_usuario character, perfil text, nombresucursal character varying, created_at timestamp without time zone, id_sucursal bigint)
    LANGUAGE plpgsql
    AS $$
begin
	return query 
		select c.id_cajero as id_usuario,
				c.nombre_usuario as nombre_usuario, 
				concat(c.primer_nombre,' ', c.segundo_nombre,' ',c.paterno,' ',c.materno) as nombre_completo, 
				c.dni as dni, 
				c.tipo_usuario as tipo_usuario, 
				'Cajero' as perfil, 
				s.nombre as nombreSucursal, 
				c.created_at as created_at, 
				s.id_sucursal
		from cajeros as c
		inner join sucursals as s on s.id_sucursal = c.id_sucursal
		where s.id_restaurant = idRestaurant and c.deleted_at is null
		union
		select m.id_mozo as id_usuario,
				m.nombre_usuario as nombre_usuario, 
				concat(m.primer_nombre,' ',m.segundo_nombre,' ',m.paterno,' ',m.materno) as nombre_completo, 
				m.dni as dni, 
				m.tipo_usuario as tipo_usuario, 
				'Mozo' as perfil, 
				s.nombre as nombreSucursal, 
				m.created_at as created_at, 
				s.id_sucursal
		from mozos as m
		inner join sucursals as s on s.id_sucursal = m.id_sucursal
		where s.id_restaurant = idRestaurant and m.deleted_at is null
		union
		select n.id_cocinero as id_usuario, 
				n.nombre_usuario as nombre_usuario, 
				concat(n.primer_nombre,' ',n.segundo_nombre,' ',n.paterno,' ',n.materno) as nombre_completo, 
				n.dni as dni,
				n.tipo_usuario as tipo_usuario,
				'Cocinero' as perfil,
				s.nombre as nombreSucursal,
				n.created_at as created_at,
				s.id_sucursal
		from cocineros as n
		inner join sucursals as s on s.id_sucursal = n.id_sucursal
		where s.id_restaurant = idRestaurant and n.deleted_at is null
		order by created_at desc;
end;
$$;
 >   DROP FUNCTION public.function_personal(idrestaurant integer);
       public       postgres    false    1    3            �            1255    68049 6   function_producto_cantidad(bigint, bigint, date, date)    FUNCTION       CREATE FUNCTION public.function_producto_cantidad(idrestaurante bigint, idcategoria bigint, fechaini date, fechafin date) RETURNS TABLE(nom_producto character varying, nom_categoria character varying, cantidad bigint)
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
       public       postgres    false    1    3            �            1255    68050 5   function_producto_importe(bigint, bigint, date, date)    FUNCTION       CREATE FUNCTION public.function_producto_importe(idrestaurante bigint, idcategoria bigint, fechaini date, fechafin date) RETURNS TABLE(nom_producto character varying, nom_categoria character varying, importe numeric)
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
       public       postgres    false    1    3            �            1255    67874 '   registraproductosfunction(text, bigint)    FUNCTION     =  CREATE FUNCTION public.registraproductosfunction(cad text, id_venta_producto bigint) RETURNS integer
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
       public       postgres    false    3    1            �            1259    50248    users    TABLE     �  CREATE TABLE public.users (
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
       public       postgres    false    203    3                       0    0 #   administradors_id_administrador_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE public.administradors_id_administrador_seq OWNED BY public.administradors.id_administrador;
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
       public       postgres    false    221    3                       0    0    cajas_id_caja_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.cajas_id_caja_seq OWNED BY public.cajas.id_caja;
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
       public       postgres    false    3    209                       0    0 -   categoria_productos_id_categoria_producto_seq    SEQUENCE OWNED BY        ALTER SEQUENCE public.categoria_productos_id_categoria_producto_seq OWNED BY public.categoria_productos.id_categoria_producto;
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
       public       postgres    false    3    213                       0    0    clientes_id_cliente_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.clientes_id_cliente_seq OWNED BY public.clientes.id_cliente;
            public       postgres    false    212            �            1259    68059 	   cocineros    TABLE     �   CREATE TABLE public.cocineros (
    id_cocinero bigint NOT NULL,
    sueldo numeric(9,2),
    fecha_inicio date,
    id_sucursal bigint NOT NULL,
    id_administrador bigint NOT NULL
)
INHERITS (public.users);
    DROP TABLE public.cocineros;
       public         postgres    false    3    199            �            1259    68057    cocineros_id_cocinero_seq    SEQUENCE     �   CREATE SEQUENCE public.cocineros_id_cocinero_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.cocineros_id_cocinero_seq;
       public       postgres    false    3    233            	           0    0    cocineros_id_cocinero_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.cocineros_id_cocinero_seq OWNED BY public.cocineros.id_cocinero;
            public       postgres    false    232            �            1259    50318    empleados_id_empleado_seq    SEQUENCE     �   CREATE SEQUENCE public.empleados_id_empleado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public.empleados_id_empleado_seq;
       public       postgres    false    3    207            
           0    0    empleados_id_empleado_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public.empleados_id_empleado_seq OWNED BY public.cajeros.id_cajero;
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
       public       postgres    false    3    227                       0    0 $   historial_caja_id_historial_caja_seq    SEQUENCE OWNED BY     m   ALTER SEQUENCE public.historial_caja_id_historial_caja_seq OWNED BY public.historial_caja.id_historial_caja;
            public       postgres    false    226            �            1259    50606    mozos    TABLE     �   CREATE TABLE public.mozos (
    id_mozo bigint NOT NULL,
    sueldo numeric(9,2),
    fecha_inicio date,
    id_sucursal bigint NOT NULL,
    id_administrador bigint NOT NULL
)
INHERITS (public.users);
    DROP TABLE public.mozos;
       public         postgres    false    3    199            �            1259    50604    mozos_id_mozo_seq    SEQUENCE     z   CREATE SEQUENCE public.mozos_id_mozo_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.mozos_id_mozo_seq;
       public       postgres    false    219    3                       0    0    mozos_id_mozo_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.mozos_id_mozo_seq OWNED BY public.mozos.id_mozo;
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
       public       postgres    false    3    229                       0    0    pagos_id_pago_seq    SEQUENCE OWNED BY     G   ALTER SEQUENCE public.pagos_id_pago_seq OWNED BY public.pagos.id_pago;
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
       public       postgres    false    225    3                       0    0 !   perfilimagens_id_perfilimagen_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.perfilimagens_id_perfilimagen_seq OWNED BY public.perfilimagens.id_perfilimagen;
            public       postgres    false    224            �            1259    68008    plan_de_pagos    TABLE     C  CREATE TABLE public.plan_de_pagos (
    id_planpago bigint NOT NULL,
    cant_pedidos integer,
    cant_mozos integer,
    cant_cajas integer,
    cant_cajeros integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    id_suscripcion bigint NOT NULL,
    cant_cocineros integer
);
 !   DROP TABLE public.plan_de_pagos;
       public         postgres    false    3            �            1259    68006    plan_de_pagos_id_planpago_seq    SEQUENCE     �   CREATE SEQUENCE public.plan_de_pagos_id_planpago_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public.plan_de_pagos_id_planpago_seq;
       public       postgres    false    231    3                       0    0    plan_de_pagos_id_planpago_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.plan_de_pagos_id_planpago_seq OWNED BY public.plan_de_pagos.id_planpago;
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
       public       postgres    false    3    217                       0    0 )   producto_vendidos_id_producto_vendido_seq    SEQUENCE OWNED BY     w   ALTER SEQUENCE public.producto_vendidos_id_producto_vendido_seq OWNED BY public.producto_vendidos.id_producto_vendido;
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
       public       postgres    false    211    3                       0    0    productos_id_producto_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.productos_id_producto_seq OWNED BY public.productos.id_producto;
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
       public       postgres    false    3    201                       0    0    restaurants_id_restaurant_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public.restaurants_id_restaurant_seq OWNED BY public.restaurants.id_restaurant;
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
       public       postgres    false    205    3                       0    0    sucursals_id_sucursal_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public.sucursals_id_sucursal_seq OWNED BY public.sucursals.id_sucursal;
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
       public       postgres    false    197    3                       0    0 -   superadministradors_id_superadministrador_seq    SEQUENCE OWNED BY        ALTER SEQUENCE public.superadministradors_id_superadministrador_seq OWNED BY public.superadministradors.id_superadministrador;
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
       public       postgres    false    223    3                       0    0    suscripcions_id_suscripcion_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE public.suscripcions_id_suscripcion_seq OWNED BY public.suscripcions.id_suscripcion;
            public       postgres    false    222            �            1259    50246    users_id_usuario_seq    SEQUENCE     }   CREATE SEQUENCE public.users_id_usuario_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.users_id_usuario_seq;
       public       postgres    false    3    199                       0    0    users_id_usuario_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE public.users_id_usuario_seq OWNED BY public.users.id_usuario;
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
    estado_atendido boolean,
    id_cocinero bigint
);
 #   DROP TABLE public.venta_productos;
       public         postgres    false    3            �            1259    50436 %   venta_productos_id_venta_producto_seq    SEQUENCE     �   CREATE SEQUENCE public.venta_productos_id_venta_producto_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.venta_productos_id_venta_producto_seq;
       public       postgres    false    215    3                       0    0 %   venta_productos_id_venta_producto_seq    SEQUENCE OWNED BY     o   ALTER SEQUENCE public.venta_productos_id_venta_producto_seq OWNED BY public.venta_productos.id_venta_producto;
            public       postgres    false    214            �
           2604    50280    administradors id_usuario    DEFAULT     }   ALTER TABLE ONLY public.administradors ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);
 H   ALTER TABLE public.administradors ALTER COLUMN id_usuario DROP DEFAULT;
       public       postgres    false    203    198            �
           2604    50281    administradors id_administrador    DEFAULT     �   ALTER TABLE ONLY public.administradors ALTER COLUMN id_administrador SET DEFAULT nextval('public.administradors_id_administrador_seq'::regclass);
 N   ALTER TABLE public.administradors ALTER COLUMN id_administrador DROP DEFAULT;
       public       postgres    false    203    202    203            �
           2604    50955    cajas id_caja    DEFAULT     n   ALTER TABLE ONLY public.cajas ALTER COLUMN id_caja SET DEFAULT nextval('public.cajas_id_caja_seq'::regclass);
 <   ALTER TABLE public.cajas ALTER COLUMN id_caja DROP DEFAULT;
       public       postgres    false    221    220    221            �
           2604    50323    cajeros id_usuario    DEFAULT     v   ALTER TABLE ONLY public.cajeros ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);
 A   ALTER TABLE public.cajeros ALTER COLUMN id_usuario DROP DEFAULT;
       public       postgres    false    198    207            �
           2604    50324    cajeros id_cajero    DEFAULT     z   ALTER TABLE ONLY public.cajeros ALTER COLUMN id_cajero SET DEFAULT nextval('public.empleados_id_empleado_seq'::regclass);
 @   ALTER TABLE public.cajeros ALTER COLUMN id_cajero DROP DEFAULT;
       public       postgres    false    206    207    207            �
           2604    50350 )   categoria_productos id_categoria_producto    DEFAULT     �   ALTER TABLE ONLY public.categoria_productos ALTER COLUMN id_categoria_producto SET DEFAULT nextval('public.categoria_productos_id_categoria_producto_seq'::regclass);
 X   ALTER TABLE public.categoria_productos ALTER COLUMN id_categoria_producto DROP DEFAULT;
       public       postgres    false    209    208    209            �
           2604    50428    clientes id_cliente    DEFAULT     z   ALTER TABLE ONLY public.clientes ALTER COLUMN id_cliente SET DEFAULT nextval('public.clientes_id_cliente_seq'::regclass);
 B   ALTER TABLE public.clientes ALTER COLUMN id_cliente DROP DEFAULT;
       public       postgres    false    213    212    213                       2604    68062    cocineros id_usuario    DEFAULT     x   ALTER TABLE ONLY public.cocineros ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);
 C   ALTER TABLE public.cocineros ALTER COLUMN id_usuario DROP DEFAULT;
       public       postgres    false    233    198                       2604    68063    cocineros id_cocinero    DEFAULT     ~   ALTER TABLE ONLY public.cocineros ALTER COLUMN id_cocinero SET DEFAULT nextval('public.cocineros_id_cocinero_seq'::regclass);
 D   ALTER TABLE public.cocineros ALTER COLUMN id_cocinero DROP DEFAULT;
       public       postgres    false    233    232    233                        2604    59737     historial_caja id_historial_caja    DEFAULT     �   ALTER TABLE ONLY public.historial_caja ALTER COLUMN id_historial_caja SET DEFAULT nextval('public.historial_caja_id_historial_caja_seq'::regclass);
 O   ALTER TABLE public.historial_caja ALTER COLUMN id_historial_caja DROP DEFAULT;
       public       postgres    false    227    226    227            �
           2604    50609    mozos id_usuario    DEFAULT     t   ALTER TABLE ONLY public.mozos ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);
 ?   ALTER TABLE public.mozos ALTER COLUMN id_usuario DROP DEFAULT;
       public       postgres    false    219    198            �
           2604    50610    mozos id_mozo    DEFAULT     n   ALTER TABLE ONLY public.mozos ALTER COLUMN id_mozo SET DEFAULT nextval('public.mozos_id_mozo_seq'::regclass);
 <   ALTER TABLE public.mozos ALTER COLUMN id_mozo DROP DEFAULT;
       public       postgres    false    218    219    219                       2604    67888    pagos id_pago    DEFAULT     n   ALTER TABLE ONLY public.pagos ALTER COLUMN id_pago SET DEFAULT nextval('public.pagos_id_pago_seq'::regclass);
 <   ALTER TABLE public.pagos ALTER COLUMN id_pago DROP DEFAULT;
       public       postgres    false    229    228    229            �
           2604    51318    perfilimagens id_perfilimagen    DEFAULT     �   ALTER TABLE ONLY public.perfilimagens ALTER COLUMN id_perfilimagen SET DEFAULT nextval('public.perfilimagens_id_perfilimagen_seq'::regclass);
 L   ALTER TABLE public.perfilimagens ALTER COLUMN id_perfilimagen DROP DEFAULT;
       public       postgres    false    225    224    225                       2604    68011    plan_de_pagos id_planpago    DEFAULT     �   ALTER TABLE ONLY public.plan_de_pagos ALTER COLUMN id_planpago SET DEFAULT nextval('public.plan_de_pagos_id_planpago_seq'::regclass);
 H   ALTER TABLE public.plan_de_pagos ALTER COLUMN id_planpago DROP DEFAULT;
       public       postgres    false    231    230    231            �
           2604    50470 %   producto_vendidos id_producto_vendido    DEFAULT     �   ALTER TABLE ONLY public.producto_vendidos ALTER COLUMN id_producto_vendido SET DEFAULT nextval('public.producto_vendidos_id_producto_vendido_seq'::regclass);
 T   ALTER TABLE public.producto_vendidos ALTER COLUMN id_producto_vendido DROP DEFAULT;
       public       postgres    false    217    216    217            �
           2604    50373    productos id_producto    DEFAULT     ~   ALTER TABLE ONLY public.productos ALTER COLUMN id_producto SET DEFAULT nextval('public.productos_id_producto_seq'::regclass);
 D   ALTER TABLE public.productos ALTER COLUMN id_producto DROP DEFAULT;
       public       postgres    false    211    210    211            �
           2604    50264    restaurants id_restaurant    DEFAULT     �   ALTER TABLE ONLY public.restaurants ALTER COLUMN id_restaurant SET DEFAULT nextval('public.restaurants_id_restaurant_seq'::regclass);
 H   ALTER TABLE public.restaurants ALTER COLUMN id_restaurant DROP DEFAULT;
       public       postgres    false    201    200    201            �
           2604    50302    sucursals id_sucursal    DEFAULT     ~   ALTER TABLE ONLY public.sucursals ALTER COLUMN id_sucursal SET DEFAULT nextval('public.sucursals_id_sucursal_seq'::regclass);
 D   ALTER TABLE public.sucursals ALTER COLUMN id_sucursal DROP DEFAULT;
       public       postgres    false    205    204    205            �
           2604    50227 )   superadministradors id_superadministrador    DEFAULT     �   ALTER TABLE ONLY public.superadministradors ALTER COLUMN id_superadministrador SET DEFAULT nextval('public.superadministradors_id_superadministrador_seq'::regclass);
 X   ALTER TABLE public.superadministradors ALTER COLUMN id_superadministrador DROP DEFAULT;
       public       postgres    false    197    196    197            �
           2604    51058    suscripcions id_suscripcion    DEFAULT     �   ALTER TABLE ONLY public.suscripcions ALTER COLUMN id_suscripcion SET DEFAULT nextval('public.suscripcions_id_suscripcion_seq'::regclass);
 J   ALTER TABLE public.suscripcions ALTER COLUMN id_suscripcion DROP DEFAULT;
       public       postgres    false    222    223    223            �
           2604    50251    users id_usuario    DEFAULT     t   ALTER TABLE ONLY public.users ALTER COLUMN id_usuario SET DEFAULT nextval('public.users_id_usuario_seq'::regclass);
 ?   ALTER TABLE public.users ALTER COLUMN id_usuario DROP DEFAULT;
       public       postgres    false    198    199    199            �
           2604    50441 !   venta_productos id_venta_producto    DEFAULT     �   ALTER TABLE ONLY public.venta_productos ALTER COLUMN id_venta_producto SET DEFAULT nextval('public.venta_productos_id_venta_producto_seq'::regclass);
 P   ALTER TABLE public.venta_productos ALTER COLUMN id_venta_producto DROP DEFAULT;
       public       postgres    false    215    214    215            �          0    50277    administradors 
   TABLE DATA               B  COPY public.administradors (id_usuario, primer_nombre, paterno, materno, dni, direccion, nombre_usuario, email, password, fecha_nac, sexo, nombre_fotoperfil, created_at, updated_at, id_administrador, id_restaurant, id_superadministrador, tipo_usuario, api_token, segundo_nombre, celular, telefono, deleted_at) FROM stdin;
    public       postgres    false    203   �2      �          0    50952    cajas 
   TABLE DATA               �   COPY public.cajas (id_caja, nombre, descripcion, created_at, updated_at, id_administrador, id_sucursal, deleted_at) FROM stdin;
    public       postgres    false    221   �:      �          0    50320    cajeros 
   TABLE DATA               L  COPY public.cajeros (id_usuario, primer_nombre, paterno, materno, dni, direccion, nombre_usuario, email, password, fecha_nac, sexo, nombre_fotoperfil, created_at, updated_at, id_cajero, sueldo, fecha_inicio, id_sucursal, id_administrador, tipo_usuario, api_token, id_caja, segundo_nombre, celular, telefono, deleted_at) FROM stdin;
    public       postgres    false    207   2=      �          0    50347    categoria_productos 
   TABLE DATA               �   COPY public.categoria_productos (id_categoria_producto, nombre, descripcion, fecha_inicio, id_restaurant, id_administrador, created_at, updated_at, deleted_at) FROM stdin;
    public       postgres    false    209   �F      �          0    50425    clientes 
   TABLE DATA                  COPY public.clientes (id_cliente, nombre_completo, dni, id_cajero, created_at, updated_at, id_mozo, id_restaurant) FROM stdin;
    public       postgres    false    213   �I      �          0    68059 	   cocineros 
   TABLE DATA               G  COPY public.cocineros (id_usuario, primer_nombre, paterno, materno, dni, direccion, nombre_usuario, email, password, fecha_nac, sexo, nombre_fotoperfil, created_at, updated_at, tipo_usuario, api_token, segundo_nombre, celular, telefono, deleted_at, id_cocinero, sueldo, fecha_inicio, id_sucursal, id_administrador) FROM stdin;
    public       postgres    false    233   fS      �          0    59734    historial_caja 
   TABLE DATA               �   COPY public.historial_caja (id_historial_caja, monto_inicial, monto, fecha, estado, id_caja, id_administrador, id_cajero, created_at, updated_at) FROM stdin;
    public       postgres    false    227   !U      �          0    50606    mozos 
   TABLE DATA               ?  COPY public.mozos (id_usuario, primer_nombre, paterno, materno, dni, direccion, nombre_usuario, email, password, fecha_nac, sexo, nombre_fotoperfil, created_at, updated_at, tipo_usuario, id_mozo, sueldo, fecha_inicio, id_sucursal, id_administrador, api_token, segundo_nombre, celular, telefono, deleted_at) FROM stdin;
    public       postgres    false    219   5X      �          0    67885    pagos 
   TABLE DATA               �   COPY public.pagos (id_pago, efectivo, total, total_pagar, visa, mastercard, cambio, id_venta_producto, created_at, updated_at) FROM stdin;
    public       postgres    false    229   _^      �          0    51315    perfilimagens 
   TABLE DATA               ~   COPY public.perfilimagens (id_perfilimagen, nombre, id_administrador, id_mozo, id_cajero, created_at, updated_at) FROM stdin;
    public       postgres    false    225   Jt      �          0    68008    plan_de_pagos 
   TABLE DATA               �   COPY public.plan_de_pagos (id_planpago, cant_pedidos, cant_mozos, cant_cajas, cant_cajeros, created_at, updated_at, id_suscripcion, cant_cocineros) FROM stdin;
    public       postgres    false    231   �w      �          0    50467    producto_vendidos 
   TABLE DATA               �   COPY public.producto_vendidos (id_producto_vendido, cantidad, importe, id_producto, id_venta_producto, nota, p_unit, created_at) FROM stdin;
    public       postgres    false    217   3x      �          0    50370 	   productos 
   TABLE DATA               �   COPY public.productos (id_producto, nombre, descripcion, id_categoria_producto, id_administrador, created_at, updated_at, precio, deleted_at, producto_image) FROM stdin;
    public       postgres    false    211   >�      �          0    50261    restaurants 
   TABLE DATA               �   COPY public.restaurants (id_restaurant, nombre, estado, descripcion, created_at, updated_at, id_superadministrador, observacion, id_suscripcion, tipo_moneda, identificacion) FROM stdin;
    public       postgres    false    201   ��      �          0    50299 	   sucursals 
   TABLE DATA               �   COPY public.sucursals (id_sucursal, nombre, direccion, descripcion, id_restaurant, id_superadministrador, created_at, updated_at, ciudad, pais, telefono, celular) FROM stdin;
    public       postgres    false    205   B�      �          0    50224    superadministradors 
   TABLE DATA               v   COPY public.superadministradors (id_superadministrador, nombre_usuario, password, created_at, updated_at) FROM stdin;
    public       postgres    false    197   �      �          0    51055    suscripcions 
   TABLE DATA               �   COPY public.suscripcions (id_suscripcion, tipo_suscripcion, observacion, precio_anual, precio_mensual, created_at, updated_at, id_superadministrador) FROM stdin;
    public       postgres    false    223   ��      �          0    50248    users 
   TABLE DATA                 COPY public.users (id_usuario, primer_nombre, paterno, materno, dni, direccion, nombre_usuario, email, password, fecha_nac, sexo, nombre_fotoperfil, created_at, updated_at, tipo_usuario, api_token, segundo_nombre, celular, telefono, deleted_at) FROM stdin;
    public       postgres    false    199   p�      �          0    50438    venta_productos 
   TABLE DATA               �   COPY public.venta_productos (id_venta_producto, nro_venta, total, descuento, estado_venta, id_cliente, id_cajero, created_at, updated_at, id_sucursal, id_mozo, sub_total, id_historial_caja, estado_atendido, id_cocinero) FROM stdin;
    public       postgres    false    215   9�                 0    0 #   administradors_id_administrador_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.administradors_id_administrador_seq', 68, true);
            public       postgres    false    202                       0    0    cajas_id_caja_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.cajas_id_caja_seq', 35, true);
            public       postgres    false    220                       0    0 -   categoria_productos_id_categoria_producto_seq    SEQUENCE SET     \   SELECT pg_catalog.setval('public.categoria_productos_id_categoria_producto_seq', 31, true);
            public       postgres    false    208                       0    0    clientes_id_cliente_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.clientes_id_cliente_seq', 128, true);
            public       postgres    false    212                       0    0    cocineros_id_cocinero_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.cocineros_id_cocinero_seq', 3, true);
            public       postgres    false    232                       0    0    empleados_id_empleado_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.empleados_id_empleado_seq', 25, true);
            public       postgres    false    206                       0    0 $   historial_caja_id_historial_caja_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.historial_caja_id_historial_caja_seq', 34, true);
            public       postgres    false    226                       0    0    mozos_id_mozo_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.mozos_id_mozo_seq', 14, true);
            public       postgres    false    218                        0    0    pagos_id_pago_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.pagos_id_pago_seq', 331, true);
            public       postgres    false    228            !           0    0 !   perfilimagens_id_perfilimagen_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.perfilimagens_id_perfilimagen_seq', 63, true);
            public       postgres    false    224            "           0    0    plan_de_pagos_id_planpago_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.plan_de_pagos_id_planpago_seq', 3, true);
            public       postgres    false    230            #           0    0 )   producto_vendidos_id_producto_vendido_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('public.producto_vendidos_id_producto_vendido_seq', 1617, true);
            public       postgres    false    216            $           0    0    productos_id_producto_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.productos_id_producto_seq', 112, true);
            public       postgres    false    210            %           0    0    restaurants_id_restaurant_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.restaurants_id_restaurant_seq', 43, true);
            public       postgres    false    200            &           0    0    sucursals_id_sucursal_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.sucursals_id_sucursal_seq', 20, true);
            public       postgres    false    204            '           0    0 -   superadministradors_id_superadministrador_seq    SEQUENCE SET     [   SELECT pg_catalog.setval('public.superadministradors_id_superadministrador_seq', 2, true);
            public       postgres    false    196            (           0    0    suscripcions_id_suscripcion_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.suscripcions_id_suscripcion_seq', 3, true);
            public       postgres    false    222            )           0    0    users_id_usuario_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public.users_id_usuario_seq', 111, true);
            public       postgres    false    198            *           0    0 %   venta_productos_id_venta_producto_seq    SEQUENCE SET     U   SELECT pg_catalog.setval('public.venta_productos_id_venta_producto_seq', 465, true);
            public       postgres    false    214                       2606    50286 "   administradors administradors_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.administradors
    ADD CONSTRAINT administradors_pkey PRIMARY KEY (id_administrador);
 L   ALTER TABLE ONLY public.administradors DROP CONSTRAINT administradors_pkey;
       public         postgres    false    203            (           2606    50960    cajas cajas_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_pkey PRIMARY KEY (id_caja);
 :   ALTER TABLE ONLY public.cajas DROP CONSTRAINT cajas_pkey;
       public         postgres    false    221                       2606    50355 ,   categoria_productos categoria_productos_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY public.categoria_productos
    ADD CONSTRAINT categoria_productos_pkey PRIMARY KEY (id_categoria_producto);
 V   ALTER TABLE ONLY public.categoria_productos DROP CONSTRAINT categoria_productos_pkey;
       public         postgres    false    209                        2606    50430    clientes clientes_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id_cliente);
 @   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_pkey;
       public         postgres    false    213            6           2606    68068    cocineros cocineros_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.cocineros
    ADD CONSTRAINT cocineros_pkey PRIMARY KEY (id_cocinero);
 B   ALTER TABLE ONLY public.cocineros DROP CONSTRAINT cocineros_pkey;
       public         postgres    false    233                       2606    50329    cajeros empleados_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT empleados_pkey PRIMARY KEY (id_cajero);
 @   ALTER TABLE ONLY public.cajeros DROP CONSTRAINT empleados_pkey;
       public         postgres    false    207            0           2606    59739 "   historial_caja historial_caja_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_pkey PRIMARY KEY (id_historial_caja);
 L   ALTER TABLE ONLY public.historial_caja DROP CONSTRAINT historial_caja_pkey;
       public         postgres    false    227            &           2606    50615    mozos mozos_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.mozos
    ADD CONSTRAINT mozos_pkey PRIMARY KEY (id_mozo);
 :   ALTER TABLE ONLY public.mozos DROP CONSTRAINT mozos_pkey;
       public         postgres    false    219            2           2606    67890    pagos pagos_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_pkey PRIMARY KEY (id_pago);
 :   ALTER TABLE ONLY public.pagos DROP CONSTRAINT pagos_pkey;
       public         postgres    false    229            ,           2606    51322 &   perfilimagens perfilimagens_nombre_key 
   CONSTRAINT     c   ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_nombre_key UNIQUE (nombre);
 P   ALTER TABLE ONLY public.perfilimagens DROP CONSTRAINT perfilimagens_nombre_key;
       public         postgres    false    225            .           2606    51320     perfilimagens perfilimagens_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_pkey PRIMARY KEY (id_perfilimagen);
 J   ALTER TABLE ONLY public.perfilimagens DROP CONSTRAINT perfilimagens_pkey;
       public         postgres    false    225            4           2606    68013     plan_de_pagos plan_de_pagos_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public.plan_de_pagos
    ADD CONSTRAINT plan_de_pagos_pkey PRIMARY KEY (id_planpago);
 J   ALTER TABLE ONLY public.plan_de_pagos DROP CONSTRAINT plan_de_pagos_pkey;
       public         postgres    false    231            $           2606    50472 (   producto_vendidos producto_vendidos_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY public.producto_vendidos
    ADD CONSTRAINT producto_vendidos_pkey PRIMARY KEY (id_producto_vendido);
 R   ALTER TABLE ONLY public.producto_vendidos DROP CONSTRAINT producto_vendidos_pkey;
       public         postgres    false    217                       2606    50378    productos productos_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id_producto);
 B   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_pkey;
       public         postgres    false    211                       2606    51052 %   restaurants restaurants_nombre_unique 
   CONSTRAINT     b   ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_nombre_unique UNIQUE (nombre);
 O   ALTER TABLE ONLY public.restaurants DROP CONSTRAINT restaurants_nombre_unique;
       public         postgres    false    201                       2606    50269    restaurants restaurants_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_pkey PRIMARY KEY (id_restaurant);
 F   ALTER TABLE ONLY public.restaurants DROP CONSTRAINT restaurants_pkey;
       public         postgres    false    201                       2606    50307    sucursals sucursals_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.sucursals
    ADD CONSTRAINT sucursals_pkey PRIMARY KEY (id_sucursal);
 B   ALTER TABLE ONLY public.sucursals DROP CONSTRAINT sucursals_pkey;
       public         postgres    false    205                       2606    50229 ,   superadministradors superadministradors_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY public.superadministradors
    ADD CONSTRAINT superadministradors_pkey PRIMARY KEY (id_superadministrador);
 V   ALTER TABLE ONLY public.superadministradors DROP CONSTRAINT superadministradors_pkey;
       public         postgres    false    197                       2606    50499 6   superadministradors superadministradors_usuario_unique 
   CONSTRAINT     {   ALTER TABLE ONLY public.superadministradors
    ADD CONSTRAINT superadministradors_usuario_unique UNIQUE (nombre_usuario);
 `   ALTER TABLE ONLY public.superadministradors DROP CONSTRAINT superadministradors_usuario_unique;
       public         postgres    false    197            *           2606    51063    suscripcions suscripcions_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY public.suscripcions
    ADD CONSTRAINT suscripcions_pkey PRIMARY KEY (id_suscripcion);
 H   ALTER TABLE ONLY public.suscripcions DROP CONSTRAINT suscripcions_pkey;
       public         postgres    false    223            
           2606    50503    users users_dni_unique 
   CONSTRAINT     P   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_dni_unique UNIQUE (dni);
 @   ALTER TABLE ONLY public.users DROP CONSTRAINT users_dni_unique;
       public         postgres    false    199                       2606    50497    users users_email_unique 
   CONSTRAINT     T   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);
 B   ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_unique;
       public         postgres    false    199                       2606    50507 !   users users_nombre_usuario_unique 
   CONSTRAINT     f   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_nombre_usuario_unique UNIQUE (nombre_usuario);
 K   ALTER TABLE ONLY public.users DROP CONSTRAINT users_nombre_usuario_unique;
       public         postgres    false    199                       2606    50256    users users_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_usuario);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public         postgres    false    199            "           2606    50443 $   venta_productos venta_productos_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_pkey PRIMARY KEY (id_venta_producto);
 N   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_pkey;
       public         postgres    false    215            9           2606    50287 0   administradors administradors_id_restaurant_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.administradors
    ADD CONSTRAINT administradors_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);
 Z   ALTER TABLE ONLY public.administradors DROP CONSTRAINT administradors_id_restaurant_fkey;
       public       postgres    false    2836    201    203            :           2606    50292 8   administradors administradors_id_superadministrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.administradors
    ADD CONSTRAINT administradors_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);
 b   ALTER TABLE ONLY public.administradors DROP CONSTRAINT administradors_id_superadministrador_fkey;
       public       postgres    false    197    203    2822            Q           2606    50961 !   cajas cajas_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 K   ALTER TABLE ONLY public.cajas DROP CONSTRAINT cajas_id_administrador_fkey;
       public       postgres    false    203    2838    221            R           2606    50971    cajas cajas_id_sucursal_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);
 F   ALTER TABLE ONLY public.cajas DROP CONSTRAINT cajas_id_sucursal_fkey;
       public       postgres    false    2840    221    205            ?           2606    50966    cajeros cajeros_id_caja_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT cajeros_id_caja_fkey FOREIGN KEY (id_caja) REFERENCES public.cajas(id_caja);
 F   ALTER TABLE ONLY public.cajeros DROP CONSTRAINT cajeros_id_caja_fkey;
       public       postgres    false    2856    207    221            A           2606    50361 =   categoria_productos categoria_productos_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.categoria_productos
    ADD CONSTRAINT categoria_productos_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 g   ALTER TABLE ONLY public.categoria_productos DROP CONSTRAINT categoria_productos_id_administrador_fkey;
       public       postgres    false    209    203    2838            @           2606    50356 :   categoria_productos categoria_productos_id_restaurant_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.categoria_productos
    ADD CONSTRAINT categoria_productos_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);
 d   ALTER TABLE ONLY public.categoria_productos DROP CONSTRAINT categoria_productos_id_restaurant_fkey;
       public       postgres    false    201    209    2836            D           2606    50431 "   clientes clientes_id_empleado_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_empleado_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);
 L   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_id_empleado_fkey;
       public       postgres    false    2842    207    213            E           2606    50631    clientes clientes_id_mozo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_mozo_fkey FOREIGN KEY (id_mozo) REFERENCES public.mozos(id_mozo);
 H   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_id_mozo_fkey;
       public       postgres    false    213    2854    219            F           2606    67862 $   clientes clientes_id_restaurant_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);
 N   ALTER TABLE ONLY public.clientes DROP CONSTRAINT clientes_id_restaurant_fkey;
       public       postgres    false    201    213    2836            ]           2606    68074 )   cocineros cocineros_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cocineros
    ADD CONSTRAINT cocineros_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 S   ALTER TABLE ONLY public.cocineros DROP CONSTRAINT cocineros_id_administrador_fkey;
       public       postgres    false    233    203    2838            \           2606    68069 $   cocineros cocineros_id_sucursal_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cocineros
    ADD CONSTRAINT cocineros_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);
 N   ALTER TABLE ONLY public.cocineros DROP CONSTRAINT cocineros_id_sucursal_fkey;
       public       postgres    false    205    233    2840            >           2606    50335 '   cajeros empleados_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT empleados_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 Q   ALTER TABLE ONLY public.cajeros DROP CONSTRAINT empleados_id_administrador_fkey;
       public       postgres    false    2838    207    203            =           2606    50330 "   cajeros empleados_id_sucursal_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.cajeros
    ADD CONSTRAINT empleados_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);
 L   ALTER TABLE ONLY public.cajeros DROP CONSTRAINT empleados_id_sucursal_fkey;
       public       postgres    false    2840    207    205            X           2606    59745 3   historial_caja historial_caja_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 ]   ALTER TABLE ONLY public.historial_caja DROP CONSTRAINT historial_caja_id_administrador_fkey;
       public       postgres    false    227    2838    203            W           2606    59740 *   historial_caja historial_caja_id_caja_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_id_caja_fkey FOREIGN KEY (id_caja) REFERENCES public.cajas(id_caja);
 T   ALTER TABLE ONLY public.historial_caja DROP CONSTRAINT historial_caja_id_caja_fkey;
       public       postgres    false    221    2856    227            Y           2606    59750 ,   historial_caja historial_caja_id_cajero_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.historial_caja
    ADD CONSTRAINT historial_caja_id_cajero_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);
 V   ALTER TABLE ONLY public.historial_caja DROP CONSTRAINT historial_caja_id_cajero_fkey;
       public       postgres    false    207    2842    227            P           2606    50621 !   mozos mozos_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mozos
    ADD CONSTRAINT mozos_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 K   ALTER TABLE ONLY public.mozos DROP CONSTRAINT mozos_id_administrador_fkey;
       public       postgres    false    219    203    2838            O           2606    50616    mozos mozos_id_sucursal_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.mozos
    ADD CONSTRAINT mozos_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);
 F   ALTER TABLE ONLY public.mozos DROP CONSTRAINT mozos_id_sucursal_fkey;
       public       postgres    false    205    219    2840            Z           2606    67891 "   pagos pagos_id_venta_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_id_venta_producto_fkey FOREIGN KEY (id_venta_producto) REFERENCES public.venta_productos(id_venta_producto);
 L   ALTER TABLE ONLY public.pagos DROP CONSTRAINT pagos_id_venta_producto_fkey;
       public       postgres    false    215    229    2850            T           2606    51323 1   perfilimagens perfilimagens_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 [   ALTER TABLE ONLY public.perfilimagens DROP CONSTRAINT perfilimagens_id_administrador_fkey;
       public       postgres    false    203    2838    225            V           2606    51333 *   perfilimagens perfilimagens_id_cajero_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_id_cajero_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);
 T   ALTER TABLE ONLY public.perfilimagens DROP CONSTRAINT perfilimagens_id_cajero_fkey;
       public       postgres    false    2842    225    207            U           2606    51328 (   perfilimagens perfilimagens_id_mozo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.perfilimagens
    ADD CONSTRAINT perfilimagens_id_mozo_fkey FOREIGN KEY (id_mozo) REFERENCES public.mozos(id_mozo);
 R   ALTER TABLE ONLY public.perfilimagens DROP CONSTRAINT perfilimagens_id_mozo_fkey;
       public       postgres    false    219    2854    225            [           2606    68014 /   plan_de_pagos plan_de_pagos_id_suscripcion_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.plan_de_pagos
    ADD CONSTRAINT plan_de_pagos_id_suscripcion_fkey FOREIGN KEY (id_suscripcion) REFERENCES public.suscripcions(id_suscripcion);
 Y   ALTER TABLE ONLY public.plan_de_pagos DROP CONSTRAINT plan_de_pagos_id_suscripcion_fkey;
       public       postgres    false    2858    223    231            M           2606    50473 4   producto_vendidos producto_vendidos_id_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.producto_vendidos
    ADD CONSTRAINT producto_vendidos_id_producto_fkey FOREIGN KEY (id_producto) REFERENCES public.productos(id_producto);
 ^   ALTER TABLE ONLY public.producto_vendidos DROP CONSTRAINT producto_vendidos_id_producto_fkey;
       public       postgres    false    2846    211    217            N           2606    50478 :   producto_vendidos producto_vendidos_id_venta_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.producto_vendidos
    ADD CONSTRAINT producto_vendidos_id_venta_producto_fkey FOREIGN KEY (id_venta_producto) REFERENCES public.venta_productos(id_venta_producto);
 d   ALTER TABLE ONLY public.producto_vendidos DROP CONSTRAINT producto_vendidos_id_venta_producto_fkey;
       public       postgres    false    215    217    2850            C           2606    50384 )   productos productos_id_administrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_id_administrador_fkey FOREIGN KEY (id_administrador) REFERENCES public.administradors(id_administrador);
 S   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_id_administrador_fkey;
       public       postgres    false    203    211    2838            B           2606    50379 .   productos productos_id_categoria_producto_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_id_categoria_producto_fkey FOREIGN KEY (id_categoria_producto) REFERENCES public.categoria_productos(id_categoria_producto);
 X   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_id_categoria_producto_fkey;
       public       postgres    false    211    2844    209            7           2606    50270 2   restaurants restaurants_id_superadministrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);
 \   ALTER TABLE ONLY public.restaurants DROP CONSTRAINT restaurants_id_superadministrador_fkey;
       public       postgres    false    2822    201    197            8           2606    51069 +   restaurants restaurants_id_suscripcion_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.restaurants
    ADD CONSTRAINT restaurants_id_suscripcion_fkey FOREIGN KEY (id_suscripcion) REFERENCES public.suscripcions(id_suscripcion);
 U   ALTER TABLE ONLY public.restaurants DROP CONSTRAINT restaurants_id_suscripcion_fkey;
       public       postgres    false    223    2858    201            ;           2606    50308 &   sucursals sucursals_id_restaurant_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sucursals
    ADD CONSTRAINT sucursals_id_restaurant_fkey FOREIGN KEY (id_restaurant) REFERENCES public.restaurants(id_restaurant);
 P   ALTER TABLE ONLY public.sucursals DROP CONSTRAINT sucursals_id_restaurant_fkey;
       public       postgres    false    201    2836    205            <           2606    50313 .   sucursals sucursals_id_superadministrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.sucursals
    ADD CONSTRAINT sucursals_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);
 X   ALTER TABLE ONLY public.sucursals DROP CONSTRAINT sucursals_id_superadministrador_fkey;
       public       postgres    false    205    197    2822            S           2606    51064 4   suscripcions suscripcions_id_superadministrador_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.suscripcions
    ADD CONSTRAINT suscripcions_id_superadministrador_fkey FOREIGN KEY (id_superadministrador) REFERENCES public.superadministradors(id_superadministrador);
 ^   ALTER TABLE ONLY public.suscripcions DROP CONSTRAINT suscripcions_id_superadministrador_fkey;
       public       postgres    false    197    223    2822            G           2606    50454 /   venta_productos venta_productos_id_cliente_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_cliente_fkey FOREIGN KEY (id_cliente) REFERENCES public.clientes(id_cliente);
 Y   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_cliente_fkey;
       public       postgres    false    2848    215    213            I           2606    68079 0   venta_productos venta_productos_id_cocinero_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_cocinero_fkey FOREIGN KEY (id_cocinero) REFERENCES public.cocineros(id_cocinero);
 Z   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_cocinero_fkey;
       public       postgres    false    2870    215    233            H           2606    50459 0   venta_productos venta_productos_id_empleado_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_empleado_fkey FOREIGN KEY (id_cajero) REFERENCES public.cajeros(id_cajero);
 Z   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_empleado_fkey;
       public       postgres    false    2842    215    207            L           2606    67896 6   venta_productos venta_productos_id_historial_caja_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_historial_caja_fkey FOREIGN KEY (id_historial_caja) REFERENCES public.historial_caja(id_historial_caja);
 `   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_historial_caja_fkey;
       public       postgres    false    227    215    2864            K           2606    50626 ,   venta_productos venta_productos_id_mozo_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_mozo_fkey FOREIGN KEY (id_mozo) REFERENCES public.mozos(id_mozo);
 V   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_mozo_fkey;
       public       postgres    false    2854    219    215            J           2606    50491 0   venta_productos venta_productos_id_sucursal_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.venta_productos
    ADD CONSTRAINT venta_productos_id_sucursal_fkey FOREIGN KEY (id_sucursal) REFERENCES public.sucursals(id_sucursal);
 Z   ALTER TABLE ONLY public.venta_productos DROP CONSTRAINT venta_productos_id_sucursal_fkey;
       public       postgres    false    215    2840    205            �   �  x�}VY��:}N�
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
�O��mr̎Ԁ%=K�?���Ò��2렃ԫ�!�����o#N��i��b��o>zbhHW������k�<�^��û��`�R��ؼ��Z�X���q�o�׎�� �]Ŗ�b�e_h��؛	XH_�煦;�WhaK�+��4��4�bք���V�����C�y� g��!�C��E0)xlEs�S��M���K��nΐ(�®4,j	ձ�=8�m�������kqۑZB��V����w#R����Z"��>��0��1��|7@`Hj]R�	en�k���8}:P_�p��q���$g_.-���_���<�A���)W�`���S5�!���Ň�.>��r��7�@��p�!�� �]������Es���GA`�U(��k	�}/f��k�����`��|CO�/�)i!�EKj���>�<� �ΐe��#����H-��{�'���Q6/P��P���Pt�X���4��z�%�Ї�#�����j}��x��R������[|�      �   �  x�m�QS�0��/��y��M��iY�EQ�0�Z��6�VJ��o*Uݙ�ps�&s�{�āi���0�i��'ӵ���1jA����X.7�y�D��1�'?�_�#c�bhѲ��e����/��;,�L�v����W�N��Q�{.�g⸎W��~�v���cF�\"^����%X���\�t�<ӸK�k!Xհ.N���@)�Q0R��	1�����D^$�0S�~�\����uX})5N��]�,�[\��:���������t�:�B6[Ў,����*��ˑQ�Ͽcp�Y���4���'Ʃ�7�Wd��­J���@�J��$W��q�����d��(��PO}4?����,|c7Yq����h��|1�����7	v�}�|����%��Wىw��gv�>u��o��	�^�k���]�N�S�s���h�i��P      �     x��Vۍ�0�����м�*"�;�����dk/	p����ph�&�����ʞ��_��_����F2T_
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
̴U�壼��[_��x3f)�c�4 ���)F��M��?���      �   Q   x�u���0���,�kZ��������
(���ɐ�R���7��l��?]1<K��JG����)���:5�+8wcW��_>      �      x���ɒG��ω�H�cU��K^Gd��}��"j@$K˰�~T�c����W��$��m꺙�Z�/�%�S/����r�����)��t
�G��h����QE��]���Q�?���䏪����Gu����`�w#,��@�=5���ok���R�ҕ�~P�{��Q|)/c�����U�s^�Ii�I��~�Hob��N����˧�?޿|y�۫���߾~z��������xJ���ud)���0���klo���v���9>��z֯=�+D���6���/��-׫������e�d�^���������3�/�ˊ��OL��y�;DJ}��K��?� �|��D�yۿBH�|�cA$�TN�v����Gd��-��Nm�*3V�~����H���J�k>���(��_X}Y%>������Pc�Pa���V�Ҋ> ���I+��������?��z�-��>T\��`�����W?=> ���������/�K%��������!�����w�~~8���������oi�Z̳�W�<> �������/��~y0|@p���ዺ�����_���ׇ��!�����w�~}8������3ˈ)�����k:H�{I�:6`,�#9��.��y��',%uZd��v��a);_JD�u�V�?1��cE�����������૏H��Q窿��c�qHF�V���"��q�����_��3�Bx��S-c|���W����~�>̊$�uH��SJu��af�uHV��'�R�dE ���!Y�*u�[,2�Q�����{������/_���y~������������ʀ�Q�cE&OV�����>}?_#����q��1���Էr�ĕZda�[���f�M�jƆH�[(��G�E����1;{��Sa�1�3*Ӳ�ň[�)Τ�,��Ɣ�g�fT�4��o�����i��hs���%����/��m�� ��h�r;��� x���Dar}�Yt���_D=��ZϠ"a��3�IX`�p#*�l=��sИ�WfHDx�c�6�/2"1`�$�������?~~�ʧb�X�1	t��۲?"S�}N`e�2�'��P�3�e4f��)Yנ�2B����v�N�����__?���UT)�����_P����ۏ��.��]~��1��.NE+מo�Ț���˔��)V��OiTw�&܊�_�9*I��'L36�j(�Z;���� ���3io��Bt�)0ǘz�	�� a�[Hj$�I�fn�Z,��L����3��������S�?r{F�^�,)XO$�@Y|�05��<�j�D���W��4��tE��:cPYx߈1�6~3f�Wzl<s�6om]A4���D�I��!�������~��ݙ����u.���������"��x_�ۑ�s��7�Ճ,��8��{Ϯ��S�턣�4�ǘ��3�{8ʸUw���c%��¡��y*ej
!� ��<�4���>mi�������r#C��V�bt��)"�j:(瞲2e�w�Qb�����jd�-�΍ژ��+���&��ݼ�tw!>e��.�gL��X�:x�9W�����
ʠ8OHj���zB��Pw�ru���L�}:���C����R�����k�oqjd�gi:��)��ܻA]'����N�!���!�-	%c̵1e��;� ��r��&�1�vtO1u�����F��f��i�5����́gN%�㙽5��5܉"��)�г��ױ72Ӟs�ۃ� ���?l��SM�UQ��W�?�d ����� �Rp��ͮ>��mL��x�0du&J�x8o{�W}<�۞��w����A�J�� H��}��9v��ds�pGxз�&�ǔZo�@1�!��LvS�2:�Qǀ6��x��9��RII�Aߐ� �`;s/��L\����9:��6b&¼%6o�A9H�o�A9HLVa$&���`�P�1U�B��Ք�r�\π>�bm��,���6�0���;&�]�{&�uﱾ%�jM�n��y��f�ZSǠT.�rp�o�T�j;�
�>�kdPڃ�շ:���[d'�P��2��e�ڃyC���2i￪���򰚊М�=�\��)���h��ӣ�!�|��s��ILZ���gH>j��r2�-���r�0��c�A�q�)֏��Q��K��헸�X��zI:�rN�~�fRwB�&V�bG\����N�8��U��v�~�2`F&5��5=1�1�������@p1��ء8ַ
ɦ�L���:H� j
�c2�3�n:�N�K3y��	.���A�����A����y��O4���.���G�����G���.�Wu���d�I������%�KuB�+�VDؘ�l�2��Sj15�S���ŭ�A!a6�3�Nf�<S���I�p�T�I>�M�AT�,q>�V����ʧ�9��C]�@Nrvg�9�K;��I�[�� .���͘Z��tͱ	[;��7׌){�2V)`D�m4�����ϟ�{?�C�� 'Me魀���P's�s�Q9�������1F�o�ұ�hW�<a =��hC��r%��I��|;����3����/�(�p"��ޠ���lUt��8&�0h�����OS�>����P;s�o|����S�yF�D�">���E��� ��f����8����pL�����0�#5��E|~�A���.ǵ%7&�rX$�q��A	ĵPq�vL���{$����A�M�5���)P�	��U�p�1����^�U:�;�2d∼o�AMϬ��k��c@���ĽU2����K��A���>��v
�sl�����K�E��}cN�c~�ځ��W��53P��3q���g��N!J�#�j
8	�S�P!%��G�X�2~AǠ�k8U��#�C��(8���pY��塎������NH�!��n���{�ƷXNCb��JCd~��0{y��b��-�<l1��K
m��lso�f�A*QZ�Qb�_,H�	�%�?.H����CH�!���>�h��_���rW���KH�A~D>8=^aP]??-�<8h��9�J�:ЀΘg��.t�t�+�k�AICT�4}�������>�r�3�����QőR��J,]�b;=y�n�$��o�~?�~#[���N�n��d,�e�!]�<مMs�ֳ�S��27ĵ�=!����qa�$;���(��T�dէ� u��裈�fy��SY;��eV2�$��CH��n�Dg;����c���&�-�9��R��� �LS�C��Yt��%���7��Ϡ�Lڎ���8KQ������3y;4a
�A$��%�!aC�S$�r�u9������Z�U��!�Any?E�X������l��^��!�Y�)�����O��ؓ �I�<4`
\�!s�2����g�l9��x��7$6;"b��=�x�%����#�R�]ӛp�QH�֛ �d޵[������r��~g����f��H����qP��QT�e"�s�t'C&N@{0M�0Fl�
�6�����A$�h:M���jwk��^x����fH���t,�Z�r�C/���G�A<��l"ͣC�o]���YV�b���I��4��@(�vM�9��7�-��"�z�-g&j�#i����u����e��=R`,\Cסq��rJ�T�j��@>�ok/��4�R�STz7!��D�^���\�tNLI;j܂]�A�&�S�IM�x^�و��P,�5S7���HĮ޵�۷'=�І@	���[���T�"9��M4�L�U��J�Aӧ�M�Rm��vװP?���';��!�4��t#c&��񾉂/b|ǔP�C�`2�	���dff��gWO3�� `2�	�����Q��S;f���M�.�|�����_�^(܏4�6�x���I��HU�'�[K]�3q�=2A�'�If������>Ա��Ha6bh&Y/֕ҲV�����v0f�dJ��b�:_k���i�`�,���d���R���!܋(~g�A*mS\s�    ��2�ʍJ(3d��>u&T?�M�ym�B�x���e�������,>pmS��5�ӗ7�M���`���"y/݅�1���.��=ETG���^wqqC�]���d9[Md)G���}R�=E�M{�)��2h��c]����سf�g"����>}���?�p�~$���)�g��Q\��&�!L�T*����z9����ƥ@R���C�sؐ���Bq&АZ���HuJ�Q�󐷎9Ȑ�c��c�3���(.�bH4�n�ا�ʫeT�uqj��gM��/n�k�!%|�Ip�z�p�\�y��W	AB��:�@@yl.�`K�	�H��Bl�����qD���4����9X?�2���u�G��p���O�{Ra\���u�:2�C(e=���7��.c8��\<^ݥC#��b���*��iK	R%
-��M؆t�������ɥ{��tۭ��7���C�G?��x����j-��݃�BqaʆT=c�A\������`�\��t]����6����b�ܹ|�]זj�)ze��Gr���moD��x��4|Eú����-�b�� T��`��jn�F�x|��}]��.&0$�\'>�������QA�DTG�f��	��!0��E��Ќ�K�����CdG��wx�s��oH:�����nc�!�U��߱�P�!l� qo��������A�P�F�!Ek:�R�#(�BuI9�TpŌ!S�@��o�3�üU:ob��u{C����J{Ԋ����\��a�-N㋃LD�֝Zۘ��ϖ$�%�B.u8�A�BؘJV�^���|U��߮Pi�Rh
5����aD�c�������P�"2s�3j
�9g�q�I@(��g��2�E�Ǡnl�΍eJin�굘��h��W}]��mwm�U̡MC:Sec� � �HV�!�4�l�Գ]�H���#6��A�ݜ�6�D;�'�@����
0w��߁ڠ�g�tmh��4ccF�!�A0���5X��c�3�صʺ6��U�<RP��p4�1�"v"�ۂcH�ڨEuOk.�����$�˵�4O��ܧ �����A.��\"CȚہcl75�~���W���'C�xZ�|44�k.1H�
��˽����g�`��|�A/6�36��A=�BY��|0����ي<A&���!��ɿ�B{�,�CP�"A�x+U��{�U�t�n�!	&���M��h
C �ܙ��j޳^%�Z>��2Щ�v�@w��!��̾;Χuw�oC��&����40݅��$�nq����ҡ�ut	$.��+����HT�͙��B�0�(9C�>���'P$i9����Y�=�hGl����Jc�.ꣃGЉ�H��%:�}=20u֙qS�*"�^f?�҇;�nD�d��՝Eъ-�qJ%ٻ`�j�l��ra���\J'�'��S��Tz��n@��8��G�OЉ�qD�;��DKw[1�����S��,p��*����,��MY���ȼH�Z���S�-��[�H��wO����v%]k|^�rG����0]�7�C��y:#��y(/cJ����F(��O��m򆻴Ðzk�zw��v[٭w�Sv��K��ٱ,�w�dC�2�ϸ���cV[?�ҽʻ'F(諞������� ��D�\��׎������o���aE�C��e�Ӈ���)��/|?���,��BY{V���5��]��6h{�j��P(ߊ�X�N=1���� ��<�����b?P�|���������/���Lɯ�~��[f�/������^��Tۻ �y��{S~���Z+�Q�9�RN��c�,EvO��g�,Ev�B)�d�B3�'�\�V=�����O�1
���6��Q����i�:UM#�)�A��CH��{G��x��C����dÜn�� �!�	�?Π3���4]Z�-rXO���dI3Ν�C@eL�{��D���fH�{�ʔ=������z���b� G>�|w��+RÂ��0nܦ\����n���?ȓL�R�[��.�i��R�)��X;>�Ǡ��W>c$J��AA�t���Jn��d��oL�0��e��=�1�Q��'�E�^^��/�Zp�/�؉\�i=41����=���T��Y��i7�!%�ܣ�yi�)�n^��W��/M�#u��,Y<�f/��p����g-��ǧ}���ӟ��~����?>�{E���Ky���M��à���δ3����Y�����/�_>���3s��7����Š����Az_�����ؔ�l���~���!�g�>�Ƞr=�\;��7�y>v��k�͠��	Y���Tx�=���ܳY��;z�#��,���/����}���at�.4rH�t�TYn��Iv��~�V���E�p;�;�gJ�� ��������/���w�6���6�kq�4����t1��@p�{k�t��w;Rp��yI��!t�U�H:V7�~H���6FUa�*լ?�?<�d�8�
��v��|f����]��a�� ZZA"ϒ�Nf߻cƸ��1�M���Ȅ�����J<�"�v�����o�q��W/Q��(�~#�Aqg��q���u{��G0�苩���`���k�tl�����o�tx	r?S�97�yۏ��/}j������_��u?������d�\����K|�K��.b��&��|�ޫx�s�A.��Є�]w�	�j���������^�(�.f�P�X�Q$���6�D��-�ΦH�V��=�8�O�5��52��b��]�꛽�s�%�)̀eZ7S1q4._I���!OZ��jrE��p����)z2�}�J��_O�S�ܝ7��/��s�ZgG��D��7N�Y'�#V5�����xh�И���;�Gǳ�*�'x���St]KD�YK*zڟ� �kV���JAt�Q
�����e�=�SF>6K�^#C �a���y0��`�A8a�6� �J(؄�z+0�kΎ"VsuV����Q|RW�-�K���'\g���p#�׊C�
�����ؘ���2J��E	�L��KS7ȥcuXNg��^A�^��[n):� ����A��֨��BC/(kґ"	�`=lG�E	�So�ն�H��9�~E$��i��Hîy�A���60��0��ӆd}pB�Z.Q>�
��+�G���}A����(�އؠ���Z�0lT`A�DE*tm�Q��D����%H�����$QQ鲜X�0�J}p�`����z���Sdj%���0,@��_ޏB��Rc܂:�@���Q�NE��(���A i�a�XW܏"���_
A.�U�V�A��xj1Ĕ?��HAvS� ��s#� 9g�!(�%bH�Y���*̚�p��5}�3�V�(��>Ar	
�5H��aXWG�"&�F��#�ZR��,N�=�r;�b�kgE"fݸdD�{�ZE1�6��x�Y�<���ڱeifܘ��)��
cp��B�O��5��L=�Rc�)
� ��/R���}Ñ�M��I�4�hU����˸�:���2�W��5dy�[fޠ�&�A�E���5\Z
O[�;�%��9(C8��u;
�]�ːV-�]�|�sP�pk�9��X��)2v{w�=E&~��F��@����T� �h����j^�V7�٢�p�B��g�����B!ة8"<��ǐ�*ۻ��M�duL�g��ʐ8!�R�@�w�	��l�A�spP��v[�BW1{׷�Kj��È��	�CW��"�3U[3O[�ā+�J�S�ݮ!� `p�Yc�J�bU��\�BDO�ge8�����E8�Lh-I��a$Ld�2���9�I�5���K�2=$�N�`Ș��� �Nb���1٥���x=�����Z���s{����/������E���Ӗa3ӕi� ]�����1�&8��|*cr@1�/����g�����.;��÷J?��x۷N[�l~Ayq���' O��6E�2���O31�L٥�)���P�T�    ��WZ� �U2�b��H���5��-yh��{v./C`�Չ� ��9%X���e���0Y���]e�w7��'(�#�(��; J�KUM������2��W���W���LKY��H���o��9�
����,�,�xs_�q���9b����'pjy֬:�x-��hCqjG��5�@��ӫHՃ泈O����XQ��KY|f�A�]��Ո6���C�Pѡ,��:h�<fz=�Dq� ��i(.�S/���&Pi!FAЕ(>�� �>�j�����R�@�ճ!�u5��NQ���1t4����5R9�����)�[J��PwX<nO�]B�A�/L<�ʮ����+���'\I���VV�=t�p�����J!T��ÆT��d�z���@ c ��.:�;kW�* ��0ADQ���Vw��D>���B�L�+�����\Dg������C�!�rz5P��vȀ+�wA���ΚN
A��A(L���Ѻ����c��	�R�tT�mݽ��J��c�*jeP
��*Z�&(���P� �u�sAĄ��#JZ}��R�� ܆�~o�A�T�����ي
�����7e8)���A�Y]v�#3�������2r:�XBK�@��J�QW>L��u%����A�!hT:4As�"��CИ��p\e����I�K�f�"4��:���E Nln� $�Rh����L=06#�GhTE�Ljn�p.��P�kϬ�J�p��6��F�C�3BL��,C &ln�!p&�1��!�	��qJ���:�V^OQ:� x:ٗ��~��:��Q��l���\R���'�IW��,u�!H�v�}r* b��Ш��I���]È��&�D��Xl�_�)H��TQ��,r���2Qv%�(F��J������i�Bd��x3�;��t|A3
�tg�)����ؒ|p��{�� �W���@�^��#��l1��tg;b��m/�'�?�A���-�,R`)��^�B�MB�v�U�H��f������НE��E�QČ�;��8��
sQ���C $�N�7-��$��~Ř�{�� ���aw��=�@H +�˧���/�t\C�8��S18�ޘ0����aʂ��a�ݙ,Cr�ص������5����
&�8ܚy�J�4Qw{5�@�\�о~�T�_����<z����F�)GO�zm�nWJ[�<%+LFyp]���y)�W��o��q�*C��^
�����P{�R�S.��1��E���N�$�Y4� i_ND��.{@"Wڎ"��t�O9-s��.dR�Z̳"�m\���E���HgޔC�&D�ewj�A����v�1�F�I\�%'9���2�;5�!`���BV0oڅG�j*�1\�U
Ab0��!�y��`ؚ�\���W�`��ཌS��o�����}���>u� �<�ː0����H;���$h��`2���@�{:��`��C@��M�Д唰�G�='F��:��"s=q�p�y��j/D��J��*�a����ԫ�Y_�ȥ��8��8�wa�GAU@|U����L�Y�_~�/��t�yW�A���?ސ�O��>�2�(��+qv	�$�	���`�.�0K5�_�[�讌?��$(�KSQ�ARN�PhЭ�(�K�5BA� � >Bԇдo��Դo	�/��!f,�!
=��<�Ċ�~�/�R`+&�H��$�a`�b�Mʀ��ď!�|��e/��<K�JA�jo�0 �F��z\ ��k&�<����By��=9�ȃϯoTѪ3̘t�2hW�3�!&��$�e��1(M���.�/��)���㍩�X���z�W�}YGN�L0C��9�\�ƍ��JC�v֩��,�*�BgrRM�)��o�o��g�1-ᷩ)�:���ޭh_e�o����z�v���3S���_>:Xx
x��<5o�޹u������}��ŧ}=^�0&KaJ��v�H��������	>�����:�%��OX�T�u+�����Պp�����^�鹋:������ՙ�4.�n��v����p�nݶ���|��W�(g���[E�e&�Q�TC=4^n��z�/��mm�����e¶��b�g�����6����w�j��]�r:���7�(U`���^�˽�qT��ڮ�(���o��gV�"T*5�����A^�zj]� ���޺m=e�������[Sd�V*���2{O[�0$�����WפnUf����v��*������7�y��N�)󯟟��~dX��J�1g<����L�x�t�?�@���&[)H�q��b��/��1s���*��^�om�%^��wE�"��B�)�o7-#�6[l�)�P����)��z#̀/j}��3t���𹜒�Y5,$Ss y4�D�
I�0	f�d��w��\�󴝂��U��TE�+L�<��sr/3s�b����mX�i�ڲHJ��r����y���V���K8��<�w,��>a�D�uC����FR���?Iy� E�";���i�`>A�w��2�Iy�ñv��_�ۨaT��6�&��yߎ�FD�4	�7�|�+�`��.�䑽P=��s:u��2f�l���,��P�4��X��3�OI�Bk��d�LԔ�OvT
�F��.�v�̷�VA�l�^t]���O��K��~�=����A���)�)#�)����q����� �%���\��V\�>)4n��JԬg!G�#�Æ}�C�l*E��d��W�(���S��S�T�"���0�?���d���uP��gn�C@W���i ��Etj�H}Q���nH��UOd3�!��uT	����>L��_���L��Bɢ��_ί��ג.?���v����?pQ������ӷ��I�]J}t����<���K;���G6��lSo�S�Vv-:!�쀕a����×eL0+dg2%{�^b�SU$°H.�#	��y����ʐ�!{��n|�y��u��
~��J�5�k#L��_J����u�l8�F�x������e�mg�����a��Y)�s�ٗ5e�Ȥzh�\!��|�Q��A�"�$ e0aA�R
�D����;��ƨ'u���AL�`#��2�hH�_�x�㻿��5�%�yW�s]͌�wI#
�[�jn���9�ܚ��p&4�����e~����0x��r��������/�W��/����K��5c�׶o�f�9�N�?^ʅ�)�w����s��Ξ�~^M�h�~i�Y�G�R�9�3[�5�lIם;-�"fC�\����k���R�&w�2�$�a�������l�{�SDt���`������_ғ2�ee��Q_�����U	*�jrF�!�������dd����W�;ص����}��ƹ��	�q�f����{&%����GR@p>C"
�����gff:v-��i�0�T
���r$��4_U�2�x�����x�T����/�hL��!_i�6w(��"������L�UR]q��>Ek�ԪT�F��"e����6N��n��@/�J�Ƥj߫��RDA�2R
�)e	�� �(.y�1�N׋?�v)EP�O^P
���1&�J�e0O���rJ-ڢ�|���ۧ�_?���/��?�|�ۛ1�S:)�3o9�C��?蓳+n�^�����1�'}�!s�2m�?ݵaE��VğP���ĚZ�E��#Ӕ{r���c�c{����W}����o;ԓDrɦ%G�I�FJ���9�GQ��m��!��T��e�@�=
����E����%�l����+H[o���=�k+xk�H�D��R��R�#��n�V<�[�@:�9���ǳ�
(�����f���<����"��ַ�dB�b���G���UH[:wAUMC������)�R��L:���w��.*�
J��dظ�D�PkS�8}NdE�O]T�����nz�`��ZW�`�B�[[NC]��"�GU�%B�}2�f��|�j%	�|U��j^H �  �d���2QMb�kUٸ?���i
U\�cP���:�Q��-Ģq����4�t� 4������FK�ߑZ���A
E��1���	�QN=���"�1zB��F�UiZr��$ �����~��Ty%ʓ0�q�i;�!�u��V��s��$Ӗ!�ι�!�,C��ܦ�u{tdY����W�7=�,_IИ��$�^CQ��1{Aj	R
Y��Z��6lu)����t����?2E)L�O�;���c-�c4
��6��Y��6�(Eu	�+�G�u,*vr��%�(��p;�Z�C)Cs%�	-�g3��x�A˱;J�}�R�+.��k� ��u�2jt��6s��}q���*<e�`O��;OV�0PJ�Ē�QSmY��K@-/hB��������i���A�V�>�h����^��b����X�U���-�4dӲt��fɺ=�.��_E��̣P��\&ac�m��نu��%(���f7,	��d��i�%�I��Qj�����`9-�G�)�LzV�6�z(�?��c�e�O�[�7�.Gc���287�%�h�9�+V�I�Ԕ���4I�Q� _Cnc�*�#����<���W����עp���|TѲ��V���/rgΨ��tt���5Ñ�&���~:|q8
-��U`��Q�)�1�.b,ڙ�硲�+�qͻ�-�3�HŊm���@!�UّV	�ErGL
u�LB�d�#�["�Ns�m����b�XkӪ�G�s*�)·��Qh�9:~���}z�*�����
�e::����C)1���@.�"\�-L_V����Q��g����ߤ�ʣ����F5���������̛��zt�xT3Z�s�UO8�G'v����0hĮ������{0��e;oS�*QhI_|w;�W�(O���"2��$�wԊ�h9cn˗$������/֪���-+��)�1�~�Y�f�kV���q�~����N2 ����bE�p��dyϫ��ߣUs�2{(=Tqg��K1�)%�Wn���1�mp�r��2����Oݯ�Ew��b�ڪ����6
�`5�{�C���
H�\1{�4��9�׃h��`���K����ؼͽ�]��Bu�����Yt��x�`��X[i���e*����˗�X�uv�0(T��Ƶ`�_�e�����X�!��nGh�[jӿvH��mŇ�)7:iO�Gh�&�	Owg�2j{�5l�Ua�����s;��7�YK��V�ME|�R�4�}Y��1;�dT�ө�4a���/��a? ��s����qʹ�b-zD˽�>�`�ͤI|VՏZ�a���U�rh�Ǧ�[�th�S	sh��&|lsU����~�V����������v̒v�Y-�:�v��b��~�L�o}:}����h2��>4��-e����f�c{��M�P�|j�h:ݬ��8q�F�N=很˪�94�9t�rêIY	EBL��2�N�Sl��U�s(��>��)�k�ITѴOB�D�9F���lm��X���h� �ŬA�&K��F֖�"k�cG��<4�S�%鮶��b��]�aUz0��8�cm���L�����0	���_֪~y�3���dx�Ĩ��~����ɹ�JMz���F����"�2Qh.my˴aY1���G��`��abL\毲�s�*�A��F1c��1�8�rQhU�A�.]���0=c�N��9�Ρ�B�8�c� OǨ�ӡ�\��[r��	��t>9hi�{�R%%����+��2������g:ĕ^��������y�T�8c���x�L��+�l&�rZ4H���؍�r5%U%�߱al\nj��>;(�Ah�H�l��b��~*)a[�bz���PY&��[TH�ƯX�Ps~�j��$T!�Z�
9��A=�M��"��E}��O�I��aI�r3���	���6̪ �>��Η�p��\����d���r!'��K.8��l�PE���g
-)<k.Z��E:�����v�r����=0�+�.Hd�I����3h@�Т>Ae�2�]��
��4�-V&R�żDj
��B���V�jA�b^�f��x����'���*~?.�P[:Kma�w�D<g����!.�0����{�̬y%%1��ߒ��;e�9�Aw�@$�1�_̎.�ǟ�������B4�>zT�P!�^��8��7��}6�h[�n�)L6;e��ݸ���PG�isۥL�T{�zr�ԁ�:-�&Qs����n2ܖ�]�h@�%�I4��fr�꒤[ĥ�;�������*ԐzlI�$��űE$�6a��'y��bM�KM�V��}�ب�P_� �ƅ]�E�y�zUA�����6�c�$f���2���a�{*��Ӑk�A�r�u�nX�O�Y�e��u�P�`M<,=�_��;���f�՝�muݲ���Ѻdf)4��4d��"��	�ZΧ�F��
e�ld��=��qZ|�L����a�N���X[0j��9G�ڪ���1��O���Q��V��і��`��Aݏ��*ގ�˫º�T�X}��p6�By�C������ynZ��,��07{�]_EIU-�r����cb ��ҦВ�hH�����45����dנ˒K�.H�%a��� X�L��A�d�3%��d������5�{�w�������2_߿��D�3�+/���2ӎ|�SjS���T�yj�Š��%�7Y�%RNu쟫��Qz�w�4{0m!��Zށ3ƴ����Vwcr�8w'�5rf���Q3m���G�"ӰB %�^�tM�qk�;�C��5�7\��S��l��,.gP6�;�ϩ����{�[ڟ�0O�ٿypD[�R�f�u��/�P¼$;����!I�W/�!ng)Ο����a�J�۠���V�˔���u�<��
.�pJe�zMǠ�S��^�1&?g�ëk�ǵ��6��?(,U�5u���1l���I��^������?�]�'�?r>.�l����V��A�Ϧ�t��m����5V�I(b6�:/T:0���,����[	�Q�~��^Ѷ�ß��vY�M�E$��/�R���\[c�i˒�(��6,=8[�Pl�R���)V0�(>��X��dqN;��K-��ޠ��%N�E]���1�%~)>�T�T�xl����4lqO���V�=-�ӧP�q��x�,�=��Q�ȥN�mjFK�\L}D��x�S���U�GL�O��o�`ʚ!lU��+���o�w���/HQf��׽����[�uK���ԑy E��C�F�E�����iܠH{�"���0*)�A��޲��5�����x��A�j_ø,�nLմ{�wm���F���
^�2��R���/rT#�#�C-��j�PDΠ�j� �mxf_���<mʓnPzNUSz0�n��{��_+\�/K��GL�1%>��Y�F]�J��U4C�y�[�F]�9`x��T4m��%�U˃.&M����U�:�����l��e�ƛ�Γ2��}�JF�!<�sZ�dks��T�K�/Ny����+�mm�B�tt֖^��<[���:�������,�ݭ��`�����6�z9�ٲ�JSl�8�`]���qZ��[2�u�N6���~.��]�˞[���[�c�y�Ѐ�a�
��҇As�P*��c���~����Q�����(�b( -�>.�;-����Z��|XKl\]��j���Soa9{�[g��v}KddZ��4o%�ަ>�#�*g+��ޓ۰��M���"n����w�Y��mŮ����#=q��ʚ/�@�0�a����{��g�7%K���޿�~��������55�Q�������{���zG���J����[_�@��Z)��[pf�`�y�������      �      x��Zے�ڒ}f��{�;�)�P.��  "(��c����P`)����b��\�#gΑ��3����7,B2��o�����Q��.T�>�"�G;5�Z�E��i���-:M�}�a �b�Cv+�e���}�ig�}��A�~wZ�+���%,�<Ӈ�|)σ�A;�CMi���j?��N�A��@�/։�:�j�+��/��8�'�4²��"C�F��ox�O�O�O#(�ejJ�2X�B���M����?��_�����.�_�AqF���8PS`��<G!F��sB��^Q� e��>,�_Y�W��K3Ȝ���k�=��}H��V!;]�
h�$��6���8u%��@��/ރvH�N�ׂ�)A0h�"<����}�?���fjvW	���M��|����y�4�}�(�َ����vN����d���l�w3��Y|�7����J���͉JSrEI=zf/0!R���g�/X�'S�#�"��*�9befy&%
����)<�G`�X7S*EY�qx�5H\�|����a�
����M*ukJ���jS��cvT��2d�?��i�E�J�E��p�C�s4OK���'�|�in��rpcN�(?��a�kb>�I�^�%7��Ev���e{�� |:��n!����E1���Y97�#�!/�,%��$�w�7��}�%����? \d�=+�L$�;��@�F�^ٜ�>Ju�@y��O�Żs������D�D�6�A�as��qk���ѐ����6렉w*`h���m`����zE-��/�|t�H]Sb�G�w��,B.�����&��+���
�sj���%N:o�U�ݝK.�)��>��+m".9Z�-I�1GT���/V�*�$e�9�=�_4e26����'�8����n�/��:�x��v �IV��FJ�u��3L4"yV� ��ӷ-�͌zkč�kX�Fg�m��g�W$���[7j�:�qvϏm��T�c?�DP?YÕYS��3����M�'�Ej��0!�������yn}F�q��#�&�i��`Q;B"q`fQ/6-؆����}�#0�]�*MYVٗ)���=�WE����R/��R�؎�8_B�2C�X�*,�˅d;8��7�l��[��8R%�OK�'��fN�5U��To�e�x�Z��'c�I:���=���Ӆ�$]I���V<���fd�?�8������k�����" ʺN�h��h~�`�1���|��N�S͟��t���#n��t"q5~�  Q��L~�9�(s{��h�e����׋��Y^�_�4��s�$t�Nt8��� �7tɴ`<���݀��o�Oz)+#�!�~�������C3�L$v�4
ͮV�kh��Fִ2�I'����x���� ���]7����vx�q[�'5HD)O��y���'K���B�l��E�?��Cux5<��0�p�����ɓby��<���`<�-:9웁�����:k}��@�UW�1�rn묖�F��Tޕ2�sHp����LV�y�`Z(���`��.5oײL6��轔`=xd��۰ߪT�)��8�c?Y��u��V�Iͧ;�%��>�j���9�n��)��#���eATݱ��W�vs�O��hl���f�"{���,F|��nj��tV{D�y�9t���;�}��|=��Xi�S,`>�XNi|�%X!���g,7��n�q�f���T�����YU�.�c�X�����N��+��1B�t������O��I�[yטּ�y��ھ�r�WX��{����=_�mYy]��.�团s�T|l/����>��uf6�#��R�H <,'L(���r�t���w�Ⱥ��� ��w����>�ϰ`6�&�MƄ�ϭՖ>϶5.��Q3�X�:���|�Z2@�ǍxL٩����3��R)7^Ԭ���ǃ����56jX��A�4�'6Cx꺦1����+��^ִ|a�E;�"�`�/�y���.�L9�Z^�Gw��|�T����<���kȮ#SՐۆ���;��R�����Z�).�h���c����Vp�R#���iY1-����X؞�LkɚαF���Z�+h���Ϣ����.gn<���Ȼ&�ihE�k�^�ɭ��;0�竾%hzf(n'ܥ�6gTgMJ�;9�t��CvH�@��5(�̣ЎB����$�*_�dM|�u4�|ͽ�!W�R����nv�2.�p&Ji]ޘrX��dT�2��ۼv[2�a�l,붩����d�띙�����#9	�>-Q��W��,�p*��H�r��z�x�mH4�m�}Q�ሢ!�f�c����?7ʯ?�,��OM6���e��l����s��zk�zX�ZNV�*>�u9��z�ы��D���SpBX��^f&6��0�yL8�o�r��ro��`�.+Oĝu�SCԇV2K��o�D@s�2�L3�R���ل�b9-�:S�>!hdD��LR�����=F��*�y�_��Īh�&-'���%�Ҧ~+�_�e�ZV�\�>�ag�%�)��^�q+��7�-���}��G��`��e�<Y�R�|.0��U!�j�g�l���_�S��N�Lܳ�Y,y�v�H�urs���,Ȕ�,�u���d�yNu�ȦU��å���=ca��]�0!u0��Q ;,�UCR���`u��g`����S�;ZV5�q�;�c��@�۔~ȏ�� x\/��Ϸ����-�q����[��0��H�_�-\���_Ɓw6�SqO�$��-�!o�b�m����<�����{-����z?�)�H�##�s. {㵃�sWΖR���39�g���,�6᛫�VHg�"U2���ܘ]Z��Ѝ\U��j�+��|��Y�aJ���[eQD�C�F��k�z{ؼȚʽV[]_-���D���XYE+5/��u�z/�XT���u��`��)c��a8�Ǉ�4����ik�7�����Le������F�uPY���
�v�%#�?է-��K{�%�t�E?�P����8]��h����!����Z�T'l%IeC�뚖4�I\�3�ïz�7��M�\ؼ|���D�����ڊ%��ㅎ�_1�>Jtʞ�$:����>����zVEvr3��	k��������^c����{����꤭-�/�|��d.7�bwX{�:+��`�F��$�m��N�_�G'������|��2��C��(��}��9mH�;e�BFЁ�8*����>�Fa��uLC�\��u�*je�q�ԯ�&Ǔ.�J҂{�����	k���B1�[=��{�����~�Y�Lw 3�5@K@�LS7�<S�G&2f,���w��6�7�X-�Y6ֽ����L`�]8u��1%��j#��9��$���=|Z�/s�tI��Cf,��1!��=
�%�.�x�M�j��e�P0��em���t���,߯��g>�������|�m�{ahR�J������$n�,���V�D';�_��UV���pG����t�f��UדC��y����-�ը~G�C��%Nb~�|���4}���lJ3�~eN�����_HQ���ь�$r���C�	�Q{�}2U��d� Ss9��좹ǮUm5!s��)���pnH��f�W"����A�)_��WY�n��E�_y��*F�h���+�?'#\����I��_���A_F�WY��y��t�᳡�-��̝�JP�xq��$g ֣�x�/݁��|y�=C�y��'� �ȱ���tB�Z�o�#�����h<P������[�gӐm "����;J�S{�`�f�+=�)��7z@?�K�� *X�ޢY~~�=��%#��Ay3��r���[����lG�0_�G��U��&s��}�;1��%#���"�}�V�,��哶�O�1gyp�Sw�vJL������}�UF6y
� e[�d;M�X�����ܴ�0�x&Nգx��ë͏��޽�ۮ9,^�! ��7�� �> ݲ�
MS��J��^��]Y��toL�^Mѕo$�?c @'���v�:����p��]�˚\X3������\nl5��+r�Ȥ�X�� C   ҿ����p�0c��':e(��9w�1��4�c��Bg�#��?�Ȕ$�����믿�K��a      �   �  x��W�r�H=㯘��3���%r��[�e�r�eH/b� �M�)����?��	��z���0�ӯ_�n��C��>�Lz�w�Y��2���W�~|�}��X$"vl���ǽ�k�V���Sf�ܙ��x��w{w���t*ӽ,�c]�-Y�Lf/o��g������U-���q��=}:�{���d_d��?@����?�"����q(�g�{�3�龇J�2�5Kuɾ����$J�x�6vj��?����H�p�ƽ�͏o���ȲA}η]tNkɲ���9��
;�~ ެy�Y��]y��$�6�����)~����k|�9"�^����cWA�D|�6v/|�^ȃ,S��1O�IVHVIcTQ��-���g��8&���}q�_d�ϧ;��*d�OQv�9���_�������`�{O�fww�֓Y��DC�>R_^l�H���A䀪��ac�rԕܿ�hN'}1o�	�(,�z�G�ת$f�-)�3+j"�g��d��z�~kU-��Ep���H�gXB
�ʢ�_4u���%4��V�ğ�	Ɇ��K�S�@Et?UV����١S�A�ŰUy�Ч�Y��l�kKv��^���{�e��dw�
	/q"p�h��{E���..�� ��ɶ�摽��e u���~xz�[?��{&�OX)SE�ѣ�PG%eٸ�� CN2�?㹰l�(�p��P��v.����L�IY4�
}�`�����DO�mGP�KE*�H~�FՍ��b
ETL4��)<�I'��)m�O�:�4,�+-�Z�m7�f�'��<C�?��4C
�b������������������GbX�<VU�)����B�R�$ �S�Ga�a�sH����"������-���ҫVM��H�E�P�i���ʍ��2�%v!�l^e�~wF6��yX9�F���@E�ܞd��]ހ���+�GS�O4d>���^l�*M&~L*U)D���]��D `Qɝ����@��w�w�%�\pb��a��UGv���ۋ8ς�bAz��B���	�/���t��{#�ן�d'�!(j67JD��w����|������9���4��Ã@�UE��NB��=0���,���Y��3��N��Zq�QКB5Tx;	��.�b��D��;y5����@<���m����)�2��v�Lu��4�$���r��7�Qb�9$����b&��p�����B�cg�� ��u�C��Ik�G!��l���~��܎�>4�Y��[�m��s����P��j���B�[9�3�v٬�2r����P�};�q ,�y�粦-Iݱt+ǆ��r8����Mw�����|lo����_�Ω=�#�l���pj��\��Y~}wsZ~�/��dO���?���M��L�K����U��6�-�(F��0S�]4�`�ii�6 �O6��s�ts������_��	      �   �  x����N�0��ާ��q�M�[Y*q��J�K��$LC���C��c�%�M�D��4����7c'�{Ewη�"ߞ������]:���c���z^��j���������g�n�.� ��G,=b��bL�l2v��N�!'���V���k����J�3[�z&P�*G��5�u�p�V㗡Oڷ�t$�q�P0���≒<�&���L�ˮ�|�+ژ��K|_#RE7��̃�	�*�)����b����es���f򽽍��@9�\�\11���Ï��1�\�B�
�hKM���P�Z a}�ܫ�����S�~�ͷ����H�QL)@%�d,B=	_�'�a�~�e��Daa��:H�y�y�WOb��Tn�q��o����Mv���(����/CH��������,�W�x�Ha�]둫5�ڸR�ô�p4!R���,֓�X��L��	I>�rI9j#���X���,���;S�V�z;����9�w(�0�H�$��`
��X�A�W�����[Z�dT�4��{*��=��k��d�0�B�C���XfM�24�#G����s)�e2���S��7�� .(f�1�JO�bC�-�#��0{��0�e�I��D��l�������!A��� x"Wh��μM��%S���U�6��W�Ц}opʲp{I�}&D��ϐ���@�/����A��x��g$^9��0@di��#W�ǫ��/[�1      �   �   x�3�,JLKL��44261�420��50�50Q00�#lb\F�^�y�%�y�*F�*�*&9~I��Ii�~F%UN9a����U9!%���>�9z��>����!>�9>�p��,����������q��qqq p9*r      �   �   x����
�0E��+����1��*�uy�	Ԧ�D�\]�c���;�3�U�\hH�%��P�@�u��Ba��İ~~�K�1e���0��g,�RZ�I�'e��ʢ�7�kZo�w�ʌ��Yҿ���b��|WgFu�CR�	[/����]��Mj�R���2��Vk�3TU      �   �   x�m��
�@EןO!�Vs�t�U`�Ff�����5F#��Z����A҂�Ltx�e#|�_viEaIL�a6e,�����k�E����*�SX����vHx��*=�K�O��z���'{��I�xѝ���zx~�Q5z����al ��.��� �V�)���D�-�[���/B���D>�      �      x��]I�&)�^�u��@�93Į/�V��;A��I���,����M�k��O�_��y>���?a|���!��g|����B��Oh���{�������_��O��J��L�*!C��wy�K�!sY��~ K��O�r�������'<�i�)�V���NCX�)|�S�CL�Ϟ8�����C�3��Q�ycހs��ӟ�Bct s�~�KC@�e������- �o~ܛ��xp~����k�ȝ�I�9�!�ǭ�+-�y,b�~��ǧ!"13�����m��1>.�f����7Et�K��`Z�΁���G?1�1�0�O]1i����S�(�/U+���xEIb��SX~�+��#-��B�Ύ�n�ܿ>-�~>�s���(GE�-p64qGp����AR�ا�/�:�\JYnȉ`$!� ��lS7�-8o�%[�����F��a1��6H�BL��ވSLD��r���!s�zA��'ȡ ��ϐs2��^ �X��-f�΂�0͂WT�z�o� k���^�:'?�sx���]s�&�3�ݒ
cz㜟4�4w��c���� 5͝{�s���Žݐ�g�����I�oH��S`�2� ǽBD;� +9���)�4�y��-�鯼�ַDv���.Eәx	�"�Z�	�5�d�vl���d��.�Z7��w�ߒhJ���R8�}��{�TQ�4܁�H.����pi��%s�r��j�`���IuihЈyzZk��yF8�35��yi<s0S��K#�����c|��Gg6g��\\c���/����$�y��d��Psi4Hb?�� ��	�Jwhcϻ�y'0?=�|��@��jߴ=�����Ӈ�424�ti"�v�5)� v����㚧j�9bRT�v�Ѡ�1�=�e�='f�/K4ʴ�`Vg�ӽ�{�Y�ΰqz��5ؙ����������?�{DsT��B�����Dߴ�� �$p߷���q�i�D5�MKU��g�y��v��k8E�0L�ߑ�y�����ԗ�F��`6�a��{���
Q�E����dј>�s/�R�]��q3�>�֙�Yo�Rd�,i�����sd{��sO����L�mL�����T�Q�J4��Ö6ɇ�BX�)d-[;Ͽ�2A#�3�� ��� m�ZO�1Z������@"UR`�M�eL]��4f�s������^>	CK�įz�R�qX�9���-A���8��W�4�Y�p��Ny������܏��b�K#� ;� )��~"��p���q�pĩ{� �� �Y�Sy�dXr�Y,�C2�j�v Yv�6[��Q�2F�6�F�<�2ߐ;��� �3�����XMl@�2c��3��Q䆶�'Jĥ$�dj���n�|���tSC�my�wLv�Ln .�raU6h70��Q����ؚ'�]ܜ�44���C�&Ư�i��dϠ�\�J_%�m�C���!H�m&{����V��~u�$���W���؛ى�F*7va"m��Č�/��6�όg�o�<.mM���)�y����,�4P]�-IK����{�KK�~#��S]Zښ!0d��>"4n�4g\-N|�E�o��7N/��K��<6��s��!ȏKsTy�V�I+�BsTydt É�́L��)ɁLǉ642\�ف�j3
���b!�k�Y��.��@rZ��<�mr�w�3��1�b�o����>�Ѿ�$}��mm�j��p�lh��$6O��׭��O�W�_%h���.)���#�Y�Ms�'_R^/)����`24��zIy�}'M��y�񂼤]���42]���#�����A����!v��A��sd��'�-�#�8�u8��
妥�����m�.�vm��[�N4'F�ݘ�v���%�v��<��C�v휆���hۋ��X�5¸�����qi{���� ��㱈DsV��<VF�6���*���]H�f|�f�����e�v�Tu%gఅ�&:	F�F#,�}�� H:6	3>Y	�l!A˜육ۗy�˅�����ivB���y�I�@0{\h�c*�S�߂���AP2�2bڃ��o�Jy�2!#A�5l�L��1k�i��`�	�]q毰�G�y�?���<\�:�/�.�B�_O��y���'�xn���+�іp�3��s��3��Ҝ��G��I���V��LY�B'{V�ʞ-��>[]>kY���9IW�	����(}
:��y�Gx���_.6����!%�����r2��zT�o��� Pˈ��O��G:>���)���,��猙��@Z�c�R�A��/ӡNKİVpv��ֱ���C~����M�Hڶ�7L{� @�,Cpi� [���"$KkP!=�Ļ�i�2H�Mt`�-����?�(V�����0l�ó�lh%��slx�r0�c6�ԫ��J��-�6�E��F���N�ﴸ�ܙ=�ҪEÓ��EE�}�i���*ڜu:e��DTu|��kBsE�Ť���Ԝ�.n��ث���vP�Y�)R�@r)�ܕ�çܴ��L��OZ.��dҎ�.DZ���<n1O7dy�PZ<��t�Z��S	o�� VY��hM��I!#�݃��(�жCj�<�/�pdN��E�N8fB �q���,�s��'�=�jqT��G�w�IJ� F�%�[o�=D�$�:cZ��?�PtA6Y� �Ieg4�q�S��{�v�|F�M�K]촽�O�%!�?�_���uĴV�VαEj���gL�	q�`6���P�3�n�2w��J���H)uȍȾ!�>/�_2��s��+�V���Ù���m���BL�6�����b~ O��c�p�s����d�Πل��,C�YA㘁W\Y�9]�oqn.ik�Z��ٍ\�2$%�q�qg#�r�M�t���1����x���%����6:2b�W��|� �]BR���Q��qy�l�ٕ{KRxÈ�7�:��rrԌ��8�C�+��K.�k`B�/�~��X�#<�~Ni�C�9��� i�����]V`J��F��
L������� ҙ_;����m;B�%�e���]C��@JpM�M�Y�(ޅ��nD(��.-1/&�.��4Tqir] �^��m��+�R�^��bͲ�]��ae8:�{�1:�U������W2n#:#L�r�-1/v5�n�Uͻ�yS^i
Q�� ��)IK��`ґ��n�T?Y.C�fȥpv���$n��$���K�Av �-�h���:�>F��	��Ғ�f�%��jPS����Q2CVK����~f��~9����a<S�*�Ky�B��i�h<!B*(�����R�ħ�Rа�,��p\ٰ�3�����IK����u���gZ��;�f�qFV�$��޴ļؔ���,V�E��N�zí���U�w5����'hIp3�:������\楃���s�S3��i��M��R���G�<�st���[�K�`���dm�6��Ә�H>M�2 j�rJJ�^���#k�-p~�C݈$�X����TJ{��̌�^��<S�E�S��piI0��!)��}�O�EŅD�'9L�H���)XĂg��F<ٙ�q��[���颢� x �@��{#{�xߣ%�͘���#��(+h\�/�$�r���>Dn��vީ�
H�<��!Ba�xNS���L;
M�'e	Zb^Do/SF��ehIK�ˀ�I�s� ;�E��-	�I�<�j��4o�t^Y;��\��%ffDb:wZ���30��]��dv)�%�a-H��zB�������^��:z��c�S�#�Ùt1�Cx{�U#���j�`T�zb��+�5�9xP��n�B.zQ輾����K��V��_�-Z���T��0!ѭ��z;�`d��f�3@,'苗�8��*n�x�d��x�W�4T�i�/���M`:Jt�x����X������:9�px`ԉ�5W����p��U7F��ŭ�=@u�� 3��F��o_�q�wm��Of�ɫ�S��H�\Ѳ��)�	 oU�;�2�ͳ�����Zx:}:~'��3�i�Kċ    `+Na��hV:��ze�QE���*�n��k��뻼J� ��ǏH�&�k�p��"-n�Lz�+���C7���Q�yS����@,"�,i�fqp����x%l~49DAK���!��%���铠%�e�u��mU�JS/h�y�X&��D�[��FВ`fH��G\M���V�+�2S:b�D*!Hg���
��`�����xe��~���P���#�!%^�[�D�,���/�W���"+T#�&xOBg1>�+�.�$�7f�x9����D�����"<]w���d��v��7�_L�/Z��ƴ'NQ�qdK���Uå%f>��*d8Q�]k�=�%��N��TĹ�N!�/<m�/��*̾y���z��P�{Ӓ�e��/<��bމ���@3T�@В`fȝ�{b�7F,���u���dƶ1����ܴ�3��
LR��ᇅLXCV\Z���x͚�V�X;���s�[���d�&xp�E��*�u� ��&r{�D:订ś��b���a����O1�Dw�_���7{�� b�DRJ�pjyƴ{�YN��WȊ���DIC�h��fU�_���p������M�"�T�mg�W&ǞD�q\ۛ��YCj7��A�Ԝ�}��:%!�|�<��ļH�e���j�%;���e@�f���*�B���D���k��$�U� �!IK�ˀ���������+J�m7��\���<Ԣ���7`JJlMd(pH9tsݥyr�J2���٥%� M�3e���K��*;#�-�4o�� ��ā:��b*8�KK̻]������p���I�r �Re�펄'Y�d5IK��AG[N?���B�9�,��$fF$�}�Q�V�%mn��x��h$�N�JooȽث�遤p��t�:x#2K���>���q�&Ѐv���E˧�{�3(iG���˃�O�q?.-13#V�|��sW�Xˮ3Q�#�r�^����8���/����Vv�3'����)�c�5�d�l_`/vԀ[Nw ]��"�@����O���X��<��&\�nؤ�b>藷s�r0�amv]��G5�������[�:�~E`ʙ�ļ���{���P���|PA��L�h�e�z�4��>®������g��s�.�����_Anb�g��&���������9e՞Z�D�l��r��Ipiޔ�lr�>-�f��-V�ۥ�{��'�UA�vS�1�N���J4�;���2N�bc>�;�4'�k�u8��M�v�wZJtNKBb�i��M}�$&�OKx��;���Q�i���y�]����;�iN|���ޡ�y�I[��}�]����l:*hIp3&%���4��+.-1/���s������4�˳�N��0IF��{�m����[�_,*%�0W�eeL��ԡ�|Ѵ٤#.[�р����H5D�u�x䗞p籈�Mq��1���7l�@����k���a~�@����\���=-�w@u�~ �o\��=�rH�@=��
vI��!4�5օ s�G������F��� �_�aƶ\b����Ay��f������:hN3�)u+� �2��B^Sz]e(HQ	��C����U����(x���%�]�����ؿE��0`s��,ɯ{��!����Ц�J_���/��\#�\ڬ�WU�O'���f�`	pp^L{vTO֩�Vr�ͥy#�R�8v�e��;T�N�33b҈�*.�4��U4AR�#D+����3�����7��X$eq�Dė7ph�ŬA�|��7�W�0��3���s��á��KB� �Rp��LϺ�񸕩�a%��3C���H}���q6�c��L���Vc��ҜDIZM�=.b&�ˣ%�e@J7�7�sw �lC����M!���D��@:��/�l])���I�%:�z;s!�b���3�H����oN\��r<MC���3FȦ���Uiݖ�A���w*.-1/]��!6����̌�|�q`�1��ث���؉��p�1|��k�v�\_+s1����2 ���8��O:�sh�y�.땊MO�%���q�R��0�*��������/D�5ԋD��ќ{CTw=	p�g�F�s���WU�uu �O���B����u�ʐA���Z��f��s��)�m��:��c��gU���Z�La�zD��(�E]�U��Jy�g��V�lqqh'-�U���j7 ���`�ky5s�4-�e��F�ŅӇ#V�����y��6^YFl�g�^g]�L�r\�������ic�<@�}U�bDc]u�*�
�lT����=�m��G5����F.��>nS��?m��u����G���O�Wش�fu?:��	)�p�oĮ�h�a|�b��ٖ&�����W��;��I)Fn���
�B��Ҷe�_�3�k���� "m7�	���Y��,"��Q�����\U�j�@oi\� ��u)h�0�d�A��.�{A٥]h9�{�Qս&քt�Y9����_��5nNY|II�
�N�R�"�5���}�7W�B��O�˙rԖ�9��]3���H��j��s�3hȰ6zc�ؗ�I��r�2���1��+=�Mׂ>�����Η�l��)e׽#.Ƕ���1ϹC�SO}<��/yCx�Ӷ���Q�>{�`�$kF��#��s�������B}IҞV�Wr���ӯ�N8�c8kb3�WW���)G�X�B��[2����7t�0�М1`����W���uB���[ǆgmf]���ߛy�ӿ��SD��oTL���G4/� �}O�>��.�%>Yt[�:p�AW���d5��?]7=W�l����C�F���`���d9�.���=D��+��-�?|w��E<%-��;x�{�e�DH���� �D��N�ވ�5�u���y��>�x�3܀鱡�aɴ <�Ή'oxUe���+�>�~�xN �����0��ۡ���p��D�Ek%���-�iڌ���l5{m>�=��ơ�~�^c�W�Kod]�;ծ����J�B�Q�^��Y�˶K@��d|���:E[�U�s�C`��֗QǨ,��M&� <L��/ڮ����}9����R�ptH�'��ޟ!³���j�W�[<H����x�S��>��O7_��}���OI�٣��'�qu�0��вj�'i��VG>��=,^ԑ������[�`]�Պ`VB�j_��4�2������6W�X����Ks�M���6-�>S�K%�{�4ӻ�A,���eZ�7-�J��Q#��|��9�C�H��"'>h�Ϣ{��bYe4��ӌR�O2I@��7>�����x}N(���Y��b��u��������M�ӳ�)�o/��H�:7�4����yz�Wy�i���7��J���e�ɴ�=Xg�v��K:cZ�`yy0�z��k�"�.��VܘA}�� U������N=��O��'��,�bg��W��|Ο�m�bT��-��)lz�φ/6�f߰���A�)��3�=��R�Z��D��3�����WL�Q����m_��$Z�*�q6#̫�]I�P?ڃ�Ӿ�z���(����AO��@'�8�\����u�AIS��z����˕��+JC�㍉��x�2��U�Iq隺�	��oA�'H���-�f�SX�y���n�0ug׃Y6f1�L�t�VN�g���|L�g��IV�i��X,PH��!P�9��O�k-��@�iH��q6|	�]��{�3�\�E�z��*F�[J�y�E�{2�[��1�!Z�M�X��	�E|J����NS���Xt�%�i'��Gˋ�	M����o����7ֳhg�Z¾���In�a�r��{%_4���(M0|��;�D��5��Y�iྦྷ�h���i�f�$�pi ���{�Љ4�4]0`���/�����/�A��bg���E_gL��$���i")͟�~�G�����.�[Sڂ丹��I#��X�;��<R)b�Բ3����Μ�e6C��<�����k 1޴<^��� ��i� �   ��9H2�%�	ݭT"8y�(�	M�eR !"��������]��yb�_�ͥ.��c���7}��C|�ִ�#b���[�1����Q�YM[j|(5�͔J~7�7Eۈ˿8�5�e�Ȝ�����[3�C�T,^x���?_���� ƅ�3     