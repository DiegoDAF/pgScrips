WITH _0 AS
  (SELECT (nspname || \'.\' || relname) AS rel,
    pg_size_pretty(pg_relation_size(C.oid)) AS "size"
    FROM pg_class C
    LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
    WHERE nspname NOT IN (\'pg_catalog\', \'information_schema\')
   ORDER BY pg_relation_size(C.oid) DESC)
SELECT * from _0
