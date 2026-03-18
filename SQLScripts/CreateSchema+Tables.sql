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