-- Oracle-Äquivalent zu DBCC CHECKDB:
--   1) RMAN VALIDATE - Blockprüfung des ganzen Datenbestands
--   2) DBVERIFY (dbv) - Offline-Prüfung eines Datafiles
--   3) ANALYZE TABLE ... VALIDATE STRUCTURE - Row/Index-Konsistenz einer Tabelle

/*
-- Variante 1 - RMAN (empfohlen)
-- rman target /
RMAN> VALIDATE CHECK LOGICAL DATABASE;
RMAN> VALIDATE CHECK LOGICAL DATAFILE 'FULL_PATH_TO_DATAFILE.DBF';

-- Variante 2 - DBVERIFY (auf OS-Ebene, DB darf online sein)
-- $ dbv file=/u01/oradata/PROD/users01.dbf blocksize=8192

-- Variante 3 - Einzelne Tabelle prüfen
ANALYZE TABLE scott.emp VALIDATE STRUCTURE CASCADE;
*/

-- Ergebnisse: Blockkorruptionen
SELECT
    file#,
    block#,
    blocks,
    corruption_type,
    corruption_change#
FROM   v$database_block_corruption;

-- Prüfsummen-Setting anzeigen (sollte 'TYPICAL' oder 'FULL' sein)
SELECT name, value FROM v$parameter WHERE name IN ('db_block_checksum','db_block_checking');
