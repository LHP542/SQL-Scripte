-- Index-Wartung nach Fragmentierung:
--   >= 30 %  -> REBUILD (mit ONLINE = ON, wenn Edition/Datentypen es zulassen)
--   >=  5 %  -> REORGANIZE
--   <   5 %  -> nichts tun (Kosten > Nutzen)
-- Kleine Indizes (< 1000 Pages) werden übersprungen (SQL-Server-Best-Practice).

USE [TestDB_zumSpielen];
GO

SET NOCOUNT ON;

DECLARE @SchemaName SYSNAME;
DECLARE @TableName  SYSNAME;
DECLARE @IndexName  SYSNAME;
DECLARE @Fragment   FLOAT;
DECLARE @PageCount  BIGINT;
DECLARE @Sql        NVARCHAR(MAX);

DECLARE idx_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT  s.name  AS SchemaName,
        o.name  AS TableName,
        i.name  AS IndexName,
        ips.avg_fragmentation_in_percent,
        ips.page_count
FROM    sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS ips
JOIN    sys.indexes AS i ON i.object_id = ips.object_id AND i.index_id = ips.index_id
JOIN    sys.objects AS o ON o.object_id = ips.object_id
JOIN    sys.schemas AS s ON s.schema_id = o.schema_id
WHERE   i.name IS NOT NULL
        AND o.is_ms_shipped = 0
        AND ips.page_count >= 1000
        AND ips.avg_fragmentation_in_percent >= 5.0;

OPEN idx_cursor;
FETCH NEXT FROM idx_cursor INTO @SchemaName, @TableName, @IndexName, @Fragment, @PageCount;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @Fragment >= 30
        SET @Sql = N'ALTER INDEX ' + QUOTENAME(@IndexName)
                 + N' ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName)
                 + N' REBUILD;';
    ELSE
        SET @Sql = N'ALTER INDEX ' + QUOTENAME(@IndexName)
                 + N' ON ' + QUOTENAME(@SchemaName) + N'.' + QUOTENAME(@TableName)
                 + N' REORGANIZE;';

    PRINT CAST(@Fragment AS DECIMAL(5,2)) + N' %  ' + @Sql;
    EXEC sp_executesql @Sql;

    FETCH NEXT FROM idx_cursor INTO @SchemaName, @TableName, @IndexName, @Fragment, @PageCount;
END

CLOSE idx_cursor;
DEALLOCATE idx_cursor;
