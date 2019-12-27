create table superadministradors(
	id_superadministrador serial8 primary key,
	usuario varchar(10) not null,
	pass varchar(10) not null,
	created_at timestamp,
	updated_at timestamp
)

create table categoria_empleados(
	categoria_empleado serial8 primary key,
	nombre varchar(10) not null,
	descripcion text,
	created_at timestamp,
	updated_at timestamp,
	id_superadministrador int8 not null,
	foreign key (id_superadministrador) references superadministradors (id_superadministrador)
)

alter table categoria_empleados rename column categoria_empleado to id_categoria_empleado

create table users(
	id_usuario serial8 primary key,
	nombres varchar(50),
	paterno varchar(25),
	materno varchar(25),
	dni varchar(25),
	direccion text,
	nombre_usuario varchar(25),
	email varchar(25),
	password varchar(30),
	estado bool,
	fecha_nac date,
	sexo bool,
	fotoperfil_url varchar(150),
	created_at timestamp,
	updated_at timestamp
)

create table restaurants(
	id_restaurant serial8 primary key,
	nombre varchar(20) not null,
	estado bool not null,
	descripcion text,
	created_at timestamp,
	updated_at timestamp,
	id_superadministrador int8 not null,
	foreign key (id_superadministrador) references superadministradors (id_superadministrador)
)

create table administradors(
	id_administrador serial8 primary key,
	id_restaurant int8 not null,
	id_superadministrador int8 not null,
	foreign key (id_restaurant) references restaurants (id_restaurant),
	foreign key (id_superadministrador) references superadministradors (id_superadministrador)
) inherits (users)

create table sucursals(
	id_sucursal serial8 primary key,
	nombre varchar(20) not null,
	direccion text,
	descripcion text,
	estado bool,
	id_restaurant int8 not null,
	id_superadministrador int8 not null,
	created_at timestamp,
	updated_at timestamp,
	foreign key (id_restaurant) references restaurants (id_restaurant),
	foreign key (id_superadministrador) references superadministradors (id_superadministrador)
)

create table empleados(--añadir estado
	id_empleado serial8 primary key,
	sueldo money,
	fecha_inicio date,
	id_sucursal int8 not null,
	id_administrador int8 not null,
	id_categoria_empleado int8 not null,
	foreign key (id_sucursal) references sucursals (id_sucursal),
	foreign key (id_administrador) references administradors (id_administrador),
	foreign key (id_categoria_empleado) references categoria_empleados (id_categoria_empleado)
) inherits (users)

alter table empleados add column estado bool

create table categoria_productos(--añadir campos created_at, updated_at
	id_categoria_producto serial8 primary key,
	nombre varchar(50) not null,
	descripcion text,
	estado bool not null,
	fecha_inicio date,
	id_restaurant int8 not null,
	id_administrador int8 not null,
	created_at timestamp,
	updated_at timestamp,
	foreign key (id_restaurant) references restaurants (id_restaurant),
	foreign key (id_administrador) references administradors (id_administrador)
)

create table productos(
	id_producto serial8 primary key,
	nombre varchar(50) not null,
	descripcion text,
	estado bool not null,
	fotoproducto_url varchar(150),
	id_categoria_producto int8 not null,
	id_administrador int8 not null,
	created_at timestamp,
	updated_at timestamp,
	foreign key (id_categoria_producto) references categoria_productos (id_categoria_producto),
	foreign key (id_administrador) references administradors (id_administrador)
)

create table cartas(
	id_carta serial8 primary key,
	nombre varchar(50) not null,
	descripcion text,
	dia date,
	cantidad int,
	id_administrador int8 not null,
	created_at timestamp,
	updated_at timestamp,
	foreign key (id_administrador) references administradors (id_administrador)
)

create table sucursal_cartas(
	id_sucursal_carta serial8 primary key,
	id_sucursal int8 not null,
	id_carta int8 not null,
	created_at timestamp,
	updated_at timestamp,
	foreign key (id_sucursal) references sucursals (id_sucursal),
	foreign key (id_carta) references cartas (id_carta)
)

create table clientes(
	id_cliente serial8 primary key,
	nombre_completo varchar(100),
	dni varchar(50),
	id_empleado int8 not null,
	created_at timestamp,
	updated_at timestamp,
	foreign key (id_empleado) references empleados (id_empleado)
)

create table venta_productos(
	id_venta_producto serial8 primary key,
	cantidad int,
	importe money,
	descuento int,
	estado_venta char,
	fecha date,
	id_producto int8 not null,
	id_carta int8 not null,
	id_cliente int8 not null,
	id_empleado int8 not null,
	created_at timestamp,
	updated_at timestamp,
	foreign key (id_producto) references productos (id_producto),
	foreign key (id_carta) references cartas (id_carta),
	foreign key (id_cliente) references clientes (id_cliente),
	foreign key (id_empleado) references empleados (id_empleado)
)








