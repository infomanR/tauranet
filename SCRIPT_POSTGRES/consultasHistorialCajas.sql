select * from clientes order by created_at desc

select * from venta_productos
select * from historial_caja order by created_at desc


select sum(p.total_pagar), sum(p.cambio) from pagos as p
inner join venta_productos as v on p.id_venta_producto = v.id_venta_producto
where v.id_historial_caja = 13

select p.* from pagos as p
inner join venta_productos as v on p.id_venta_producto = v.id_venta_producto
where v.id_historial_caja = 13

select * from historial_caja