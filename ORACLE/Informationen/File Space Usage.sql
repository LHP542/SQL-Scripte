-- Pro Datafile / Tempfile: allokiert, belegt, frei, Autoextend-Konfiguration.

SELECT
    df.tablespace_name,
    df.file_name,
    ROUND(df.bytes / 1024 / 1024, 2)                                AS allocated_mb,
    ROUND((df.bytes - NVL(fs.free_bytes, 0)) / 1024 / 1024, 2)      AS used_mb,
    ROUND(NVL(fs.free_bytes, 0) / 1024 / 1024, 2)                   AS free_mb,
    ROUND(100 * NVL(fs.free_bytes, 0) / df.bytes, 2)                AS free_pct,
    df.autoextensible,
    ROUND(df.maxbytes / 1024 / 1024, 2)                             AS max_mb,
    ROUND(df.increment_by * ts.block_size / 1024 / 1024, 2)         AS increment_mb
FROM   dba_data_files df
LEFT JOIN (SELECT file_id, SUM(bytes) AS free_bytes
           FROM   dba_free_space
           GROUP BY file_id) fs
       ON fs.file_id = df.file_id
JOIN   dba_tablespaces ts ON ts.tablespace_name = df.tablespace_name
UNION ALL
SELECT
    tf.tablespace_name,
    tf.file_name,
    ROUND(tf.bytes / 1024 / 1024, 2),
    NULL, NULL, NULL,
    tf.autoextensible,
    ROUND(tf.maxbytes / 1024 / 1024, 2),
    ROUND(tf.increment_by * ts.block_size / 1024 / 1024, 2)
FROM   dba_temp_files tf
JOIN   dba_tablespaces ts ON ts.tablespace_name = tf.tablespace_name
ORDER BY 1, 2;
