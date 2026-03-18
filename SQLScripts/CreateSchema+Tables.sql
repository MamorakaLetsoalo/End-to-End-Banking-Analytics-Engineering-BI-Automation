CREATE DATABASE FinancialAnalyticsDB;
GO
USE FinancialAnalyticsDB;

--Creating Schemas
--raw data
CREATE SCHEMA staging;

--Structured data
CREATE SCHEMA warehouse;

--Reporting Layer
CREATE SCHEMA analytics;

--Creating Tables
--Stating table
CREATE TABLE staging.stg_transactions (
    Transaction_ID INT,
    Customer_ID INT,
    Account_ID INT,
    Transaction_Type VARCHAR(50),
    Channel VARCHAR(50),
    Currency VARCHAR(10),
    Amount DECIMAL(18,2),
    Transaction_Date DATE,
    Balance_Before DECIMAL(18,2),
    Balance_After DECIMAL(18,2),
    Fraud_Flag INT,
    Risk_Score DECIMAL(5,3),
    Region VARCHAR(50),
    Load_Date DATETIME DEFAULT GETDATE());
     
    