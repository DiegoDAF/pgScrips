WITH q0_0 AS
  (SELECT relid,
          CASE
              WHEN coalesce(last_vacuum, last_analyze, last_autovacuum, last_autoanalyze) IS NULL THEN NULL
              WHEN last_vacuum =
                     (SELECT MAX(UNNEST)
                      FROM
                        (SELECT UNNEST(ARRAY[last_vacuum,
                                             last_analyze,
                                             last_autovacuum,
                                             last_autoanalyze]))s0_0) THEN ' v '
              WHEN last_analyze =
                     (SELECT MAX(UNNEST)
                      FROM
                        (SELECT UNNEST(ARRAY[last_vacuum,
                                             last_analyze,
                                             last_autovacuum,
                                             last_autoanalyze]))s1_0) THEN ' z '
              WHEN last_autoanalyze =
                     (SELECT MAX(UNNEST)
                      FROM
                        (SELECT UNNEST(ARRAY[last_vacuum,
                                             last_analyze,
                                             last_autovacuum,
                                             last_autoanalyze]))s2_0) THEN 'az '
              WHEN last_autovacuum =
                     (SELECT MAX(UNNEST)
                      FROM
                        (SELECT UNNEST(ARRAY[last_vacuum,
                                             last_analyze,
                                             last_autovacuum,
                                             last_autoanalyze]))s3_0) THEN 'av '
          END AS last_stats_str,
          CASE
              WHEN coalesce(last_vacuum, last_analyze, last_autovacuum, last_autoanalyze) IS NULL THEN NULL
              WHEN last_vacuum =
                     (SELECT MAX(UNNEST)
                      FROM
                        (SELECT UNNEST(ARRAY[last_vacuum,
                                             last_analyze,
                                             last_autovacuum,
                                             last_autoanalyze]))s0_0) THEN last_vacuum::TIMESTAMP
              WHEN last_analyze =
                     (SELECT MAX(UNNEST)
                      FROM
                        (SELECT UNNEST(ARRAY[last_vacuum,
                                             last_analyze,
                                             last_autovacuum,
                                             last_autoanalyze]))s1_0) THEN last_analyze::TIMESTAMP
              WHEN last_autoanalyze =
                     (SELECT MAX(UNNEST)
                      FROM
                        (SELECT UNNEST(ARRAY[last_vacuum,
                                             last_analyze,
                                             last_autovacuum,
                                             last_autoanalyze]))s2_0) THEN last_autoanalyze::TIMESTAMP
              WHEN last_autovacuum =
                     (SELECT MAX(UNNEST)
                      FROM
                        (SELECT UNNEST(ARRAY[last_vacuum,
                                             last_analyze,
                                             last_autovacuum,
                                             last_autoanalyze]))s3_0) THEN last_autovacuum::TIMESTAMP
          END AS last_stats_stamp
   FROM pg_stat_user_tables),
     q0 AS
  (SELECT relid::regclass rel,
          n_tup_ins ti,
          n_tup_upd + n_tup_del tm,
          n_live_tup tliv,
          n_dead_tup nded,
          n_mod_since_analyze tmod,
          last_stats_str||last_stats_stamp AS last_stats,
          autoanalyze_count naz,
          autovacuum_count nav,
          analyze_count nz,
          vacuum_count nv
   FROM pg_stat_user_tables
   JOIN q0_0 USING (relid)
   ORDER BY last_stats_stamp DESC nulls LAST,
                                        schemaname,
                                        relname)
SELECT *
FROM q0