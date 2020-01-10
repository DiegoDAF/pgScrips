SELECT * from (SELECT
    nspname,
    pg_size_pretty(sum(pg_table_size(pg_class.oid))) "Schema Size",
    pg_size_pretty(sum(pg_indexes_size(pg_class.oid))) "Indexes",
    count(pg_class.oid) "Tables"
FROM pg_class
JOIN pg_namespace ON (pg_class.relnamespace=pg_namespace.oid)
WHERE relkind = 'r' or relkind = 'm'
GROUP BY nspname
ORDER BY sum(pg_total_relation_size(pg_class.oid)) DESC) _

