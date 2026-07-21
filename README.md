# NIFTY Sector Performance Analysis (2015–2026)

## Project Overview

The stock market is made up of multiple sectors, each responding differently to economic events, government policies, market sentiment, and industry specific developments. During different market cycles, some sectors consistently outperform while others lag behind, making sector level analysis an important part of understanding market behavior.

I built this project to analyze the long term performance of major NIFTY sector indices between 2015 and 2026 by creating a complete end-to-end analytics pipeline using MySQL and Power BI.

*Note: The dashboard is based on data available up to 25 June 2026, so metrics and rankings will evolve as new market data is added.

Instead of simply visualizing historical price data, I wanted to transform raw market data into meaningful financial insights. The project measures sector returns, volatility, benchmark performance, and investment growth, presenting the results through an interactive Power BI dashboard.

The complete workflow covers data collection, SQL-based ETL, database design, financial metric calculation, and dashboard development, demonstrating the entire analytics lifecycle from raw data to business insights.

---

# Business Problem

Investors often need answers to questions such as:

- Which sector generated the highest returns over a specific period?
- Which sector consistently outperformed the overall market?
- Which sectors carried the highest level of risk?
- How much would an investment have grown if it had been invested in a particular sector?
- Do overnight returns contribute more than intraday returns?
- Which sectors remained relatively stable during market downturns?

Answering these questions requires much more than historical price data. Before meaningful analysis can be performed, the data must be cleaned, transformed, normalized, and enriched with financial metrics.

To address this, I built a structured analytics pipeline that converts raw NSE market data into a reporting ready dataset capable of supporting investment analysis and business decision making.

---

# Project Objectives

The main objectives of this project were to:

- Analyze the historical performance of major NIFTY sector indices.
- Compare sector returns against the NIFTY 50 benchmark.
- Measure sector risk using financial metrics such as volatility and maximum drawdown.
- Build a reusable SQL ETL pipeline for transforming raw market data.
- Design a normalized relational database for efficient reporting.
-Develop an interactive Power BI dashboard for investment analysis.

Beyond answering these business questions, I also wanted to build a scalable analytics workflow where SQL handles data preparation and business logic, allowing Power BI to focus on visualization and interactive analysis.

---

# Dataset Collection

The historical market data used in this project was collected from the National Stock Exchange of India (NSE).

One challenge during data collection was that the NSE Historical Data portal exports price data for only one index at a time, so the entire dataset couldn't be downloaded in a single file.

Instead, I downloaded historical data separately for each of the following indices:

- NIFTY 50
- NIFTY AUTO
- NIFTY BANK
- NIFTY FMCG
- NIFTY IT
- NIFTY PHARMA

For each index, I collected daily trading data covering the period from 1 January 2015 to 25 June 2026.

Each CSV file contained the following information:

Column	Description
trade_date	Trading date
open_price	Opening price
high_price	Highest price of the day
low_price	Lowest price of the day
close_price	Closing price
shares_traded	Total shares traded
turnover_cr	Trading turnover (₹ Crores)

Since each downloaded file represented only one sector, I added an additional column called sector_name before combining the datasets. This allowed me to merge all six datasets while preserving the identity of each sector throughout the ETL pipeline.

After standardizing the structure of every CSV file, I combined them into a single consolidated dataset containing over 17,000 daily trading records, which became the foundation of the analytical database.

---

# Why NIFTY 50 was Chosen as the Benchmark

Looking at a sector's returns in isolation doesn't provide enough context. To understand whether a sector truly performed well, it needs to be compared against the broader market.

For that reason, I selected NIFTY 50 as the benchmark throughout this project.

NIFTY 50 represents the performance of fifty of the largest publicly traded companies listed on the National Stock Exchange across multiple industries, making it one of the most widely accepted benchmarks for the Indian equity market.

Using NIFTY 50 as a benchmark allowed me to determine whether a sector:

Outperformed the market
Underperformed the market
Generated positive excess returns
Delivered stronger long-term growth than the benchmark

These comparisons form the basis of several key dashboard metrics, including:

- Benchmark Return %
- Excess Return %
- Benchmark Indexed Performance
- Benchmark CAGR

---

# Technology Stack

| Component | Technology |
|-----------|------------|
| Database | MySQL |
| ETL | SQL |
| Data Cleaning | Excel |
| Data Visualization | Power BI |
| Analytics | DAX |
| Version Control | GitHub |

