create materialized view orb_indicateurs.mv_sraddet_ind_esp_lrr as (
  with tab_statut as ( select  t.cd_ref, 
						 	 string_agg(distinct bs.code_statut, ',') as statut 
					from taxonomie.taxref t
					left join taxonomie.bdc_statut bs on t.cd_nom = bs.cd_nom 
					where bs.cd_type_statut in ( 'LRR') --'LRR',
							and bs.lb_adm_tr ILIKE ANY (array['Auvergne','%Rhône-Alpes%'])
							and bs.cd_ref is not null
					group by t.cd_ref  ),
chiffre_ref as (    select   count(distinct t2.cd_ref) as nb_cd_ref
		                    , count(distinct s2.id_synthese) as nb_data
                    from gn_synthese.synthese s2
                    left join taxonomie.taxref t2 on t2.cd_nom = s2.cd_nom )
select 	'Général' as declinaison
		, case when ts.statut is not null then 'avec liste rouge'
		   else 'sans liste rouge' end as statut_liste
		, count(distinct t2.cd_ref) as nb_cd_ref
		, count(distinct s.id_synthese) as nb_data
        , (count(distinct t2.cd_ref)/(select cr.nb_cd_ref*1.0 from chiffre_ref as cr))*100 as taux_cd_ref
		, (count(distinct s.id_synthese)/(select cr.nb_cd_ref*1.0 from chiffre_ref as cr))*100 as taux_data
from gn_synthese.synthese s
left join taxonomie.taxref t2 on t2.cd_nom = s.cd_nom 
left join tab_statut ts on ts.cd_ref = t2.cd_ref 
group by 1,2);