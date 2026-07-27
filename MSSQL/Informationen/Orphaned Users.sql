-- Orphaned Users über alle User-DBs:
-- DB-User mit SID, zu der kein Server-Login existiert.
-- Klassisch nach Restore auf anderem Server -> Login-Mapping bricht.
-- Fix: ALTER USER [xy] WITH LOGIN = [xy];  (bei Namensgleichheit)

DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql = @sql + N'
USE ' + QUOTENAME(name) + N';
SELECT
    DB_NAME()                  AS database_name,
    dp.name                    AS orphaned_user,
    dp.type_desc,
    dp.create_date,
    CONVERT(VARCHAR(85), dp.sid, 1) AS sid
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp ON sp.sid = dp.sid
WHERE dp.type IN (''S'', ''U'', ''G'')            -- SQL-User, Windows-User, Windows-Group
  AND dp.principal_id > 4                          -- System-User ausblenden
  AND dp.authentication_type <> 0                  -- keine contained-DB-User
  AND sp.sid IS NULL
  AND dp.name NOT IN (''guest'', ''sys'', ''INFORMATION_SCHEMA'');
'
FROM sys.databases
WHERE state_desc = 'ONLINE'
  AND database_id > 4;

EXEC sp_executesql @sql;
