-- ====================================
-- OBJECTIVE 1: EXPLORE THE ITEMS TABLE
-- ====================================

-- View the menu_items table and write a query to find the number of items on the menu.
SELECT *
FROM    dbo.menu_items;

SELECT COUNT (*) AS num_menu_items
FROM   dbo.menu_items;

-- What are the least and most expensive items on the menu?
SELECT  item_name AS least_expensive,
        price
FROM    dbo.menu_items
WHERE   price = (SELECT MIN (price) FROM dbo.menu_items);

SELECT  item_name AS most_expensive,
        price
FROM    dbo.menu_items
WHERE   price = (SELECT MAX (price) FROM dbo.menu_items);

-- How many Italian dishes are on the menu? What are the least and most expensive Italian dishes on the menu?
SELECT
        COUNT (item_name) AS num_italian_dishes
FROM    dbo.menu_items
WHERE   category = 'Italian';

SELECT  item_name AS italian_least_expensive,
        price
FROM    dbo.menu_items
WHERE   category = 'Italian'
        AND price = (SELECT MIN (price) FROM dbo.menu_items WHERE category = 'Italian');

SELECT  item_name AS itilian_most_expensive,
        price
FROM    dbo.menu_items
WHERE   category = 'Italian'
        AND price = (SELECT MAX (price) FROM dbo.menu_items WHERE category = 'Italian');

-- How many dishes are in each category? What is the average dish price within each category?
SELECT   category,
         COUNT (category) AS num_dishes
FROM     dbo.menu_items
GROUP BY category
ORDER BY num_dishes DESC;

SELECT   category,
         ROUND (AVG (price), 1) AS avg_dishes
FROM     dbo.menu_items
GROUP BY category
ORDER BY avg_dishes DESC;

-- ====================================
-- OBJECTIVE 2: EXPLORE THE ORDERS TABLE
-- ====================================

-- View the order_details table. What is the date range of the table?
SELECT *
FROM   dbo.order_details;

SELECT MIN (order_date) AS start_date,
    MAX (order_date) AS end_date
FROM   dbo.order_details;

-- How many orders were made within this date range? How many items were ordered within this date range?
SELECT COUNT (distinct order_id) AS all_orders 
FROM   dbo.order_details
where  order_date BETWEEN '2001-01-23' AND '2023-03-31';

SELECT count (item_id) AS items_ordered
FROM   dbo.order_details
where  order_date BETWEEN '2001-01-23' AND '2023-03-31';

-- Which orders had the most number of items?
SELECT   order_id,
         COUNT(item_id) AS num_items
FROM     dbo.order_details
GROUP BY order_id
HAVING   COUNT(item_id) = (SELECT MAX(q.num_items)
                           FROM   (SELECT   COUNT(item_id) AS num_items
                                   FROM     dbo.order_details
                                   GROUP BY order_id) AS q);

-- How many orders had more than 12 items?
SELECT  COUNT(*) AS orders_with_more_than_12_items
FROM (
        SELECT order_id
        FROM dbo.order_details
        GROUP BY order_id
        HAVING COUNT(item_id) > 12
        ) AS q;

-- ====================================
-- OBJECTIVE 3: ANALYZE CUSTOMER BEHAVIOR
-- ====================================

-- Combine the menu_items and order_details tables into a single table.
SELECT od.order_details_id,
       od.order_id,
       mi.item_name,
       mi.category,
       mi.price,
       od.order_date,
       CAST (od.order_time AS TIME (0)) AS order_time
FROM   dbo.order_details AS od
       LEFT OUTER JOIN
       dbo.menu_items AS mi
       ON mi.menu_items_id = od.item_id;

-- What were the least and most ordered items? What categories were they in?
WITH   orders_list
AS     (SELECT od.order_details_id,
               od.order_id,
               mi.item_name,
               mi.category,
               mi.price,
               od.order_date,
               CAST (od.order_time AS TIME (0)) AS order_time
        FROM   dbo.order_details AS od
               INNER JOIN
               dbo.menu_items AS mi
               ON mi.menu_items_id = od.item_id),
       orders_count
AS     (SELECT   item_name,
                 category,
                 count(item_name) AS cnt_orders
        FROM     orders_list
        GROUP BY item_name, category)
SELECT item_name AS item_name,
       category AS category,
       'most ordered' AS 'most/least ordered items',
       cnt_orders AS counts
FROM   orders_count
WHERE  cnt_orders = (SELECT max(cnt_orders)
                     FROM   orders_count)
UNION ALL
SELECT item_name,
category,
       'least ordered',
       cnt_orders
FROM   orders_count
WHERE  cnt_orders = (SELECT min(cnt_orders)
                     FROM   orders_count);

-- What were the top 5 orders that spent the most money?
SELECT   TOP 5 od.order_id,
               COUNT(*) AS items_in_order,
               SUM(mi.price) AS total_spend
