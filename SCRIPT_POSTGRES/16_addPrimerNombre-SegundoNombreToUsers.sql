alter table users
add column segundo_nombre varchar(100)

alter table users
rename column nombres to primer_nombre

alter table users
alter column primer_nombre type varchar(100)