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
          regexp_replace(query, '[\n ]+', ' ', 'g') query1
   FROM pg_stat_activity order by xact_start desc nulls last, query_start desc)
SELECT *
FROM _0
