-- Aktive Blocking-Ketten: welche Session blockiert wen, wie lange, mit welchem SQL.

SELECT
    blocker.sid                     AS blocker_sid,
    blocker.serial#                 AS blocker_serial,
    blocker.username                AS blocker_user,
    blocker.machine                 AS blocker_host,
    blocker.program                 AS blocker_program,
    blocked.sid                     AS blocked_sid,
    blocked.username                AS blocked_user,
    blocked.event                   AS wait_event,
    blocked.seconds_in_wait,
    q.sql_fulltext                  AS blocking_sql
FROM   v$session blocked
JOIN   v$session blocker ON blocker.sid = blocked.blocking_session
LEFT JOIN v$sql q
       ON q.sql_id = blocker.prev_sql_id
WHERE  blocked.blocking_session IS NOT NULL
ORDER BY blocked.seconds_in_wait DESC;

-- Sperren im Detail (welche Row/Objekt wird gehalten)
-- SELECT s.sid, s.username, s.machine, o.object_name, l.type, l.mode_held, l.mode_requested
-- FROM   v$lock l
-- JOIN   v$session s ON s.sid = l.sid
-- LEFT JOIN dba_objects o ON o.object_id = l.id1
-- WHERE  l.block > 0 OR l.request > 0;
