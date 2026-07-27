-- Physische IO pro Datafile: Reads, Writes, Bytes, Latenz.
-- Werte sind kumulativ seit Instanz-Start.

SELECT
    df.tablespace_name,
    df.file_name,
    fs.phyrds                                       AS physical_reads,
    fs.phywrts                                      AS physical_writes,
    ROUND(fs.phyblkrd  * ts.block_size / 1024 / 1024, 2) AS read_mb,
    ROUND(fs.phyblkwrt * ts.block_size / 1024 / 1024, 2) AS write_mb,
    fs.readtim / 100                                AS read_time_sec,
    fs.writetim / 100                               AS write_time_sec,
    ROUND(fs.readtim  / NULLIF(fs.phyrds, 0), 2)    AS avg_read_ms,
    ROUND(fs.writetim / NULLIF(fs.phywrts, 0), 2)   AS avg_write_ms,
    fs.avgiotim / 100                               AS avg_io_time_sec
FROM   v$filestat fs
JOIN   dba_data_files df ON df.file_id = fs.file#
JOIN   dba_tablespaces ts ON ts.tablespace_name = df.tablespace_name
ORDER BY (fs.phyrds + fs.phywrts) DESC;
