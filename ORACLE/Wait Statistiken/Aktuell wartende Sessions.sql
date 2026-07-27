-- Oracle-Äquivalent zu MSSQL "What are you waiting for":
-- Was tut jede aktive User-Session gerade und worauf wartet sie?

SELECT
    s.sid,
    s.serial#,
    s.username,
    s.machine,
    s.program,
    s.status,
    s.event                                   AS wait_event,
    s.wait_class,
    s.seconds_in_wait,
    s.blocking_session,
    s.p1text || '=' || s.p1                   AS p1,
    s.p2text || '=' || s.p2                   AS p2,
    s.p3text || '=' || s.p3                   AS p3,
    s.sql_id,
    q.sql_fulltext
FROM   v$session s
LEFT JOIN v$sql q ON q.sql_id = s.sql_id
WHERE  s.type = 'USER'
  AND  s.status = 'ACTIVE'
  AND  s.wait_class <> 'Idle'
ORDER BY s.seconds_in_wait DESC;
