select regexp_split_to_array('1-67-Pechuga de pavo-22.30-0-22.3|1-64-Pechuga de pollo-32.00-0-32|', '|')


SELECT 
	a[1] AS DiskInfo
	,a[2] AS DiskNumber
	,a[3] AS MessageKeyword
FROM (
    SELECT regexp_split_to_array('1-67-Pechuga de pavo-22.30-0-22.3,1-64-Pechuga de pollo-32.00-0-32,', ',')
) AS dt(a)

SELECT 
	a[1] AS DiskInfo
	,a[2] AS DiskNumber
	,a[3] AS MessageKeyword
FROM (
    SELECT array_length(regexp_split_to_array('1,67,Pechuga de pavo,22.30,0,22.3:1,64,Pechuga de pollo,32.00,0,32:1,66,Pierna a la brasa,22.40,0,22.4:1,60,Sacta de Pollo,22.30,0,22.3:3,63,Pollo a la broaster,66.00,0,22:1,65,Piernas la jugo,55.60,0,55.6', ':'),1)
) AS dt(a)

SELECT regexp_split_to_table('1,67,Pechuga de pavo,22.30,0,22.3:1,64,Pechuga de pollo,32.00,0,32:1,66,Pierna a la brasa,22.40,0,22.4:1,60,Sacta de Pollo,22.30,0,22.3:3,63,Pollo a la broaster,66.00,0,22:1,65,Piernas la jugo,55.60,0,55.6', ':')
select * from venta_productos
select registraProductosFunction('67,1,22.3,22.30,0:64,1,32,32.00,0:66,1,22.4,22.40,0', 26)

select * from producto_vendidos