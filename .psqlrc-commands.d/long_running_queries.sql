SELECT pid,
       now() - pg_stat_activity.query_start AS duration,
       query AS query
FROM pg_stat_activity
WHERE pg_stat_activity.query <> ''::text
  AND now() - pg_stat_activity.query_start > interval '5 minutes'
ORDER BY now() - pg_stat_activity.query_start DESC;

