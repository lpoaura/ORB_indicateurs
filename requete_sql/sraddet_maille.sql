create or replace view orb_indicateurs.maille_reg as (
with data_reg as (select la.geom from ref_geo.l_areas la
					 where la.area_code = '84' and la.id_type =75),
	 data_dep as (select * from ref_geo.l_areas la
					 where la.id_type = 26
					 and ST_Within(la.centroid, (select dr.geom from data_reg dr)))
select la.id_area,
	   la.id_type,
	   la.area_name,
	   la.area_code,
	   la.geom,
	   dd.area_name as nom_dept 
from ref_geo.l_areas la, data_dep dd
where la.id_type= 70
and ST_Within(la.centroid, (select st_buffer(dr.geom, -500) from data_reg dr) )
and ST_Within(la.centroid, dd.geom) );