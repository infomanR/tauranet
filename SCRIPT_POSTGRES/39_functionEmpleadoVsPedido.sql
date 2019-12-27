create or replace function function_empleado_pedido(idRestaurante bigint, fechaIni date, fechaFin date)
returns table(
	nombre_usuario varchar(25),
	perfil text,
	pedidos bigint
) as $$
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
$$ language plpgsql;

--drop function function_empleado_pedido

--select * from function_empleado_pedido(42, '01/11/2019', '12/11/2019')
