use FoodMart;
/*
List firstname, surname and occupation of customers in Burnaby with a name starting with "M" and finishing with
"y"
*/
SELECT fname , lname , occupation
FROM customer
WHERE fname  LIKE 'M%y' AND city = 'Burnaby'
/*
List the products bought by only woman customers with a store cost > 2.00
*/
SELECT product.product_name
FROM product
JOIN sales_fact ON product.product_id = sales_fact.product_id
JOIN customer ON sales_fact.customer_id = customer.customer_id
WHERE customer.gender = 'female' AND sales_fact.store_cost > 2.00;
/*
List of products (ID and name of the product) bought in 1998 and belonging to the brand "Washington" or
"Bravo".
*/
SELECT product.product_id, product.product_name
FROM sales_fact
JOIN product ON sales_fact.product_id = product.product_id
JOIN time_by_day ON sales_fact.time_id = time_by_day.time_id
WHERE brand_name  IN ('Washington', 'Bravo') AND time_by_day.the_year = 1998;
/*
List the products bought only in 1998
*/
SELECT product.product_id, product.product_name,time_by_day.the_year 
FROM sales_fact
JOIN product ON sales_fact.product_id = product.product_id
JOIN time_by_day ON sales_fact.time_id = time_by_day.time_id
WHERE time_by_day.the_year = 1998;
  /*
List the products (indicating the code and the name) bought with the promotion "Price Winners" and that in 1997
have been bought at least once with store sales > 15.00, while in 1998 with store sales > 10.00.
*/          
SELECT product.product_id, product.product_name
FROM product
JOIN sales_fact ON product.product_id = sales_fact.product_id
JOIN time_by_day ON sales_fact.time_id = time_by_day.time_id
JOIN promotion ON sales_fact.promotion_id = promotion.promotion_id
WHERE promotion.promotion_name = 'Price Winners'
AND ((time_by_day.the_year = 1997 AND sales_fact.store_sales > 15.00)
OR (time_by_day.the_year = 1998 AND sales_fact.store_sales > 10.00))
GROUP BY product.product_id, product.product_name
HAVING COUNT(DISTINCT time_by_day.the_year) = 2;
 /*
List customers (indicating the firstname, surname, and number of children) who bought products of the category
"Fruit" in January 1997 or "Seafood" January 1998.
*/  
SELECT customer.fname, customer.lname, customer.num_children_at_home
FROM customer
JOIN sales_fact ON customer.customer_id = sales_fact.customer_id
JOIN product ON sales_fact.product_id = product.product_id
JOIN product_class ON product.product_class_id = product_class.product_class_id
JOIN time_by_day ON sales_fact.time_id = time_by_day.time_id
WHERE (time_by_day.the_year = 1997 AND product_class.product_category = 'Fruit'
      AND time_by_day.the_month = 1)
OR (time_by_day.the_year = 1998 AND product_class.product_category = 'Seafood'
    AND time_by_day.the_month = 1)
GROUP BY customer.customer_id, customer.fname, customer.lname, customer.num_children_at_home;
/*
List store cities with at least 100 active customers in September 1998
*/  

SELECT store.store_city, COUNT(DISTINCT customer.account_num) AS active_customers
FROM store
JOIN sales_fact ON store.store_id = sales_fact.store_id
JOIN time_by_day ON sales_fact.time_id = time_by_day.time_id
JOIN customer ON sales_fact.account_num = customer.account_num
WHERE time_by_day.the_year = 1998 AND time_by_day.the_month = 9
GROUP BY store.store_city
HAVING active_customers >= 100;
/*
List for each store country the number of female customers and the number of male customers. Order the result
with respect to the store country.
*/  
SELECT store.store_country,
       SUM(CASE WHEN customer.gender = 'female' THEN 1 ELSE 0 END) AS female_customers,
       SUM(CASE WHEN customer.gender = 'male' THEN 1 ELSE 0 END) AS male_customers
FROM store
JOIN customer ON store.store_id = customer.store_id
GROUP BY store.store_country
ORDER BY store.store_country;
/*
For each month provide the number of distinct customers who bought at least 10 distinct product categories
*/  
SELECT time_by_day.the_month,
       time_by_day.the_year,
       COUNT(DISTINCT customer.customer_id) AS distinct_customers
FROM sales_fact
JOIN time_by_day ON sales_fact.time_id = time_by_day.time_id
JOIN customer ON sales_fact.customer_id = customer.customer_id
JOIN (
  SELECT customer_id, COUNT(DISTINCT product_category) AS num_categories
  FROM sales_fact
  JOIN product ON sales_fact.product_id = product.product_id
  GROUP BY product_category 
  HAVING product_category  >= 10
) customer_categories ON customer.customer_id = customer_categories.customer_id
GROUP BY time_by_day.the_month, time_by_day.the_year
ORDER BY time_by_day.the_year, time_by_day.the_month;

