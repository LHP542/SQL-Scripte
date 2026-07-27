-- Index-Rebuild für alle Indexe eines Schemas.
-- SE2-Variante: OFFLINE-Rebuild (REBUILD ONLINE ist EE-only!).
-- Während des Rebuilds ist die zugehörige Tabelle für DML gesperrt.
-- Rebuild lohnt sich, wenn nach ANALYZE INDEX ... VALIDATE STRUCTURE
-- del_lf_rows / lf_rows >= 20 %.

DEFINE target_schema = 'SCOTT';

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_sql VARCHAR2(4000);
BEGIN
    FOR i IN (
        SELECT owner, index_name, index_type
        FROM   dba_indexes
        WHERE  owner = UPPER('&target_schema')
          AND  index_type IN ('NORMAL', 'FUNCTION-BASED NORMAL')
          AND  status = 'VALID'
    ) LOOP
        -- SE2: kein ONLINE. Zeitpunkt in Wartungsfenster legen!
        v_sql := 'ALTER INDEX ' || i.owner || '.' || i.index_name || ' REBUILD';
        DBMS_OUTPUT.PUT_LINE(v_sql);
        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('  Fehler: ' || SQLERRM);
        END;
    END LOOP;
END;
/

-- Enterprise Edition könnte:
--   EXECUTE IMMEDIATE 'ALTER INDEX ... REBUILD ONLINE';
