create materialized view orb_indicateurs.mv_sraddet_ind_surf_reserve as (
    with surf_reg as (	select round(CAST(st_area(la.geom)/1000000.0 AS numeric),2) as surf_km from ref_geo.l_areas la 
                        where la.area_name = 'AUVERGNE-RHONE-ALPES'),
        surf_env as (	select 	  bat.type_name as espace
                                , st_union(la.geom) as geom
                                , round(CAST(st_area(st_union(la.geom))/1000000.0 as numeric),2) as surf_km  
                        from ref_geo.l_areas la
                        inner join ref_geo.bib_areas_types bat on la.id_type = bat.id_type 
                        where bat.type_name in ( 'Réserves naturelles nationales'
                                                ,'Réserves naturelles regionales'
                                                ,'Natura 2000 - Zones de protection spéciales'
                                                ,'Natura 2000 - Sites d''importance communautaire'
                                                ,'ZNIEFF1'
                                                ,'ZNIEFF2'
                                                ,'Parcs naturels régionaux'
                                                ,'Espace Naturel Sensible ')
                        group by bat.type_name
                        union 
                        select 'Reservoir' as espace
                                , st_union(crsf.geom) as geom	
                                , round(CAST(st_area(st_union(crsf.geom))/1000000.0 as numeric),2 ) as surf_km 							
                        from ref_geo."CER_RESERVOIR_S_FR84" crsf)
    select 	se.espace,
            se.geom,
            se.surf_km as surf_km,
            round(CAST(((1-(( surf_reg.surf_km - se.surf_km)/surf_reg.surf_km))*100.0) as numeric),2 )  as taux_surf_reg
    from surf_env se, surf_reg );