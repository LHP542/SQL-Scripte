-- Größe der Datenbank aufgeschlüsselt in Data / Temp / Redo / Backups.

SELECT 'Data Files' AS component,
       ROUND(SUM(bytes) / 1024 / 1024 / 1024, 2) AS size_gb
FROM   dba_data_files
UNION ALL
SELECT 'Temp Files',
       ROUND(SUM(bytes) / 1024 / 1024 / 1024, 2)
FROM   dba_temp_files
UNION ALL
SELECT 'Redo Logs',
       ROUND(SUM(bytes) / 1024 / 1024 / 1024, 2)
FROM   v$log
UNION ALL
SELECT 'Control Files',
       ROUND(SUM(block_size * file_size_blks) / 1024 / 1024 / 1024, 2)
FROM   v$controlfile;

-- Detaillierter: pro Tablespace
SELECT
    df.tablespace_name,
    ROUND(SUM(df.bytes) / 1024 / 1024, 2)                       AS allocated_mb,
    ROUND((SUM(df.bytes) - NVL(SUM(fs.free_bytes),0)) / 1024 / 1024, 2) AS used_mb,
    ROUND(NVL(SUM(fs.free_bytes),0) / 1024 / 1024, 2)           AS free_mb,
    ROUND(100 * (SUM(df.bytes) - NVL(SUM(fs.free_bytes),0)) / SUM(df.bytes), 2) AS used_pct
FROM   dba_data_files df
LEFT JOIN (SELECT tablespace_name, SUM(bytes) AS free_bytes
           FROM   dba_free_space
           GROUP BY tablespace_name) fs
       ON fs.tablespace_name = df.tablespace_name
GROUP BY df.tablespace_name
ORDER BY used_pct DESC;
