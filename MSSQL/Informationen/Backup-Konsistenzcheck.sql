EXEC msdb.dbo.usp_VerifyLatestBackup
    @BackupType = 'D',
    @Database = NULL,
    @ThrowOnError = 0,
    @CaptureMessages = 1;
