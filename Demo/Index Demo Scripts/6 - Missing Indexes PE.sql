USE AutoDealershipDemo
GO
SET STATISTICS TIME ON
SET STATISTICS IO ON
GO




-----
-- Report Query for Sales Information, for select Sales People
-- Turn on Actual Execution Plan
SELECT 
	SalesPerson.LastName, SalesPerson.FirstName,
	Vw_VehicleBaseModel.ModelName, Vw_VehicleBaseModel.ColorName,
	Inventory.VIN, Inventory.MSRP, Inventory.InvoicePrice, Inventory.DateReceived,
	SalesHistory.TransactionDate, SalesHistory.SellPrice, SalesPerson.Email
FROM dbo.Inventory
INNER JOIN dbo.Vw_VehicleBaseModel
	ON Vw_VehicleBaseModel.BaseModelID = Inventory.BaseModelID
INNER JOIN dbo.SalesHistory
	ON SalesHistory.InventoryID = Inventory.InventoryID
INNER JOIN dbo.SalesPerson
	ON SalesPerson.SalesPersonID = SalesHistory.SalesPersonID
WHERE SalesHistory.TransactionDate > '2014-01-01'
	AND Inventory.DateReceived > '2013-01-01'
	AND SalesPerson.LastName IN (
		'Randall', 'Martin', 'Baker', 'Kane', 'Liu', 
		'Brown', 'Johnson', 'Miller', 'Hill'
	)
ORDER BY 
	SalesPerson.LastName, SalesPerson.FirstName, 
	Vw_VehicleBaseModel.ModelName, Vw_VehicleBaseModel.ColorName, 
	Inventory.DateReceived, SalesHistory.TransactionDate;




-----
-- Check Missing Index Details in Execution PLan




-----
-- Open in Plan Explorer!








-----
-- How about this change?
IF EXISTS (
	SELECT 1 FROM sys.indexes WHERE name = 'PE_SalesHistory_SalesPersonID' AND object_ID = OBJECT_ID('[AutoDealershipDemo].[dbo].[SalesHistory]')
)
	DROP INDEX [PE_SalesHistory_SalesPersonID] ON [AutoDealershipDemo].[dbo].[SalesHistory]
GO

CREATE INDEX [PE_SalesHistory_SalesPersonID] 
	ON [AutoDealershipDemo].[dbo].[SalesHistory] (
		[SalesPersonID] ASC, [TransactionDate] ASC
	)
INCLUDE (
	[InventoryID], [SellPrice]
)
GO








-----
-- Notice multiple executions!








-----
-- Try it the other way?
IF EXISTS (
	SELECT 1 FROM sys.indexes WHERE name = 'PE_SalesHistory_SalesPersonID' AND object_ID = OBJECT_ID('[AutoDealershipDemo].[dbo].[SalesHistory]')
)
	DROP INDEX [PE_SalesHistory_SalesPersonID] ON [AutoDealershipDemo].[dbo].[SalesHistory]
GO

CREATE INDEX [PE_SalesHistory_SalesPersonID] 
	ON [AutoDealershipDemo].[dbo].[SalesHistory] (
		[TransactionDate] ASC, [SalesPersonID] ASC
	)
INCLUDE (
	[InventoryID], [SellPrice]
)
GO








-----
-- CLEAN UP
IF EXISTS (
	SELECT 1 FROM sys.indexes WHERE name = 'PE_SalesHistory_SalesPersonID' AND object_ID = OBJECT_ID('[AutoDealershipDemo].[dbo].[SalesHistory]')
)
	DROP INDEX [PE_SalesHistory_SalesPersonID] ON [AutoDealershipDemo].[dbo].[SalesHistory]
GO


