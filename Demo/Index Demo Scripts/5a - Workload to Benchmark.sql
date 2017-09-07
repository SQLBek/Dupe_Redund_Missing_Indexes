USE AutoDealershipDemo;
GO
SET STATISTICS TIME ON;
-- SET STATISTICS IO ON;	-- Enable if 'net access available: statisticsparser.com
GO
EXEC dbo.sp_DealershipWorkload 
	@NumToLoop = 1	-- Set to 10 if 'net access unavailable
GO

-----
-- Record time & IO baseline run


-----
-- Recheck Index Usage
SELECT 
	indexes.Name AS IndexName,
	dm_db_index_usage_stats.user_seeks,
	dm_db_index_usage_stats.user_scans,
	dm_db_index_usage_stats.user_lookups,
	dm_db_index_usage_stats.user_updates,
	dm_db_index_usage_stats.last_user_seek,
	dm_db_index_usage_stats.last_user_scan,
	dm_db_index_usage_stats.last_user_lookup,
	dm_db_index_usage_stats.last_user_update,
	indexes.type_desc,
	indexes.is_primary_key,
	indexes.is_unique,
	indexes.is_unique_constraint

FROM master.sys.dm_db_index_usage_stats
INNER JOIN master.sys.databases
	ON dm_db_index_usage_stats.database_id = databases.database_id
INNER JOIN sys.objects
	ON dm_db_index_usage_stats.object_id = objects.object_id
INNER JOIN sys.schemas
	ON schemas.schema_id = objects.schema_id	
INNER JOIN sys.indexes
	ON dm_db_index_usage_stats.index_id = indexes.index_id
	AND dm_db_index_usage_stats.object_id = indexes.object_id
INNER JOIN sys.dm_db_partition_stats
	ON dm_db_index_usage_stats.index_id = dm_db_partition_stats.index_id
	AND dm_db_index_usage_stats.object_id = dm_db_partition_stats.object_id
WHERE objects.type = 'U' 
	AND databases.name = db_name()
	AND objects.name = 'InventoryFlat'
ORDER BY objects.name, indexes.type_desc, indexes.is_primary_key DESC, indexes.name