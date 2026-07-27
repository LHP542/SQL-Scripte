 SELECT ss.session_id,
       db.NAME,
       ss.login_time,
       ss.host_name,
       ss.program_name,
       ss.login_name,
       ss.status,
       ss.last_request_start_time,
       ss.last_request_end_time,
       ss.original_login_name,
       ss.database_id
FROM   sys.dm_exec_sessions ss
       JOIN sys.databases db
         ON ss.database_id = db.database_id
order by db.Name, ss.session_id
