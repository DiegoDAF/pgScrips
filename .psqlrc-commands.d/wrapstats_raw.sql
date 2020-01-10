/*
https://gist.githubusercontent.com/skehlet/36aad599171b25826e82/raw/b84501643ec16d05f8b307ad87bac884bc14fd52/gistfile1.sql
*/

select relid, spcid, spcname, nspid, nspname, reltuples, relpages, relsize_pgs, frozenage, icein
from (
SELECT
  storage_settings.oid AS relid,
  spc.oid spcid,
  spc.spcname,
  nsp.oid nspid,
  nsp.nspname,
  c.reltuples,
  c.relpages,
  8192::bigint*c.relpages relsize_pgs,
  age(relfrozenxid) as frozenage,
  autovacuum_freeze_max_age - age(relfrozenxid) AS icein
FROM
  pg_stat_user_tables psut
  JOIN pg_class c ON psut.relid = c.oid
  JOIN (
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
      (
    SELECT
      pg_class.oid, relname, nspname, array_to_string(reloptions, '') AS relopts
    FROM
      pg_class INNER JOIN pg_namespace ns ON relnamespace = ns.oid
      )table_opts
)storage_settings ON c.oid = storage_settings.oid
  JOIN pg_tablespace spc on c.reltablespace=spc.oid or (c.reltablespace=0 and spc.spcname='pg_default')
  JOIN pg_namespace nsp on c.relnamespace=nsp.oid
ORDER BY icein
)_
