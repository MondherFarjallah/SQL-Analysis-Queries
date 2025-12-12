# FoodMart SQL Analysis Queries

This repository contains a collection of SQL queries I wrote to practice data analysis on the **FoodMart** sample data warehouse. The goal of this project is to strengthen my ability to explore a star-schema dataset using **joins**, **filters**, **time-based conditions**, **GROUP BY/HAVING**, and **conditional aggregation**.

## What I worked on
Using the FoodMart schema (facts + dimensions), I created queries to answer business-style questions such as:
- Finding customers in a specific city with name patterns (e.g., starts with “M” and ends with “y”)
- Listing products purchased under specific customer constraints (e.g., female customers + cost threshold)
- Retrieving products purchased in specific years and for specific brands
- Detecting products purchased under a specific promotion with different thresholds across years
- Identifying customers who purchased certain categories in specific months/years
- Counting “active customers” per store city in a given period
- Reporting customer gender counts by store country
- Monthly customer segmentation based on purchasing breadth (distinct product categories)

## Skills demonstrated
- Working with a **star schema** (fact table + dimensions)
- Multi-table **JOINs** (customer, product, time, promotion, store, product_class)
- **Date / year / month** filtering via the time dimension
- **Aggregations** with `GROUP BY`, `HAVING`, and `COUNT(DISTINCT ...)`
- Business logic translation into SQL (thresholds, promotion constraints, category constraints)

## Tech
- SQL (FoodMart / data warehouse style schema)
- Tested in environments that support `USE FoodMart;` (e.g., MySQL/MariaDB-style syntax)

## How to run
1. Load the FoodMart database into your SQL environment.
2. Open the `.sql` file in this repo.
3. Run the script query-by-query (or all at once) after:
   ```sql
   USE FoodMart;
