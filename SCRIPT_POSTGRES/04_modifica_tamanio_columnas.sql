--select * from categoria_empleados
/*Modificacion del ancho de la columnas*/
alter table categoria_empleados
alter column nombre type varchar(50)

alter table users
alter column nombres type varchar(250)

alter table users
alter column paterno type varchar(250)

alter table users
alter column materno type varchar(250)

alter table superadministradors
alter column usuario type varchar(250)

alter table superadministradors
alter column pass type varchar(250)

alter table users
alter column email type varchar(250)

alter table users
alter column password type varchar(500)

alter table restaurants
alter column nombre type varchar(50)

