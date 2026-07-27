-- Backup in Oracle läuft über RMAN, nicht über SQL*Plus.
-- Diese Datei ist eine Vorlage - Blöcke im rman-Client ausführen.

/*
-- rman target /

-- 1) Konfiguration ansehen
RMAN> SHOW ALL;

-- 2) Volles Datenbank-Backup mit Kontrolldatei und Archived Logs
RMAN> BACKUP DATABASE PLUS ARCHIVELOG DELETE INPUT;

-- 3) Inkrementelles Level-1-Backup (setzt vorheriges Level-0-Backup voraus)
RMAN> BACKUP INCREMENTAL LEVEL 1 DATABASE;

-- 4) Nur Archived Logs
RMAN> BACKUP ARCHIVELOG ALL DELETE INPUT;

-- 5) Backup validieren
RMAN> VALIDATE BACKUPSET ALL;

-- 6) Alte Backups aufräumen laut RETENTION POLICY
RMAN> DELETE OBSOLETE;
RMAN> DELETE EXPIRED BACKUP;

-- 7) Retention setzen (einmalig)
RMAN> CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 14 DAYS;
RMAN> CONFIGURE BACKUP OPTIMIZATION ON;
RMAN> CONFIGURE CONTROLFILE AUTOBACKUP ON;
*/

-- In SQL: aktuellen Backup-Status kompakt anzeigen (was in RMAN gerade läuft)
SELECT
    sid,
    serial#,
    context,
    sofar,
    totalwork,
    ROUND(sofar / NULLIF(totalwork,0) * 100, 2) AS pct_complete,
    start_time,
    time_remaining
FROM   v$session_longops
WHERE  opname LIKE 'RMAN%'
  AND  totalwork > 0
ORDER BY start_time DESC;
