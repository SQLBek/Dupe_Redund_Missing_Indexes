USE AutoDealershipDemo;
GO


-----
-- CONSOLIDATE DUE TO DUPE/REDUNDANCY
DROP INDEX InventoryFlat.[IX_InventoryFlat_ModelName_MSRP];
DROP INDEX InventoryFlat.[IX_InventoryFlat_ModelName_MSRP_InvoicePrice];
DROP INDEX InventoryFlat.[IX_InventoryFlat_ModelName];

CREATE NONCLUSTERED INDEX IX_InventoryFlat_ModelName ON InventoryFlat (
	[ModelName]
) INCLUDE (
	[InvoicePrice], [MSRP]
);

-----
-- CONSOLIDATE DUE TO DUPE/REDUNDANCY
DROP INDEX InventoryFlat.[IX_InventoryFlat_Sold];
DROP INDEX InventoryFlat.[IX_InventoryFlat_Sold_SoldPrice];
DROP INDEX InventoryFlat.[IX_InventoryFlat_Sold_VIN];
DROP INDEX InventoryFlat.[IX_InventoryFlat_Sold_VIN_InventoryFlatID];
DROP INDEX InventoryFlat.[IX_InventoryFlat_VIN_Sold];

CREATE NONCLUSTERED INDEX IX_InventoryFlat_VIN_Sold	ON InventoryFlat (
	[VIN], [Sold]
)
INCLUDE (
	[SoldPrice]
);

-----
-- DROP DUE TO NO USAGE
DROP INDEX InventoryFlat.IX_InventoryFlat_DateReceived;
DROP INDEX InventoryFlat.IX_InventoryFlat_SoldPrice;
DROP INDEX InventoryFlat.IXF_InventoryFlat_SoldNotNull;
GO




-----
-- Return to 3a - Savings








-----
-- Spin up Workload to run in background
-- 0-Rogue_Execute Full Workload Script Bat x5.bat
-- 0-Rogue_Execute Query Workload Script Bat x5.bat








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
ORDER BY objects.name, indexes.type_desc, indexes.is_primary_key DESC, indexes.name;
