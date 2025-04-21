create database walmart_db;
show databases;
use walmart_db;
show tables;
select count(*) from walmart;
drop table walmart;
select * from walmart limit 10;
Select count(distinct city)
from walmart;

-- Business Questions

-- 1.Find different payment methods, number of transactions, and quantity sold by payment method
select payment_method, 
count(*) as no_of_transaction,
sum(quantity) as quantity_sold 
from walmart group by payment_method
order by 2;

-- 2.Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating

select * from
(
select branch,category, avg(rating) as avg_rating ,
rank() over(partition by branch order by avg(rating) desc) as ranks   
from walmart group by branch,category
) as high_rated
where ranks=1;

-- Q3: Identify the busiest day for each branch based on the number of transactions

SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranks
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE ranks = 1;

-- Q4: Calculate the total quantity of items sold per payment method

select payment_method,
sum(quantity) as total_quantity 
from walmart
group by payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city

select
city,
category,
round(avg(rating),2) as avg_rating,
min(rating) as min_rating,
max(rating) as max_rating
from walmart
group by city,category;

-- Q6: Calculate the total profit for each category

select
category,
round(sum(Total_amt * profit_margin),2) as total_profit
from walmart
group by 1
order by 2 desc;

-- Q7: Determine the most common payment method for each branch

select * from 
(
select branch , 
payment_method ,
count(*) as total_trans,
rank() over(partition by branch order by count(*) desc) as ranks
from walmart
group by  1,2 
) As common_pay
where ranks =1 ;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts

SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(Total_amt) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(Total_amt) AS revenue
    FROM walmart
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