Each tool was selected for a specific role within the project. I used MySQL because I wanted to centralize all data preparation and financial calculations before the data reached Power BI. So Power BI was used to create interactive dashboards and dynamic visualizations. Keeping the responsibilities of each tool separate made the overall solution easier to maintain and extend.

---

# Project Architecture

I designed the project as a simple analytics pipeline where raw NSE data is progressively transformed into reporting-ready information before being visualized in Power BI.

<img width="1920" height="720" alt="project architecture" src="https://github.com/user-attachments/assets/e4064d89-0d43-4a7b-bff0-a93334f9ea1c" />

Instead of connecting Power BI directly to the raw database tables, I centralized all data preparation and business logic inside SQL and exposed the final dataset through a reporting view. This approach keeps the Power BI model lightweight, avoids duplicate calculations, and ensures that every report uses the same business logic.

---

# Database Design

I built a simple data warehouse consisting of a staging table, a dimension table, a fact table, and a reporting view.

Each database object has a specific role within the ETL pipeline, making the overall workflow easier to maintain, debug, and extend.

<img width="1920" height="720" alt="database schema" src="https://github.com/user-attachments/assets/10f73bd8-ccf4-4481-8f4a-80fd438c21c6" />

---

# ETL Pipeline

The following workflow shows how the raw NSE data moves through each stage of the ETL process before becoming a reporting ready dataset.

<img width="1813" height="868" alt="etl pipeline" src="https://github.com/user-attachments/assets/7bf7ddfe-982c-49e2-8480-33d04de1af53" />

---

# Staging Layer

I started the ETL process by importing the raw CSV files into a staging table named **stg_sector_prices**.

```sql
LOAD DATA INFILE ...
```

Instead of loading the data directly into the analytical tables, I used a staging table as a temporary landing zone for the raw data. This allowed me to validate and prepare the dataset before moving it into the warehouse.

Using a staging layer provides several advantages:

- Separates raw imported data from production tables.
- Allows data validation before transformation.
- Makes the ETL process repeatable.
- Simplifies debugging when import issues occur.
- Prevents accidental corruption of analytical data.

Since the staging table mirrors the structure of the imported CSV files, no financial calculations are performed at this stage. Its sole purpose is to receive and temporarily store the raw market data.

---

# Handling Missing Values During Import

While importing the historical NSE data, I noticed that the Shares Traded and Turnover columns occasionally contained blank values.

Instead of importing blank strings directly into numeric columns, I used SQL to convert them into NULL values during the import process.

```sql
SET
shares_traded = NULLIF(@shares_traded,''),
turnover_cr = NULLIF(@turnover_cr,'');
```

This prevents conversion errors and ensures that numeric calculations and aggregate functions work correctly later in the pipeline.

---

# Import Timestamp

To keep track of when data was imported, I added an additional column to the staging table:
```text
load_timestamp
```

This column is automatically populated using:

```sql
CURRENT_TIMESTAMP
```

Although this project currently performs full data loads, storing the import timestamp creates a simple audit trail by recording when each dataset entered the warehouse.

It also makes the database easier to extend in the future if I decide to implement incremental loading strategies.

---

# Dimension Table

To avoid storing sector names repeatedly for every trading day, I created a dimension table called **dim_sector**, where each sector is assigned a unique identifier.

| sector_id | sector_name |
|-----------|-------------|
| 1 | NIFTY 50 |
| 2 | NIFTY AUTO |
| 3 | NIFTY BANK |
| 4 | NIFTY FMCG |
| 5 | NIFTY IT |
| 6 | NIFTY PHARMA |

This follows the principles of database normalization.
Instead of storing values such as:

```text
NIFTY BANK
```

thousands of times in the price table, only the corresponding **sector_id** is stored.

Using surrogate keys provides several advantages:

- Reduces data redundancy.
- Improves storage efficiency.
- Maintains referential integrity.
- Simplifies joins between tables.
- Makes future updates easier.

---

# Fact Table

The cleaned and validated trading data is stored in the **fact_sector_prices** table.

Each record represents the trading activity of a single sector on a specific trading day.

The table stores:

- Trade Date
- Sector ID
- Open Price
- High Price
- Low Price
- Close Price
- Shares Traded
- Turnover

Unlike the staging table, the fact table contains only production ready data.

Each record references **dim_sector** through a foreign key relationship, creating a simple star schema that is well suited for analytical reporting.

