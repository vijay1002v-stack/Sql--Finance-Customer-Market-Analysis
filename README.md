# SQL Finance Customer & Market Analytics

## Project Overview

**Project Title**: Finance Customer & Market Analytics
**Database**: `gdb0041_db`

This project focuses on analyzing sales and financial data using SQL to generate business insights. It involves calculating gross sales, pre-invoice deductions, post-invoice deductions, and net sales, followed by identifying top-performing markets, products, and customers.

The project demonstrates strong SQL fundamentals along with advanced concepts like Stored Procedures, Views, CTEs, Window Functions, and performance optimization.

## Business Objectives

**1.Generate monthly product-level sales reports for Croma India (FY 2021).**

**2.Calculate Gross Sales for customers**

**3.Implement Fiscal Year logic (September–August)**

**4.Compute Pre-invoice and Post-invoice deductions**

**5.Calculate Net Invoice Sales and Net Sales**

**6.Identify Top Markets, Products, and Customers based on Net Sales**

**7.Classify markets as Gold or Silver based on total sold quantity**


## Technical Concepts Used

 **1.User Defined Function (UDF).**

 **2.Stored Procedures.**

 **3.Common Table Expressions (CTE).**

 **4.SQL Views.**

 **5.Window Functions.**

 **6.Aggregations & Group By.**

 **7.Performance Optimization.**


## Key Implementations

## 1.Fiscal Year Function.

**Created a UDF to calculate Fiscal Year using April as the starting month.**

## 2.Monthly Gross Sales Procedure.

**Built a stored procedure to calculate monthly gross sales for a given customer.**

## 3️.Market Badge Classification.

**Developed a stored procedure to classify markets.**

**Gold → Total Sold Quantity > 5 Million.**

**Silver → Otherwise.**

## 4️.Pre-Invoice & Post-Invoice Calculations.

**. * . Calculated gross price total.**

**. * Applied pre-invoice discount percentage.**

**. * Created view for post-invoice deductions.**

**. * Computed final Net Sales.**

## 5️.Top Performance Reports.

**. * Generated reports for.**

**. * Top Markets by Net Sales.**

**. * Top Products by Net Sales.**

**. * Top Customers by Net Sales,**

**. * Customer Contribution %.**

## Business Insights Generated

**1.Identified high-performing markets.**

**2.Measured customer revenue contribution.**

**3.Evaluated product-level profitability.**

**4.Enabled fiscal-year based reporting.**

**5.Improved query performance by removing scalar function dependency**


## Performance Optimization.

**1.Replaced scalar UDF calls with fiscal_year column.**

**2.Used CTE for modular query design.**

**3.Created Views for reusable discount logic.**

**4.Optimized joins to reduce execution time.**


## Skills Demonstrated.

**1.Advanced SQL Query Writing.**

**2.Data Transformation.**

**3.Financial Metrics Calculation.**

**4.Analytical Thinking.**

**5.Business-Oriented Data Modeling.**


## Conclusion

**This project simulates a real-world finance analytics use case where SQL is used to transform raw transactional data into meaningful business insights, supporting strategic decision-making.**
