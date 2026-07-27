DECLARE @DatabaseName NVARCHAR(128)
DECLARE @SQL NVARCHAR(MAX)

DECLARE db_cursor CURSOR FOR 
SELECT name FROM sys.databases WHERE database_id > 4 order by name

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @DatabaseName  

WHILE @@FETCH_STATUS = 0  
BEGIN  
    SET @SQL = 'USE [' + @DatabaseName + ']; 
                SELECT 
                    DB_NAME() AS DatabaseName,
                    CASE 
                        WHEN actual_state = 0 THEN ''Deaktiviert''
                        WHEN actual_state = 1 THEN ''Lese- und Schreibzugriff'' 
                        WHEN actual_state = 2 THEN ''Nur-Lese-Modus'' 
                    END AS QueryStoreStatus
                FROM sys.database_query_store_options;'

    EXEC sp_executesql @SQL

    FETCH NEXT FROM db_cursor INTO @DatabaseName  
END  

CLOSE db_cursor  
DEALLOCATE db_cursor
