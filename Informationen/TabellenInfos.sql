-- Komplette Strukturübersicht: Tabellen, Spalten, PKs, FKs
SELECT 
    t.TABLE_SCHEMA AS [Schema],
    t.TABLE_NAME AS [Tabelle],
    c.COLUMN_NAME AS [Spalte],
    c.DATA_TYPE + ISNULL('(' + 
        CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX'
             ELSE CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR) 
        END + ')', '') AS [Datentyp],
    c.CHARACTER_MAXIMUM_LENGTH,
    c.IS_NULLABLE AS [Nullable],
    CASE WHEN pk.COLUMN_NAME IS NOT NULL THEN 'PK' ELSE '' END AS [PK],
    fk.FK_Name,
    fk.Referenced_Table,
    fk.Referenced_Column
FROM INFORMATION_SCHEMA.TABLES t
JOIN INFORMATION_SCHEMA.COLUMNS c 
    ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
LEFT JOIN (
    SELECT ku.TABLE_SCHEMA, ku.TABLE_NAME, ku.COLUMN_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku 
        ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME
    WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
) pk ON c.TABLE_SCHEMA = pk.TABLE_SCHEMA 
    AND c.TABLE_NAME = pk.TABLE_NAME 
    AND c.COLUMN_NAME = pk.COLUMN_NAME
LEFT JOIN (
    SELECT 
        fk.name AS FK_Name,
        SCHEMA_NAME(tp.schema_id) AS Parent_Schema,
        tp.name AS Parent_Table,
        cp.name AS Parent_Column,
        tr.name AS Referenced_Table,
        cr.name AS Referenced_Column
    FROM sys.foreign_keys fk
    JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
    JOIN sys.tables tp ON fkc.parent_object_id = tp.object_id
    JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id 
        AND fkc.parent_column_id = cp.column_id
    JOIN sys.tables tr ON fkc.referenced_object_id = tr.object_id
    JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id 
        AND fkc.referenced_column_id = cr.column_id
) fk ON c.TABLE_SCHEMA = fk.Parent_Schema 
    AND c.TABLE_NAME = fk.Parent_Table 
    AND c.COLUMN_NAME = fk.Parent_Column
WHERE t.TABLE_TYPE = 'BASE TABLE'
ORDER BY t.TABLE_SCHEMA, t.TABLE_NAME, c.ORDINAL_POSITION;