-- SQL-Agent-Jobs: Status des letzten Laufs pro Job.
-- run_status: 0=Failed, 1=Succeeded, 2=Retry, 3=Canceled, 4=In Progress.

WITH LastRun AS
(
    SELECT
        jh.job_id,
        jh.run_status,
        jh.run_date,
        jh.run_time,
        jh.run_duration,
        jh.message,
        ROW_NUMBER() OVER (PARTITION BY jh.job_id ORDER BY jh.run_date DESC, jh.run_time DESC) AS rn
    FROM msdb.dbo.sysjobhistory jh
    WHERE jh.step_id = 0   -- Job-Gesamtergebnis, nicht einzelne Steps
)
SELECT
    j.name                                                                     AS job_name,
    CASE j.enabled WHEN 1 THEN 'Ja' ELSE 'Nein' END                            AS aktiviert,
    CASE lr.run_status
         WHEN 0 THEN 'Failed'
         WHEN 1 THEN 'Succeeded'
         WHEN 2 THEN 'Retry'
         WHEN 3 THEN 'Canceled'
         WHEN 4 THEN 'In Progress'
    END                                                                        AS last_status,
    -- run_date (YYYYMMDD) + run_time (HHMMSS) in datetime umwandeln
    msdb.dbo.agent_datetime(lr.run_date, lr.run_time)                          AS last_run,
    STUFF(STUFF(RIGHT('000000' + CAST(lr.run_duration AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':') AS duration_hhmmss,
    lr.message                                                                 AS last_message,
    ja.next_run_date,
    ja.next_run_time
FROM msdb.dbo.sysjobs j
LEFT JOIN LastRun lr ON lr.job_id = j.job_id AND lr.rn = 1
LEFT JOIN (SELECT job_id, MIN(next_run_date) AS next_run_date, MIN(next_run_time) AS next_run_time
           FROM   msdb.dbo.sysjobactivity
           WHERE  next_run_date > 0
           GROUP BY job_id) ja ON ja.job_id = j.job_id
ORDER BY
    CASE WHEN lr.run_status = 0 THEN 0 ELSE 1 END,   -- Failed zuerst
    last_run DESC;
