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
     
   --Warehouse Tables
CREATE TABLE warehouse.dim_customers (
    Customer_ID INT PRIMARY KEY);

CREATE TABLE warehouse.dim_accounts (
    Account_ID INT PRIMARY KEY,
    Customer_ID INT);

CREATE TABLE warehouse.dim_channel (
    Channel_ID INT PRIMARY KEY,
    Channel_Name VARCHAR(50));

CREATE TABLE warehouse.dim_region (
    Region_ID INT PRIMARY KEY,
    Region_Name VARCHAR(50));

CREATE TABLE warehouse.dim_date (
    Date_ID INT PRIMARY KEY,
    Full_Date DATE,
    Day INT,
    Month INT,
    Year INT,
    Quarter INT,
    Weekday VARCHAR(10));
    
    --Creating Fact Table
    CREATE TABLE warehouse.fact_transactions (
    Transaction_ID INT PRIMARY KEY,
    Customer_ID INT,
    Account_ID INT,
    Date_ID INT,
    Channel_ID INT,
    Region_ID INT,
    Transaction_Type VARCHAR(50),
    Currency VARCHAR(10),
    Amount DECIMAL(18,2),
    Balance_Before DECIMAL(18,2),
    Balance_After DECIMAL(18,2),
    Fraud_Flag INT,
    Risk_Score DECIMAL(5,3));