create or replace function function_fecha_importe(idRestaurante bigint, fechaIni date, fechaFin date)
returns table(
	fecha date,
	importe numeric(10,2)
) as $$
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
$$ language plpgsql;

--drop function function_fecha_importe

--select * from function_fecha_importe(42, '2019-10-01', '2019/11/17')