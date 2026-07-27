-- Findet exakt-doppelte Indexe (gleiche Tabelle, gleiche Key-Column-Reihenfolge).
-- Included Columns werden IGNORIERT -> auch "fast identische" Indexe fallen auf.
-- Läuft im Kontext der aktuellen Datenbank.

WITH IndexCols AS
(
    SELECT
        i.object_id,
        i.index_id,
        i.name AS index_name,
        i.is_unique,
        i.is_primary_key,
        i.type_desc,
        -- Key-Columns in Reihenfolge, kommasepariert
        STUFF((
            SELECT ',' + c.name + CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE '' END
            FROM   sys.index_columns ic
            JOIN   sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
            WHERE  ic.object_id = i.object_id
              AND  ic.index_id  = i.index_id
              AND  ic.is_included_column = 0
            ORDER BY ic.key_ordinal
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 1, '') AS key_columns
    FROM sys.indexes i
    WHERE i.type_desc IN ('CLUSTERED', 'NONCLUSTERED')
      AND i.is_hypothetical = 0
)
SELECT
    s.name + '.' + t.name                   AS table_name,
    ic.key_columns,
    COUNT(*)                                AS duplicate_count,
    STRING_AGG(ic.index_name, ', ')         AS duplicate_indexes
FROM IndexCols ic
JOIN sys.objects t ON t.object_id = ic.object_id
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.is_ms_shipped = 0
  AND ic.key_columns IS NOT NULL
GROUP BY s.name, t.name, ic.key_columns
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, table_name;
