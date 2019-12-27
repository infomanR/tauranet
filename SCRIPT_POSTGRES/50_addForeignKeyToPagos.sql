alter table pagos 
add column id_cajero int8, 
add constraint pagos_id_cajero_fkey 
foreign key (id_cajero) 
references cajeros (id_cajero);