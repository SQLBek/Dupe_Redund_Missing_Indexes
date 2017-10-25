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
-- By: by Kimberly Tripp Randal
-- Reference: 
-- http://www.sqlskills.com/blogs/kimberly/category/sp_helpindex-rewrites/
---------------------------------------
EXEC sp_SQLSkills_helpindex 'dbo.InventoryFlat';
GO








-----
-- SSMS Keyboard Shortcuts are AWESOME!








---------------------------------------
-- sys.dm_db_index_usage_stats
--
-- Provides Index Usage Information
-- Reference:
-- https://msdn.microsoft.com/en-us/library/ms188755.aspx
---------------------------------------
SELECT *
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID();
GO








---------------------------------------
-- sys.dm_db_missing_index_groups
-- sys.dm_db_missing_index_group_stats
-- sys.dm_db_missing_index_details
--
-- Reference: 
-- https://msdn.microsoft.com/en-us/library/ms345434.aspx
---------------------------------------
SELECT *
FROM sys.dm_db_missing_index_groups;

SELECT *
FROM sys.dm_db_missing_index_group_stats;

SELECT *
FROM sys.dm_db_missing_index_details;
GO




---------------------------------------
-- What the Missing Index DMVs Miss
-- 
-- Recommendation has limited scope
-- Column Order presented is not accurate
-- Limited capacity: 500 index groups max
-- Less accurate with inequality predicates
--
-- Reference: 
-- https://technet.microsoft.com/en-us/library/ms345485%28v=sql.105%29.aspx
---------------------------------------