--drop materialized view if exists orb_indicateurs.mv_sraddet_ind ;
create materialized view orb_indicateurs.mv_sraddet_ind as (
select    EXTRACT(YEAR FROM s.date_min) as annee,												-- année d'observation
		 'Générale' as declinaison, 
		 count(*) as nb_data_tot,																-- nombre de données
		 count(distinct(t.cd_ref) ) as nb_espece_dis,											-- nombre d'espèces
		 count(distinct(t.group2_inpn)) as nb_group_taxo,										-- nombbre de groupe taxonomique
		 count(distinct(s.date_min::date)) as nb_date_dis										-- nombre de jours d'observations
from gn_synthese.synthese s 
inner join taxonomie.taxref t on s.cd_nom = t.cd_nom 
where EXTRACT(YEAR FROM s.date_min) > 2000														-- filtre sur les dates > 2000 (à partir de 2001) 						
and t.id_rang in ('ES','SSES')																	-- filtre uniquement sur les espèces ou sous espèces 
group by 1,2);