FROM     dbo.order_details AS od
         INNER JOIN
         dbo.menu_items AS mi
         ON mi.menu_items_id = od.item_id
GROUP BY od.order_id
ORDER BY SUM(mi.price) DESC;

-- View the details of the highest spend order. What insights can you gather from the results?
SELECT   TOP 1 od.order_id
FROM     dbo.order_details AS od
         INNER JOIN
         dbo.menu_items AS mi
         ON mi.menu_items_id = od.item_id
GROUP BY od.order_id
ORDER BY SUM(mi.price) DESC;

SELECT SUM(mi.price) total_amount
FROM   dbo.order_details AS od
       INNER JOIN
       dbo.menu_items AS mi
       ON mi.menu_items_id = od.item_id
WHERE  od.order_id = 440;

SELECT mi.category,
       mi.item_name,
       mi.price
FROM   dbo.order_details AS od
       INNER JOIN
       dbo.menu_items AS mi
       ON mi.menu_items_id = od.item_id
WHERE  od.order_id = 440;

SELECT   mi.category,
         COUNT(mi.category) AS count_category,
         SUM(mi.price) AS total_spent,
         ROUnD(SUM(mi.price) / 192.15, 3) * 100 AS ratio_of_total
FROM     dbo.order_details AS od
         INNER JOIN
         dbo.menu_items AS mi
         ON mi.menu_items_id = od.item_id
WHERE    od.order_id = 440
GROUP BY mi.category
ORDER BY total_spent DESC;

-- View the details of the top 5 highest spend orders. What insights can you gather from the results?
SELECT
    mi.category,
    COUNT(*) AS item_count,
    SUM(mi.price) AS category_amount
FROM dbo.order_details AS od
INNER JOIN dbo.menu_items AS mi
    ON mi.menu_items_id = od.item_id
WHERE od.order_id IN (440, 2075, 1957, 330, 2675)
GROUP BY mi.category
ORDER BY category_amount DESC;

WITH     order_category
AS       (SELECT   od.order_id,
                   mi.category,
                   COUNT(*) AS item_count,
                   SUM(mi.price) AS category_amount
          FROM     dbo.order_details AS od
                   INNER JOIN
                   dbo.menu_items AS mi
                   ON mi.menu_items_id = od.item_id
          WHERE    od.order_id IN (440, 2075, 1957, 330, 2675)
          GROUP BY od.order_id,
                   mi.category)
SELECT   order_id,
         category,
         item_count,
         CAST (category_amount / item_count AS DECIMAL (5, 1))  AS avg_item_price,
         CAST (100.0* category_amount / SUM(category_amount)
            OVER (PARTITION BY order_id) AS DECIMAL (5, 1))     AS amount_share_pct
FROM     order_category
ORDER BY order_id,
         amount_share_pct DESC;

SELECT q.category,
       q.item_name,
        order_count,
        CAST(100.0 * order_count / SUM(order_count) OVER () AS decimal(5,2)) AS ratio_total_order_count,
        item_count,
        CAST(100.0 * item_count / SUM(item_count) OVER () AS decimal(5,2)) AS ratio_total_item_count,
        item_amount,
        CAST(100.0 * item_amount / SUM(item_amount) OVER () AS decimal(5,2)) AS ratio_total_amount
FROM
        (SELECT mi.category,
                mi.item_name,
                COUNT(*) AS item_count,
                COUNT(DISTINCT od.order_id) AS order_count,
                SUM(mi.price) AS item_amount
        FROM     dbo.order_details AS od
                INNER JOIN dbo.menu_items AS mi
                    ON mi.menu_items_id = od.item_id
        GROUP BY mi.category, mi.item_name) AS q
GROUP BY q.category, q.item_name, order_count, item_count, item_amount
ORDER BY item_amount DESC;

-- Busiest & Quitest times
SELECT min(order_time) AS min_order_time, 
       max(order_time) AS max_order_time 
FROM order_details;

SELECT   DATEPART(HOUR, order_time) AS order_hour,
         COUNT(DISTINCT order_id) AS order_count
FROM     dbo.order_details
GROUP BY DATEPART(HOUR, order_time)
ORDER BY order_hour;

SELECT   DATENAME(WEEKDAY, od.order_date) AS day_name,
         COUNT(DISTINCT od.order_id) AS order_count,
         COUNT(*) AS item_count,
         SUM(mi.price) AS total_amount,
         CAST(
             SUM(mi.price) * 1.0 / COUNT(DISTINCT od.order_id)
             AS DECIMAL(10,2)
         ) AS avg_order_value
FROM     dbo.order_details AS od
         INNER JOIN dbo.menu_items AS mi
             ON mi.menu_items_id = od.item_id
GROUP BY DATENAME(WEEKDAY, od.order_date),
         DATEPART(WEEKDAY, od.order_date)
ORDER BY DATEPART(WEEKDAY, od.order_date);
