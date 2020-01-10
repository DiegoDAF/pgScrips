SELECT now() - backend_start AS uptime
FROM pg_stat_activity
WHERE pid = pg_backend_pid();

