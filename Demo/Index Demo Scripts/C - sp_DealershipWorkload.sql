USE AutoDealershipDemo;
GO
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
ALTER PROCEDURE sp_DealershipWorkload (
	@NumToLoop INT = 1
)
WITH RECOMPILE
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON;
	DECLARE @ModValue INT,
		@ModValue2 INT,
		@ModValue3 INT,
		@ModelName VARCHAR(50),
		@PackageName VARCHAR(50),
		@ColorName VARCHAR(50),
		@MaxInventoryFlatID INT,
		@LoopCounter INT = 1;

	PRINT '--------------------------'
	PRINT 'Starting Workload'

	WHILE @LoopCounter <= @NumToLoop
	BEGIN
		PRINT '------'
		PRINT 'LoopCounter = ' + CAST(@LoopCounter AS VARCHAR(10))

		------------------------------------
		-- Unsold Models
		SELECT MakeName, ModelName, COUNT(1) AS MyCount
		INTO #tmpA
		FROM dbo.InventoryFlat
		WHERE Sold = 0
		GROUP BY MakeName, ModelName 
		ORDER BY MakeName, ModelName;


		------------------------------------
		-- Unsold Models by Age
		SELECT MakeName, ModelName, 
			CAST(CAST(YEAR(DateReceived) AS VARCHAR(10)) + '-' + CAST(MONTH(DateReceived) AS VARCHAR(10)) + '-01' AS DATE) AS MonthReceived,
			SUM(InvoicePrice) AS TotalInvoicePrice,
			COUNT(1) AS MyCount
		INTO #tmpB
		FROM dbo.InventoryFlat
		WHERE Sold = 0
		GROUP BY MakeName, ModelName, CAST(CAST(YEAR(DateReceived) AS VARCHAR(10)) + '-' + CAST(MONTH(DateReceived) AS VARCHAR(10)) + '-01' AS DATE)
		ORDER BY MakeName, ModelName, CAST(CAST(YEAR(DateReceived) AS VARCHAR(10)) + '-' + CAST(MONTH(DateReceived) AS VARCHAR(10)) + '-01' AS DATE)


		------------------------------------
		-- Sold Models by Age
		SELECT MakeName, ModelName, 
			CAST(CAST(YEAR(DateReceived) AS VARCHAR(10)) + '-' + CAST(MONTH(DateReceived) AS VARCHAR(10)) + '-01' AS DATE) AS MonthReceived,
			SUM(TrueCost) AS TotalTrueCost,
			SUM(MSRP) AS TotalMSRP,
			SUM(InvoicePrice) AS TotalInvoicePrice,
			SUM(SoldPrice) AS TotalSoldPrice,
			COUNT(1) AS MyCount
		INTO #tmpC
		FROM dbo.InventoryFlat
		WHERE Sold = 1
		GROUP BY MakeName, ModelName, CAST(CAST(YEAR(DateReceived) AS VARCHAR(10)) + '-' + CAST(MONTH(DateReceived) AS VARCHAR(10)) + '-01' AS DATE)
		ORDER BY MakeName, ModelName, CAST(CAST(YEAR(DateReceived) AS VARCHAR(10)) + '-' + CAST(MONTH(DateReceived) AS VARCHAR(10)) + '-01' AS DATE)


		------------------------------------
		-- Find all Inventory by ModelName: Query Method 1
		SELECT @ModValue = MAX(ModelID)
		FROM Vehicle.Model

		SELECT InventoryFlat.VIN,
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			InventoryFlat.ColorName,
			InventoryFlat.MSRP
		INTO #tmpD
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName IN (
			SELECT ModelName
			FROM Vehicle.Model
			WHERE Model.ModelID = (CAST((RAND() * 10000) AS INT) % @ModValue) + 1
		)
	

		------------------------------------
		-- Find all Inventory by ModelName: Query Method 2
		SELECT @ModValue = MAX(ModelID)
		FROM Vehicle.Model

		SELECT @ModelName = ModelName
		FROM Vehicle.Model
		WHERE Model.ModelID = (CAST((RAND() * 10000) AS INT) % @ModValue) + 1

		SELECT InventoryFlat.VIN,
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			InventoryFlat.ColorName,
			InventoryFlat.MSRP
		INTO #tmpE
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName = @ModelName

		SELECT InventoryFlat.VIN,
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			InventoryFlat.ColorName,
			InventoryFlat.MSRP
		INTO #tmpF
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName IN (
			SELECT ModelName
			FROM Vehicle.Model
			WHERE Model.ModelID = (CAST((RAND() * 10000) AS INT) % @ModValue) + 1
		)


		------------------------------------
		-- Find all Inventory by Color
		SELECT @ModValue = MAX(ColorID)
		FROM Vehicle.Color

		SELECT InventoryFlat.VIN,
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			InventoryFlat.ColorName,
			InventoryFlat.MSRP
		INTO #tmpG
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ColorName IN (
			SELECT ColorName
			FROM Vehicle.Color
			WHERE Color.ColorID = (CAST((RAND() * 10000) AS INT) % @ModValue) + 1
		)


		------------------------------------
		-- Find all Inventory by ModelName & Package
		SELECT @ModValue = MAX(ModelID)
		FROM Vehicle.Model

		SELECT @ModValue2 = MAX(PackageID)
		FROM Vehicle.Package

		SELECT @ModelName = ModelName
		FROM Vehicle.Model
		WHERE Model.ModelID = (CAST((RAND() * 10000) AS INT) % @ModValue) + 1

		SELECT @PackageName = PackageName
		FROM Vehicle.Package
		WHERE Package.PackageID = (CAST((RAND() * 10000) AS INT) % @ModValue2) + 1

		SELECT InventoryFlat.VIN,
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			InventoryFlat.ColorName,
			InventoryFlat.MSRP
		INTO #tmpH
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName = @ModelName
			AND InventoryFlat.PackageName = @PackageName

		SELECT InventoryFlat.VIN,
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			InventoryFlat.ColorName,
			InventoryFlat.MSRP
		INTO #tmpI
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName = @ModelName
			OR InventoryFlat.PackageName = @PackageName


		------------------------------------
		-- Profit By Model
		-- Sold Models by Age
		------------------------------------
		SELECT @ModValue = MAX(ModelID)
		FROM Vehicle.Model

		SELECT @ModelName = ModelName
		FROM Vehicle.Model
		WHERE Model.ModelID = (CAST((RAND() * 10000) AS INT) % @ModValue) + 1

		SELECT MakeName, ModelName, 
			SUM(SoldPrice) - SUM(TrueCost) AS TotalProfit,
			(SUM(SoldPrice) - SUM(TrueCost)) / COUNT(1) AS AvgProfit,
			COUNT(1) AS MyCount
		INTO #tmpJ
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName = @ModelName
			AND Sold = 1
		GROUP BY MakeName, ModelName


		------------------------------------
		-- Profit By Model
		SELECT @ModValue = MAX(ModelID)
		FROM Vehicle.Model

		SELECT @ModValue2 = MAX(PackageID)
		FROM Vehicle.Package

		SELECT @ModelName = ModelName
		FROM Vehicle.Model
		WHERE Model.ModelID = (CAST((RAND() * 10000) AS INT) % @ModValue) + 1

		SELECT @PackageName = PackageName
		FROM Vehicle.Package
		WHERE Package.PackageID = (CAST((RAND() * 10000) AS INT) % @ModValue2) + 1

		SELECT MakeName, ModelName, PackageName,
			SUM(SoldPrice) - SUM(TrueCost) AS TotalProfit,
			(SUM(SoldPrice) - SUM(TrueCost)) / COUNT(1) AS AvgProfit,
			COUNT(1) AS MyCount
		INTO #tmpK
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName = @ModelName
			AND InventoryFlat.PackageName = @PackageName
			AND Sold = 1
		GROUP BY MakeName, ModelName, PackageName


		SELECT MakeName, ModelName, PackageName,
			SUM(SoldPrice) - SUM(TrueCost) AS TotalProfit,
			(SUM(SoldPrice) - SUM(TrueCost)) / COUNT(1) AS AvgProfit,
			COUNT(1) AS MyCount
		INTO #tmpL
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName IN (
			SELECT ModelName
			FROM Vehicle.Model
			WHERE Model.ModelID = (CAST((RAND() * 10000) AS INT) % @ModValue) + 1
		)
			AND InventoryFlat.PackageName = @PackageName
			AND Sold = 1
		GROUP BY MakeName, ModelName, PackageName


		SELECT MakeName, ModelName, PackageName,
			SUM(SoldPrice) - SUM(TrueCost) AS TotalProfit,
			(SUM(SoldPrice) - SUM(TrueCost)) / COUNT(1) AS AvgProfit,
			COUNT(1) AS MyCount
		INTO #tmpM
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.PackageName IN (
			SELECT PackageName
			FROM Vehicle.Package
			WHERE Package.PackageID = (CAST((RAND() * 10000) AS INT) % @ModValue2) + 1
		)
			AND Sold = 1
		GROUP BY MakeName, ModelName, PackageName


		SELECT MakeName, ModelName, PackageName,
			SUM(SoldPrice) - SUM(TrueCost) AS TotalProfit,
			(SUM(SoldPrice) - SUM(TrueCost)) / COUNT(1) AS AvgProfit,
			COUNT(1) AS MyCount
		INTO #tmpN
		FROM dbo.InventoryFlat
		WHERE (
				InventoryFlat.ModelName = @ModelName
				OR InventoryFlat.PackageName = @PackageName
			)
			AND Sold = 1
		GROUP BY MakeName, ModelName, PackageName


		------------------------------------
		-- Try writing a query that would 
		-- generate more than one Missing
		-- Index recommendation
		--
		-- Additionally introduce an inequality
		SELECT @ModValue = MAX(ModelID)
		FROM Vehicle.Model

		SELECT @ModValue2 = MAX(PackageID)
		FROM Vehicle.Package

		SELECT @ModValue3 = MAX(ColorID)
		FROM Vehicle.Color

		SELECT @ModelName = ModelName
		FROM Vehicle.Model
		WHERE Model.ModelID = (CAST((RAND() * 10000) AS INT) % @ModValue) + 1

		SELECT @PackageName = PackageName
		FROM Vehicle.Package
		WHERE Package.PackageID = (CAST((RAND() * 10000) AS INT) % @ModValue2) + 1

		SELECT @ColorName = ColorName
		FROM Vehicle.Color
		WHERE Color.ColorID = (CAST((RAND() * 10000) AS INT) % @ModValue3) + 1

		SELECT 
			InventoryFlat.VIN,
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			InventoryFlat.ColorName,
			InventoryFlat.MSRP,
			InventoryFlat.SoldPrice
		INTO #tmpO
		FROM dbo.InventoryFlat 
		INNER JOIN (
			SELECT 
				InventoryFlat.VIN
			FROM dbo.InventoryFlat
			WHERE InventoryFlat.ModelName = @ModelName
				AND Sold = 1
		) SoldModelName
			ON SoldModelName.VIN = InventoryFlat.VIN
		INNER JOIN (
			SELECT 
				InventoryFlat.VIN
			FROM dbo.InventoryFlat
			WHERE InventoryFlat.PackageName = @PackageName
				AND Sold = 1
		) SoldPackageName
			ON SoldPackageName.VIN = InventoryFlat.VIN
		INNER JOIN (
			SELECT 
				InventoryFlat.VIN
			FROM dbo.InventoryFlat
			WHERE InventoryFlat.ColorName = @ColorName
				AND Sold = 1
		) SoldColorName
			ON SoldColorName.VIN = InventoryFlat.VIN


		SELECT 
			InventoryFlat.VIN,
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			InventoryFlat.ColorName,
			InventoryFlat.MSRP,
			InventoryFlat.SoldPrice
		INTO #tmpP
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName = @ModelName
			AND InventoryFlat.PackageName = @PackageName
			AND InventoryFlat.ColorName <> @ColorName
			AND Sold = 0



		SELECT 
			InventoryFlat.VIN,
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			InventoryFlat.ColorName,
			InventoryFlat.MSRP,
			InventoryFlat.SoldPrice
		INTO #tmpQ
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName = @ModelName
			AND InventoryFlat.PackageName <> @PackageName
			AND InventoryFlat.ColorName <> @ColorName
			AND Sold = 0


		SELECT 
			InventoryFlat.VIN,
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			InventoryFlat.ColorName,
			InventoryFlat.MSRP,
			InventoryFlat.SoldPrice
		INTO #tmpR
		FROM dbo.InventoryFlat
		WHERE InventoryFlat.ModelName = @ModelName
			AND InventoryFlat.PackageName <> @PackageName
			AND InventoryFlat.ColorName <> @ColorName
			AND Sold <> 1


		----------------------
		-- Let's try a query with
		-- an Avg Profit calculation
		SELECT 
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName,
			AVG(InventoryFlat.MSRP) AS AvgMSRP,
			AVG(InventoryFlat.SoldPrice) AS AvgSoldPrice,
			AVG(InventoryFlat.TrueCost) AS AvgTrueCost,
			(SUM(InventoryFlat.MSRP) - SUM(SoldPrice)) / COUNT(1) AS AvgDiscount,
			(SUM(SoldPrice) - SUM(TrueCost)) / COUNT(1) AS AvgProfit,
			SUM(SoldPrice) - SUM(TrueCost) AS TotalProfit
		INTO #tmpS
		FROM dbo.InventoryFlat
		WHERE Sold = 1
		GROUP BY 
			InventoryFlat.MakeName,
			InventoryFlat.ModelName,
			InventoryFlat.PackageName

		DROP TABLE #tmpA;
		DROP TABLE #tmpB;
		DROP TABLE #tmpC;
		DROP TABLE #tmpD;
		DROP TABLE #tmpE;
		DROP TABLE #tmpF;
		DROP TABLE #tmpG;
		DROP TABLE #tmpH;
		DROP TABLE #tmpI;
		DROP TABLE #tmpJ;
		DROP TABLE #tmpK;
		DROP TABLE #tmpL;
		DROP TABLE #tmpM;
		DROP TABLE #tmpN;
		DROP TABLE #tmpO;
		DROP TABLE #tmpP;
		DROP TABLE #tmpQ;
		DROP TABLE #tmpR;
		DROP TABLE #tmpS;
		--DROP TABLE #tmpT;
		--DROP TABLE #tmpU;

		SET @LoopCounter = @LoopCounter + 1;
	END
END
GO