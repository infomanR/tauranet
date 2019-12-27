create table plan_de_pagos(
	id_planpago serial8 primary key,
	cant_pedidos int,
	cant_mozos int,
	cant_cajas int,
	cant_cajeros int,
	created_at timestamp,
	updated_at timestamp,
	id_suscripcion int8 not null,
	foreign key (id_suscripcion) references suscripcions (id_suscripcion)
)