USE AutoDealershipDemo;
GO








-----
-- My personal sys.dm_db_index_usage_stats query
SELECT 
	databases.Name AS DatabaseName,
	schemas.Name AS SchemaName,
	objects.Name AS TableName,
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
	indexes.is_unique_constraint,
	dm_db_partition_stats.row_count,
	dm_db_partition_stats.in_row_data_page_count,
	dm_db_partition_stats.in_row_used_page_count,
	dm_db_partition_stats.in_row_reserved_page_count,
	dm_db_partition_stats.lob_used_page_count,
	dm_db_partition_stats.lob_reserved_page_count,
	dm_db_partition_stats.row_overflow_used_page_count,
	dm_db_partition_stats.row_overflow_reserved_page_count,
	dm_db_partition_stats.used_page_count,
	dm_db_partition_stats.reserved_page_count

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
ORDER BY databases.name, schemas.name, objects.name, indexes.type_desc, indexes.is_primary_key DESC, indexes.name








-----
-- Slimmed Down Output for Demo
USE AutoDealershipDemo;
GO


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








-----
-- Recommendations For Removal?
