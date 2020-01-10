SELECT
    coalesce(spcname, '[Default]') "Tablespace",
    pg_size_pretty(sum(pg_relation_size(c.oid)) FILTER (WHERE relkind = 'r' or relkind = 'm')) "Data Size",
    pg_size_pretty(sum(pg_relation_size(c.oid)) FILTER (WHERE relkind = 'i'                 )) "Index Size",
    count(c.oid) "# Tables"
FROM pg_class c
LEFT JOIN pg_tablespace spc ON (c.reltablespace=spc.oid)
WHERE relkind = 'r' or relkind = 'm' or relkind = 'i'
GROUP BY 1
/*ORDER BY sum(pg_total_relation_size(c.oid)) DESC;*/
ORDER BY 1;
