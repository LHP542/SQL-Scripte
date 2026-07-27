SELECT 
    r.session_id,
    r.status,
    r.wait_type,
    r.wait_time,
    r.cpu_time,
    r.total_elapsed_time,
    t.text AS query_text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.database_id = DB_ID('SPAR_FIS');