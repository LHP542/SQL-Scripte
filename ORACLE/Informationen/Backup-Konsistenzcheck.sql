-- Backup-Validierung in Oracle. Muss in RMAN ausgeführt werden, nicht in SQL*Plus.
-- Diese Datei ist eine Vorlage - Blöcke im rman-Client ausführen.

/*
-- 1) Prüfen ob DB physisch restorbar ist (ohne echten Restore)
RMAN> RESTORE DATABASE VALIDATE;

-- 2) Alle Backupsätze auf Lesbarkeit prüfen
RMAN> VALIDATE BACKUPSET ALL;

-- 3) Datafiles + Controlfile + Redo Logs komplett prüfen (Block-Level)
RMAN> VALIDATE CHECK LOGICAL DATABASE;

-- 4) Ergebnis der letzten Validierungen ansehen
*/

-- In SQL: welche Blöcke wurden bei der letzten VALIDATE als korrupt markiert?
SELECT
    file#,
    block#,
    blocks,
    corruption_type,
    corruption_change#
FROM   v$database_block_corruption
ORDER BY file#, block#;

-- Alle Validation-Läufe
SELECT
    vd.file#,
    df.name                       AS datafile,
    vd.completion_time,
    vd.blocks,
    vd.blocks_read,
    vd.marked_corrupt,
    vd.checked_corrupt
FROM   v$rman_status vd
JOIN   v$datafile   df ON df.file# = vd.file#
WHERE  vd.operation = 'VALIDATE'
ORDER BY vd.completion_time DESC
FETCH FIRST 20 ROWS ONLY;
