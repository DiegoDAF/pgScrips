SELECT c.oid relid,
       nsp.nspname,
       c.relname,
       segnum,
       fpath,
       fstat.size,
       fstat.access,
       fstat.modification,
       fstat.change,
       fstat.creation,
       fstat.isdir
FROM (SELECT setting::bigint seg_size
FROM pg_settings
WHERE name = 'segment_size') AS segsz,
pg_class c
JOIN pg_namespace nsp ON c.relnamespace=nsp.oid,
generate_series(0::bigint, relpages / segsz.seg_size) segnum,
concat(pg_relation_filepath(c.oid), coalesce('.'||nullif(segnum, 0), '')) fpath,
pg_stat_file(fpath) fstat
