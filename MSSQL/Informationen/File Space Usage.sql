-- Pro Datenbank-Datei: allokierte Größe, tatsächlich belegt, freier Platz und
-- Autogrowth-Konfiguration. "free_pct < 10" ist der klassische Alarmwert.
-- Muss pro Datenbank ausgeführt werden (FILEPROPERTY greift nur lokal).

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql + N'
USE ' + QUOTENAME(name) + N';
SELECT
    DB_NAME()                                                      AS database_name,
    f.name                                                         AS logical_name,
    f.type_desc,
    f.physical_name,
    CAST(f.size          * 8.0 / 1024 AS DECIMAL(10,2))            AS allocated_mb,
    CAST(FILEPROPERTY(f.name, ''SpaceUsed'') * 8.0 / 1024 AS DECIMAL(10,2)) AS used_mb,
    CAST((f.size - FILEPROPERTY(f.name, ''SpaceUsed'')) * 8.0 / 1024 AS DECIMAL(10,2)) AS free_mb,
    CAST(100.0 * (f.size - FILEPROPERTY(f.name, ''SpaceUsed'')) / NULLIF(f.size,0) AS DECIMAL(5,2)) AS free_pct,
    CASE f.is_percent_growth
         WHEN 1 THEN CAST(f.growth AS VARCHAR) + '' %''
         ELSE CAST(f.growth * 8 / 1024 AS VARCHAR) + '' MB''
    END                                                            AS growth,
    CASE WHEN f.max_size = -1 THEN ''unbegrenzt''
         WHEN f.max_size =  0 THEN ''kein Wachstum''
         ELSE CAST(f.max_size * 8 / 1024 AS VARCHAR) + '' MB''
    END                                                            AS max_size
FROM sys.database_files f;
'
FROM sys.databases
WHERE state_desc = 'ONLINE'
  AND database_id > 4;

EXEC sp_executesql @sql;
