--Returns size and fragmentation information for the data and indexes of the specified table or view in SQL Server.

declare @dbName as Varchar(50); Set @dbName = 'TREND-APONE01-ApexOne';

SELECT avg_fragmentation_in_percent AS AverageFragmentation,
       page_count                   AS Pages,
       partition_number             AS PartitionNumber,
	   *
FROM   sys.Dm_db_index_physical_stats(DB_ID(@dbName), OBJECT_ID(N'T1'),  NULL, NULL, NULL)
WHERE  index_level = 0
       AND alloc_unit_type_desc = 'IN_ROW_DATA'

SELECT	DB_NAME(database_id) as Name,
		sum(avg_fragmentation_in_percent) /count(avg_fragmentation_in_percent) AS AverageFragmentation,
		index_type_desc
FROM	sys.Dm_db_index_physical_stats(DB_ID(@dbName), OBJECT_ID(N'T1'),  NULL, NULL, NULL)
WHERE	index_level = 0
		AND alloc_unit_type_desc = 'IN_ROW_DATA'
group by index_type_desc,database_id
     