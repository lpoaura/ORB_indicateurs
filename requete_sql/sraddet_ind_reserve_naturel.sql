create materialized view orb_indicateurs.mv_sraddet_ind_surf_reserve as (
    with surf_reg as (	select round(CAST(st_area(la.geom)/1000000.0 AS numeric),2) as surf_km from ref_geo.l_areas la 
                        where la.area_name ilike 'Auvergne-Rhône-Alpes'),
        surf_env as (   select 'Reservoir' as espace
                                , st_union(crsf.geom) as geom	
                                , round(CAST(st_area(st_union(crsf.geom))/1000000.0 as numeric),2 ) as surf_km 							
                        from ref_geo."CER_RESERVOIR_S_FR84" crsf)
    select 	se.espace,
            ST_Simplify(se.geom,100) as geom,
            se.surf_km as surf_km,
            round(CAST(((1-(( surf_reg.surf_km - se.surf_km)/surf_reg.surf_km))*100.0) as numeric),2 )  as taux_surf_reg
    from surf_env se, surf_reg);
