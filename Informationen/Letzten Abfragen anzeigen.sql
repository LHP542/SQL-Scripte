 SELECT deqs.last_execution_time AS [Time],
       dest.text                AS [Query],
       dbs.NAME

FROM   sys.dm_exec_query_stats AS deqs
       CROSS apply sys.Dm_exec_sql_text(deqs.sql_handle) AS dest
       LEFT JOIN sys.databases AS dbs
              ON dbs.database_id = dest.dbid
WHERE  --dest.dbid IS NOT NULL
       --AND dbs.database_id IS NOT NULL
       --AND dbs.NAME NOT IN ( 'master', 'tempdb', 'msdb', 'model' )
	   DATEDIFF(HOUR,deqs.last_execution_time,CURRENT_TIMESTAMP)<1
ORDER  BY deqs.last_execution_time DESC  