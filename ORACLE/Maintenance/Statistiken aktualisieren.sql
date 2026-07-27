-- Statistiken aktualisieren via DBMS_STATS.
-- AUTO_SAMPLE_SIZE lässt Oracle die Sample-Größe selbst wählen (Best Practice ab 11g).

-- Schema-weit
BEGIN
    DBMS_STATS.GATHER_SCHEMA_STATS(
        ownname          => 'SCOTT',
        estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
        method_opt       => 'FOR ALL COLUMNS SIZE AUTO',
        cascade          => TRUE,
        degree           => DBMS_STATS.AUTO_DEGREE
    );
END;
/

-- Nur eine Tabelle
-- BEGIN
--     DBMS_STATS.GATHER_TABLE_STATS(
--         ownname          => 'SCOTT',
--         tabname          => 'EMP',
--         estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
--         method_opt       => 'FOR ALL COLUMNS SIZE AUTO',
--         cascade          => TRUE
--     );
-- END;
-- /

-- Ganze DB (Vorsicht: dauert lange, meist übernimmt der Auto Task nachts)
-- BEGIN
--     DBMS_STATS.GATHER_DATABASE_STATS(
--         estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
--         cascade          => TRUE,
--         degree           => DBMS_STATS.AUTO_DEGREE
--     );
-- END;
-- /

-- Status des Auto Optimizer Stats Task
SELECT client_name, status
FROM   dba_autotask_client
WHERE  client_name = 'auto optimizer stats collection';
