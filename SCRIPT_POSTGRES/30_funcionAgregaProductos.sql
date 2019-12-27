CREATE OR REPLACE FUNCTION registraProductosFunction (cad text, id_venta_producto bigint)
RETURNS integer AS $total$
declare
	nro_elementos integer;
	row_cad text;
	col_cad text;
	i integer;
	j integer;
	
BEGIN
	i = 1;
    nro_elementos = (select array_length(regexp_split_to_array(cad, ':'),1));
    WHILE i <= (select nro_elementos) LOOP
		row_cad = (SELECT split_part(cad, ':', i));
		raise notice '%',row_cad;
		raise notice '-> %', (SELECT split_part(row_cad, '|', 1));--cod
		raise notice '-> %', (SELECT split_part(row_cad, '|', 2));--cant
		raise notice '-> %', (SELECT split_part(row_cad, '|', 3));--p_unit
		raise notice '-> %', (SELECT split_part(row_cad, '|', 4));--importe
		raise notice '-> %', (SELECT split_part(row_cad, '|', 5));--nota
		insert into producto_vendidos
			(
				id_producto,
				cantidad,
				p_unit,
				importe,
				nota,
				id_venta_producto,
				created_at
			)
			values (
				CAST(split_part(row_cad, '|', 1) as bigint),--cod
				CAST(split_part(row_cad, '|', 2) as int),--cant
				CAST(split_part(row_cad, '|', 3) as numeric(9, 4)),--p_unit
				CAST(split_part(row_cad, '|', 4) as numeric(9, 4)),--importe
				(SELECT split_part(row_cad, '|', 5)),--nota
				id_venta_producto,
				now()
			);
		
		--raise notice '% %', suma, i;
		i = i+1;
	END LOOP;
    RETURN i-1;
END;          
$total$ LANGUAGE plpgsql;

--drop function registraProductosFunction