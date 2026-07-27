-- Unbenutzte Indexe in Oracle:
-- Oracle trackt Index-Nutzung nur, wenn explizit aktiviert:
--   ALTER INDEX <owner>.<idx> MONITORING USAGE;
-- Ab 12.2+ automatisch via V$INDEX_USAGE_INFO / DBA_INDEX_USAGE.
-- Vor dem Löschen: mindestens einen kompletten Business-Zyklus warten!

-- 12.2+ Variante (automatisches Tracking)
SELECT
    u.owner,
    u.name                      AS index_name,
    u.total_access_count,
    u.total_exec_count,
    u.total_rows_returned,
    u.last_used
FROM   dba_index_usage u
WHERE  u.owner NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN')
  AND  (u.total_access_count = 0 OR u.last_used < SYSDATE - 90)
ORDER BY u.last_used NULLS FIRST;

-- Klassische Variante (V$OBJECT_USAGE, pro Session, nur wenn MONITORING USAGE aktiv)
-- SELECT owner, index_name, monitoring, used, start_monitoring, end_monitoring
-- FROM   dba_object_usage
-- WHERE  used = 'NO';

-- Monitoring flächendeckend aktivieren (einmalig):
-- BEGIN
--   FOR i IN (SELECT owner, index_name FROM dba_indexes
--             WHERE owner NOT IN ('SYS','SYSTEM','DBSNMP','OUTLN')) LOOP
--     EXECUTE IMMEDIATE 'ALTER INDEX ' || i.owner || '.' || i.index_name || ' MONITORING USAGE';
--   END LOOP;
-- END;
-- /
