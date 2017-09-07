USE AutoDealershipDemo;
GO

-------------------------------------------------------------------------------------
-- Cross-Reference Missing Index DMVs with Cached Plans
--
-- Purpose: Explore Cached Plan Statements & associated Missing Index suggestions
--
-- Source:
-- http://bradsruminations.blogspot.com/2011/04/index-tuning-detective.html
-------------------------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

WITH xmlnamespaces (
	DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'
)
SELECT 
	Impact, 
	IxDB + '.' + IxSchema + '.' + IxTable AS TableName, 
	KeyCols, 
	IncludeCols, 
	IndexCommand, 
	usecounts, 
	size_in_bytes, 
	objtype, 
	BatchCode, 
	qp.query_plan AS QueryPlan
FROM sys.dm_exec_cached_plans qs 
CROSS APPLY	--Get the Query Text
	sys.dm_exec_sql_text(qs.plan_handle) qt             
CROSS APPLY	--Get the Query Plan
	sys.dm_exec_query_plan(qs.plan_handle) qp
CROSS APPLY	(--Get the Code for the Batch in Hyperlink Form
	SELECT (
		SELECT 
			[processing-instruction(q)] = ':' + NCHAR(13) + qt.text + NCHAR(13) FOR XML PATH(''), TYPE
	) AS BatchCode
) F_Code
CROSS APPLY	--Find the Missing Indexes Group Nodes in the Plan
	qp.query_plan.nodes('//MissingIndexes/MissingIndexGroup') F_GrpNodes(GrpNode)
CROSS APPLY (	--Pull out the Impact Figure
	SELECT 
		GrpNode.value('(./@Impact)', 'float') AS Impact
) F_Impact
CROSS APPLY	--Get the Missing Index Nodes from the Group
	GrpNode.nodes('(./MissingIndex)') F_IxNodes(IxNode)
CROSS APPLY	(	--Pull out the Database, Schema, Table of the Missing Index
	SELECT 
		IxNode.value('(./@Database)', 'sysname') AS IxDB, 
		IxNode.value('(./@Schema)', 'sysname') AS IxSchema, 
		IxNode.value('(./@Table)', 'sysname') AS IxTable
) F_IxInfo
CROSS APPLY (
	--How many INCLUDE columns are there;
	--And how many EQUALITY/INEQUALITY columns are there?
	SELECT 
		IxNode.value('count(./ColumnGroup[@Usage="INCLUDE"]/Column)', 'int') AS NumIncludes, 
		IxNode.value('count(./ColumnGroup[@Usage!="INCLUDE"]/Column)', 'int') AS NumKeys
) F_NumIncl
CROSS APPLY (	--Pull out the Key Columns and the Include Columns from the various Column Groups
	SELECT 
		MAX(CASE WHEN USAGE='EQUALITY' THEN ColList END) AS EqCols, 
		MAX(CASE WHEN USAGE='INEQUALITY' THEN ColList END) AS InEqCols, 
		MAX(CASE WHEN USAGE='INCLUDE' THEN ColList END) AS IncludeCols
	FROM IxNode.nodes('(./ColumnGroup)') F_ColGrp(ColGrpNode)
	CROSS APPLY	(	--Pull out the Usage of the Group? (EQUALITY of INEQUALITY or INCLUDE)
		SELECT ColGrpNode.value('(./@Usage)', 'varchar(20)') AS USAGE
	) F_Usage
	CROSS APPLY (	--Get a comma-delimited list of the Column Names in the Group
		SELECT STUFF((
			SELECT ', ' + ColNode.value('(./@Name)', 'sysname')
			FROM ColGrpNode.nodes('(./Column)') F_ColNodes(ColNode)
			FOR XML PATH('')
		), 1, 1, '') AS ColList
	) F_ColList
) F_ColGrps
CROSS APPLY (	--Put together the Equality and InEquality Columns
	SELECT 
		ISNULL(EqCols, '')
		+ CASE 
			WHEN EqCols IS NOT NULL AND InEqCols IS NOT NULL 
				THEN ', ' 
			ELSE '' 
		END
		+ ISNULL(InEqCols, '') AS KeyCols
	) F_KeyCols
CROSS APPLY (	--Construct a CREATE INDEX command
	SELECT 
		'CREATE INDEX <InsertNameHere> ON '
		+ IxDB + '.' + IxSchema + '.' + IxTable + ' ('
		+ KeyCols + ')'
		+ ISNULL(' INCLUDE (' + IncludeCols + ')', '') AS IndexCommand
) F_Cmd
WHERE qs.cacheobjtype = 'Compiled Plan'
ORDER BY 2, 3, 4, Impact DESC;
GO

