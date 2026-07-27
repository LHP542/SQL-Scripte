-- Löschkandidaten: Indexe, die seit letztem SQL-Server-Start nie gelesen wurden,
-- aber bei jedem Write mitgepflegt werden müssen (bremst INSERT/UPDATE/DELETE).
-- Läuft im Kontext der aktuellen Datenbank.

-- WICHTIG: dm_db_index_usage_stats wird bei jedem Neustart und (in älteren
-- Versionen) bei ALTER INDEX REBUILD zurückgesetzt -> mindestens einen
-- kompletten Business-Zyklus (Woche/Monat) Uptime abwarten, bevor gelöscht wird.

SELECT
    DB_NAME()                                          AS database_name,
    s.name + '.' + t.name                              AS table_name,
    i.name                                             AS index_name,
    i.type_desc,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ps.row_count,
    ps.used_page_count * 8 / 1024                      AS size_mb,
    ius.last_user_seek,
    ius.last_user_scan,
    ius.last_user_update
FROM sys.indexes i
JOIN sys.objects t              ON t.object_id = i.object_id
JOIN sys.schemas s              ON s.schema_id = t.schema_id
LEFT JOIN sys.dm_db_index_usage_stats ius
       ON ius.object_id = i.object_id
      AND ius.index_id  = i.index_id
      AND ius.database_id = DB_ID()
LEFT JOIN sys.dm_db_partition_stats ps
       ON ps.object_id = i.object_id
      AND ps.index_id  = i.index_id
WHERE t.is_ms_shipped = 0
  AND i.type_desc IN ('NONCLUSTERED')
  AND i.is_primary_key = 0
  AND i.is_unique_constraint = 0
  AND ISNULL(ius.user_seeks, 0) + ISNULL(ius.user_scans, 0) + ISNULL(ius.user_lookups, 0) = 0
  AND ISNULL(ius.user_updates, 0) > 0
ORDER BY ius.user_updates DESC;
