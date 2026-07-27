-- Autoextend-Konfiguration + Resize-Events aus dem Alert Log.
-- SE2-kompatibel (kein AWR / kein Diagnostics Pack nötig).

-- 1) Aktuelle Autoextend-Konfiguration pro Datafile
SELECT
    tablespace_name,
    file_name,
    ROUND(bytes    / 1024 / 1024, 2)    AS current_mb,
    autoextensible,
    ROUND(maxbytes / 1024 / 1024, 2)    AS max_mb,
    increment_by                        AS increment_blocks,
    ROUND(increment_by * 8 / 1024, 2)   AS increment_mb   -- 8k Default-Blocksize
FROM   dba_data_files
ORDER BY tablespace_name, file_name;

-- 2) Resize-Events aus dem Alert Log (letzte 7 Tage)
SELECT
    originating_timestamp,
    message_text
FROM   v$diag_alert_ext
WHERE  (message_text LIKE '%KCF: resize%'                 -- Datafile Auto-Resize
        OR message_text LIKE '%Autoextending%'
        OR message_text LIKE '%extending datafile%'
        OR message_text LIKE '%ORA-01652%'                -- unable to extend TEMP
        OR message_text LIKE '%ORA-01653%'                -- unable to extend TABLE
        OR message_text LIKE '%ORA-01654%'                -- unable to extend INDEX
        OR message_text LIKE '%ORA-01688%')               -- unable to extend PARTITION
  AND  originating_timestamp > SYSTIMESTAMP - INTERVAL '7' DAY
ORDER BY originating_timestamp DESC;
