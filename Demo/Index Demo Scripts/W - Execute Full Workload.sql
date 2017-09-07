USE AutoDealershipDemo;
GO

-----
-- Execute Query Workload
EXEC dbo.sp_DealershipWorkload 
	@NumToLoop = 3

-----
-- Execute DML Workload
EXEC dbo.sp_DealershipDMLWorkload 
	@NumToLoop = 1

-----
-- Execute Query Workload
EXEC dbo.sp_DealershipWorkload 
	@NumToLoop = 3

-----
-- Execute DML Workload
EXEC dbo.sp_DealershipDMLWorkload 
	@NumToLoop = 1