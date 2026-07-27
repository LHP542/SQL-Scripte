-- Top 10 langsamste Statements aus dem Shared Pool nach durchschnittlicher Elapsed Time.

SELECT * FROM (
    SELECT
        s.sql_id,
        s.parsing_schema_name,
        s.executions,
        ROUND(s.elapsed_time / NULLIF(s.executions,0) / 1000, 2) AS avg_elapsed_ms,
        ROUND(s.cpu_time     / NULLIF(s.executions,0) / 1000, 2) AS avg_cpu_ms,
        s.buffer_gets / NULLIF(s.executions,0)                   AS avg_buffer_gets,
        s.disk_reads  / NULLIF(s.executions,0)                   AS avg_disk_reads,
        s.rows_processed / NULLIF(s.executions,0)                AS avg_rows,
        SUBSTR(s.sql_text, 1, 400)                               AS sql_text
    FROM   v$sql s
    WHERE  s.executions > 0
      AND  s.parsing_schema_name NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN')
    ORDER BY avg_elapsed_ms DESC NULLS LAST
)
WHERE ROWNUM <= 10;
