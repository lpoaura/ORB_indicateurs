select matviewname as nom, 'vm' as type_data from pg_catalog.pg_matviews pm 
where schemaname = 'orb_indicateurs'
union 
select tablename as nom, 'table' as type_data from pg_catalog.pg_tables pt 
where schemaname = 'orb_indicateurs'
union 
select pv.viewname as nom, 'view' as type_data from pg_catalog.pg_views pv 
where schemaname = 'orb_indicateurs'
