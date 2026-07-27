-- Kandidaten für fehlende Indexe via Full Table Scans im Shared Pool.
-- SE2-kompatibel (SQL Tuning / Access Advisor ist Tuning Pack -> nur EE).
-- Grundidee: Statements finden, die viel Zeit + viele Buffer Gets brauchen
-- und dabei FULL TABLE SCAN auf größere Tabellen machen.

-- 1) Full Table Scans auf große Tabellen, sortiert nach Kosten
SELECT
    s.sql_id,
    p.object_owner,
    p.object_name                        AS table_name,
    seg.mb                               AS table_size_mb,
    s.executions,
    ROUND(s.elapsed_time / NULLIF(s.executions,0) / 1000, 2) AS avg_ms,
    s.buffer_gets / NULLIF(s.executions,0)                   AS avg_buffer_gets,
    SUBSTR(s.sql_text, 1, 300)           AS sql_text
FROM   v$sql       s
JOIN   v$sql_plan  p
       ON  p.sql_id       = s.sql_id
       AND p.child_number = s.child_number
LEFT JOIN (SELECT owner, segment_name, ROUND(SUM(bytes)/1024/1024, 2) AS mb
           FROM   dba_segments
           WHERE  segment_type IN ('TABLE','TABLE PARTITION')
           GROUP BY owner, segment_name) seg
       ON  seg.owner = p.object_owner AND seg.segment_name = p.object_name
WHERE  p.operation      = 'TABLE ACCESS'
  AND  p.options        = 'FULL'
  AND  p.object_owner  NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN')
  AND  s.executions     > 0
  AND  seg.mb           > 100          -- nur Tabellen > 100 MB (klein ist FTS ok)
ORDER BY s.elapsed_time DESC
FETCH FIRST 25 ROWS ONLY;

-- 2) Für einen konkreten SQL_ID den Plan im Detail ansehen:
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('&sql_id', NULL, 'ALLSTATS LAST'));

-- 3) WHERE-Klausel und Prädikate aus V$SQL_PLAN
-- SELECT operation, options, object_name, access_predicates, filter_predicates
-- FROM   v$sql_plan
-- WHERE  sql_id = '&sql_id'
-- ORDER BY id;

-- Hinweis: die "richtige" Missing-Index-Analyse (SQL Access Advisor)
-- braucht das Tuning + Diagnostics Pack. In SE2 muss manuell entschieden werden:
--   - Welche Spalten stehen im WHERE / JOIN / ORDER BY?
--   - Selektivität hoch genug?
--   - Passt der Index in die vorhandene Write-Last?
