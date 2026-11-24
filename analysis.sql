-- Customer Purchase Behavior Analysis | PostgreSQL
-- Synthetic practice dataset. Replace with a licensed real dataset for production use.
DROP TABLE IF EXISTS purchases;
CREATE TABLE purchases (
  order_id INT PRIMARY KEY, customer_id INT, order_date DATE,
  category VARCHAR(40), order_value NUMERIC(10,2), payment_method VARCHAR(20)
);
INSERT INTO purchases VALUES
(1001,1,'2026-01-03','Electronics',12999,'UPI'),(1002,2,'2026-01-04','Fashion',1899,'Card'),
(1003,1,'2026-01-18','Accessories',799,'UPI'),(1004,3,'2026-02-02','Home',3499,'Cash'),
(1005,2,'2026-02-12','Fashion',2599,'Card'),(1006,4,'2026-02-19','Electronics',8999,'UPI'),
(1007,1,'2026-03-05','Electronics',4999,'Card'),(1008,5,'2026-03-09','Beauty',1199,'UPI'),
(1009,3,'2026-03-21','Home',2199,'Cash'),(1010,6,'2026-03-25','Fashion',1599,'UPI'),
(1011,2,'2026-04-02','Beauty',899,'Card'),(1012,4,'2026-04-17','Electronics',15999,'UPI');
-- 1. Revenue and order KPIs
SELECT COUNT(*) AS orders, COUNT(DISTINCT customer_id) AS customers,
       SUM(order_value) AS revenue, ROUND(AVG(order_value),2) AS average_order_value
FROM purchases;
-- 2. Monthly revenue trend
SELECT DATE_TRUNC('month',order_date)::date AS month, SUM(order_value) AS revenue
FROM purchases GROUP BY 1 ORDER BY 1;
-- 3. Repeat vs one-time customers
SELECT customer_id, COUNT(*) AS orders, SUM(order_value) AS lifetime_value,
       CASE WHEN COUNT(*) > 1 THEN 'Repeat' ELSE 'One-time' END AS customer_type
FROM purchases GROUP BY customer_id ORDER BY lifetime_value DESC;
-- 4. Category contribution
SELECT category, COUNT(*) AS orders, SUM(order_value) AS revenue,
       ROUND(100.0*SUM(order_value)/SUM(SUM(order_value)) OVER (),2) AS revenue_share_pct
FROM purchases GROUP BY category ORDER BY revenue DESC;
-- 5. Payment preferences
SELECT payment_method, COUNT(*) AS orders, SUM(order_value) AS revenue
FROM purchases GROUP BY payment_method ORDER BY orders DESC;
-- 6. Customer ranking
SELECT customer_id, SUM(order_value) AS lifetime_value,
       DENSE_RANK() OVER (ORDER BY SUM(order_value) DESC) AS value_rank
FROM purchases GROUP BY customer_id;
-- 7. Days between customer purchases
SELECT customer_id, order_date,
       order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_since_previous
FROM purchases;
-- 8. Monthly order value and running revenue
SELECT DATE_TRUNC('month',order_date)::date AS month, SUM(order_value) AS monthly_revenue,
       SUM(SUM(order_value)) OVER (ORDER BY DATE_TRUNC('month',order_date)) AS cumulative_revenue
FROM purchases GROUP BY 1 ORDER BY 1;
