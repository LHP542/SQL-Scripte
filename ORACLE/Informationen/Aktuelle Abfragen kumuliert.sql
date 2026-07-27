-- Aktive Sessions aggregiert nach Host/User/Status/Command.

SELECT
    COUNT(*)          AS session_count,
    s.machine,
    s.username,
    s.status,
    s.command,
    DECODE(s.command,
           0, 'idle',
           2, 'INSERT',
           3, 'SELECT',
           6, 'UPDATE',
           7, 'DELETE',
           47, 'PL/SQL EXECUTE',
           TO_CHAR(s.command)) AS command_name
FROM   v$session s
WHERE  s.type = 'USER'
  AND  s.status = 'ACTIVE'
GROUP BY s.machine, s.username, s.status, s.command
ORDER BY session_count DESC;
