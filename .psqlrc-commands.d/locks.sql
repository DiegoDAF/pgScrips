SELECT pg_stat_activity.pid,
       pg_class.relname,
       pg_locks.transactionid,
       pg_locks.granted,
       substring(pg_stat_activity.query
                 FROM '([^

]*

?){1,3}') AS query_snippet,
       age(now(),pg_stat_activity.query_start) AS "age"
FROM pg_stat_activity,
     pg_locks
LEFT OUTER JOIN pg_class ON (pg_locks.relation = pg_class.oid)
WHERE pg_stat_activity.query <> '<insufficient privilege>'
  AND pg_locks.pid=pg_stat_activity.pid
  AND pg_locks.mode = 'ExclusiveLock'
ORDER BY query_start;

