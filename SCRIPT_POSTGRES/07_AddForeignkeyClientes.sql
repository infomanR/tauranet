alter table clientes 
      add column id_sucursal int8, 
      add constraint clientes_id_sucursal_fkey 
      foreign key (id_sucursal) 
      references sucursals (id_sucursal);
	  
alter table venta_productos 
      add column id_sucursal int8, 
      add constraint venta_productos_id_sucursal_fkey 
      foreign key (id_sucursal) 
      references sucursals (id_sucursal);
	  
alter table users 
      add constraint users_email_unique unique (email)

alter table users
      add constraint users_nombre_usuario_unique unique (nombre_usuario)

alter table superadministradors 
      add constraint superadministradors_usuario_unique unique (usuario)
	  
alter table restaurants 
      add constraint restaurants_nombre_unique unique (nombre)
	  
alter table users 
      add constraint users_dni_unique unique (dni)
	  
alter table clientes 
  add constraint clientes_dni_unique unique (dni)

	  