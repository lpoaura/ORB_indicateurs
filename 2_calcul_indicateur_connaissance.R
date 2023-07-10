

# . -------------------------------------------------------------------------- =============
# 0 - Lecture des données SQL ====
# . -------------------------------------------------------------------------- =============

## les vues matérialisés intérogé ont permis de mettre en forme les données pour les traiter et calculer plus rapidement
## pour voir la méthode de mise en forme merci de regarder le script sql associé

# ## les différentes vm a intérroger
## Selection du niveau d'analyse (1 = générale, 2 = pole, 3 = taxonomie )
# # générale :
# info <-'lpoaura_afo.mv_sraddet_ind'
# info_geom <- 'lpoaura_afo.mv_sraddet_ind_geom'
# # pole :
# info <-'lpoaura_afo.mv_sraddet_ind_pole'
# info_geom <- 'lpoaura_afo.mv_sraddet_ind_pole_geom'
# # taxonomie :
# info <-'lpoaura_afo.mv_sraddet_ind_taxo'
# info_geom <- 'lpoaura_afo.mv_sraddet_ind_taxo_geom'
calcul_ind_connaissance <-function(niveau){

##niveau = 1
nom_schema = 'orb_indicateurs'

info <- switch(niveau, paste0(nom_schema,'.mv_sraddet_ind'),paste0(nom_schema,'.mv_sraddet_ind_pole') ,paste0(nom_schema,'.mv_sraddet_ind_taxo')) 
info_geom <- switch(niveau, paste0(nom_schema,'.mv_sraddet_ind_geom'), paste0(nom_schema,'.mv_sraddet_ind_pole_geom'),paste0(nom_schema,'.mv_sraddet_ind_taxo_geom')) 

## chiffre générale décliné par le niveau choisi
TAB_Info <- dbGetQuery(con_gn_orb, paste0("select * from ",info) ) 
## chiffres à la maille 5x5 décliné par le niveau choisi
TAB_Info_geom <- st_read(con_gn_orb, query = paste0("select * from ",info_geom) ) 

### remplacer à partir de la ligne 66 


## Gestion des entités géométrique
geom_id <- TAB_Info_geom %>%
  st_drop_geometry() %>%
  group_by(id_area) %>%
  summarise() %>%
  inner_join(  select(TAB_Info_geom,id_area, geom), by = "id_area")


# . -------------------------------------------------------------------------- =============
# 5 - Calcule des indicateurs ====
# . -------------------------------------------------------------------------- =============


### Version  1 : écart à la médiane ====

TAB_resum <- TAB_Info_geom %>%
  st_drop_geometry() %>%
  group_by(declinaison, annee_group) %>%
  summarise( nb_data_max = max(nb_data_tot),
             nb_data_min = min(nb_data_tot),
             nb_data_moy = mean(nb_data_tot), 
             nb_data_med = median(nb_data_tot),
             nb_espece_max = max(nb_espece_dis),
             nb_espece_min = min(nb_espece_dis),
             nb_espece_moy = mean(nb_espece_dis), 
             nb_espece_med = median(nb_espece_dis),
             nb_date_max = max(nb_date_dis),
             nb_date_min = min(nb_date_dis),
             nb_date_moy = mean(nb_date_dis), 
             nb_date_med = median(nb_date_dis)) 



TAB_geom_final <- TAB_Info_geom %>%
  st_drop_geometry() %>%
  mutate(nb_data_tot = as.numeric(nb_data_tot),
         nb_espece_dis = as.numeric(nb_espece_dis),
         nb_date_dis = as.numeric(nb_date_dis)) %>%
  mutate_all(~replace(., is.na(.), 0)) %>%
  inner_join(TAB_resum, by = c("declinaison","annee_group") ) %>%
  mutate(
    ind_data_med = ifelse(nb_data_tot>=nb_data_med, ((nb_data_tot-nb_data_med)/(nb_data_max-nb_data_med)),
                          (-(nb_data_tot-nb_data_med)/(nb_data_min-nb_data_med))),
    ind_esp_med = ifelse(nb_espece_dis>=nb_espece_med, ((nb_espece_dis-nb_espece_med)/(nb_espece_max-nb_espece_med)),
                         (-(nb_espece_dis-nb_espece_med)/(nb_espece_min-nb_espece_med))),
    ind_date_med = ifelse(nb_date_dis>=nb_date_med, ((nb_date_dis-nb_date_med)/(nb_date_max-nb_date_med)),
                          (-(nb_date_dis-nb_date_med)/(nb_date_min-nb_date_med))),
    ind_tot = as.numeric(ind_data_med+ind_esp_med+ind_date_med)) %>%
  #mutate_all(~replace(., is.na(.), 99)) %>%
  mutate(
    ind_data_group =  ifelse(as.numeric(ind_data_med) < (-0.5), "Nombre d'observation faible",
                             ifelse(as.numeric(ind_data_med) < 0, "Nombre d'observation moyenne",
                                    ifelse(as.numeric(ind_data_med) < 0.5, "Nombre d'observation bonne",
                                           ifelse(as.numeric(ind_data_med) <= 1, "Nombre d'observation élevés", "Pas Observation" )))),
    ind_esp_group =   ifelse(as.numeric(ind_esp_med) < (-0.5), "Variété d'espèces faible",
                             ifelse(as.numeric(ind_esp_med) < 0, "Variété d'espèces moyenne",
                                    ifelse(as.numeric(ind_esp_med) <0.5, "Variété d'espèces bonne",
                                           ifelse(as.numeric(ind_esp_med) <=1, "Variété d'espèces élevés", "Pas Observation" )))),
    ind_date_group =  ifelse(as.numeric(ind_date_med) < (-0.5), "Fréquence d'observation faible",
                             ifelse(as.numeric(ind_date_med) <0, "Fréquence d'observation moyenne",
                                    ifelse(as.numeric(ind_date_med) <0.5, "Fréquence d'observation bonne",
                                           ifelse(as.numeric(ind_date_med) <=1, "Fréquence d'observation élevés", "Pas Observation" )))),
    ind_tot_group =   ifelse(as.numeric(ind_tot) < (-1), "Faible",
                             ifelse(as.numeric(ind_tot) < 0, "Moyenne",
                                    ifelse(as.numeric(ind_tot) < 0.5, "Bonne",
                                           ifelse(as.numeric(ind_tot) <= 3, "Élevés", "Pas Observation" ))))
  ) 


# . -------------------------------------------------------------------------- =============
# 5 - Analyse de l'indicateur ====
# . -------------------------------------------------------------------------- =============


TAB_geom_final_filter_V1 <- TAB_geom_final #%>%
  #filter(annee_group == '2016 - 2020')

## précalcule 
nb_geom_prep <- TAB_geom_final_filter_V1 %>%
  group_by(declinaison, annee_group) %>%
  summarise(nb_geom_tot = n())


## calcul uniquement pour l'indicateur générale 
TAB_ind_tot_group <- TAB_geom_final_filter_V1 %>%
  group_by(declinaison, annee_group, ind_tot_group) %>%
  summarise(nb_geom = n()) %>%
  inner_join (nb_geom_prep, by = c("declinaison","annee_group")) %>%
  mutate(prop = round((nb_geom/nb_geom_tot),4)*100,
         lab.ypos = cumsum(prop) )

  map_data <- geom_id %>% 
    inner_join(TAB_geom_final_filter_V1, by = "id_area")
  
  decli_type <- switch(niveau, 'general','pole','taxo') 
  

  dbSendQuery(con_gn_orb,  paste0("CREATE TABLE IF NOT EXISTS ",nom_schema,".ind_connaissance_",decli_type,"(colonne1 int, colonne2 int);" ) )
  #st_write(obj = map_data, dsn = con_gn_orb, layer = c(schema="src_sraddet",table =  paste0("ind_connaissance_",decli_type)))
  st_write(obj = map_data, dsn = con_gn_orb, Id(schema=nom_schema,table =  paste0("ind_connaissance_",decli_type)))

}
