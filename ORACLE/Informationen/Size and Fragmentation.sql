-- Größe und "Fragmentierung" von Indexen.
-- Oracle-Fragmentierung heißt hier: DEL_LF_ROWS / LF_ROWS  (gelöschte vs. aktive Blätter).
-- Ab ~ 20 % ist ein REBUILD überlegenswert. Vorher aber ANALYZE INDEX ... VALIDATE STRUCTURE ausführen.

-- 1) Index-Größe pro Segment
SELECT
    s.owner,
    s.segment_name           AS index_name,
    s.tablespace_name,
    ROUND(s.bytes / 1024 / 1024, 2) AS size_mb,
    s.blocks,
    s.extents
FROM   dba_segments s
WHERE  s.segment_type IN ('INDEX','INDEX PARTITION')
  AND  s.owner NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN')
ORDER BY s.bytes DESC
FETCH FIRST 50 ROWS ONLY;

-- 2) Fragmentierung nach VALIDATE STRUCTURE
-- ANALYZE INDEX <owner>.<index> VALIDATE STRUCTURE;   -- vorher ausführen!
SELECT
    name           AS index_name,
    height,
    lf_rows,
    del_lf_rows,
    ROUND(del_lf_rows * 100 / NULLIF(lf_rows, 0), 2) AS deleted_pct,
    used_space,
    pct_used
FROM   index_stats;
