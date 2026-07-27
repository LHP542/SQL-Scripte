-- Redo-Log-Groups + Members. Analog zum MSSQL VLF-Count.
-- Faustregel: Log-Group-Größe so wählen, dass < 4 Log-Switches pro Stunde
-- unter Last (siehe unten V$LOG_HISTORY).

SELECT
    l.group#,
    l.thread#,
    ROUND(l.bytes / 1024 / 1024, 2) AS size_mb,
    l.members,
    l.archived,
    l.status,
    l.first_time,
    l.next_change#
FROM   v$log l
ORDER BY l.group#;

-- Log-Files (physisch)
SELECT group#, member, type, status
FROM   v$logfile
ORDER BY group#, member;

-- Log-Switch-Frequenz (letzte 24h stundenweise)
SELECT
    TRUNC(first_time, 'HH')      AS hour,
    COUNT(*)                     AS switches
FROM   v$log_history
WHERE  first_time > SYSDATE - 1
GROUP BY TRUNC(first_time, 'HH')
ORDER BY hour;
