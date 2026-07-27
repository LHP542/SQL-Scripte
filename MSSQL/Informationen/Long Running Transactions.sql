-- Alle offenen Transaktionen älter als @MinutesThreshold.
-- Typische Kandidaten für Log-Wachstum, Blockings und "vergessene BEGIN TRAN"-Situationen.

DECLARE @MinutesThreshold INT = 5;

SELECT
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    at.transaction_id,
    at.name                                                       AS transaction_name,
    at.transaction_begin_time,
    DATEDIFF(SECOND, at.transaction_begin_time, GETDATE()) / 60.0 AS running_minutes,
    CASE at.transaction_state
         WHEN 0 THEN 'not initialized'
         WHEN 1 THEN 'initialized, not started'
         WHEN 2 THEN 'active'
         WHEN 3 THEN 'ended (read-only)'
         WHEN 4 THEN 'commit initiated'
         WHEN 5 THEN 'prepared'
         WHEN 6 THEN 'committed'
         WHEN 7 THEN 'rolling back'
         WHEN 8 THEN 'rolled back'
    END                                                           AS state,
    DB_NAME(r.database_id)                                        AS database_name,
    r.status                                                      AS request_status,
    r.wait_type,
    r.blocking_session_id,
    st.text                                                       AS current_statement
FROM sys.dm_tran_active_transactions at
JOIN sys.dm_tran_session_transactions st_tx ON st_tx.transaction_id = at.transaction_id
JOIN sys.dm_exec_sessions s                 ON s.session_id = st_tx.session_id
LEFT JOIN sys.dm_exec_requests r            ON r.session_id = s.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) st
WHERE at.transaction_begin_time < DATEADD(MINUTE, -@MinutesThreshold, GETDATE())
  AND s.is_user_process = 1
ORDER BY at.transaction_begin_time;
