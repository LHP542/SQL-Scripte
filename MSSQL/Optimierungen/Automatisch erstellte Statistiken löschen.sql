-- === KONFIGURATION =====================================
DECLARE @TargetDatabase SYSNAME = N'vis_prod';  -- Ziel-Datenbank
DECLARE @Prefix NVARCHAR(128) = N'_dta_';              -- Statistik-Präfix
-- =======================================================

DECLARE @SQL NVARCHAR(MAX) = N'';
DECLARE @DropSQL NVARCHAR(MAX);
DECLARE @SchemaName SYSNAME;
DECLARE @TableName SYSNAME;
DECLARE @StatName SYSNAME;

-- Dynamisches SQL zur Ausführung in Ziel-Datenbank
SET @SQL = '
DECLARE @SchemaName SYSNAME;
DECLARE @TableName SYSNAME;
DECLARE @StatName SYSNAME;
DECLARE @DropSQL NVARCHAR(MAX);

DECLARE stat_cursor CURSOR FOR
SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    st.name AS StatName
FROM 
    sys.stats st
JOIN 
    sys.tables t ON st.object_id = t.object_id
JOIN 
    sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    st.name LIKE ''' + @Prefix + '%''

OPEN stat_cursor;
FETCH NEXT FROM stat_cursor INTO @SchemaName, @TableName, @StatName;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @DropSQL = N''DROP STATISTICS ['' + @SchemaName + ''].['' + @TableName + ''].['' + @StatName + ''];'';
    PRINT ''Lösche: '' + @DropSQL;
    BEGIN TRY
        EXEC sp_executesql @DropSQL;
    END TRY
    BEGIN CATCH
        PRINT ''Fehler beim Löschen: '' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM stat_cursor INTO @SchemaName, @TableName, @StatName;
END;

CLOSE stat_cursor;
DEALLOCATE stat_cursor;
';

-- Ausführen im Kontext der Ziel-Datenbank
EXEC ('
USE [' + @TargetDatabase + '];
' + @SQL);
