-------------------------------------------------------------------------------
-- DEMO 1: Introducing the Tools
--
-------------------------------------------------------------------------------
USE AutoDealershipDemo;
GO

-----
-- Query to show data
SELECT TOP 1000 *
FROM dbo.InventoryFlat;
GO








---------------------------------------
-- sp_help
---------------------------------------
EXEC sp_help 'dbo.InventoryFlat';
GO








---------------------------------------
-- sp_helpindex
---------------------------------------
EXEC sp_helpindex 'dbo.InventoryFlat';
GO








---------------------------------------
-- sp_SQLSkills_helpindex
--
-- Reference: 
-- http://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
---------------------------------------
EXEC sp_SQLSkills_helpindex 'dbo.InventoryFlat';
GO








-----
-- SSMS Keyboard Shortcuts are AWESOME!








---------------------------------------
-- sys.dm_db_index_usage_stats
---------------------------------------
SELECT *
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID();
GO








---------------------------------------
-- sys.dm_db_missing_index_groups
-- sys.dm_db_missing_index_group_stats
-- sys.dm_db_missing_index_details
---------------------------------------
SELECT *
FROM sys.dm_db_missing_index_groups;

SELECT *
FROM sys.dm_db_missing_index_group_stats;

SELECT *
FROM sys.dm_db_missing_index_details;
GO
