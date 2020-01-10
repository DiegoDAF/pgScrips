/*
https://gist.githubusercontent.com/skehlet/36aad599171b25826e82/raw/b84501643ec16d05f8b307ad87bac884bc14fd52/gistfile1.sql
*/

WITH table_opts AS (
    SELECT
      pg_class.oid, relname, nspname, array_to_string(reloptions, '') AS relopts
    FROM
      pg_class INNER JOIN pg_namespace ns ON relnamespace = ns.oid
), storage_settings AS (
    SELECT
      oid, relname, nspname,
      CASE
        WHEN relopts LIKE '%autovacuum_vacuum_threshold%'
          THEN regexp_replace(relopts, '.*autovacuum_vacuum_threshold=([0-9.]+).*', E'\\1')::integer
          ELSE current_setting('autovacuum_vacuum_threshold')::integer
      END AS autovacuum_vacuum_threshold,
      CASE
        WHEN relopts LIKE '%autovacuum_vacuum_scale_factor%'
          THEN regexp_replace(relopts, '.*autovacuum_vacuum_scale_factor=([0-9.]+).*', E'\\1')::real
          ELSE current_setting('autovacuum_vacuum_scale_factor')::real
      END AS autovacuum_vacuum_scale_factor,
      CASE
        WHEN relopts LIKE '%autovacuum_freeze_min_age%'
          THEN regexp_replace(relopts, '.*autovacuum_freeze_min_age=([0-9.]+).*', E'\\1')::integer
          ELSE current_setting('vacuum_freeze_min_age')::integer
      END AS autovacuum_freeze_min_age,
      CASE
        WHEN relopts LIKE '%autovacuum_freeze_table_age%'
          THEN regexp_replace(relopts, '.*autovacuum_freeze_table_age=([0-9.]+).*', E'\\1')::real
          ELSE current_setting('vacuum_freeze_table_age')::real
      END AS autovacuum_freeze_table_age,
      CASE
        WHEN relopts LIKE '%autovacuum_freeze_max_age%'
          THEN regexp_replace(relopts, '.*autovacuum_freeze_max_age=([0-9.]+).*', E'\\1')::real
          ELSE current_setting('autovacuum_freeze_max_age')::real
      END AS autovacuum_freeze_max_age
    FROM
      table_opts
),
_ as (
SELECT
  storage_settings.nspname AS "Schema",
  storage_settings.relname AS "Table",
  to_char(pg_class.reltuples, '9G999G999G999') AS "Rows",
  to_char(pg_class.relpages, '9G999G999') AS "Pages",
  pg_size_pretty(pg_table_size(pg_class.oid)) AS "Size",
  age(relfrozenxid) as "icedXID",
  autovacuum_freeze_table_age "AV TblIceAge",
  CASE
    WHEN age(relfrozenxid) > autovacuum_freeze_table_age
      THEN 'AV'
    WHEN age(relfrozenxid) > current_setting('vacuum_freeze_table_age')::integer
      THEN 'V'
  END AS "Icing",
  autovacuum_freeze_max_age "IceMaxAV",
  autovacuum_freeze_max_age - age(relfrozenxid) AS "ice_in",
  ROUND(100.0 * age(relfrozenxid) / autovacuum_freeze_max_age::numeric, 1) || '%' AS "IceAV%"
FROM
  pg_stat_user_tables psut INNER JOIN pg_class ON psut.relid = pg_class.oid
  INNER JOIN storage_settings ON pg_class.oid = storage_settings.oid
ORDER BY ice_in
)
select "Schema", "Table", "Pages", "Size", "icedXID", ice_in, "IceAV%" from _