---

# Data Transformation

Once the raw data was loaded into the staging table, I used SQL to populate the fact table.

Instead of inserting sector names directly, the ETL process converts each **sector_name** into its corresponding **sector_id** by joining the staging table with the dimension table.

```sql
FROM stg_sector_prices s
INNER JOIN dim_sector d
ON s.sector_name = d.sector_name
```

The **INNER JOIN** performs a lookup against the dimension table and replaces the textual sector name with its numeric identifier before inserting the record into the fact table.

This keeps the analytical database normalized while preserving the relationship between the fact and dimension tables.

---

# Preventing Duplicate Records

Since the ETL process may be executed multiple times, I added safeguards to prevent duplicate records from being inserted into the fact table.

A **UNIQUE** constraint is created on the combination of:

trade_date
sector_id

This ensures that only one record can exist for each sector on a given trading day.

In addition, the INSERT statement performs a duplicate check using:

```sql
WHERE NOT EXISTS (...)
```

before inserting each record.

Using both techniques helps maintain data integrity while making the ETL pipeline safe to run multiple times without creating duplicate entries.

---

# Reporting View

Instead of exposing the raw database tables directly to Power BI, I created a reporting view called **vw_sector_prices_enriched**.

This view joins the fact table with the sector dimension using an **INNER JOIN**, allowing Power BI to work with descriptive sector names instead of numeric foreign keys.

More importantly, the reporting view acts as the single source of truth for the entire dashboard. By moving the joins and financial calculations into SQL, I kept the Power BI data model much simpler and ensured that all reports use the same business logic.

The view exposes the following calculated fields:

- Previous Closing Price
- Daily Return
- Overnight Return
- Intraday Return

As a result, Power BI receives a clean, analysis ready dataset without requiring additional joins or data transformations.

---

# Financial Return Calculations

Rather than calculating financial return metrics inside Power BI, I chose to compute them directly within SQL.

Keeping these calculations in the database centralizes the business logic and reduces the amount of transformation required in the reporting layer.

To calculate the return metrics, I first retrieved each sector's previous trading day's closing price using SQL's **LAG()** window function.

```sql
LAG(close_price)
OVER
(
    PARTITION BY sector_id
    ORDER BY trade_date
)
```

Partitioning by **sector_id** ensures that each sector's historical price data is processed independently, allowing the previous closing price to be calculated correctly for every sector.

Once the previous closing price is available, it is used to calculate three key financial return metrics.

### Daily Return

It measures the percentage change between the previous trading day's closing price and the current day's closing price.

This metric forms the foundation for several dashboard calculations, including annualized volatility.

---

### Overnight Return

It measures the percentage return generated between the previous trading day's closing price and the current day's opening price.

This helps identify price movements that occur outside trading hours due to factors such as overnight news, earnings announcements, or global market events.

---

### Intraday Return

It measures the percentage return generated during the trading session by comparing the opening and closing prices of the same trading day.

Together, these three metrics provide a more complete picture of how sector returns are generated over time.

---

# Why Returns Were Calculated in SQL

One of the key design decisions in this project was to calculate all financial return metrics in SQL rather than Power BI.

I chose this approach for several reasons:

- Business logic remains centralized in one location.
- Every reporting tool uses the same calculations.
- Power BI can focus on visualization instead of data preparation.
- SQL window functions provide efficient access to historical observations.
- The reporting view can be reused by future analytical applications without rewriting the calculations.

Separating data preparation from visualization results in a cleaner, more scalable, and easier-to-maintain analytics workflow.

# Power BI Dashboard

After completing the ETL pipeline and creating the reporting view, I connected Power BI directly to **vw_sector_prices_enriched** to build the interactive dashboard.

Instead of importing multiple SQL tables into Power BI, I used the reporting view as the single data source. Since the joins and financial calculations were already handled in SQL, the Power BI data model remained simple and focused entirely on analysis.

Using the reporting view provides several advantages:

- All joins are already handled within SQL.
- Financial return metrics are pre calculated.
- Sector names are available without additional lookups.
- Business logic stays centralized inside the database.
- Power BI can focus entirely on visualization and analytical calculations.

I also created a separate **Date Table** in Power BI to support time intelligence functions, slicers, and year-based analysis.

---

# DAX Measures

While SQL handles the data preparation and financial calculations, I used DAX to create dynamic measures that respond to user selections within the dashboard.

