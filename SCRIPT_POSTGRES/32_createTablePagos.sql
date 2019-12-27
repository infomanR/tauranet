create table pagos(
	id_pago serial8 primary key,
	efectivo numeric(9,4),
	total numeric(9,4),
	total_pagar numeric(9,4),
	visa numeric(9,4),
	mastercard numeric(9,4),
	cambio numeric(9,4),
	id_venta_producto int8 not null,
	created_at timestamp,
	updated_at timestamp,
	foreign key (id_venta_producto) references venta_productos (id_venta_producto)
)

alter table venta_productos 
      add column id_historial_caja int8, 
      add constraint venta_productos_id_historial_caja_fkey 
      foreign key (id_historial_caja) 
      references historial_caja (id_historial_caja);