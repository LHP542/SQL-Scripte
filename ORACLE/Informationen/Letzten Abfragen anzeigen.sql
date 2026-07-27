-- Zuletzt im Shared Pool ausgeführte Statements (letzte Stunde).

SELECT
    s.last_active_time,
    s.parsing_schema_name,
    s.executions,
    ROUND(s.elapsed_time / NULLIF(s.executions,0) / 1000, 2) AS avg_ms,
    s.sql_id,
    SUBSTR(s.sql_text, 1, 300) AS sql_text
FROM   v$sql s
WHERE  s.last_active_time > SYSDATE - INTERVAL '1' HOUR
  AND  s.parsing_schema_name NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN')
ORDER BY s.last_active_time DESC;