The dashboard includes measures such as:

- Period Return
- CAGR
- Benchmark Return
- Excess Return
- Benchmark CAGR
- Indexed Performance
- Maximum Drawdown
- Volatility
- Investment Growth
- Portfolio Value
- Profit
- Sector Ranking

These measures automatically update based on the selected date range, sector, and year, allowing users to explore the data interactively without modifying the underlying dataset.

---

# Power BI Data Model

I designed the Power BI data model as a simple star schema, with the SQL reporting view serving as the central fact table.

<img width="1920" height="720" alt="powerbi data model" src="https://github.com/user-attachments/assets/ab659df5-d675-412c-ace2-19d32190e2c6" />

The model consists of:

- **vw_sector_prices_enriched**: Central reporting table imported from MySQL containing historical prices and calculated return metrics.
- **dim_sector**: Dimension table used for sector filtering.
- **Date_Table**: Calendar dimension supporting time intelligence calculations and date-based filtering.
- **Investment Amount**: Disconnected parameter table used to simulate different investment amounts.
- **Measures**: Dedicated measure table containing all DAX calculations, including CAGR, Period Return, Volatility, Maximum Drawdown, Portfolio Value, and Benchmark metrics.

Relationships:

- `dim_sector[sector_id]` → `vw_sector_prices_enriched[sector_id]` (1:*)

- `Date_Table[Date]` → `vw_sector_prices_enriched[trade_date]` (1:*)

The **Investment Amount** table remains intentionally disconnected because it acts as a parameter table rather than filtering transactional data.

---

# Dashboard Design

The dashboard is divided into four analytical pages, each designed to answer a different business question.

---

## Executive Overview

The Executive Overview page provides a high level summary of sector performance for the selected time period.

Instead of requiring users to navigate through multiple reports, I designed this page to bring together the most important financial metrics in a single dashboard. This gives users a quick overview of how a selected sector has performed before they explore the more detailed analysis pages.

<img width="721" height="405" alt="1_Executive" src="https://github.com/user-attachments/assets/cb57e64c-67b0-45ad-8144-50f8344d1346" />

### Key Features

- Period Return
- Benchmark Return
- Excess Return
- CAGR
- Annualized Volatility
- Maximum Drawdown

In addition to the KPI cards, the dashboard includes several supporting visuals that help explain the overall performance.

### Sector Performance vs NIFTY 50

This visual compares the indexed growth of the selected sector against the **NIFTY 50** benchmark over time, making it easy to see whether the sector outperformed or underperformed the broader market.

### Sector Return Ranking

Ranks all sectors based on their total returns for the selected period, allowing users to quickly identify the best and worst performing sectors.

### Risk vs Return

Compares annualized volatility with total returns to help identify sectors that delivered stronger returns without taking on proportionally higher risk.

Overall, this page is designed to answer the question:

> **"How well did this sector perform compared to the overall market?"**

---

## Performance Analysis

The Performance Analysis page focuses on comparing the long-term growth of each sector and identifying performance trends across different market conditions.

<img width="721" height="404" alt="2_Performance" src="https://github.com/user-attachments/assets/7ab06b95-196e-452f-aba7-92943bf86b22" />

### Annual Performance Heatmap

This visual displays yearly sector returns using conditional formatting, making strong and weak years easy to identify at a glance.

The heatmap highlights:

- Bull market periods
- Market corrections
- Recovery phases
- Consistency of sector performance over time

### Indexed Sector Performance

Normalizes every sector to a common starting value, allowing users to compare cumulative growth over the selected time period regardless of their original index values.

### Average Overnight vs Intraday Return

Compares the average returns generated:

- Outside market hours
- During trading sessions

This helps determine whether a sector's performance is primarily driven by overnight price movements or by trading activity during market hours.

### Sector CAGR Comparison

Compares the Compound Annual Growth Rate (CAGR) of each sector against the benchmark CAGR, making it easier to evaluate long-term growth relative to the overall market.

This page primarily answers the question:

> **"Which sectors delivered the strongest long-term growth?"**

---

## Risk Analysis

Strong returns don't always indicate a good investment. To better understand performance, it's equally important to evaluate the level of risk involved.

<img width="721" height="406" alt="3_Risk" src="https://github.com/user-attachments/assets/35e20173-9045-4f91-af36-167bf8a54fa3" />

