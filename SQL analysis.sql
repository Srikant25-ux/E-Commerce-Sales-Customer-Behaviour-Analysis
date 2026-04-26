CREATE TABLE superstore (
    order_id        TEXT,
    order_date      DATE,
    ship_date       DATE,
    ship_mode       TEXT,
    customer_id     TEXT,
    customer_name   TEXT,
    segment         TEXT,
    city            TEXT,
    state           TEXT,
    region          TEXT,
    product_id      TEXT,
    category        TEXT,
    sub_category    TEXT,          
    product_name    TEXT,
    sales           NUMERIC(12,2),
    quantity        INTEGER,
    discount        NUMERIC(5,2),
    profit          NUMERIC(12,2)
);

copy superstore FROM 'C:\Program Files\PostgreSQL\18\cleaned_superstore.csv'
WITH (FORMAT csv, HEADER true);

select * from superstore;

--- 1. Revenue by category.
select category, sum(sales*quantity) as revenue
from superstore 
group by category
order by sum(sales*quantity);

--- 2. Revenue by region.
select region, sum(sales*quantity) as revenue
from superstore 
group by region
order by sum(sales*quantity);

--- 3. Average Profit by Product Category.
SELECT category, AVG(profit)
FROM superstore
GROUP BY category
ORDER BY category DESC; --- We can observe technology category is the most profitable.

--- 4. Identifying Loss-Making Sub-Categories Driven by Discounting Strategy.
SELECT sub_category,
    (discount*100.0) as discount,
    AVG(profit) AS avg_profit
FROM superstore
GROUP BY discount,sub_category
HAVING AVG(profit) < 0
ORDER BY discount;

--- 5. Analying revenue increasing and decreasing over Month over Month.

WITH CTE AS(SELECT DATE_TRUNC('month',order_date) as month,
        SUM(sales*quantity) as revenue
		FROM superstore
		GROUP BY month
		ORDER BY month),

	CTE_2 AS(SELECT month,revenue,
	LAG(revenue)OVER(ORDER BY revenue) AS prev_rev
	FROM CTE),

    CTE_3 AS(SELECT *, 
    CASE 
	    WHEN revenue > prev_rev THEN 'increasing'
		WHEN revenue < prev_rev THEN 'decreasing'
		ELSE 'No_change' END AS Trends
	FROM CTE_2
	ORDER BY revenue)

	SELECT trends,COUNT(*) as COUNT
	FROM CTE_3
	GROUP BY trends
	ORDER BY COUNT DESC; --- We can observe that revenue is increasing over Month over Month. 
	
--- 6. Which months perform best?

SELECT DATE_TRUNC('month',order_date) as month,
sum(sales*quantity) AS revenue
FROM superstore
GROUP BY month
ORDER BY revenue DESC;

--- 7. Customer Retention & Churn Analysis.
WITH CTE AS(
SELECT customer_id,COUNT(DISTINCT order_id) AS orders
FROM superstore
GROUP BY customer_id)

SELECT customer_id,
CASE WHEN orders > 1 THEN 'regular_cust'
     ELSE 'one_time_cust' END as cust_type
	 FROM CTE; 	  

--- 8. Is company making profit?
 SELECT 
    SUM(profit) AS total_profit,
    CASE 
        WHEN SUM(profit) > 0 THEN 'Yes - Business is Profitable'
        WHEN SUM(profit) < 0 THEN 'No - Business is in Loss'
        ELSE 'Break Even'
    END AS profit_status
FROM superstore;  --- We can observe that company is in profit.

--- 9. Top 10 loss-making products?

SELECT product_id, AVG(profit) as prod_avg
FROM superstore
GROUP BY product_id
HAVING AVG(profit) < 0
ORDER BY prod_avg
LIMIT 10;

--- 10. Does discount reduce profit?

SELECT 
    CASE 
        WHEN discount = 0 THEN 'No Discount'
        WHEN discount <= 0.2 THEN 'Low Discount'
        WHEN discount <= 0.5 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_range,
    COUNT(*) AS total_orders,
    ROUND(AVG(profit), 2) AS avg_profit
FROM superstore
GROUP BY discount_range
ORDER BY avg_profit DESC; --- We can observe that high and medium discounts reduces profit.


SELECT category, discount, AVG(profit) AS avg_profit
FROM superstore
GROUP BY 1,2
HAVING AVG(profit)<0;





















