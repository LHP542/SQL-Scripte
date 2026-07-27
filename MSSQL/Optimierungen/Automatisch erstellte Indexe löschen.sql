DECLARE @IndexName NVARCHAR(300)
DECLARE @TableName NVARCHAR(100)
DECLARE @SchemaName NVARCHAR(100)
DECLARE index_cursor CURSOR FOR
SELECT idx.name AS IndexName, 
       obj.name AS TableName,
       schema_name(obj.schema_id) AS SchemaName
FROM sys.indexes idx
INNER JOIN sys.objects obj ON idx.object_id = obj.object_id
WHERE idx.name LIKE '_dta_%' 

OPEN index_cursor

FETCH NEXT FROM index_cursor INTO @IndexName, @TableName, @SchemaName
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Index: ' + @IndexName + ' - Table: ' + @TableName
    -- Falls du die Indizes löschen möchtest, benutze den folgenden Befehl:
    Execute ('DROP INDEX ' + @IndexName + ' ON ' +@SchemaName+'.'+ @TableName)
    FETCH NEXT FROM index_cursor INTO @IndexName, @TableName,@SchemaName
END

CLOSE index_cursor
DEALLOCATE index_cursor
