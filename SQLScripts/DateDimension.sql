SELECT TOP (10) [Transaction_ID]
      ,[Customer_ID]
      ,[Account_ID]
      ,[Transaction_Type]
      ,[Channel]
      ,[Currency]
      ,[Amount]
      ,[Transaction_Date]
      ,[Balance_Before]
      ,[Balance_After]
      ,[Fraud_Flag]
      ,[Risk_Score]
      ,[Region]
      ,[Load_Date]
  FROM [FinancialAnalyticsDB].[staging].[stg_transactions]
 
INSERT INTO warehouse.dim_date
SELECT DISTINCT
    (YEAR(Transaction_Date)*10000 + MONTH(Transaction_Date)*100 + DAY(Transaction_Date)),
    Transaction_Date,
    DAY(Transaction_Date),
    MONTH(Transaction_Date),
    YEAR(Transaction_Date),
    DATEPART(QUARTER, Transaction_Date),
    DATENAME(WEEKDAY, Transaction_Date)
FROM staging.stg_transactions;
