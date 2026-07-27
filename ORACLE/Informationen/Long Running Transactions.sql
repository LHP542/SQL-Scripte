-- Alle offenen Transaktionen älter als @minutes.
-- Redo-Size zeigt, wieviel Log-Volumen die Session aktuell "unterwegs" hat -> Kandidat für Log-Wachstum.

SELECT
    s.sid,
    s.serial#,
    s.username,
    s.machine,
    s.program,
    t.start_time,
    ROUND((SYSDATE - TO_DATE(t.start_time,'MM/DD/YY HH24:MI:SS')) * 24 * 60, 2) AS running_minutes,
    t.status,
    t.used_ublk                         AS undo_blocks,
    t.used_urec                         AS undo_records,
    ROUND(t.used_ublk * ts.block_size / 1024 / 1024, 2) AS undo_mb,
    s.event                             AS wait_event,
    q.sql_fulltext                      AS current_sql
FROM   v$transaction t
JOIN   v$session     s ON s.saddr = t.ses_addr
LEFT JOIN v$sql q      ON q.sql_id = s.sql_id
JOIN   dba_tablespaces ts ON ts.contents = 'UNDO' AND ROWNUM = 1
WHERE  (SYSDATE - TO_DATE(t.start_time,'MM/DD/YY HH24:MI:SS')) * 24 * 60 > 5
ORDER BY t.start_time;
