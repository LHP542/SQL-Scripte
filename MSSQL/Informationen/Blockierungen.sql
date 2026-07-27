SELECT 
    blocking.session_id AS blocking_session,
    blocked.session_id AS blocked_session,
    blocked.wait_type,
    blocked.wait_time,
    t.text AS blocking_query
FROM sys.dm_exec_requests blocked
INNER JOIN sys.dm_exec_sessions blocking ON blocked.blocking_session_id = blocking.session_id
CROSS APPLY sys.dm_exec_sql_text(blocking.sql_handle) t
WHERE blocked.database_id = DB_ID('SPAR_FIS');