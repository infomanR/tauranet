alter table pagos
alter column efectivo type numeric(9,2)

alter table pagos
alter column total type numeric(9,2)

alter table pagos
alter column total_pagar type numeric(9,2)

alter table pagos
alter column visa type numeric(9,2)

alter table pagos
alter column mastercard type numeric(9,2)

alter table pagos
alter column cambio type numeric(9,2)

--tabla historial caja
alter table historial_caja
alter column monto_inicial type numeric(10,2)

alter table historial_caja
alter column monto type numeric(10,2)

--02/10/2019
alter table cajeros
alter column sueldo type numeric(9,2)

alter table mozos
alter column sueldo type numeric(9,2)

alter table producto_vendidos
alter column p_unit type numeric(9,2)

alter table producto_vendidos
alter column importe type numeric(9,2)

alter table productos
alter column precio type numeric(9,2)

alter table suscripcions
alter column precio_anual type numeric(9,2)

alter table suscripcions
alter column precio_mensual type numeric(9,2)

alter table venta_productos
alter column total type numeric(9,2)

alter table venta_productos
alter column sub_total type numeric(9,2)


