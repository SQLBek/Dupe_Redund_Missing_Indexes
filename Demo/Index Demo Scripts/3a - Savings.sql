USE AutoDealershipDemo;
GO


-----
-- Space Used
SELECT OBJECT_NAME(dm_db_partition_stats.object_id) AS TableName,
	indexes.name AS IndexName,
	dm_db_partition_stats.row_count AS RowCnt,
	dm_db_partition_stats.used_page_count AS UsedPgs, 
	(dm_db_partition_stats.used_page_count * 8.0) / 1024 AS UsedMB,
	SUM(dm_db_partition_stats.used_page_count) OVER(PARTITION BY dm_db_partition_stats.object_id) TotalPgUsed,
	((SUM(dm_db_partition_stats.used_page_count) OVER(PARTITION BY dm_db_partition_stats.object_id))
	* 8.0) / 1024 AS TotalMB
FROM sys.dm_db_partition_stats 
INNER JOIN sys.indexes
	ON indexes.index_id = dm_db_partition_stats.index_id
	AND indexes.object_id = dm_db_partition_stats.object_id
WHERE dm_db_partition_stats.object_id = OBJECT_ID('dbo.InventoryFlat');




-----
-- Record the output
-- TotalPagesUsed: xxxx
-- TotalMB: xxxx








-----
-- What about Transaction Log Overhead?
--
-- Execute DML Workload & record before output
-- Repeat after making changes
SET STATISTICS TIME ON;

BEGIN TRANSACTION
	EXEC Workload.sp_DealershipDMLWorkload 
		@NumToLoop = 1

		SELECT database_transaction_log_bytes_used
		FROM sys.dm_tran_database_transactions
		WHERE database_id = DB_ID('AutoDealershipDemo');

COMMIT TRANSACTION

/*
-- Record output below

SELECT 1.0 - (After_TLogBytes / (Before_TLogBytes * 1.0)) AS PctDifference
SELECT 1.0 - (After_TLogBytes / (Before_TLogBytes * 1.0)) AS PctDifference

SELECT 1.0 - (After_ElapsedTime / (Before_ElapsedTime * 1.0)) AS PctDifference
SELECT 1.0 - (After_ElapsedTime / (Before_ElapsedTime * 1.0)) AS PctDifference

--SELECT 1.0 - (After_TLogBytes / (Before_TLogBytes * 1.0)) AS PctDifference
--SELECT 1.0 - (After_ElapsedTime / (Before_ElapsedTime * 1.0)) AS PctDifference

*/