-- =====================================================================
-- Customer Shopping Behavior - Business Questions
-- Dialect: PostgreSQL  (SQLite version: customer_analysis_queries_sqlite.sql)
-- Note: in PostgreSQL, ROUND(value, n) needs a NUMERIC value, so decimal columns are cast with ::numeric
-- Table:   customer  (load data/processed/customer_shopping_data_clean.csv into PostgreSQL first)
-- Tip: in pgAdmin, highlight one query and press F5 to run it.
-- =====================================================================


-- Q1: Revenue and average order value by gender
SELECT gender,
       COUNT(*)                        AS customers,
       SUM(purchase_amount)            AS total_revenue,
       ROUND(AVG(purchase_amount), 2)  AS avg_order_value
FROM customer
GROUP BY gender
ORDER BY total_revenue DESC;


-- Q2: How many discount users still spent above the overall average order value?
WITH avg_spend AS (SELECT AVG(purchase_amount) AS overall_avg FROM customer)
SELECT COUNT(*)                               AS high_spending_discount_users,
       ROUND(AVG(c.purchase_amount), 2)       AS their_avg_spend,
       ROUND((SELECT overall_avg FROM avg_spend), 2) AS overall_avg_spend
FROM customer c
WHERE c.discount_applied = 'Yes'
  AND c.purchase_amount > (SELECT overall_avg FROM avg_spend);


-- Q3: Top 5 products by average review rating
SELECT item_purchased,
       ROUND(AVG(review_rating)::numeric, 2) AS avg_rating,
       COUNT(*)                     AS reviews
FROM customer
GROUP BY item_purchased
ORDER BY avg_rating DESC
LIMIT 5;


-- Q4: Average spend by shipping type
SELECT shipping_type,
       COUNT(*)                       AS orders,
       ROUND(AVG(purchase_amount), 2) AS avg_order_value
FROM customer
GROUP BY shipping_type
ORDER BY avg_order_value DESC;


-- Q5: Do subscribers spend more than non-subscribers?
SELECT subscription_status,
       COUNT(*)                       AS customers,
       ROUND(AVG(purchase_amount), 2) AS avg_order_value,
       SUM(purchase_amount)           AS total_revenue,
       ROUND(100.0 * SUM(purchase_amount) / (SELECT SUM(purchase_amount) FROM customer), 1)
                                      AS revenue_share_pct
FROM customer
GROUP BY subscription_status;


-- Q6: Top 5 products most dependent on discounts
SELECT item_purchased,
       ROUND(100.0 * AVG(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END), 1) AS discount_rate_pct,
       COUNT(*) AS orders
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate_pct DESC
LIMIT 5;


-- Q7: Customer lifecycle segments (New / Returning / Loyal)
SELECT customer_segment,
       COUNT(*)                       AS customers,
       ROUND(AVG(purchase_amount), 2) AS avg_order_value,
       ROUND(100.0 * AVG(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END), 1) AS subscription_rate_pct
FROM customer
GROUP BY customer_segment
ORDER BY customers DESC;


-- Q8: Top 3 best-selling products in each category (window function)
WITH ranked AS (
    SELECT category,
           item_purchased,
           COUNT(*) AS orders,
           DENSE_RANK() OVER (PARTITION BY category ORDER BY COUNT(*) DESC) AS rnk
    FROM customer
    GROUP BY category, item_purchased
)
SELECT category, rnk, item_purchased, orders
FROM ranked
WHERE rnk <= 3
ORDER BY category, rnk;


-- Q9: Subscription rate of repeat buyers (>5 previous purchases) vs others
SELECT CASE WHEN previous_purchases > 5 THEN 'Repeat buyer (>5)' ELSE 'Occasional (<=5)' END AS buyer_type,
       COUNT(*) AS customers,
       ROUND(100.0 * AVG(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END), 1) AS subscription_rate_pct
FROM customer
GROUP BY buyer_type
ORDER BY buyer_type;


-- Q10: Revenue contribution by age group
SELECT age_group,
       COUNT(*)             AS customers,
       SUM(purchase_amount) AS total_revenue,
       ROUND(100.0 * SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER (), 1) AS revenue_share_pct
