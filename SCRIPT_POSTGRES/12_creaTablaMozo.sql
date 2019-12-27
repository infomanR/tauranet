create table cajas(
	id_caja serial8 primary key,
	nombre varchar(20) not null,
	direccion text,
	descripcion text,
	estado bool,
	created_at timestamp,
	updated_at timestamp,
	id_administrador int8 not null,
	foreign key (id_administrador) references administradors (id_administrador)
)

alter table cajas 
      add column id_sucursal int8, 
      add constraint cajas_id_sucursal_fkey 
      foreign key (id_sucursal) 
      references sucursals (id_sucursal);

alter table cajeros 
      add column id_caja int8, 
      add constraint cajeros_id_caja_fkey 
      foreign key (id_caja) 
      references cajas (id_caja);