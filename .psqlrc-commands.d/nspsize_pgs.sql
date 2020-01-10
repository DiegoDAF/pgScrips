SELECT * from (
SELECT
    nspname,
    pg_size_pretty(sum(8192::bigint*nullif(tbl.relpages, 0))) "tables",
    pg_size_pretty(sum(8192::bigint*nullif(idx.relpages, 0))) "indexes",
    pg_size_pretty(sum(8192::bigint*nullif(tst.relpages, 0))) "toast",
    pg_size_pretty(sum(8192::bigint*(
        coalesce(tbl.relpages, 0)
      + coalesce(idx.relpages, 0)
      + coalesce(tst.relpages, 0)))) AS "total",
    concat(
       count(distinct tbl.oid) FILTER (where tbl.relkind='r')::text,
       '/',
       count(distinct tst.oid)::text,
       '/',
       count(distinct idx.oid)::text,
       '/',
       count(distinct tbl.oid) FILTER (where tbl.relkind='m')::text
    ) AS "#r/t/i/m"
FROM
    pg_class AS tbl
JOIN
    pg_namespace AS nsp ON (tbl.relnamespace=nsp.oid)
LEFT JOIN
    pg_class tst ON (tbl.reltoastrelid=tst.oid)
LEFT JOIN
    pg_index ON (pg_index.indrelid=tbl.oid)
LEFT JOIN
    pg_class idx ON pg_index.indexrelid=idx.oid
WHERE
    (tbl.relkind = 'r' OR tbl.relkind = 'm')
GROUP BY
    nspname
ORDER BY
    sum(coalesce(tbl.relpages, 0)+coalesce(idx.relpages, 0)+coalesce(tst.relpages, 0))
DESC) _

