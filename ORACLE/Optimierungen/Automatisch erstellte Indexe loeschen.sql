-- Oracle 19c+ "Auto Indexes" wieder aufräumen.
-- Standard-Präfix ist "SYS_AI_" (Auto Index) - anpassen falls anders benannt.
-- HINWEIS SE2: Auto Index ist EE-/Exadata-only. Auf SE2 findet das Skript
-- normalerweise nichts - das Skript ist also nur relevant, wenn eine
-- EE-DB migriert wird oder händisch SYS_AI_*-Indexe angelegt wurden.

DEFINE target_schema = 'SCOTT';
DEFINE prefix        = 'SYS_AI_';

SET SERVEROUTPUT ON SIZE UNLIMITED;

BEGIN
    FOR i IN (
        SELECT owner, index_name
        FROM   dba_indexes
        WHERE  owner = UPPER('&target_schema')
          AND  index_name LIKE '&prefix' || '%'
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('DROP INDEX ' || i.owner || '.' || i.index_name);
        EXECUTE IMMEDIATE 'DROP INDEX ' || i.owner || '.' || i.index_name;
    END LOOP;
END;
/

-- Alternative: nur zurücksetzen, ohne zu droppen
-- EXEC DBMS_AUTO_INDEX.DROP_AUTO_INDEXES(allow_drop => TRUE);
