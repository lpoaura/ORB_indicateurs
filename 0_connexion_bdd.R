# . -------------------------------------------------------------------------- =============
# 0 - Objectifs ====
# . -------------------------------------------------------------------------- =============

# Le script a pour objectif de realiser la connexion à la base de donnees 

# . -------------------------------------------------------------------------- =============
# 1 - Librairie ====
# . -------------------------------------------------------------------------- =============

pkgs <-  c("RPostgreSQL", "DBI","stringr","dplyr")

if (length(setdiff(pkgs, rownames(installed.packages()))) > 0) {
  # installation des packages 
  install.packages(setdiff(pkgs, rownames(installed.packages())))  
} 
# chargement des packages 
lapply(pkgs, library, character.only = TRUE)
rm(pkgs)

# . -------------------------------------------------------------------------- =============
# 2 - Connexion BDD postGIS ====
# . -------------------------------------------------------------------------- =============

## Supressions de toutes les connexions pr?c?dentes
lapply(dbListConnections(drv = dbDriver("PostgreSQL")),
       function(x) {dbDisconnect(conn = x)})

# type de connexion PostgreSQL et information de connexion 
drv <- dbDriver("PostgreSQL")

# connexion a la BDD
con_gn_orb <- DBI::dbConnect(RPostgres::Postgres(),
                             dbname = XXXXXXXXXXX,
                             host = XXXXXXXXXXX,
                             port = XXXXXXXXXXX,
                             password = XXXXXXXXXXX,
                             user = XXXXXXXXXXX,
                             base::list(sslmode="require", connect_timeout="10"),
                             service = NULL)

# lists des tables dans la BDD 
dbListTables(con_gn_orb)
rm(name,addresse,port,user,password)
rm(id_ligne_gnlpoaura, pg_info, pg_service)


