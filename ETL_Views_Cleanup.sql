/*
  PROJECT: Telco & SaaS Retention Analytics
  FILE: 01_Data_Transformation_Logic.sql
  AUTHOR: Vaibhav Pant
  DESCRIPTION: 
      - Creates SQL Views to normalize raw data.
      - Handles type casting (Text -> Float/Date).
      - segments customers into 'Tenure Brackets'.
      - Calculates 'Profit Margin' at the row level.
*/
USE ChurnProject;
GO

-- 1. Create a Clean View for SaaS Sales (Advanced Version)
CREATE OR ALTER VIEW vw_SaaSData_Cleaned AS
SELECT 
    Order_ID,
    -- Turning the 'Date_Key' (e.g. 20221109) into a real SQL Date
    TRY_CAST(CAST(Date_Key AS VARCHAR) AS DATE) AS Order_Date,
    Customer,
    Customer_ID,
    Industry,
    Region,
    Country,
    Product,
    -- Handling the data types and potential NULLs
    TRY_CAST(Sales AS FLOAT) AS Sales_Amount,
    TRY_CAST(Quantity AS INT) AS Quantity_Sold,
    TRY_CAST(Profit AS FLOAT) AS Profit_Amount,
    -- Advanced Column: Profit Margin %
    CASE 
        WHEN TRY_CAST(Sales AS FLOAT) <= 0 THEN 0 
        ELSE (TRY_CAST(Profit AS FLOAT) / TRY_CAST(Sales AS FLOAT)) 
    END AS Profit_Margin
FROM SaaSData;
GO

-- 2. Create the Clean View for Churn Analysis
CREATE OR ALTER VIEW vw_ChurnData_Cleaned AS
SELECT 
    customerID,
    gender,
    SeniorCitizen,
    Contract,
    InternetService,
    tenure,
    -- Create 'Tenure Brackets' for advanced segmenting
    CASE 
        WHEN tenure <= 12 THEN '0-1 Year'
        WHEN tenure <= 24 THEN '1-2 Years'
        WHEN tenure <= 48 THEN '2-4 Years'
        ELSE 'Over 4 Years'
    END AS Tenure_Bracket,
    TRY_CAST(NULLIF(TotalCharges, ' ') AS FLOAT) AS Total_Charges,
    TRY_CAST(MonthlyCharges AS FLOAT) AS Monthly_Charges,
    Churn
FROM ChurnData;
GO
/*
-- DATA QUALITY CHECKS (Run these to verify views)
-- 1. Check for negative profit margins (Potential data errors)
SELECT * FROM vw_SaaSData_Cleaned WHERE Profit_Margin < -1;

-- 2. Check total customer count matches raw source
SELECT COUNT(*) AS Clean_Count FROM vw_ChurnData_Cleaned;
*/