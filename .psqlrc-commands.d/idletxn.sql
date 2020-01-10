SELECT datname,
       pid,
       (clock_timestamp() - backend_start) AS bk_age,
       (clock_timestamp() - state_change) state_age,
       (clock_timestamp() - xact_start) xact_age,
       usename,
       application_name app,
       client_addr,
       (STATE || CASE
                     WHEN waiting THEN '(w)'
                     ELSE ''
                 END) AS STATE,
       query
FROM pg_stat_activity
WHERE xact_start IS NOT NULL
  AND pid <> pg_backend_pid()
ORDER BY xact_start;

