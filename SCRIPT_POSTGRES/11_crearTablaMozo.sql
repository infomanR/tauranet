create table mozos(--añadir estado
	id_mozo serial8 primary key,
	sueldo money,
	fecha_inicio date,
	id_sucursal int8 not null,
	id_administrador int8 not null,
	foreign key (id_sucursal) references sucursals (id_sucursal),
	foreign key (id_administrador) references administradors (id_administrador)
) inherits (users)

drop table categoria_empleados

alter table venta_productos 
      add column id_mozo int8, 
      add constraint mozos_id_mozo_fkey 
      foreign key (id_mozo) 
      references mozos (id_mozo);
	  
alter table clientes 
      add column id_mozo int8, 
      add constraint clientes_id_mozo_fkey 
      foreign key (id_mozo) 
      references mozos (id_mozo);
	  
alter table venta_productos
rename constraint mozos_id_mozo_fkey to venta_productos_id_mozo_fkey

alter table venta_productos
alter column id_cajero drop not null

alter table clientes
alter column id_cajero drop not null



