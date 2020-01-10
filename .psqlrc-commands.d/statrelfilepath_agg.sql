select * from (select relid,
    nsp.nspname,
    c.relname,
    fpath,numsegs,
tot_size,
access_bnds,
modification_bnds,
change_bnds,
creation_bnds,
isdir
 from (SELECT c.oid relid,
       relpages / segsz.seg_size AS numsegs,
       pg_relation_filepath(c.oid) AS fpath,
       sum(size) tot_size,
       tstzrange(min(fstat.access), max(fstat.access), '[]') access_bnds,
       tstzrange(min(fstat.modification), max(fstat.modification), '[]') modification_bnds,
       tstzrange(min(fstat.change), max(fstat.change), '[]') change_bnds,
       tstzrange(min(fstat.creation), max(fstat.creation), '[]') creation_bnds,
       fstat.isdir
FROM (SELECT setting::bigint seg_size
FROM pg_settings
WHERE name = 'segment_size') AS segsz,
pg_class c,
generate_series(0::bigint, relpages / segsz.seg_size) segnum,
concat(pg_relation_filepath(c.oid), coalesce('.'||nullif(segnum, 0), '')) _fpath,
pg_stat_file(_fpath) fstat
where relkind='r' group by relid, numsegs, fstat.isdir)_
JOIN pg_class c on c.oid=relid
JOIN pg_namespace nsp ON c.relnamespace=nsp.oid)_
