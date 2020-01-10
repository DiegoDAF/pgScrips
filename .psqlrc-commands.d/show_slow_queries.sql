SELECT (total_time / 1000 / 60) AS total_minutes,
       (total_time/calls) AS average_time,
       query
FROM pg_stat_statements
ORDER BY 1 DESC LIMIT 100;

