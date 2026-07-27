-- Session gezielt beenden.
-- IMMEDIATE = sofortiger Rollback statt sanftem Ausrollen.
-- Bei Marked Sessions ("KILLED"), die sich nicht abbauen: als OS-Prozess killen (SPID aus V$PROCESS).

DEFINE session_id = 0;
DEFINE serial_no  = 0;

BEGIN
    IF &session_id = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'session_id nicht gesetzt');
    END IF;

    EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''
        || &session_id || ',' || &serial_no || ''' IMMEDIATE';
END;
/

-- OS-Prozess-ID einer Session ermitteln (wenn KILL nicht durchschlägt)
-- SELECT s.sid, s.serial#, s.username, s.status, p.spid AS os_pid
-- FROM   v$session s
-- JOIN   v$process p ON p.addr = s.paddr
-- WHERE  s.sid = &session_id;
-- -- Dann OS-seitig: kill -9 <spid>
