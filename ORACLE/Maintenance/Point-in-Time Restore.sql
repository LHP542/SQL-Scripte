-- Zurück auf einen früheren Zeitpunkt via RMAN Point-in-Time Recovery.
-- SE2-kompatibel (FLASHBACK DATABASE ist EE-only!).
-- Voraussetzung: ARCHIVELOG-Mode + lückenlose Archived Logs seit dem letzten Full-Backup.

-- Aktueller Status prüfen
SELECT name, log_mode, current_scn FROM v$database;

-- Verfügbare Backups
-- rman target /
-- RMAN> LIST BACKUP OF DATABASE SUMMARY;
-- RMAN> LIST ARCHIVELOG ALL;

/*
-- ============ Ablauf: DB auf einen Zeitpunkt zurückspielen ============

-- 1) DB herunterfahren und im Mount öffnen
SQL> SHUTDOWN IMMEDIATE;
SQL> STARTUP MOUNT;

-- 2) In RMAN Restore + Recover mit Ziel-Zeitpunkt
-- rman target /
RMAN> RUN {
    SET UNTIL TIME "TO_DATE('2026-07-27 10:00:00','YYYY-MM-DD HH24:MI:SS')";
    RESTORE DATABASE;
    RECOVER DATABASE;
};

-- 3) Öffnen mit RESETLOGS (neue Incarnation!)
RMAN> ALTER DATABASE OPEN RESETLOGS;

-- Nach RESETLOGS SOFORT ein Full-Backup fahren - ältere Backups sind ungültig.
RMAN> BACKUP DATABASE PLUS ARCHIVELOG;
*/

-- Nach dem Restore: Incarnation prüfen
-- rman target /
-- RMAN> LIST INCARNATION;

-- Ansehen was auf welche SCN welche Zeit hatte (falls SCN als Ziel gewünscht)
SELECT scn_to_timestamp(current_scn) AS current_time, current_scn FROM v$database;
