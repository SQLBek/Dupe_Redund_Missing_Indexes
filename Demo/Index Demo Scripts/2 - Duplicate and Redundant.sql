USE AutoDealershipDemo;
GO




-----
-- First Query all indexes in dbo.InventoryFlat
EXEC sp_SQLSkills_helpindex 'dbo.InventoryFlat';
GO








-----
-- Save Off output of sp_SQLSkills_helpindex
IF OBJECT_ID('tempdb.dbo.#tmpHelpIndex') IS NOT NULL
	DROP TABLE #tmpHelpIndex;

CREATE TABLE #tmpHelpIndex (
	RecID INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,
	index_id INT,
	is_disabled BIT,
	index_name VARCHAR(256),
	index_description VARCHAR(500),
	index_keys VARCHAR(4000),
	included_columns VARCHAR(4000),
	filter_definition VARCHAR(4000),
	columns_in_tree VARCHAR(4000),
	columns_in_leaf VARCHAR(4000)
)
INSERT INTO #tmpHelpIndex (
	index_id,
	is_disabled,
	index_name,
	index_description,
	index_keys,
	included_columns,
	filter_definition,
	columns_in_tree,
	columns_in_leaf
)
EXEC sp_SQLSkills_helpindex 'dbo.InventoryFlat';
GO








-----
-- Look at subset of output, sorted by index keys
SELECT 
	#tmpHelpIndex.index_name,
	#tmpHelpIndex.index_keys,
	#tmpHelpIndex.included_columns,
	#tmpHelpIndex.index_description
FROM #tmpHelpIndex
WHERE index_description LIKE 'nonclustered%'
ORDER BY index_keys, included_columns, index_name
GO




-----
-- Recommendations for Consolidation?








-----
-- Did you consider actual B-Tree Structure?
SELECT 
	#tmpHelpIndex.index_name,
	#tmpHelpIndex.columns_in_tree,
	#tmpHelpIndex.columns_in_leaf,
	#tmpHelpIndex.index_keys,
	#tmpHelpIndex.included_columns
FROM #tmpHelpIndex
WHERE index_description LIKE 'nonclustered%'
	AND #tmpHelpIndex.index_keys LIKE '%\[Sold\]%' ESCAPE '\'
ORDER BY index_keys








-----
-- Did whomever created these indexes, know that the Clustering Key 
-- is also serialized with the Index Keys?  
