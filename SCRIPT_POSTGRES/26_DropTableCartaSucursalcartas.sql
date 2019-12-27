alter table venta_productos
drop column id_carta

drop table sucursal_cartas

drop table cartas

drop table producto_imagens

alter table venta_productos
drop column id_producto

alter table venta_productos
alter column total type numeric(9,4)

alter table venta_productos
add column sub_total numeric(9,4)

alter table producto_vendidos
add column nota text