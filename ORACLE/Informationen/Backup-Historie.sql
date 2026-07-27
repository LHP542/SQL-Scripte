-- RMAN-Backup-Historie: letztes Full/Incremental/Archivelog je DB / Tablespace.
-- Muss vom RMAN-Katalog oder vom Control-File gelesen werden.

SELECT
    bs.recid                                 AS backup_id,
    bs.bs_key,
    bs.backup_type,
    DECODE(bs.backup_type,
           'D', 'Full/Datafile',
           'I', 'Incremental',
           'L', 'Archivelog')                AS backup_type_desc,
    bs.incremental_level,
    bs.pieces,
    TO_CHAR(bs.start_time, 'YYYY-MM-DD HH24:MI:SS') AS start_time,
    TO_CHAR(bs.completion_time, 'YYYY-MM-DD HH24:MI:SS') AS completion_time,
    ROUND(bs.elapsed_seconds / 60, 2)        AS elapsed_min,
    ROUND(bs.bytes / 1024 / 1024, 2)         AS size_mb,
    bs.compressed,
    bs.status
FROM   v$backup_set bs
WHERE  bs.start_time > SYSDATE - 30
ORDER BY bs.start_time DESC;

-- Kompakt: letztes Full-Backup pro Tablespace
-- SELECT b.file#, df.tablespace_name, MAX(b.completion_time) AS last_full
-- FROM   v$backup_datafile b
-- JOIN   dba_data_files df ON df.file_id = b.file#
-- GROUP BY b.file#, df.tablespace_name
-- ORDER BY last_full;
