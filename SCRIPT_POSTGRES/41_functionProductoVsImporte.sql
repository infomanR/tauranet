create or replace function function_producto_importe(idRestaurante bigint, idCategoria bigint, fechaIni date, fechaFin date)
returns table(
	nom_producto varchar(50),
	nom_categoria varchar(50),
	importe numeric(10,2)
) as $$
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
$$ language plpgsql;


--drop function function_producto_cantidad
--select * from function_producto_importe(42, -1, '2019-01-01', '2019-11-15')