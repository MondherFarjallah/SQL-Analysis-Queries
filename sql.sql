--Total sales by store_country, product_family, quarter
SELECT pc.product_family, s.store_country, tbd.quarter, SUM(sf.store_sales) as total_sales
FROM sales_fact sf 
JOIN store s ON s.store_id = sf.store_id
JOIN product p ON p.product_id = sf.product_id 
JOIN product_class pc ON pc.product_class_id = p.product_class_id 
JOIN time_by_day tbd ON tbd.time_id = sf.time_id
GROUP BY pc.product_family, s.store_country, tbd.quarter 


--Slice of Ex. 1 for the_day = ‘Monday’, and ordered by decreasing total sales
SELECT pc.product_family, s.store_country, tbd.quarter, SUM(sf.store_sales) as total_sales
FROM sales_fact sf 
JOIN store s ON s.store_id = sf.store_id
JOIN product p ON p.product_id = sf.product_id 
JOIN product_class pc ON pc.product_class_id = p.product_class_id 
JOIN time_by_day tbd ON tbd.time_id = sf.time_id
WHERE tbd.the_day = 'Monday'
GROUP BY pc.product_family, s.store_country, tbd.quarter 
ORDER BY total_sales DESC


--Ex. 1 with subtotals by store_country, product_family and by store_country and with grandtotal
SELECT pc.product_family, s.store_country, tbd.quarter, SUM(sf.store_sales) as total_sales
FROM sales_fact sf 
JOIN store s ON s.store_id = sf.store_id
JOIN product p ON p.product_id = sf.product_id 
JOIN product_class pc ON pc.product_class_id = p.product_class_id 
JOIN time_by_day tbd ON tbd.time_id = sf.time_id
GROUP BY ROLLUP(pc.product_family, s.store_country, tbd.quarter)



--Ex. 1 plus additional columns:
--1. Rank wrt store_country ordered by decreasing total sales
SELECT pc.product_family, s.store_country, tbd.quarter, SUM(sf.store_sales) as total_sales,
RANK() OVER(PARTITION BY s.store_country ORDER BY SUM(sf.store_sales) DESC) as rango
FROM sales_fact sf 
JOIN store s ON s.store_id = sf.store_id
JOIN product p ON p.product_id = sf.product_id 
JOIN product_class pc ON pc.product_class_id = p.product_class_id 
JOIN time_by_day tbd ON tbd.time_id = sf.time_id
GROUP BY pc.product_family, s.store_country, tbd.quarter

WITH q1 AS (
SELECT pc.product_family, s.store_country, tbd.quarter, SUM(sf.store_sales) as total_sales
FROM sales_fact sf 
JOIN store s ON s.store_id = sf.store_id
JOIN product p ON p.product_id = sf.product_id 
JOIN product_class pc ON pc.product_class_id = p.product_class_id 
JOIN time_by_day tbd ON tbd.time_id = sf.time_id
GROUP BY pc.product_family, s.store_country, tbd.quarter
)

SELECT *, RANK() OVER(PARTITION BY q1.store_country ORDER BY total_sales DESC) as rango
FROM q1

--2. Row number wrt product_family ordered by total sales
SELECT pc.product_family, s.store_country, tbd.quarter, SUM(sf.store_sales) as total_sales,
ROW_NUMBER() OVER(PARTITION BY pc.product_family ORDER BY SUM(sf.store_sales) DESC) as rango
FROM sales_fact sf 
JOIN store s ON s.store_id = sf.store_id
JOIN product p ON p.product_id = sf.product_id 
JOIN product_class pc ON pc.product_class_id = p.product_class_id 
JOIN time_by_day tbd ON tbd.time_id = sf.time_id
GROUP BY pc.product_family, s.store_country, tbd.quarter

--3. Percentage wrt total store_country sales
WITH q1 as (
SELECT pc.product_family, s.store_country, tbd.quarter, SUM(sf.store_sales) as total_sales
FROM sales_fact sf 
JOIN store s ON s.store_id = sf.store_id
JOIN product p ON p.product_id = sf.product_id 
JOIN product_class pc ON pc.product_class_id = p.product_class_id 
JOIN time_by_day tbd ON tbd.time_id = sf.time_id
GROUP BY pc.product_family, s.store_country, tbd.quarter )

SELECT *, 100*total_sales/sum(total_sales) OVER(PARTITION BY store_country) as perc
FROM q1

--4. Percentage over previous quarter wrt store_country, product_family
WITH q1 as (
SELECT pc.product_family, s.store_country, tbd.quarter, SUM(sf.store_sales) as total_sales
FROM sales_fact sf 
JOIN store s ON s.store_id = sf.store_id
JOIN product p ON p.product_id = sf.product_id 
JOIN product_class pc ON pc.product_class_id = p.product_class_id 
JOIN time_by_day tbd ON tbd.time_id = sf.time_id
GROUP BY pc.product_family, s.store_country, tbd.quarter ),

q2 AS (
SELECT *, LAG(total_sales,1, 0) OVER(PARTITION BY store_country, product_family ORDER BY quarter) as previous_total
FROM q1)

SELECT *, CASE previous_total WHEN 0 THEN Null ELSE ((total_sales/previous_total)*100) END as percent_difference
FROM q2


--Output for every city in USA the difference in total sales between 1998 and 1997
with q1998 as (
select st.store_city, sum(sf.store_sales) as total_city_1998
from [dbo].[sales_fact] as sf join
[dbo].[time_by_day] as t on sf.time_id = t.time_id join
[dbo].[store] as st on sf.store_id = st.store_id
where t.the_year = '1998' and st.store_country = 'USA'
group by st.store_city
),
q1997 as (
select st.store_city, sum(sf.store_sales) as total_city_1997
from [dbo].[sales_fact] as sf join
[dbo].[time_by_day] as t on sf.time_id = t.time_id join
[dbo].[store] as st on sf.store_id = st.store_id
where t.the_year = '1997' and st.store_country = 'USA'
group by st.store_city
)
select q1998.store_city, total_city_1998 - total_city_1997 as differenza98meno97
from q1998 join q1997 on q1998.store_city = q1997.store_city

WITH q1 AS (
select st.store_city, t.the_year, sum(sf.store_sales) as total_city
from sales_fact as sf join
time_by_day as t on sf.time_id = t.time_id join
store as st on sf.store_id = st.store_id
where (t.the_year = '1998' or t.the_year = '1997') and st.store_country = 'USA'
group by st.store_city, t.the_year
),
q2 as (
SELECT *, LAG(total_city,1,0) OVER (PARTITION BY store_city ORDER BY the_year ASC) as prev
FROM q1)
SELECT store_city, total_city - prev
FROM q2
WHERE the_year=1998


-- Output all store id, year, month number, n_new_customers
-- where the value n_new_customers is the number of distinct customer_id's that for a given store id, year, and month number had no purchases in the previous month.
WITH q1 AS (
SELECT DISTINCT sf.customer_id, sf.store_id, tbd.the_year,tbd.month_of_year, tbd.the_year*12+tbd.month_of_year as monthperyear
FROM sales_fact sf JOIN time_by_day tbd on sf.time_id = tbd.time_id 
),
q2 AS (
SELECT *, LAG(monthperyear,1,0) OVER(PARTITION BY customer_id,store_id ORDER BY monthperyear) prev
FROM Q1)
SELECT store_id, monthperyear/12 as the_year, monthperyear%12 as the_month, count(*) as n_new_customers
FROM q2
WHERE monthperyear - 1 <> prev
GROUP BY store_id, monthperyear
ORDER BY store_id, monthperyear


