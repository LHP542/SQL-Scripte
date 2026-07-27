-- Restore einer Datenbank auf einen anderen Server / anderes Ziel-Verzeichnis.
-- Ablauf: 1) Backup-Header prüfen, 2) FileList holen, 3) mit WITH MOVE ausführen.

DECLARE @BackupFile NVARCHAR(400) = N'D:\Backup\TestDB_zumSpielen_FULL_20260101_120000.bak';
DECLARE @NewDbName  SYSNAME       = N'TestDB_Restored';
DECLARE @DataPath   NVARCHAR(260) = N'D:\SQL\Data\';
DECLARE @LogPath    NVARCHAR(260) = N'D:\SQL\Log\';

-- 1) Header ansehen (welche DB, welches Recovery-Modell, welcher Zeitpunkt)
RESTORE HEADERONLY FROM DISK = @BackupFile;

-- 2) Enthaltene Files anzeigen -> logische Namen für WITH MOVE ableiten
RESTORE FILELISTONLY FROM DISK = @BackupFile;

-- 3) Restore mit MOVE (logische Namen und Pfade anpassen!)
/*
RESTORE DATABASE @NewDbName
FROM DISK = @BackupFile
WITH
    MOVE N'TestDB_zumSpielen'      TO @DataPath + N'TestDB_Restored.mdf',
    MOVE N'TestDB_zumSpielen_log'  TO @LogPath  + N'TestDB_Restored.ldf',
    REPLACE,
    RECOVERY,        -- NORECOVERY, wenn danach noch Log-Backups eingespielt werden
    STATS = 5;
*/

-- 4) Nach Restore: verwaiste User reparieren (typisch nach Server-Wechsel)
/*
USE [TestDB_Restored];
ALTER USER [MeinUser] WITH LOGIN = [MeinUser];
*/
