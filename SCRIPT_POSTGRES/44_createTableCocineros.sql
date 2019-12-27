create table cocineros(--añadir estado
	id_cocinero serial8 primary key,
	sueldo numeric(9,2),
	fecha_inicio date,
	id_sucursal int8 not null,
	id_administrador int8 not null,
	foreign key (id_sucursal) references sucursals (id_sucursal),
	foreign key (id_administrador) references administradors (id_administrador)
) inherits (users)


alter table venta_productos 
add column id_cocinero int8, 
add constraint venta_productos_id_cocinero_fkey 
foreign key (id_cocinero) 
references cocineros (id_cocinero);