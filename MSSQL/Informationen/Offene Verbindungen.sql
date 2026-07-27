WITH DiaDB AS (
    SELECT database_id, name
    FROM   sys.databases
    WHERE  name LIKE 'PDV_%'
)
SELECT  d.database_id,
        d.name,
        mf.physical_name,
        mf.name                                   AS LogFileName,
        COUNT(s.session_id)                       AS [Anz. Connections],

        /* Benutzer-Liste bauen */
        STUFF((
            SELECT DISTINCT ', ' + s2.login_name
            FROM   sys.dm_exec_sessions s2
            WHERE  s2.database_id = d.database_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)')
        ,1,2,'') AS Benutzer,

        /* Computer-Liste bauen */
        STUFF((
            SELECT DISTINCT ', ' + s3.host_name
            FROM   sys.dm_exec_sessions s3
            WHERE  s3.database_id = d.database_id
            FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)')
        ,1,2,'') AS Computer
FROM    DiaDB               AS d
JOIN    sys.master_files     AS mf ON mf.database_id = d.database_id
LEFT JOIN sys.dm_exec_sessions s  ON s.database_id  = d.database_id
WHERE   mf.type_desc = 'ROWS'
GROUP BY d.database_id, d.name, mf.physical_name, mf.name