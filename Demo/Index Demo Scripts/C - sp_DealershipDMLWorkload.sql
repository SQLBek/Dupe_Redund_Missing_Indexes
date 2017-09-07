USE AutoDealershipDemo;
GO
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO
ALTER PROCEDURE dbo.sp_DealershipDMLWorkload (
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

		----------------------
		-- Garbage UPDATE to simulate
		-- DML operations
		UPDATE dbo.InventoryFlat
		SET VIN = VIN,
			MakeName = MakeName,
			ModelName = ModelName,
			PackageName = PackageName,
			ColorName = ColorName,
			PackageCode = PackageCode,
			ColorCode = ColorCode,
			TrueCost = TrueCost,
			InvoicePrice = InvoicePrice,
			MSRP = MSRP,
			DateReceived = DateReceived,
			Sold = Sold,
			SoldPrice = SoldPrice

		UPDATE dbo.InventoryFlat
		SET TrueCost = TrueCost + 0.1,
			InvoicePrice = InvoicePrice + 0.1,
			MSRP = MSRP + 0.1				

		SET @LoopCounter = @LoopCounter + 1;
	END

	
	-----
	-- Add more cars to simulate DML
	BEGIN
		SELECT @MaxInventoryFlatID = MAX(InventoryFlatID)
		FROM dbo.InventoryFlat;

		EXEC dbo.sp_Add_Automobile_Inventory 100;

		UPDATE dbo.InventoryFlat
		SET Sold = 1,
			SoldPrice = TrueCost + ((MSRP - TrueCost) * RAND()) 
		WHERE InventoryFlatID % ((CAST((RAND() * 10000) AS INT) % 13) + 1) = 1
			AND Sold = 0
			AND SoldPrice IS NULL
			AND InventoryFlatID >= @MaxInventoryFlatID
	END
END
GO