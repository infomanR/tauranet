
alter table clientes
drop column id_sucursal

alter table clientes 
      add column id_restaurant int8, 
      add constraint clientes_id_restaurant_fkey 
      foreign key (id_restaurant) 
      references restaurants (id_restaurant);