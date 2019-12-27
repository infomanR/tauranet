alter table empleados
drop column id_categoria_empleado

alter table empleados
rename column id_empleado to id_cajero

alter table empleados
rename to cajeros

alter table venta_productos
rename column id_empleado to id_cajero

alter table clientes
rename column id_empleado to id_cajero