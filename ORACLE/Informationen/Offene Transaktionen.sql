-- Offene Transaktionen mit Session-Kontext und Undo-Nutzung.
-- Entspricht dem MSSQL SQLOffeneTransaktionenAnzeigen.

SELECT
    s.sid,
    s.serial#,
    s.username,
    s.machine,
    s.program,
    s.status                              AS session_status,
    t.status                              AS transaction_status,
    t.start_time,
    t.used_ublk                           AS undo_blocks,
    t.used_urec                           AS undo_records,
    t.log_io                              AS logical_io,
    t.phy_io                              AS physical_io,
    t.cr_get                              AS consistent_reads,
    t.cr_change                           AS cr_changes,
    q.sql_fulltext                        AS current_sql
FROM   v$transaction t
JOIN   v$session s ON s.saddr = t.ses_addr
LEFT JOIN v$sql q  ON q.sql_id = s.sql_id
WHERE  s.type = 'USER'
  AND  s.sid <> SYS_CONTEXT('USERENV','SID')
ORDER BY t.start_time;
