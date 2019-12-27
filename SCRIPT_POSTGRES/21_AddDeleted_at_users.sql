alter table users
add column deleted_at timestamp

alter table cajas
add column deleted_at timestamp

alter table categoria_productos
add column deleted_at timestamp

alter table productos
add column deleted_at timestamp
