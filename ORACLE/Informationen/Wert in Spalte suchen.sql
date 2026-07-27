-- Volltextsuche über alle string-Spalten aller User-Tabellen.
-- Als anonymer PL/SQL-Block; Ergebnis geht per DBMS_OUTPUT / in eine Temp-Tabelle.

DEFINE search_string = 'Test';
DEFINE schema_name   = 'SCOTT';

SET SERVEROUTPUT ON SIZE UNLIMITED;

DECLARE
    v_search    VARCHAR2(200) := '&search_string';
    v_owner     VARCHAR2(128) := '&schema_name';
    v_sql       VARCHAR2(4000);
    v_count     NUMBER;
BEGIN
    FOR c IN (
        SELECT owner, table_name, column_name
        FROM   dba_tab_columns
        WHERE  owner = v_owner
          AND  data_type IN ('VARCHAR2','CHAR','NVARCHAR2','NCHAR','CLOB')
    ) LOOP
        BEGIN
            v_sql := 'SELECT COUNT(*) FROM ' || c.owner || '.' || c.table_name ||
                     ' WHERE ' || c.column_name || ' LIKE ''%' || v_search || '%''';
            EXECUTE IMMEDIATE v_sql INTO v_count;
            IF v_count > 0 THEN
                DBMS_OUTPUT.PUT_LINE(c.owner || '.' || c.table_name || '.' || c.column_name
                                     || ' -> ' || v_count || ' Treffer');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Fehler in ' || c.owner || '.' || c.table_name
                                     || '.' || c.column_name || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/
