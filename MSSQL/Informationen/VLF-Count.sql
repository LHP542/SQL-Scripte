-- VLF-Count pro Datenbank. Faustregeln:
--   < 50   -> ok
--   50-200 -> im Auge behalten
--   > 200  -> Log ist zerstückelt: langsame Restores, langsame Recovery
-- Fix: Log shrinken auf minimal, dann in großen Schritten (z. B. 8 GB) wachsen lassen.

CREATE TABLE #VLF (
    database_name SYSNAME NULL,
    vlf_count     INT     NULL
);

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql + N'
INSERT INTO #VLF (database_name, vlf_count)
SELECT ''' + name + N''', COUNT(*)
FROM sys.dm_db_log_info(' + CAST(database_id AS NVARCHAR(10)) + N');
'
FROM sys.databases
WHERE state_desc = 'ONLINE';

EXEC sp_executesql @sql;

SELECT
    database_name,
    vlf_count,
    CASE
        WHEN vlf_count > 200 THEN 'KRITISCH'
        WHEN vlf_count >  50 THEN 'beobachten'
        ELSE 'ok'
    END AS bewertung
FROM #VLF
ORDER BY vlf_count DESC;

DROP TABLE #VLF;
