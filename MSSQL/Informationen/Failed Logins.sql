-- Fehlgeschlagene Login-Versuche aus dem SQL-Error-Log.
-- Voraussetzung: Login Auditing = "Both failed and successful logins"
-- (Server-Properties -> Security -> Login auditing).
-- sp_readerrorlog liest immer nur die aktuelle Log-Datei (0 = current).

-- Aktuelles Log
EXEC xp_readerrorlog 0, 1, N'Login failed';

-- Vorherige Logs durchsuchen (1 = vor letztem Recycle, 2 = davor, ...)
-- EXEC xp_readerrorlog 1, 1, N'Login failed';
-- EXEC xp_readerrorlog 2, 1, N'Login failed';

-- Kompakte Zusammenfassung nach Login
CREATE TABLE #err (LogDate DATETIME, ProcessInfo NVARCHAR(50), Text NVARCHAR(MAX));
INSERT INTO #err EXEC xp_readerrorlog 0, 1, N'Login failed';

SELECT
    CAST(LogDate AS DATE)                                          AS log_day,
    -- Login-Name aus dem Text extrahieren: "Login failed for user 'xy'."
    SUBSTRING(Text,
              CHARINDEX('''', Text) + 1,
              CHARINDEX('''', Text, CHARINDEX('''', Text) + 1) - CHARINDEX('''', Text) - 1) AS login_name,
    COUNT(*) AS attempts
FROM #err
GROUP BY CAST(LogDate AS DATE),
         SUBSTRING(Text,
                   CHARINDEX('''', Text) + 1,
                   CHARINDEX('''', Text, CHARINDEX('''', Text) + 1) - CHARINDEX('''', Text) - 1)
ORDER BY log_day DESC, attempts DESC;

DROP TABLE #err;
