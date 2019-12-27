insert into superadministradors (usuario, pass, created_at, updated_at) values ('rafael', '12345', current_date, current_date)

/*Inserta la categoria ADMINISTRADOR*/
insert into categoria_empleados (nombre, descripcion, created_at, id_superadministrador)
values ('Administrador', 'Se encarga de gestionar empleados, productos, categoria productos, cartas', current_date, 1)

/*Inserta la categoria CAJERO*/
insert into categoria_empleados (nombre, descripcion, created_at, id_superadministrador)
values ('Cajero', 'Se encarga de gestionar clientes, venta de productos, ademas de ver reportes diarios y semanales', current_date, 1)

/*Inserta la categoria MOZO*/
insert into categoria_empleados (nombre, descripcion, created_at, id_superadministrador)
values ('Mozo', 'Se encarga de gestionar clientes, venta de productos', current_date, 1)