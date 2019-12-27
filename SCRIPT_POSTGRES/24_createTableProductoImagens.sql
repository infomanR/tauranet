alter table productos
drop column estado

alter table productos
drop column fotoproducto_url

create table producto_imagens(
	id_producto_imagen serial8 primary key,
	nombre varchar(250) not null,
	descripcion text,
	id_producto int8 not null,
	id_administrador int8 not null,
	created_at timestamp,
	updated_at timestamp,
	foreign key (id_producto) references productos (id_producto),
	foreign key (id_administrador) references administradors (id_administrador)
)