FROM customer
GROUP BY age_group
ORDER BY age_group;


-- ---------------------------------------------------------------------
-- NEW: deeper questions added on top of the core analysis
-- ---------------------------------------------------------------------

-- Q11: Seasonal revenue by category - which category leads each season?
WITH season_cat AS (
    SELECT season, category, SUM(purchase_amount) AS revenue
    FROM customer
    GROUP BY season, category
)
SELECT season,
       category,
       revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (PARTITION BY season), 1) AS share_of_season_pct,
       RANK() OVER (PARTITION BY season ORDER BY revenue DESC)            AS rank_in_season
FROM season_cat
ORDER BY season, rank_in_season;


-- Q12: Top 10 states by revenue with running (cumulative) revenue share
WITH state_rev AS (
    SELECT location AS state, SUM(purchase_amount) AS revenue
    FROM customer
    GROUP BY location
)
SELECT state,
       revenue,
       ROUND(100.0 * SUM(revenue) OVER (ORDER BY revenue DESC ROWS UNBOUNDED PRECEDING)
             / SUM(revenue) OVER (), 1) AS cumulative_share_pct
FROM state_rev
ORDER BY revenue DESC
LIMIT 10;


-- Q13: Payment method preference by age group (share within each age group)
SELECT age_group,
       payment_method,
       COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY age_group), 1) AS share_pct
FROM customer
GROUP BY age_group, payment_method
ORDER BY age_group, share_pct DESC;


-- Q14: Customer value tiers - score each customer on spend, loyalty and frequency
--      (quartile scores 1-4 per dimension, total 3-12)
WITH scored AS (
    SELECT customer_id,
           purchase_amount,
           previous_purchases,
           est_purchases_per_year,
           NTILE(4) OVER (ORDER BY purchase_amount, customer_id)        AS spend_score,
           NTILE(4) OVER (ORDER BY previous_purchases, customer_id)     AS loyalty_score,
           NTILE(4) OVER (ORDER BY est_purchases_per_year, customer_id) AS frequency_score
    FROM customer
),
tiered AS (
    SELECT *,
           spend_score + loyalty_score + frequency_score AS value_score,
           CASE
               WHEN spend_score + loyalty_score + frequency_score >= 10 THEN '1. High value'
               WHEN spend_score + loyalty_score + frequency_score >= 7  THEN '2. Mid value'
               ELSE '3. Low value'
           END AS value_tier
    FROM scored
)
SELECT value_tier,
       COUNT(*)                             AS customers,
       ROUND(AVG(purchase_amount), 2)       AS avg_order_value,
       ROUND(AVG(previous_purchases), 1)    AS avg_previous_purchases,
       ROUND(AVG(est_purchases_per_year)::numeric, 1) AS avg_purchases_per_year,
       ROUND(SUM(purchase_amount * est_purchases_per_year)::numeric, 0) AS est_annual_revenue
FROM tiered
GROUP BY value_tier
ORDER BY value_tier;


-- Q15: Do discounts actually lift basket size? Avg spend with vs without discount, per category
SELECT category,
       ROUND(AVG(CASE WHEN discount_applied = 'Yes' THEN purchase_amount END), 2) AS avg_with_discount,
       ROUND(AVG(CASE WHEN discount_applied = 'No'  THEN purchase_amount END), 2) AS avg_without_discount,
       ROUND(AVG(CASE WHEN discount_applied = 'Yes' THEN purchase_amount END)
           - AVG(CASE WHEN discount_applied = 'No'  THEN purchase_amount END), 2) AS difference
FROM customer
GROUP BY category
ORDER BY difference;


-- Q16: Estimated annual revenue by purchase frequency (order value x purchases per year)
SELECT frequency_of_purchases,
       COUNT(*)                        AS customers,
       ROUND(AVG(purchase_amount), 2)  AS avg_order_value,
       ROUND(SUM(purchase_amount * est_purchases_per_year)::numeric, 0) AS est_annual_revenue
FROM customer
GROUP BY frequency_of_purchases
ORDER BY est_annual_revenue DESC;
