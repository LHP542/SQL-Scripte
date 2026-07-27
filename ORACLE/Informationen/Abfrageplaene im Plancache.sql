-- Ausführungspläne aus dem Shared Pool (Library Cache) mit Nutzungshäufigkeit.
-- Für den Detail-Plan eines konkreten Cursors:
--   SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('<sql_id>', <child>, 'ALLSTATS LAST'));

SELECT
    s.sql_id,
    s.child_number,
    s.parsing_schema_name,
    s.executions,
    s.buffer_gets,
    s.disk_reads,
    s.rows_processed,
    ROUND(s.elapsed_time / NULLIF(s.executions,0) / 1000, 2) AS avg_ms,
    s.last_active_time,
    SUBSTR(s.sql_text, 1, 200) AS sql_text
FROM   v$sql s
WHERE  s.parsing_schema_name NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN','ORDS_METADATA','APPQOSSYS','GSMADMIN_INTERNAL')
  AND  s.executions > 0
ORDER BY s.executions DESC
FETCH FIRST 100 ROWS ONLY;
