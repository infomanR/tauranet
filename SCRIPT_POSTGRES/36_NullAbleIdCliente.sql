--select * from cajeros order by id_cajero desc

alter table venta_productos
alter column id_cliente drop not null

alter table clientes
drop constraint clientes_dni_unique