create materialized view orb_indicateurs.mv_sraddet_ind_meta_producteur as (
    select  cda.id_organism 
            , bo.nom_organisme 
            , count(distinct s.id_synthese) as nb_data
            , count(distinct td.id_dataset) as nb 
    from gn_synthese.synthese s 
    inner join gn_meta.cor_dataset_actor cda on cda.id_dataset = s.id_dataset
    inner join gn_meta.t_datasets td on td.id_dataset = s.id_dataset
    inner join utilisateurs.bib_organismes bo on bo.id_organisme = cda.id_organism 
    where cda.id_nomenclature_actor_role = 371
    group by cda.id_organism, bo.nom_organisme  );