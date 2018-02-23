USE AutoDealershipDemo;
GO


-------------------------------------------------------------------------------
-- Tools - Index Tuning
--
-- Written By: Andy Yun
-- Created On: 2010-01-01
-- 
-- Summary: Analyze Missing Index DMVs to assess what SQL thinks would help the most.
-- 
-- Source:
-- http://blogs.msdn.com/b/bartd/archive/2007/07/19/are-you-using-sql-s-missing-index-dmvs.aspx
-- Further modified by AYun
-------------------------------------------------------------------------------
SELECT
	dm_db_missing_index_group_stats.avg_total_user_cost 
	* (
		dm_db_missing_index_group_stats.avg_user_impact / 100.0
	) 
	* (
		dm_db_missing_index_group_stats.user_seeks + dm_db_missing_index_group_stats.user_scans
	) 
	AS improvement_measure,           
	DB_NAME(dm_db_missing_index_details.database_id) AS DatabaseName,
	REPLACE(REPLACE(dm_db_missing_index_details.statement, DB_NAME(dm_db_missing_index_details.database_id), ''), '[].', '') AS TableName, 
	dm_db_missing_index_details.equality_columns, 
	dm_db_missing_index_details.inequality_columns, 
	dm_db_missing_index_details.included_columns, 
	dm_db_missing_index_group_stats.unique_compiles, 
	dm_db_missing_index_group_stats.user_seeks, 
	dm_db_missing_index_group_stats.user_scans, 
	dm_db_missing_index_group_stats.last_user_seek, 
	dm_db_missing_index_group_stats.last_user_scan, 
	dm_db_missing_index_group_stats.avg_total_user_cost, 
	dm_db_missing_index_group_stats.avg_user_impact		-- Is a Percentage
FROM sys.dm_db_missing_index_groups
INNER JOIN sys.dm_db_missing_index_group_stats 
	ON dm_db_missing_index_group_stats.group_handle = dm_db_missing_index_groups.index_group_handle
INNER JOIN sys.dm_db_missing_index_details
	ON dm_db_missing_index_groups.index_handle = dm_db_missing_index_details.index_handle
WHERE dm_db_missing_index_details.database_id = DB_ID(N'AutoDealershipDemo')
	AND dm_db_missing_index_group_stats.avg_total_user_cost 
		* (
			dm_db_missing_index_group_stats.avg_user_impact / 100.0
		) 
		* (
			dm_db_missing_index_group_stats.user_seeks + dm_db_missing_index_group_stats.user_scans
		) > 10
	---
	-- Only for DEMO
	AND REPLACE(REPLACE(dm_db_missing_index_details.statement, DB_NAME(dm_db_missing_index_details.database_id), ''), '[].', '') = '[dbo].[InventoryFlat]'
ORDER BY 
	dm_db_missing_index_group_stats.avg_total_user_cost 
	* dm_db_missing_index_group_stats.avg_user_impact 
	* (
		dm_db_missing_index_group_stats.user_seeks + dm_db_missing_index_group_stats.user_scans
	) DESC;
GO


-----
-- Copy out to Excel




-----
-- Re-reference Existing Indexes
EXEC sp_SQLSkills_helpindex 'dbo.InventoryFlat';
GO








-----
-- Filtered Index?
-- Create one for SOLD vehicles

-- *** Open and execute 5a first ***
IF EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IXF_InventoryFlat_Sold')
	DROP INDEX InventoryFlat.IXF_InventoryFlat_Sold;
IF EXISTS(SELECT 1 FROM sys.indexes WHERE name = 'IXF_InventoryFlat_Unsold')
	DROP INDEX InventoryFlat.IXF_InventoryFlat_Unsold;

CREATE NONCLUSTERED INDEX IXF_InventoryFlat_Sold ON InventoryFlat (
	[ModelName], [PackageName], [ColorName]
)
INCLUDE (
	[VIN], [MakeName], [TrueCost], [InvoicePrice], [MSRP], [DateReceived], [SoldPrice]
)
WHERE Sold = 1;


-- Create one for SOLD vehicles
CREATE NONCLUSTERED INDEX IXF_InventoryFlat_Unsold ON InventoryFlat (
	[ModelName], [PackageName], [ColorName]
)
INCLUDE (
	[VIN], [MakeName], [TrueCost], [InvoicePrice], [MSRP], [DateReceived], [SoldPrice]
)
WHERE Sold = 0;
