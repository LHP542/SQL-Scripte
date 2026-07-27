-- Session beenden. Rollback läuft, kann bei großen offenen Transaktionen dauern.
-- Fortschritt eines Rollbacks: KILL <spid> WITH STATUSONLY;

DECLARE @spid INT = 0;   -- session_id einsetzen

IF @spid = 0
BEGIN
    RAISERROR('Kein SPID gesetzt.', 16, 1);
    RETURN;
END

DECLARE @cmd NVARCHAR(20) = N'KILL ' + CAST(@spid AS NVARCHAR(10));
EXEC (@cmd);

-- Rollback-Status abfragen (separater Batch, falls Kill nicht sofort durch ist):
-- KILL 123 WITH STATUSONLY;
