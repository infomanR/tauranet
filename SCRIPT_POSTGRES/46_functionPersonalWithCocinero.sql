create or replace function function_personal(idRestaurant int)
returns table(
	id_usuario bigint,
	nombre_usuario varchar(25),
	nombre_completo text,
	dni varchar(25),
	tipo_usuario character(1),
	perfil text,
	nombresucursal varchar(20),
	created_at timestamp,
	id_sucursal bigint
) as $$
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
$$ language plpgsql;


--select * from function_personal(42)


--drop function function_personal