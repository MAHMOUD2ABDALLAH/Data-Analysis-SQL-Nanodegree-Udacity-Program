-- ==========================================
-- SQL Aggregations - Parch & Posey Database
-- ==========================================
-- This file covers the SQL Aggregations unit:
-- SUM, MIN, MAX, AVG, COUNT, GROUP BY, HAVING,
-- DISTINCT, date aggregations, CASE, and
-- additional aggregation concepts.

-- ==========================================
-- 1. SUM Solutions
-- ==========================================

-- Find the total amount of poster_qty paper ordered in the orders table.
SELECT SUM(poster_qty) AS total_poster_sales
FROM orders;

-- Find the total amount of standard_qty paper ordered in the orders table.
SELECT SUM(standard_qty) AS total_standard_sales
FROM orders;

-- Find the total dollar amount of sales using the total_amt_usd in the orders table.
SELECT SUM(total_amt_usd) AS total_dollar_sales
FROM orders;

-- Find the total amount for each individual order that was spent on standard
-- and gloss paper in the orders table. This should give a dollar amount for
-- each order in the table.
-- Note: This solution does NOT use an aggregate.
SELECT standard_amt_usd + gloss_amt_usd AS total_standard_gloss
FROM orders;

-- Though the price/standard_qty paper varies from one order to the next,
-- find this ratio across all of the sales made in the orders table.
-- Note: This solution uses both an aggregate and mathematical operators.
SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;


-- ==========================================
-- 2. MIN, MAX, and AVERAGE Solutions
-- ==========================================

-- When was the earliest order ever placed?
SELECT MIN(occurred_at)
FROM orders;

-- Try performing the same query as above without using an aggregation function.
SELECT occurred_at
FROM orders
ORDER BY occurred_at
LIMIT 1;

-- When did the most recent (latest) web_event occur?
SELECT MAX(occurred_at)
FROM web_events;

-- Try to perform the result of the previous query without using an aggregation function.
SELECT occurred_at
FROM web_events
ORDER BY occurred_at DESC
LIMIT 1;

-- Find the mean (AVERAGE) amount spent per order on each paper type,
-- as well as the mean amount of each paper type purchased per order.
-- Final answer has 6 values.
SELECT AVG(standard_qty)    AS mean_standard,
       AVG(gloss_qty)       AS mean_gloss,
       AVG(poster_qty)      AS mean_poster,
       AVG(standard_amt_usd) AS mean_standard_usd,
       AVG(gloss_amt_usd)    AS mean_gloss_usd,
       AVG(poster_amt_usd)   AS mean_poster_usd
FROM orders;

-- MEDIAN total_usd spent on all orders (advanced, hard-coded solution).
-- Standard SQL does not have a MEDIAN() aggregate function.
-- This subquery approach finds the two middle values for 6912 orders.
-- The median is the average of the 3456th and 3457th order amounts.
SELECT *
FROM (SELECT total_amt_usd
      FROM orders
      ORDER BY total_amt_usd
      LIMIT 3457) AS Table1
ORDER BY total_amt_usd DESC
LIMIT 2;

-- Note: In production, use PERCENTILE_CONT(0.5) (PostgreSQL/Oracle)
-- or APPROX_MEDIAN (some databases) instead of hard-coding.


-- ==========================================
-- 3. GROUP BY Solutions
-- ==========================================

-- Which account (by name) placed the earliest order?
-- Solution should have the account name and the date of the order.
SELECT a.name, o.occurred_at
FROM accounts a
JOIN orders o
ON a.id = o.account_id
ORDER BY occurred_at
LIMIT 1;

-- Find the total sales in usd for each account.
-- Two columns: total sales for each company's orders in usd and the company name.
SELECT a.name, SUM(total_amt_usd) total_sales
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.name;

-- Via what channel did the most recent (latest) web_event occur,
-- which account was associated with this web_event?
-- Return only three values: the date, channel, and account name.
SELECT w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
ORDER BY w.occurred_at DESC
LIMIT 1;

-- Find the total number of times each type of channel from the web_events was used.
-- Two columns: the channel and the number of times the channel was used.
SELECT w.channel, COUNT(*)
FROM web_events w
GROUP BY w.channel;

-- Who was the primary contact associated with the earliest web_event?
SELECT a.primary_poc
FROM web_events w
JOIN accounts a
ON a.id = w.account_id
ORDER BY w.occurred_at
LIMIT 1;

