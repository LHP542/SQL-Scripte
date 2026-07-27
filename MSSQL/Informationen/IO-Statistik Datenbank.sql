DECLARE @db_id INT;
SET @db_id = DB_ID('PROSOZBAU');

SELECT 
    DB_NAME(vfs.database_id) AS database_name,
    mf.physical_name,
    mf.type_desc,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.num_of_bytes_read / 1024 / 1024 AS read_mb,
    vfs.num_of_bytes_written / 1024 / 1024 AS written_mb,
    vfs.io_stall_read_ms,
    vfs.io_stall_write_ms,
    vfs.io_stall_read_ms + vfs.io_stall_write_ms AS total_io_stall_ms,
    CASE WHEN vfs.num_of_reads = 0 THEN 0 ELSE vfs.io_stall_read_ms / vfs.num_of_reads END AS avg_read_stall_ms,
    CASE WHEN vfs.num_of_writes = 0 THEN 0 ELSE vfs.io_stall_write_ms / vfs.num_of_writes END AS avg_write_stall_ms,
    CASE WHEN vfs.num_of_reads = 0 THEN 0 ELSE vfs.num_of_bytes_read / vfs.num_of_reads / 1024 End AS avg_read_kb,
    CASE WHEN vfs.num_of_writes = 0 THEN 0 ELSE vfs.num_of_bytes_written / vfs.num_of_writes / 1024 End  AS avg_write_kb
FROM 
    sys.dm_io_virtual_file_stats(@db_id, NULL) AS vfs
JOIN 
    sys.master_files AS mf ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id

where vfs.database_id = @db_id