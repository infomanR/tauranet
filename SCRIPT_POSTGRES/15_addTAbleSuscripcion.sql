create table suscripcions(
	id_suscripcion serial8 primary key,
	tipo_suscripcion varchar(20) not null,
	observacion text,
	precio_anual money,
	precio_mensual money,
	created_at timestamp,
	updated_at timestamp,
	id_superadministrador int8 not null,
	foreign key (id_superadministrador) references superadministradors (id_superadministrador)
)


alter table restaurants
add column observacion text

alter table restaurants 
      add column id_suscripcion int8, 
      add constraint restaurants_id_suscripcion_fkey 
      foreign key (id_suscripcion) 
      references suscripcions (id_suscripcion);