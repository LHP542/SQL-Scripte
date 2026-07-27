-- Oracle-Äquivalent zu MSSQL "Recovery-Model ändern":
-- Archivelog-Mode = Voraussetzung für Point-in-Time-Recovery und Standby.
-- NOARCHIVELOG = analog zu MSSQL SIMPLE (nur letzter Full-Backup restorbar).

-- Status prüfen
SELECT name, log_mode FROM v$database;
ARCHIVE LOG LIST;

/*
-- Umstellung auf ARCHIVELOG (Downtime nötig!)
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE ARCHIVELOG;
ALTER DATABASE OPEN;

-- Danach: Voller Backup, dann läuft der Log-Writer in Archive-Log-Files.

-- Zurück auf NOARCHIVELOG (selten sinnvoll außerhalb Test/Dev)
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE NOARCHIVELOG;
ALTER DATABASE OPEN;
*/

-- Fast Recovery Area (FRA) für Archive Logs
-- SHOW PARAMETER db_recovery_file_dest;
-- SHOW PARAMETER db_recovery_file_dest_size;
