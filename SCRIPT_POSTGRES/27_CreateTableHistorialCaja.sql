create table historial_caja(
	id_historial_caja serial8 primary key,
	monto_inicial numeric(10,4) not null,
	monto numeric(10,4) not null,
	fecha date not null,
	estado bool not null,
	id_caja int8 not null,
	id_administrador int8,
	id_cajero int8,
	created_at timestamp,
	updated_at timestamp,
	foreign key (id_caja) references cajas (id_caja),
	foreign key (id_administrador) references administradors (id_administrador),
	foreign key (id_cajero) references cajeros (id_cajero)
)
