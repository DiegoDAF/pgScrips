SELECT pid,
       application_name AS SOURCE,
       age(now(),query_start) AS running_for,
       waiting,
       query AS query
FROM pg_stat_activity
WHERE query <> '<insufficient privilege>'
  AND STATE <> 'idle'
  AND pid <> pg_backend_pid()
ORDER BY 3 DESC;

