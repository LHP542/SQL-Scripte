-- Aktuell laufende Statements: Session, Wait, CPU, SQL-Text.
-- Entspricht dem MSSQL sys.dm_exec_requests + sys.dm_exec_sql_text.

SELECT
    s.sid,
    s.serial#,
    s.username,
    s.machine,
    s.program,
    s.status,
    s.blocking_session,
    s.event                         AS wait_event,
    s.seconds_in_wait,
    s.last_call_et                  AS active_seconds,
    q.cpu_time / 1000000            AS cpu_seconds,
    q.elapsed_time / 1000000        AS elapsed_seconds,
    q.buffer_gets,
    q.disk_reads,
    q.rows_processed,
    s.sql_id,
    q.sql_fulltext
FROM   v$session s
LEFT JOIN v$sql q
       ON q.sql_id = s.sql_id
      AND q.child_number = s.sql_child_number
WHERE  s.type = 'USER'
  AND  s.status = 'ACTIVE'
  AND  s.sid <> SYS_CONTEXT('USERENV','SID')
ORDER BY s.last_call_et DESC;
