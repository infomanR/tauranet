create or replace function function_fecha_pedidos(idRestaurante bigint, fechaIni date, fechaFin date)
returns table(
	fecha date,
	pedidos bigint
) as $$
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
$$ language plpgsql;
--drop function function_fecha_pedidos
--select * from function_fecha_pedidos(42, '2019-01-01', '2019-11-15')