 SELECT s.session_id,
       s.host_name,
       s.program_name,
       s.login_name,
       r.status,
       r.blocking_session_id,
       r.wait_type,
       r.command,
       r.cpu_time,
       r.total_elapsed_time,
       r.reads,
       r.writes,
       r.logical_reads,
       r.scheduler_id,
       r.transaction_id,
       s.transaction_isolation_level,
       Db_name(r.database_id)          AS database_name,
       Substring(t.text, r.statement_start_offset / 2,
       ( CASE
           WHEN
       r.statement_end_offset = -1 THEN Len(CONVERT(NVARCHAR(max), t.text)) *
                                        2
                                                           ELSE
         r.statement_end_offset
                                                         END -
       r.statement_start_offset ) / 2) AS running_sql
FROM   sys.dm_exec_requests r
       JOIN sys.dm_exec_sessions s
         ON r.session_id = s.session_id
       CROSS apply sys.Dm_exec_sql_text(r.sql_handle) AS t
WHERE  r.session_id <> @@SPID
       AND NOT ( Db_name(r.database_id) = 'TM_DSM'
                 AND s.host_name <> 'FOC-SQL01' )  