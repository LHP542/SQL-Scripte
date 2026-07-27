-- Alle Sessions inkl. Herkunft, Programm, Status, letzte Aktivität.

SELECT
    s.sid,
    s.serial#,
    s.username,
    s.osuser,
    s.machine,
    s.terminal,
    s.program,
    s.status,
    s.type,
    s.logon_time,
    s.last_call_et                  AS seconds_since_last_call,
    s.event                         AS current_wait,
    s.blocking_session,
    s.sql_id
FROM   v$session s
WHERE  s.type = 'USER'
ORDER BY s.username, s.machine, s.sid;
