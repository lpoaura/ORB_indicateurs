# . -------------------------------------------------------------------------- =============
# 0 - Objectifs ====
# . -------------------------------------------------------------------------- =============

# Le script a pour objectif de lancer l'actualisation des données/indicateurs du SRADDET

# . -------------------------------------------------------------------------- =============
# 1 - Librairie et fonction  ====
# . -------------------------------------------------------------------------- =============

# liste des packages R utilisé
pkgs <-  c("RPostgreSQL", "DBI","dplyr","tidyverse","lubridate","stringr", "readr", "sf")

if (length(setdiff(pkgs, rownames(installed.packages()))) > 0) {
  # installation des packages 
  install.packages(setdiff(pkgs, rownames(installed.packages())))  
} 
# chargement des packages 
lapply(pkgs, library, character.only = TRUE)
rm(pkgs)

## chargement du script qui permet de calculer l'indicateur de connaissance
getwd() %>% ## prise du chemin de dossier actuelle 
  paste0("/2_calcul_indicateur_connaissance.R") %>% ## indication du nom du fichier 
  source() ## lecture du fichier 

# . -------------------------------------------------------------------------- =============
# 2 - Connexion BDD postGIS ====
# . -------------------------------------------------------------------------- =============

## Connexion a la base de donnée LPO AURA
getwd() %>% ## prise du chemin de dossier actuelle 
  paste0("/0_connexion_bdd.R") %>% ## indication du nom du fichier 
  source() ## lecture du fichier 



# . -------------------------------------------------------------------------- =============
# 3 - Test présences VM synthèses ====
# . -------------------------------------------------------------------------- =============

## 3.1 création du schémas et des vues en cas de non existance ====

# test existance du schéma orb_indicateurs
src_survey_present <- dbListObjects(con_gn_orb) %>%
  mutate(test = str_detect(table,  "orb_indicateurs") ) %>%
  filter(test == TRUE) %>%
  nrow()
  

if(src_survey_present == 0){
  ## création du schémas 
  dbSendQuery(con_gn_orb,  "CREATE SCHEMA IF NOT EXISTS orb_indicateurs;")
  
  ## création des vues matérialisées 
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_maille.sql")))
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_general.sql")))
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_pole.sql")))
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_taxo.sql")))
  
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_general_geom.sql")))
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_pole_geom.sql")))
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_taxo_geom.sql")))
  
  calcul_ind_connaissance(1)
  calcul_ind_connaissance(2)
  calcul_ind_connaissance(3)
  
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_lrr_general.sql")))
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_lrr_pole.sql")))
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_lrr_taxo.sql")))
  
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_esp_lrr.sql")))

  
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_meta_fournisseur.sql")))
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_meta_producteur.sql")))
  
  
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_reserve_naturel.sql")))
}


## recuperation de l'ensemble des views dans le schéma 
info_schema <- dbGetQuery(con_gn_orb, read_file(paste0(getwd(),"/requete_sql/return_info_schema.sql")))


# . -------------------------------------------------------------------------- =============
# 4 - rafraichissement des données ========
# . -------------------------------------------------------------------------- =============

## création des vues de maille
if("maille_reg" %in% info_schema$nom ){} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_maille.sql")))
}
#### 4..1 - chiffres généraux ====
## vue des chiffres globales sur l'ensembles de la région
## déclinaison générale
if("mv_sraddet_ind" %in% info_schema$nom ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_general.sql")))
}
## déclinaison par pole 
if("mv_sraddet_ind_pole" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_pole")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_pole.sql")))
}
## déclinaison par groupe taxonomique
if("mv_sraddet_taxo" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_taxo")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_taxo.sql")))
}

#### 4..2 - chiffres généraux par maille ====
## vue des chiffres globales pour chaque maille de 5km sur l'ensembles de la région
## déclinaison générale
if("mv_sraddet_ind_geom" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_geom")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_general_geom.sql")))
}
## déclinaison par pole 
if("mv_sraddet_ind_pole_geom" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_pole_geom")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_pole_geom.sql")))
}
## déclinaison par groupe taxonomique
if("mv_sraddet_ind_taxo_geom" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_taxo_geom")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_taxo_geom.sql")))
}

#### 4..3 - Indicateur connaissance ====
## table de l'indicateur de connaissances
## déclinaison générale
calcul_ind_connaissance(1)
## déclinaison par pole 
calcul_ind_connaissance(2)
## déclinaison par groupe taxonomique
calcul_ind_connaissance(3)


#### 4..4 - Liste rouge ====
## vm indicateur d'état :listes rouges régionales  : 


## déclinaison générale
if("mv_sraddet_ind_lrr_general" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_lrr_general")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_lrr_general.sql")))
}
## déclinaison par pole
if("mv_sraddet_ind_lrr_pole" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_lrr_pole")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_lrr_pole.sql")))
}
## déclinaison par groupe taxonomique
if("mv_sraddet_ind_lrr_taxo" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_lrr_taxo")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_lrr_taxo.sql")))
}


## vm indicateur des connaissance nb_esp qui ont une listes rouges régionales  : 
## déclinaison par groupe taxonomique
if("mv_sraddet_ind_esp_lrr" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_esp_lrr")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_esp_lrr.sql")))
}

#### 4..5 - Sources des données ====
## vm indicateur sur la variété de sources de jeu de données (producteurs et fournisseurs des données) 
## déclinaison par groupe taxonomique
if("mv_sraddet_ind_meta_fournisseur" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_meta_fournisseur")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_meta_fournisseur.sql")))
}

## déclinaison par groupe taxonomique
if("mv_sraddet_ind_meta_producteur" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_meta_producteur")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_meta_producteur.sql")))
}

#### 4..6 - Espaces naturels ====
## vm indicateur la couverture d'espaces naturels 
if("mv_sraddet_ind_surf_reserve" %in% info_schema$nom  ){
  dbSendQuery(con_gn_orb,"REFRESH MATERIALIZED view orb_indicateurs.mv_sraddet_ind_surf_reserve")
} else {
  dbSendQuery(con_gn_orb,  read_file(paste0(getwd(),"/requete_sql/sraddet_ind_reserve_naturel.sql")))
}
