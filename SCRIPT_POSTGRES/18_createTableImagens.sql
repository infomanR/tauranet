create table perfilimagens(
	id_perfilimagen serial8 primary key,
	nombre varchar(250) not null unique,
	id_administrador int8,
	id_mozo int8,
	id_cajero int8,
	foreign key (id_administrador) references administradors (id_administrador),
	foreign key (id_mozo) references mozos (id_mozo),
	foreign key (id_cajero) references cajeros (id_cajero),
	created_at timestamp,
	updated_at timestamp
)

