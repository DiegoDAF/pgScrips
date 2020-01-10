WITH _0 AS
  (SELECT (nspname || '.' || relname) AS rel,
    pg_size_pretty(8192::bigint * c.relpages) AS "size"
    FROM pg_class c
    LEFT JOIN pg_namespace n on (n.oid = c.relnamespace)
    WHERE nspname NOT IN ('pg_catalog', 'information_schema')
   ORDER BY c.relpages DESC)
SELECT * from _0
