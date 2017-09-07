----------------------------------------------
-- CREATE Indexes against dbo.InventoryFlat
--
-- Starting Indexes
----------------------------------------------
USE AutoDealershipDemo;
GO

-- Drop PE specific Missing Index
IF EXISTS (
	SELECT 1 FROM sys.indexes WHERE name = 'PE_SalesHistory_SalesPersonID' AND object_ID = OBJECT_ID('AutoDealershipDemo.dbo.SalesHistory')
)
	DROP INDEX [PE_SalesHistory_SalesPersonID] ON [AutoDealershipDemo].[dbo].[SalesHistory]
GO

IF EXISTS (
	SELECT 1 FROM sys.indexes WHERE name = 'IXF_InventoryFlat_SoldNotNull' AND object_ID = OBJECT_ID('dbo.InventoryFlat')
)
	DROP INDEX IXF_InventoryFlat_SoldNotNull ON [AutoDealershipDemo].[dbo].[InventoryFlat]
GO

IF EXISTS (
	SELECT 1 FROM sys.indexes WHERE name = 'IXF_InventoryFlat_ColorName_Black' AND object_ID = OBJECT_ID('dbo.InventoryFlat')
)
	DROP INDEX IXF_InventoryFlat_ColorName_Black ON [AutoDealershipDemo].[dbo].[InventoryFlat]
GO

IF EXISTS (
	SELECT 1 FROM sys.indexes WHERE name = 'IXF_InventoryFlat_Sold' AND object_ID = OBJECT_ID('dbo.InventoryFlat')
)
	DROP INDEX IXF_InventoryFlat_Sold ON [AutoDealershipDemo].[dbo].[InventoryFlat]
GO

IF EXISTS (
	SELECT 1 FROM sys.indexes WHERE name = 'IXF_InventoryFlat_Unsold' AND object_ID = OBJECT_ID('dbo.InventoryFlat')
)
	DROP INDEX IXF_InventoryFlat_Unsold ON [AutoDealershipDemo].[dbo].[InventoryFlat]
GO



-- Quick Reset -> remove all NCL's from InventoryFlat
DECLARE @SQLCmd NVARCHAR(4000);
DECLARE rsExe CURSOR FAST_FORWARD FOR 
	SELECT 'DROP INDEX InventoryFlat.' + name + ';' AS SQLCmd
	FROM sys.indexes
	WHERE indexes.object_id = OBJECT_ID(N'dbo.InventoryFlat')
		AND indexes.type = 2	-- Nonclustered Indexes
		AND indexes.is_primary_key = 0

OPEN rsExe

FETCH NEXT 
	FROM rsExe INTO @SQLCmd 

WHILE @@FETCH_STATUS = 0
	BEGIN
	-- Do Stuff
	EXEC sp_executesql @SQLCmd 

	FETCH NEXT 
 		FROM rsExe INTO @SQLCmd 
	END  
CLOSE rsExe
DEALLOCATE rsExe
GO


CREATE NONCLUSTERED INDEX IX_InventoryFlat_DateReceived
	ON dbo.InventoryFlat (
		DateReceived
	);

CREATE NONCLUSTERED INDEX IX_InventoryFlat_Sold
	ON dbo.InventoryFlat (
		Sold
	);

CREATE NONCLUSTERED INDEX IX_InventoryFlat_ModelName
	ON dbo.InventoryFlat (
		ModelName
	);

CREATE NONCLUSTERED INDEX IX_InventoryFlat_SoldPrice
	ON dbo.InventoryFlat (
		SoldPrice
	);

CREATE NONCLUSTERED INDEX IX_InventoryFlat_Sold_SoldPrice
	ON dbo.InventoryFlat (
		Sold
	)
	INCLUDE (
		SoldPrice
	);

CREATE NONCLUSTERED INDEX IX_InventoryFlat_ModelName_MSRP
	ON dbo.InventoryFlat (
		ModelName
	)
	INCLUDE (
		MSRP
	);

CREATE NONCLUSTERED INDEX IX_InventoryFlat_ModelName_MSRP_InvoicePrice
	ON dbo.InventoryFlat (
		ModelName
	)
	INCLUDE (
		MSRP, InvoicePrice
	);

CREATE NONCLUSTERED INDEX IX_InventoryFlat_MSRP_InvoicePrice_TrueCost
	ON dbo.InventoryFlat (
		MSRP, InvoicePrice, TrueCost
	)
	INCLUDE (
		ModelName, PackageName, MakeName
	);

CREATE NONCLUSTERED INDEX IX_InventoryFlat_Sold_VIN_InventoryFlatID
	ON dbo.InventoryFlat (
		Sold, VIN, InventoryFlatID
	);

CREATE NONCLUSTERED INDEX IX_InventoryFlat_Sold_VIN
	ON dbo.InventoryFlat (
		Sold, VIN
	)
	INCLUDE (
		InventoryFlatID
	);

CREATE NONCLUSTERED INDEX IX_InventoryFlat_VIN_Sold
	ON dbo.InventoryFlat (
		VIN, Sold
	);

CREATE NONCLUSTERED INDEX IXF_InventoryFlat_SoldNotNull
	ON dbo.InventoryFlat (
		VIN, SoldPrice, MakeName, ModelName, PackageName
	)
	WHERE Sold IS NOT NULL;


CREATE NONCLUSTERED INDEX IXF_InventoryFlat_ColorName_Black
	ON dbo.InventoryFlat (
		VIN, SoldPrice, MakeName, ModelName, PackageName
	)
	WHERE ColorName = 'Black';


/*
CREATE NONCLUSTERED INDEX IX_InventoryFlat_
	ON dbo.InventoryFlat (
	)
	INCLUDE (
	);
*/