-- Buffer-Cache-Belegung pro Schema (bzw. Owner der Segmente).
-- Oracle hat keine "Datenbanken" wie MSSQL - die Analogie ist der Schema-Owner.

SELECT
    o.owner,
    COUNT(DISTINCT bh.file#||'.'||bh.block#) AS cached_blocks,
    ROUND(COUNT(DISTINCT bh.file#||'.'||bh.block#) * 8 / 1024, 2) AS cached_mb,
    COUNT(DISTINCT o.object_id) AS distinct_objects
FROM   v$bh bh
JOIN   dba_objects o
       ON o.data_object_id = bh.objd
WHERE  o.owner NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN')
  AND  bh.status <> 'free'
GROUP BY o.owner
ORDER BY cached_mb DESC;
