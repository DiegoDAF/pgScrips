WITH _0 AS
  (SELECT datname,
          pid,
          (clock_timestamp() - backend_start) AS bk_age,
          (clock_timestamp() - state_change) state_age,
          (clock_timestamp() - xact_start) xact_age,
          (clock_timestamp() - query_start) query_age,
          usename,
          application_name app,
          client_addr,
          concat(STATE, CASE WHEN waiting THEN '[WAIT]' ELSE '' END) AS STATE,
          query
   FROM pg_stat_activity
  WHERE pid <> pg_backend_pid()
    AND state <> 'idle'
  ORDER BY xact_start DESC NULLS LAST,
           query_start DESC)
SELECT * FROM _0
