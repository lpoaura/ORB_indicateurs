create materialized view orb_indicateurs.mv_sraddet_ind_lrr_general as (
    select 'Général' as declinaison,
    left(bs.code_statut,2) as code_statut,																-- période de grou
    count(distinct t.cd_ref)
    from taxonomie.taxref t
    left join taxonomie.bdc_statut bs on t.cd_nom = bs.cd_nom 
    where ((bs.cd_type_statut in ( 'LRR') --,'LRN'
            and bs.lb_adm_tr ILIKE ANY (array[' ','Auvergne','%Rhône-Alpes%']) 
            and bs.cd_ref is not null)
    or (bs.cd_ref is null))
    and bs.code_statut is not null
    group by 1,2
    order by 	case when left(bs.code_statut,2) = 'EX'  then 11
	 	 when left(bs.code_statut,2) = 'EW'  then 10
	 	 when left(bs.code_statut,2) = 'RE'  then 9
	 	 when left(bs.code_statut,2) = 'CR'  then 8
	 	 when left(bs.code_statut,2) = 'EN'  then 7
	 	 when left(bs.code_statut,2) = 'VU'  then 6
	 	 when left(bs.code_statut,2) = 'NT'  then 5
	 	 when left(bs.code_statut,2) = 'LC'  then 4
	 	 when left(bs.code_statut,2) = 'DD'  then 3
	 	 when left(bs.code_statut,2) = 'NA'  then 2
	 	 when left(bs.code_statut,2) = 'NE'  then 1 end desc
    );