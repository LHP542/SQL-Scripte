-- Full- und Log-Backup einer Datenbank.
-- COMPRESSION + CHECKSUM = Best Practice: kleiner + integritätsgeprüft.
-- Datei-Timestamp im Namen -> mehrere Backups nebeneinander ohne Overwrite.

DECLARE @DatabaseName SYSNAME    = N'TestDB_zumSpielen';
DECLARE @BackupPath   NVARCHAR(260) = N'D:\Backup\';
DECLARE @Timestamp    NVARCHAR(20) = FORMAT(GETDATE(), 'yyyyMMdd_HHmmss');

-- ============ FULL ============
DECLARE @FullFile NVARCHAR(400) =
    @BackupPath + @DatabaseName + N'_FULL_' + @Timestamp + N'.bak';

BACKUP DATABASE @DatabaseName
TO DISK = @FullFile
WITH  COMPRESSION,
      CHECKSUM,
      INIT,
      STATS = 5,
      NAME = N'Full-Backup manuell';

-- ============ LOG (nur bei Recovery-Model FULL/BULK_LOGGED sinnvoll) ============
-- DECLARE @LogFile NVARCHAR(400) =
--     @BackupPath + @DatabaseName + N'_LOG_' + @Timestamp + N'.trn';
--
-- BACKUP LOG @DatabaseName
-- TO DISK = @LogFile
-- WITH  COMPRESSION,
--       CHECKSUM,
--       STATS = 5,
--       NAME = N'Log-Backup manuell';

-- ============ Verify ============
RESTORE VERIFYONLY FROM DISK = @FullFile WITH CHECKSUM;
