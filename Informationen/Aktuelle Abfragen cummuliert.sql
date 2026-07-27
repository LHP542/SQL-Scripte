SELECT 
count(s.host_name) as count,
    s.host_name,
    s.login_name,
    r.status,
    r.command,
    DB_NAME(r.database_id) AS database_name
FROM 
    sys.dm_exec_requests r
JOIN 
    sys.dm_exec_sessions s ON r.session_id = s.session_id
JOIN 
    sys.dm_tran_active_transactions t ON r.transaction_id = t.transaction_id
OUTER APPLY 
    sys.dm_exec_sql_text(r.sql_handle) AS st
group by s.host_name,s.login_name, r.status, r.command, r.database_id