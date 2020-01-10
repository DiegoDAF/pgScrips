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
)
SELECT
  storage_settings.nspname AS schema,
  storage_settings.relname AS table,
  to_char(pg_class.reltuples, '9G999G999G999') AS rowcount,
  to_char(psut.n_dead_tup, '9G999G999G999') AS dead_rowcount,
  to_char(autovacuum_vacuum_threshold
          + (autovacuum_vacuum_scale_factor::numeric * pg_class.reltuples), '9G999G999G999') AS autovacuum_threshold,
  CASE
    WHEN autovacuum_vacuum_threshold + (autovacuum_vacuum_scale_factor::numeric * pg_class.reltuples) < psut.n_dead_tup
      THEN 'yes'
  END AS expect_autovacuum,
  age(relfrozenxid) as relfrozenxid_age,
  autovacuum_freeze_table_age,
  CASE
    WHEN age(relfrozenxid) > autovacuum_freeze_table_age
      THEN 'yes'
  END AS next_autovacuum_will_be_a_freeze,
  autovacuum_freeze_max_age,
  ROUND(100.0 * age(relfrozenxid) / autovacuum_freeze_max_age::numeric, 1) || '%' AS "% til forced vacuum freeze"
FROM
  pg_stat_user_tables psut INNER JOIN pg_class ON psut.relid = pg_class.oid
  INNER JOIN storage_settings ON pg_class.oid = storage_settings.oid
ORDER BY storage_settings.relname;
