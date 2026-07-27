-- Oracle protokolliert Deadlocks im Alert Log als "ORA-00060: deadlock detected"
-- und schreibt einen Trace File nach BACKGROUND_DUMP_DEST/USER_DUMP_DEST.
-- Über V$DIAG_INFO / V$DIAG_ALERT_EXT sind sie strukturiert abrufbar (11g+).

-- 1) Deadlock-Meldungen aus dem Alert Log
SELECT
    originating_timestamp,
    message_text
FROM   v$diag_alert_ext
WHERE  message_text LIKE '%ORA-00060%'
   OR  message_text LIKE '%deadlock detected%'
ORDER BY originating_timestamp DESC
FETCH FIRST 50 ROWS ONLY;

-- 2) Zugehörige Trace Files (dort steht der Deadlock-Graph im Detail)
SELECT
    incident_id,
    create_time,
    problem_key,
    error_facility,
    error_number,
    error_arg1,
    error_arg2
FROM   v$diag_incident
WHERE  problem_key LIKE 'ORA 60%'
ORDER BY create_time DESC
FETCH FIRST 20 ROWS ONLY;

-- Pfad zum Alert Log / Trace-Directory
-- SELECT name, value FROM v$diag_info;
