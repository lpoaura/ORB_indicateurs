create materialized view orb_indicateurs.mv_sraddet_ind_geom as (
select  row_number() OVER () AS id,
        la.geom,																				-- maille 5x5
		    la.id_area, 																			-- id maille
		  'Générale' as declinaison, 
		  case when EXTRACT(YEAR FROM s.date_min) BETWEEN 2001 AND 2005 then '2000 - 2005'
		 	  when EXTRACT(YEAR FROM s.date_min) BETWEEN 2006 AND 2010 then '2006 - 2010'
		 	  when EXTRACT(YEAR FROM s.date_min) BETWEEN 2011 AND 2015 then '2011 - 2015'
		 	  when EXTRACT(YEAR FROM s.date_min) BETWEEN 2016 AND 2020 then '2016 - 2020'
		 	  when EXTRACT(YEAR FROM s.date_min) BETWEEN 2021 AND 2025 then '2021 - 2025' 
		 	  end as annee_group, 																-- période de groupe d'année d'étude a analyser 
		 count(*) as nb_data_tot,																-- nombre de données
		 count(distinct(t.cd_ref) ) as nb_espece_dis,											-- nombre d'espèces
		 count(distinct(t.group2_inpn)) as nb_group_taxo,										-- nombre de groupe taxonomique
		 count(distinct(s.date_min::date)) as nb_date_dis										-- nombre de jours d'observations
from gn_synthese.synthese s 
inner join taxonomie.taxref t on s.cd_nom = t.cd_nom 
inner join gn_synthese.cor_area_synthese as cas on s.id_synthese = cas.id_synthese 
inner join lpoaura_afo.maille_reg la on cas.id_area = la.id_area 
where EXTRACT(YEAR FROM s.date_min) > 2000														-- filtre sur les dates > 2000 (à partir de 2001) 						
and t.id_rang in ('ES','SSES')																	-- filtre uniquement sur les espèces ou sous espèces 
group by la.geom,	la.id_area, 4,5);
		    