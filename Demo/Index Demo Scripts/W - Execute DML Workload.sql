USE AutoDealershipDemo;
GO

-----
-- Execute DML Workload
EXEC dbo.sp_DealershipDMLWorkload 
	@NumToLoop = 5
GO