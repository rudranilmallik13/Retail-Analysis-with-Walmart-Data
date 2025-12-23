SELECT * FROM walmart_db.walmart;
SELECT COUNT(*) FROM walmart_db.walmart;
SELECT 
	payment_method,
    count(*)
FROM walmart_db.walmart
GROUP BY payment_method;

SELECT 
	COUNT(DISTINCT Branch)
FROM walmart_db.walmart;

select MAX(quantity) FROM walmart_db.walmart;

-- Business Problems
-- Q.1: Find diffferent payment method and number of transactions, number of qty sold
  
  SELECT 
	payment_method,
    count(*) as no_payments,
    SUM(quantity) as no_qty_sold
FROM walmart_db.walmart
GROUP BY payment_method;

-- Q.2:	
-- Identify thr highest-rated category in each branch, displaying thr branch, category
-- AVG RATING

SELECT
    Branch,
    category,
    avg_rating,
    RANK() OVER (
        PARTITION BY Branch
        ORDER BY avg_rating DESC
    ) AS rank_in_branch
FROM (
    SELECT
        Branch,
        category,
        AVG(rating) AS avg_rating
    FROM walmart_db.walmart
    GROUP BY Branch, category
) t;

-- Q.3: Identify busiest day for each branch based on the number of transactions

SELECT
    Branch,
    day_name,
    no_transactions,
    RANK() OVER (
        PARTITION BY Branch
        ORDER BY no_transactions DESC
    ) AS rank_in_branch
FROM (
    SELECT
        Branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
        COUNT(*) AS no_transactions
    FROM walmart_db.walmart
    GROUP BY Branch, day_name
) t
ORDER BY Branch, rank_in_branch;

-- Q.4: Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.alter

SELECT 
	payment_method,
    count(*)
FROM walmart_db.walmart
GROUP BY payment_method;

-- Q.5:
-- Determine the average,minimum,and maximum rating of category for each city.
-- List the city,average_rating,min_rating, and max_rating.

SELECT
	city,
    category,
    MIN(rating) as min_rating,
    MAX(rating) as max_rating,
    AVG(rating) as avg_rating
FROM walmart_db.walmart
GROUP BY 1,2;

-- Q.6: Calculate the total profit for each category

SELECT 
    category,
    ROUND(SUM(unit_price * quantity * profit_margin), 2) AS total_profit
FROM walmart_db.walmart
GROUP BY category
ORDER BY total_profit DESC;

-- q.7: Determine the most common payment method for each branch

WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank_
    FROM walmart_db.walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rank_ = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart_db.walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart_db.walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart_db.walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;