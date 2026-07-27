-- Automatisch erzeugte Extended Statistics eines Schemas / einer Tabelle
-- wieder löschen.

DEFINE target_schema = 'SCOTT';

BEGIN
    FOR es IN (
        SELECT owner, table_name, extension
        FROM   dba_stat_extensions
        WHERE  owner = UPPER('&target_schema')
          AND  creator = 'AUTO'
    ) LOOP
        DBMS_STATS.DROP_EXTENDED_STATS(
            ownname  => es.owner,
            tabname  => es.table_name,
            extension => es.extension
        );
    END LOOP;
END;
/

-- Column Group Extensions einer Tabelle anzeigen
-- SELECT owner, table_name, extension_name, extension, creator, droppable
-- FROM   dba_stat_extensions
-- WHERE  owner = 'SCOTT';