The Risk Analysis page focuses on helping users compare both return and risk across different sectors.

### Sector Risk Summary

This section provides a consolidated view of the key risk metrics for every sector, including:

- CAGR
- Annualized Volatility
- Maximum Drawdown

This makes it easy to compare long-term performance alongside the level of risk taken to achieve those returns.

### Maximum Drawdown

Measures the largest percentage decline from a historical peak.

This metric helps users understand the maximum loss an investment could have experienced during major market downturns.

### Volatility

Displays annualized volatility calculated using daily returns.

Higher volatility generally indicates greater price fluctuations and, therefore, a higher level of investment risk.

Together, these visuals help answer the question:

> **"Which sectors generated returns while maintaining acceptable levels of risk?"**

---

## Investment Simulator

The final page extends the analysis beyond historical performance by turning the dashboard into a simple investment planning tool.

<img width="722" height="406" alt="4_Investment" src="https://github.com/user-attachments/assets/2ff8e86d-7297-43e2-911a-fa1578ed51b0" />

Users can enter an initial investment amount using an interactive parameter, and the dashboard automatically calculates:

- Initial Investment
- Final Investment Value
- Total Profit
- Period Return

The Portfolio Value Over Time chart simulates how that investment would have grown historically if it had been invested in the selected sector.

Instead of presenting financial metrics alone, I wanted to show the practical impact of sector performance on a real investment. This makes it easier for users to understand how historical returns translate into actual portfolio growth.

This page answers the question:

> **"If I had invested in this sector, how much would my investment be worth today?"**

---

# SQL Analysis

In addition to building the dashboard, I wrote several SQL queries to validate the data and perform exploratory analysis before moving to the reporting stage.

These queries include:

### Data Validation

- Total imported records
- Date range verification
- Sector wise record counts
- Missing value detection
- Invalid price checks
- Sector mapping validation

Running these validation checks helped ensure that only clean and reliable data entered the reporting layer.

---

### Financial Analysis

SQL was also used to calculate summary statistics such as:

- Annualized Volatility
- Average Overnight Return
- Average Intraday Return

Performing these calculations directly in SQL demonstrates how analytical insights can be generated within the database before the data is visualized in Power BI.

---

# Repository Structure

```text
NIFTY-Sector-Performance-Analysis/
│
├── Dataset/
│
├── Images/
│
├── Power BI/
│
├── SQL/
│   ├── create_tables.sql
│   ├── load_data.sql
│   ├── create_views.sql
│   └── analysis_queries.sql
│
└── README.md
```

---

# Future Enhancements

There are several ways this project can be extended in the future, including:

- Automating data ingestion using scheduled ETL workflows.
- Expanding the analysis to include additional NIFTY sector indices.
- Integrating company-level stock data for more granular insights.
- Adding risk-adjusted performance metrics such as the Sharpe Ratio and Sortino Ratio.

These enhancements would make the project more automated, scalable, and suitable for more advanced financial analysis.

---

# Key Learnings

Building this project gave me hands on experience across the complete data analytics lifecycle, from collecting raw market data to designing an interactive reporting solution.

### Data Engineering

- Data Collection
- Data Cleaning
- SQL ETL Pipelines
- Relational Database Design
- Data Warehousing

### SQL

- Joins
- Window Functions
- Views
- Aggregate Analysis
- Data Validation
- Constraints
- Normalization

### Power BI

- Data Modeling
- DAX Measures
- Interactive Dashboards
- Time Intelligence
- Financial KPI Development

---

# Conclusion

This project demonstrates how raw financial market data can be transformed into meaningful business insights through a structured analytics workflow.

By combining SQL-based ETL, a normalized database design, financial calculations, and interactive Power BI visualizations, I built a scalable solution for evaluating sector performance, measuring investment risk, and comparing historical returns against the broader market benchmark.

One of my main goals was to clearly separate data preparation from reporting. SQL handles the ETL process, business logic, and financial calculations, while Power BI focuses on interactive analysis and visualization. This approach keeps the solution easier to maintain and ensures that the reporting layer works with clean, analysis-ready data.

The final dashboard allows users to explore historical sector performance, compare investment opportunities, understand risk, and simulate portfolio growth through an intuitive and interactive reporting experience.

---

## 👨‍💻 Author

**Narasimha Swaroop Revu**

B.Tech Computer Science & Engineering

Data Analytics | Excel | SQL | Power BI