-- What was the smallest order placed by each account in terms of total usd.
-- Provide only two columns: the account name and the total usd.
-- Order from smallest dollar amounts to largest.
SELECT a.name, MIN(total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order;

-- Find the number of sales reps in each region.
-- Two columns: the region and the number of sales_reps.
-- Order from fewest reps to most reps.
SELECT r.name, COUNT(*) num_reps
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
GROUP BY r.name
ORDER BY num_reps;


-- ==========================================
-- 4. GROUP BY Part II Solutions
-- ==========================================

-- For each account, determine the average amount of each type of paper
-- they purchased across their orders. Result has four columns:
-- account name plus average quantity of each paper type.
SELECT a.name,
       AVG(o.standard_qty) avg_stand,
       AVG(o.gloss_qty)    avg_gloss,
       AVG(o.poster_qty)   avg_post
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;

-- For each account, determine the average amount spent per order on each
-- paper type. Result has four columns: account name plus average dollar
-- amount spent on each paper type.
SELECT a.name,
       AVG(o.standard_amt_usd) avg_stand,
       AVG(o.gloss_amt_usd)    avg_gloss,
       AVG(o.poster_amt_usd)   avg_post
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name;

-- Determine the number of times a particular channel was used in the
-- web_events table for each sales rep. Final table has three columns:
-- sales rep name, channel, and number of occurrences.
-- Ordered with the highest number of occurrences first.
SELECT s.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name, w.channel
ORDER BY num_events DESC;

-- Determine the number of times a particular channel was used in the
-- web_events table for each region. Final table has three columns:
-- region name, channel, and number of occurrences.
-- Ordered with the highest number of occurrences first.
SELECT r.name, w.channel, COUNT(*) num_events
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name, w.channel
ORDER BY num_events DESC;


-- ==========================================
-- 5. HAVING Solutions
-- ==========================================

-- How many of the sales reps have more than 5 accounts that they manage?
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts;

-- Same result using a SUBQUERY.
SELECT COUNT(*) num_reps_above5
FROM (SELECT s.id, s.name, COUNT(*) num_accounts
      FROM accounts a
      JOIN sales_reps s
      ON s.id = a.sales_rep_id
      GROUP BY s.id, s.name
      HAVING COUNT(*) > 5
      ORDER BY num_accounts) AS Table1;

-- How many accounts have more than 20 orders?
SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY num_orders;

-- Which account has the most orders?
SELECT a.id, a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1;

-- How many accounts spent more than 30,000 usd total across all orders?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spent;

-- How many accounts spent less than 1,000 usd total across all orders?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spent;

-- Which account has spent the most with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent DESC
LIMIT 1;

-- Which account has spent the least with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spent
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spent
LIMIT 1;

-- Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6 AND w.channel = 'facebook'
ORDER BY use_of_channel;

-- Which account used facebook most as a channel?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 1;

-- Note: This query above only works if there are no ties.
-- Best practice is to use LIMIT 3 or 5 first to check for ties.

-- Which channel was most frequently used by most accounts?
SELECT a.id, a.name, w.channel, COUNT(*) use_of_channel
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY a.id, a.name, w.channel
ORDER BY use_of_channel DESC
LIMIT 10;
-- All of the top 10 are direct.


-- ==========================================
-- 6. DISTINCT Solutions
-- ==========================================

-- Use DISTINCT to test if there are any accounts associated with more
-- than one region.
-- The two queries below have the same number of resulting rows (351),
-- so every account is associated with only one region.
SELECT a.id   AS "account id",
       r.id   AS "region id",
       a.name AS "account name",
       r.name AS "region name"
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id;

SELECT DISTINCT id, name
FROM accounts;

-- Have any sales reps worked on more than one account?
-- All sales reps have worked on more than one account. The fewest number
-- of accounts any sales rep works on is 3. There are 50 sales reps.
SELECT s.id, s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts;

SELECT DISTINCT id, name
FROM sales_reps;


-- ==========================================
-- 7. Working With DATEs Solutions
-- ==========================================

-- Find the sales in terms of total dollars for all orders in each year,
-- ordered from greatest to least.
SELECT DATE_PART('year', occurred_at) ord_year,
       SUM(total_amt_usd) total_spent
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- Note: 2013 and 2017 have much smaller totals because they only contain
-- one month of sales each (12 for 2013 and 1 for 2017). Sales have been
-- increasing year over year, with 2016 being the largest to date.

-- Which month did Parch & Posey have the greatest sales in terms of total dollars?
-- Exclude 2013 and 2017 for a fair comparison.
SELECT DATE_PART('month', occurred_at) ord_month,
       SUM(total_amt_usd) total_spent
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;
-- Greatest sales amounts occur in December (12).

-- Which year did Parch & Posey have the greatest sales in terms of total number of orders?
SELECT DATE_PART('year', occurred_at) ord_year,
       COUNT(*) total_sales
FROM orders
GROUP BY 1
ORDER BY 2 DESC;
-- Again, 2016 by far has the most orders, but 2013 and 2017 are not evenly represented.

-- Which month did Parch & Posey have the greatest sales in terms of total number of orders?
-- Exclude 2013 and 2017 for a fair comparison.
SELECT DATE_PART('month', occurred_at) ord_month,
       COUNT(*) total_sales
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;
-- December has the most sales, but November has the second most.

-- In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT DATE_TRUNC('month', o.occurred_at) ord_date,
       SUM(o.gloss_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- May 2016 was when Walmart spent the most on gloss paper.


-- ==========================================
-- 8. CASE Solutions
-- ==========================================

-- For each order, display the account ID, total amount of the order,
-- and the level of the order - 'Large' or 'Small' - depending on if
-- the order is $3000 or more, or less than $3000.
SELECT account_id, total_amt_usd,
       CASE WHEN total_amt_usd > 3000 THEN 'Large'
            ELSE 'Small' END AS order_level
FROM orders;

-- Display the number of orders in each of three categories based on
-- the total number of items in each order:
-- 'At Least 2000', 'Between 1000 and 2000', 'Less than 1000'.
SELECT CASE WHEN total >= 2000 THEN 'At Least 2000'
            WHEN total >= 1000 AND total < 2000 THEN 'Between 1000 and 2000'
            ELSE 'Less than 1000' END AS order_category,
       COUNT(*) AS order_count
FROM orders
GROUP BY 1;

-- Understand 3 different branches of customers based on the amount
-- associated with their purchases.
-- Top: Lifetime Value > 200,000 usd
-- Middle: between 200,000 and 100,000 usd
-- Low: under 100,000 usd
SELECT a.name,
       SUM(total_amt_usd) total_spent,
       CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
            WHEN SUM(total_amt_usd) > 100000 THEN 'middle'
            ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY a.name
ORDER BY 2 DESC;

-- Same calculation but only for 2016 and 2017.
SELECT a.name,
       SUM(total_amt_usd) total_spent,
       CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
            WHEN SUM(total_amt_usd) > 100000 THEN 'middle'
            ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31'
GROUP BY 1
ORDER BY 2 DESC;

-- Identify top performing sales reps: reps associated with more than 200 orders.
SELECT s.name,
       COUNT(*) num_ords,
       CASE WHEN COUNT(*) > 200 THEN 'top'
            ELSE 'not' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 2 DESC;
-- Note: assumes each name is unique.

-- Top performing sales reps: more than 200 orders OR more than 750000 in total sales.
-- Middle: more than 150 orders OR 500000 in sales.
-- Low: otherwise.
SELECT s.name,
       COUNT(*),
       SUM(o.total_amt_usd) total_spent,
       CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
            WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
            ELSE 'low' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC;


-- ==========================================
-- 9. Additional Aggregation Concepts
-- ==========================================

-- 9.1 COUNT variations and their differences
-- COUNT(*) counts all rows, including NULLs.
SELECT COUNT(*) FROM orders;

-- COUNT(column) counts only non-NULL values in that column.
SELECT COUNT(account_id) FROM orders;

-- COUNT(DISTINCT column) counts distinct non-NULL values.
SELECT COUNT(DISTINCT account_id) FROM orders;

-- In a LEFT JOIN, COUNT(*) and COUNT(right_table.column) can differ:
-- COUNT(*) includes rows with no match (NULL on right side),
-- COUNT(right_table.column) excludes those NULLs.
SELECT COUNT(*) AS all_rows,
       COUNT(o.id) AS matched_rows
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;

-- 9.2 NULL handling in aggregations
-- Most aggregate functions ignore NULLs (SUM, AVG, MIN, MAX, COUNT(column)).
-- COUNT(*) is the exception and includes NULL rows.
-- Example: AVG(gloss_qty) ignores rows where gloss_qty IS NULL.
SELECT AVG(gloss_qty) AS avg_gloss_ignoring_nulls
FROM orders;

-- To treat NULL as 0 before aggregating, use COALESCE.
SELECT AVG(COALESCE(gloss_qty, 0)) AS avg_gloss_with_zero
FROM orders;

-- 9.3 WHERE vs HAVING
-- WHERE filters rows BEFORE aggregation.
-- HAVING filters groups AFTER aggregation.
SELECT a.name,
       SUM(o.total_amt_usd) AS total
FROM accounts a
JOIN orders o
ON a.id = o.account_id
WHERE o.occurred_at >= '2016-01-01'   -- filters rows first
GROUP BY a.name
HAVING SUM(o.total_amt_usd) > 100000; -- filters groups after

-- 9.4 Conditional aggregation using CASE inside aggregate functions
-- This allows multiple conditional metrics in a single query.
SELECT DATE_TRUNC('month', occurred_at) AS month,
       SUM(CASE WHEN total_amt_usd > 3000 THEN total_amt_usd ELSE 0 END) AS large_orders_total,
       SUM(CASE WHEN total_amt_usd <= 3000 THEN total_amt_usd ELSE 0 END) AS small_orders_total
FROM orders
GROUP BY 1
ORDER BY 1;

-- Another example: count orders per channel category.
SELECT COUNT(CASE WHEN channel = 'direct' THEN 1 END) AS direct_count,
       COUNT(CASE WHEN channel = 'facebook' THEN 1 END) AS facebook_count
FROM web_events;

-- ==========================================
-- End of SQL Aggregations
-- ==========================================