-- Alle Sessions eines Users/Schemas beenden.
-- WICHTIG: Rollback läuft im Hintergrund, kann bei großen Transaktionen dauern.

DEFINE target_user = 'SCOTT';

BEGIN
    FOR s IN (
        SELECT sid, serial#, username
        FROM   v$session
        WHERE  username = UPPER('&target_user')
          AND  status <> 'KILLED'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('KILL ' || s.username || ' SID=' || s.sid || ',' || s.serial#);
        EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''
            || s.sid || ',' || s.serial# || ''' IMMEDIATE';
    END LOOP;
END;
/
