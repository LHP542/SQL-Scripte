 DECLARE @SearchString NVARCHAR(100)

SET @SearchString = 'Test' -- Setzen Sie den String, nach dem Sie suchen möchten
DECLARE @TableName   NVARCHAR(256),
        @ColumnName  NVARCHAR(128),
        @SearchQuery NVARCHAR(2000)

-- Temporäre Tabelle für die Speicherung der gefundenen Ergebnisse
CREATE TABLE #results
  (
     tablename  NVARCHAR(256),
     columnname NVARCHAR(128),
     foundvalue NVARCHAR(1000)
  )

-- Durch alle Tabellen und Spalten gehen
DECLARE table_cursor CURSOR FOR
  SELECT '[' + t.NAME + ']' AS TableName,
         '[' + c.NAME + ']' AS ColumnName
  FROM   sys.columns c
         INNER JOIN sys.tables t
                 ON c.object_id = t.object_id
  WHERE  c.system_type_id IN ( 167, 175, 231, 239, 35, 99 ) -- Text-basierte Datentypen (varchar, char, nvarchar, nchar, text, ntext)

OPEN table_cursor

FETCH next FROM table_cursor INTO @TableName, @ColumnName

WHILE @@FETCH_STATUS = 0
  BEGIN
      SET @SearchQuery =
      'INSERT INTO #Results(TableName, ColumnName, FoundValue) SELECT '''
      + @TableName + ''', ''' + @ColumnName + ''', '
      + @ColumnName + ' FROM ' + @TableName + ' WHERE '
      + @ColumnName + ' LIKE ''%' + @SearchString
      + '%'' '

      BEGIN try
          EXEC Sp_executesql
            @SearchQuery
      END try

      BEGIN catch
          PRINT 'Fehler bei der Tabelle: ' + @TableName
                + ', Spalte: ' + @ColumnName
      END catch

      FETCH next FROM table_cursor INTO @TableName, @ColumnName
  END

CLOSE table_cursor

DEALLOCATE table_cursor

-- Ergebnisse anzeigen
SELECT *
FROM   #results

-- Temporäre Tabelle löschen
DROP TABLE #results  