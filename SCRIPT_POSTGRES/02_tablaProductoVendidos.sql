alter table venta_productos
rename column cantidad to nro_venta

alter table venta_productos
rename column importe to total

create table producto_vendidos(
	id_producto_vendido serial8 primary key,
	cantidad int,
	importe money,
	id_producto int8 not null,
	id_venta_producto int8 not null,
	foreign key (id_producto) references productos (id_producto),
	foreign key (id_venta_producto) references venta_productos (id_venta_producto)
)


