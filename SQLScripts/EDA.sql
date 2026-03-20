CREATE OR ALTER VIEW analytics.vw_transaction_kpis AS
WITH transaction_summary AS (
    SELECT 
        d.Year,
        d.Month,
        COUNT(*) AS total_transactions,
        SUM(f.Amount) AS total_amount,
        AVG(f.Amount) AS avg_amount,
        SUM(CASE WHEN f.Fraud_Flag = 1 THEN 1 ELSE 0 END) AS fraud_count
    FROM warehouse.fact_transactions f
    JOIN warehouse.dim_date d ON f.Date_ID = d.Date_ID
    GROUP BY d.Year, d.Month)
SELECT *,
    CAST(fraud_count * 100.0 / total_transactions AS DECIMAL(5,2)) AS fraud_percentage
FROM transaction_summary;
GO

CREATE OR ALTER VIEW analytics.vw_risk_segmentation 
AS
SELECT 
    f.Transaction_ID,
    f.Amount,
    f.Risk_Score,
    CASE
        WHEN f.Risk_Score >= 0.8 THEN 'High Risk'
        WHEN f.Risk_Score >= 0.5 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Category,
    d.Year,
    d.Month,
    c.Channel_Name,
    r.Region_Name
FROM warehouse.fact_transactions f
JOIN warehouse.dim_date d ON f.Date_ID = d.Date_ID
JOIN warehouse.dim_channel c ON f.Channel_ID = c.Channel_ID
JOIN warehouse.dim_region r ON f.Region_ID = r.Region_ID;
GO

CREATE OR ALTER VIEW analytics.vw_customer_behavior AS
WITH customer_sums AS (
    SELECT
        f.Customer_ID,
        d.Year,
        d.Month,
        SUM(f.Amount) AS total_amount_per_month,
        COUNT(f.Transaction_ID) AS total_transactions,
        SUM(SUM(f.Amount)) OVER(PARTITION BY f.Customer_ID ORDER BY d.Full_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rolling_total
    FROM warehouse.fact_transactions f
    JOIN warehouse.dim_date d ON f.Date_ID = d.Date_ID
    GROUP BY f.Customer_ID, d.Year, d.Month, d.Full_Date
)
SELECT
    Customer_ID,
    Year,
    Month,
    rolling_total,
    total_transactions,
    RANK() OVER(PARTITION BY Month ORDER BY total_amount_per_month DESC) AS monthly_rank
FROM customer_sums;
GO


CREATE OR ALTER VIEW analytics.vw_channel_region_performance AS
SELECT
    c.Channel_Name,
    r.Region_Name,
    d.Year,
    d.Month,
    COUNT(f.Transaction_ID) AS total_transactions,
    SUM(f.Amount) AS total_amount,
    AVG(f.Risk_Score) AS avg_risk_score
FROM warehouse.fact_transactions f
JOIN warehouse.dim_channel c ON f.Channel_ID = c.Channel_ID
JOIN warehouse.dim_region r ON f.Region_ID = r.Region_ID
JOIN warehouse.dim_date d ON f.Date_ID = d.Date_ID
GROUP BY c.Channel_Name, r.Region_Name, d.Year, d.Month;
GO

CREATE OR ALTER VIEW analytics.vw_fraud_trends AS
WITH monthly_fraud AS (
    SELECT 
        d.Year,
        d.Month,
        COUNT(*) AS fraud_count
    FROM warehouse.fact_transactions f
    JOIN warehouse.dim_date d ON f.Date_ID = d.Date_ID
    WHERE f.Fraud_Flag = 1
    GROUP BY d.Year, d.Month
)
SELECT 
    Year,
    Month,
    fraud_count,
    LAG(fraud_count) OVER(ORDER BY Year, Month) AS prev_month_fraud,
    fraud_count - LAG(fraud_count) OVER(ORDER BY Year, Month) AS fraud_change
FROM monthly_fraud;
GO

CREATE OR ALTER VIEW analytics.vw_dashboard_metrics AS
SELECT 
    t.Year,
    t.Month,
    t.total_transactions,
    t.total_amount,
    t.avg_amount,
    t.fraud_count,
    CASE WHEN t.total_transactions = 0 THEN 0
         ELSE CAST(t.fraud_count AS FLOAT) / t.total_transactions * 100
    END AS fraud_percentage,
    cr.total_amount AS channel_region_total,
    cr.avg_risk_score AS channel_region_avg_risk
FROM analytics.vw_transaction_kpis t
LEFT JOIN (
    SELECT Year, Month, SUM(total_amount) AS total_amount, AVG(avg_risk_score) AS avg_risk_score
    FROM analytics.vw_channel_region_performance
    GROUP BY Year, Month
) cr
ON t.Year = cr.Year AND t.Month = cr.Month;