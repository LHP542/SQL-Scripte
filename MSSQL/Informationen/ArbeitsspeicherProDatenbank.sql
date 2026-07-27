SELECT 
    db_name(database_id) AS database_name,
    COUNT(*) * 8 / 1024 AS cached_size_mb
FROM 
    sys.dm_os_buffer_descriptors
WHERE 
    database_id <> 32767 -- Exclude the Resource DB
GROUP BY 
    db_name(database_id)
ORDER BY 
    cached_size_mb DESC;
