USE AutoDealershipDemo;
GO


-----
-- Copy out Index Usage
IF OBJECT_ID('tempdb.dbo.#tmpIndexUsageBefore') IS NOT NULL
	DROP TABLE #tmpIndexUsageBefore;
	
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
INTO #tmpIndexUsageBefore
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




-- Add new filtered indexes then execute workload again
EXEC Workload.sp_DealershipWorkload 
	@NumToLoop = 2
GO




-----
-- Recheck Index Usage
IF OBJECT_ID('tempdb.dbo.#tmpIndexUsageAfter') IS NOT NULL
	DROP TABLE #tmpIndexUsageAfter;
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
INTO #tmpIndexUsageAfter
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




-- Show new index usage
SELECT 
	IndexName,
	user_seeks,
	user_scans,
	user_lookups,
	user_updates
FROM #tmpIndexUsageAfter
ORDER BY IndexName;








-----
-- There's something else here!


-- Before Workload
SELECT 
	IndexName,
	user_seeks,
	user_scans,
	user_lookups,
	user_updates
FROM #tmpIndexUsageBefore
WHERE IndexName IN (
	'IX_InventoryFlat_ModelName',
	'IX_InventoryFlat_MSRP_InvoicePrice_TrueCost',
	'IXF_InventoryFlat_Sold',
	'IXF_InventoryFlat_Unsold'
)
ORDER BY IndexName;


-- After Workload
SELECT 
	IndexName,
	user_seeks,
	user_scans,
	user_lookups,
	user_updates
FROM #tmpIndexUsageAfter
WHERE IndexName IN (
	'IX_InventoryFlat_ModelName',
	'IX_InventoryFlat_MSRP_InvoicePrice_TrueCost',
	'IXF_InventoryFlat_Sold',
	'IXF_InventoryFlat_Unsold'
)
ORDER BY IndexName;

