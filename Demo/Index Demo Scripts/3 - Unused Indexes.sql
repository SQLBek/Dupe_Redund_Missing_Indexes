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
ORDER BY databases.name, schemas.name, objects.name, indexes.type_desc, indexes.is_primary_key DESC, indexes.name;
GO








-----
-- What about Query Store?
-- Thanks Kendra Little!
-- https://littlekendra.com/2017/01/24/how-to-find-queries-using-an-index-and-queries-using-index-hints/
SELECT
    qsq.query_id,
    qsq.query_hash,
    (SELECT TOP 1 qsqt.query_sql_text FROM sys.query_store_query_text qsqt
        WHERE qsqt.query_text_id = MAX(qsq.query_text_id)) AS sqltext,    
    SUM(qrs.count_executions) AS execution_count,
    SUM(qrs.count_executions) * AVG(qrs.avg_logical_io_reads) as est_logical_reads,
    SUM(qrs.count_executions) * AVG(qrs.avg_logical_io_writes) as est_writes,
    MIN(qrs.last_execution_time AT TIME ZONE 'Eastern Standard Time') as min_execution_time_EST,
    MAX(qrs.last_execution_time AT TIME ZONE 'Eastern Standard Time') as last_execution_time_EST,
    SUM(qsq.count_compiles) AS sum_compiles,
    TRY_CONVERT(XML, (SELECT TOP 1 qsp2.query_plan from sys.query_store_plan qsp2
        WHERE qsp2.query_id=qsq.query_id
        ORDER BY qsp2.plan_id DESC)) AS query_plan
FROM sys.query_store_query qsq
JOIN sys.query_store_plan qsp on qsq.query_id=qsp.query_id
CROSS APPLY (SELECT TRY_CONVERT(XML, qsp.query_plan) AS query_plan_xml) AS qpx
JOIN sys.query_store_runtime_stats qrs on qsp.plan_id = qrs.plan_id
JOIN sys.query_store_runtime_stats_interval qsrsi on qrs.runtime_stats_interval_id=qsrsi.runtime_stats_interval_id
WHERE    
    qsp.query_plan like N'%CK_InventoryFlat_InventoryFlatID%'
    AND qsp.query_plan not like '%query_store_runtime_stats%' /* Not a query store query */
    AND qsp.query_plan not like '%dm_exec_sql_text%' /* Not a query searching the plan cache */
    AND qsp.query_plan not like '%_MS_UPDSTATS_TBL_HELPER%' /* Not a statistics update */
GROUP BY 
    qsq.query_id, qsq.query_hash
ORDER BY est_logical_reads DESC
OPTION (RECOMPILE);
GO








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
