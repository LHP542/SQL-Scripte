-- Oracle Scheduler-Jobs (Analog zu MSSQL SQL Agent).
-- Failed zuerst, dann nach letztem Lauf.

SELECT
    j.owner,
    j.job_name,
    j.enabled,
    j.state,
    j.job_type,
    j.repeat_interval,
    j.last_start_date,
    j.last_run_duration,
    j.next_run_date,
    j.failure_count,
    j.run_count
FROM   dba_scheduler_jobs j
WHERE  j.owner NOT IN ('SYS','SYSTEM','MDSYS','ORACLE_OCM')
ORDER BY j.failure_count DESC, j.last_start_date DESC;

-- Letzte Läufe pro Job im Detail
SELECT
    r.owner,
    r.job_name,
    r.status,
    r.actual_start_date,
    r.run_duration,
    r.error#,
    r.errors                  AS error_message
FROM   dba_scheduler_job_run_details r
WHERE  r.actual_start_date > SYSTIMESTAMP - INTERVAL '7' DAY
ORDER BY
    CASE r.status WHEN 'FAILED' THEN 0 ELSE 1 END,
    r.actual_start_date DESC;
