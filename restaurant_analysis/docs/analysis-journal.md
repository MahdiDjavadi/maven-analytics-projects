# تحلیل عملکرد منو و سفارشات رستوران

## هدف 1: بررسی جدول آیتم‌های منو

### جدول `menu_items` را مشاهده کنید و یک کوئری بنویسید که تعداد آیتم‌های موجود در منو را مشخص کند

```sql
SELECT *
FROM    dbo.menu_items;

SELECT COUNT (*) AS num_menu_items
FROM   dbo.menu_items;
```

| num_menu_items |
|----------------|
| 32             |

### ارزان‌ترین و گران‌ترین آیتم‌های موجود در منو کدام‌اند؟

```sql
SELECT  item_name AS least_expensive,
        price
FROM    dbo.menu_items
WHERE   price = (SELECT MIN (price) FROM dbo.menu_items);
```

| least_expensive | price |
|-----------------|-------|
| Edamame         | 5.00  |

```sql
SELECT  item_name AS most_expensive,
        price
FROM    dbo.menu_items
WHERE   price = (SELECT MAX (price) FROM dbo.menu_items);
```

| most_expensive  | price |
|-----------------|-------|
| Shrimp Scampi   | 19.95 |

- آیتم `Edamame` با قیمت 5.00 دلار ارزانترین آیتم منو است.
- آیتم `Shrimp Scampi` با 19.95 دلار گرانترین آیتم منو است.

### غذاهای ایتالیایی چند نوع هستند؟ ارزانترین و گرانترین بشقاب ایتالیایی کدام‌اند؟

```sql
SELECT
        COUNT (item_name) AS num_italian_dishes
FROM    dbo.menu_items
WHERE   category = 'Italian';
```

| num_italian_dishes |
|--------------------|
| 9                  |

```sql
SELECT  item_name AS italian_least_expensive,
        price
FROM    dbo.menu_items
WHERE   category = 'Italian'
        AND price = (SELECT MIN (price) FROM dbo.menu_items WHERE category = 'Italian');
```

| italian_least_expensive | price |
|-------------------------|-------|
| Spaghetti               | 14.50 |
| Fettuccine Alfredo      | 14.50 |

```sql
SELECT  item_name AS itilian_most_expensive,
        price
FROM    dbo.menu_items
WHERE   category = 'Italian'
        AND price = (SELECT MAX (price) FROM dbo.menu_items WHERE category = 'Italian');
```

| itilian_most_expensive | price |
|------------------------|-------|
| Shrimp Scampi          | 19.95 |

- تنوع غذاهای `ایتالیایی` 9 بشقاب است.
- آیتم‌های `Spagetti` و `Fettuccine Alfredo` با 14.50 دلار ارزانترین بشقاب های منوی ایتالیایی هستند.
- آیتم `Shrimp Scampi` با 19.95 دلار هم گرانترین بشقاب غذای ایتالیایی است.

### هر گروه منو چند نوع غذا دارد؟ میانگین قیمت هر دسته چقدر است؟

```sql
SELECT   category,
         COUNT (category) AS num_dishes
FROM     dbo.menu_items
GROUP BY category
ORDER BY num_dishes DESC;
```

| category  | num_dishes |
|-----------|------------|
| Italian   | 9          |
| Mexican   | 9          |
| Asian     | 8          |
| American  | 6          |

```sql
SELECT   category,
         ROUND (AVG (price), 1) AS avg_dishes
FROM     dbo.menu_items
GROUP BY category
ORDER BY avg_dishes DESC;
```

| category | num_dishes |
|----------|------------|
| Italian  | 16.80      |
| Asian    | 13.50      |
| Mexican  | 11.80      |
| American | 10.10      |

- در این 4 دسته بندی، گروههای (`ایتالیایی` و `مکزیکی`) دارای 9 نوع بشقاب غذایی هستند (`غذاهای آمریکایی تنوع پایینتری دارند`)
- غذاهای ایتالیایی علاوه بر تنوع بالا، بیشترین میانگین قیمت را دارند

## هدف 2: بررسی جدول سفارش‌ها

### بررسی جدول `order_details` و تشخیص بازه زمانی سفارش‌ها

```sql
SELECT *
FROM   dbo.order_details;

SELECT MIN (order_date) AS start_date,
    MAX (order_date) AS end_date
FROM   dbo.order_details;
```

| start_date | end_date   |
|------------|------------|
| 2001-01-23 | 2023-03-31 |

### چه تعداد سفارش در این بازه ثبت شده؟ چه تعداد آیتم در بازه ثبت شده؟

```sql
SELECT COUNT (distinct order_id) AS all_orders 
FROM   dbo.order_details
where  order_date BETWEEN '2001-01-23' AND '2023-03-31';
```

| all_orders |
|------------|
| 5370       |

```SQL
SELECT count (item_id) AS items_ordered
FROM   dbo.order_details
where  order_date BETWEEN '2001-01-23' AND '2023-03-31';
```

| items_ordered |
|---------------|
| 12097         |

### کدام سفارش بیشترین آیتم را دارد؟

```SQL
SELECT   order_id,
         COUNT(item_id) AS num_items
FROM     dbo.order_details
GROUP BY order_id
HAVING   COUNT(item_id) = (SELECT MAX(q.num_items)
                           FROM   (SELECT   COUNT(item_id) AS num_items
                                   FROM     dbo.order_details
                                   GROUP BY order_id) AS q);
```

| order_id | num_items |
|----------|-----------|
| 330      | 14        |
| 3473     | 14        |
| 2675     | 14        |
| 1957     | 14        |
| 440      | 14        |
| 443      | 14        |
| 4305     | 14        |

### چند سفارش بالای 12 آیتم غذایی دارند؟

```SQL
SELECT COUNT(*) AS orders_with_more_than_12_items
FROM (
    SELECT order_id
    FROM dbo.order_details
    GROUP BY order_id
    HAVING COUNT(item_id) > 12
) AS q;
```

| orders_with_more_than_12_items |
|--------------------------------|
| 20                             |

- بازه بررسی سفارشات (` 2001-01-23 - 2023-03-31 `)
- ۱۲۰۹۷ ردیف آیتم در جزئیات سفارش‌ها ثبت شده است.
- بیشترین تعداد ردیف آیتم در یک سفارش، ۱۴ ردیف بوده که در ۷ سفارش مشاهده شده است.
- 20 سفارش با تعداد آیتم بالای 12 عدد داریم

## تحلیل رفتار مشتریان

### با ترکیب دو جدول (`menu_items`) و (`order_details`)، جزییات فروش به تفکیک آیتم را بسازید

```SQL
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
```

### بیشترین و کمترین سفارشات در کدام آیتم‌ها بوده؟ در چه دسته‌ی هستند؟

```SQL
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
```

| item_name     | category | most/least ordered items | counts |
|---------------|----------|--------------------------|--------|
| Hamburger     | American | most ordered             | 622    |
| Chicken Tacos | Mexican  | least ordered            | 123    |

- آیتم `Hamburger` در دسته `American` با ۶۲۲ بار ثبت، پرتکرارترین آیتم منو است.
- آیتم `Chicken Tacos` در دسته `Mexican` با ۱۲۳ بار ثبت، کم‌تکرارترین آیتم منو است.

### 5 سفارش برتر با بالاترین مبلغ کدام‌اند？

```sql
SELECT   TOP 5 od.order_id,
               COUNT(*) AS items_in_order,
               SUM(mi.price) AS total_spend
FROM     dbo.order_details AS od
         INNER JOIN
         dbo.menu_items AS mi
         ON mi.menu_items_id = od.item_id
GROUP BY od.order_id
ORDER BY SUM(mi.price) DESC;
```

|order_id | items_in_order | total_spend |
|---------|----------------|-------------|
| 440     | 14             | 192.15      |
| 2075    | 13             | 191.05      |
| 1957    | 14             | 190.10      |
| 330     | 14             | 189.70      |
| 2675    | 14             | 185.10      |

### کدام سفارش بالاترین مبلغ را دارد و با نگاهی به جزییات سفارش چه دیده می شود؟

```sql
SELECT   TOP 1 od.order_id
FROM     dbo.order_details AS od
         INNER JOIN
         dbo.menu_items AS mi
         ON mi.menu_items_id = od.item_id
GROUP BY od.order_id
ORDER BY SUM(mi.price) DESC;
```

| order_id |
|----------|
| 440      |

```sql
SELECT SUM(mi.price) total_amount
FROM   dbo.order_details AS od
       INNER JOIN
       dbo.menu_items AS mi
       ON mi.menu_items_id = od.item_id
WHERE  od.order_id = 440;
```

|total_amount |
|-------------|
| 192.15      |

```sql
SELECT mi.category,
       mi.item_name,
       mi.price
FROM   dbo.order_details AS od
       INNER JOIN
       dbo.menu_items AS mi
       ON mi.menu_items_id = od.item_id
WHERE  od.order_id = 440;
```

| category | item_name             | price |
|----------|-----------------------|-------|
| Mexican  | Steak Tacos           | 13.95 |
| American | Hot Dog               | 9.00  |
| Italian  | Spaghetti             | 14.50 |
| Italian  | Spaghetti & Meatballs | 17.95 |
| Italian  | Spaghetti & Meatballs | 17.95 |
| Italian  | Fettuccine Alfredo    | 14.50 |
| Italian  | Fettuccine Alfredo    | 14.50 |
| Asian    | Korean Beef Bowl      | 17.95 |
| Italian  | Meat Lasagna          | 17.95 |
| Asian    | Elamame               | 5.00  |
| Mexican  | Chips & Salsa         | 7.00  |
| Italian  | Chicken Parmesan      | 17.95 |
| American | French Fries          | 7.00  |
| Italian  | Eggplant Parmesan     | 16.95 |

```sql
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
```

| category | count_category | total_spent | ratio_of_total |
|----------|----------------|-------------|----------------|
| Italian  | 8              | 132.25      | 68.8           |
| Asian    | 2              | 22.95       | 11.9           |
| Mexican  | 2              | 20.95       | 10.9           |
| American | 2              | 16.00       | 8.3            |

نتیجه:

- گروه Italian: شامل ۸ آیتم با مجموع مبلغ ۱۳۲٫۲۵ دلار است؛ یعنی حدود ۶۸٫۸٪ از مبلغ کل سفارش.
- گروه Asian: شامل ۲ آیتم با مجموع ۲۲٫۹۵ دلار.
- گروه Mexican: شامل ۲ آیتم با مجموع ۲۰٫۹۵ دلار.
- گروه American: شامل ۲ آیتم با مجموع ۱۶ دلار.

مبلغ کل سفارش ۱۹۲٫۱۵ دلار و تعداد ردیف‌های آیتم آن ۱۴ است.

### 5 سفارش برتر با بیشترین مبلغ چه جزیاتی دارند؟ با بررسی چه برداشتی می شود؟

```sql
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
```

| category | item_count | category_amount |
|----------|------------|-----------------|
| Italian  | 26         | 430.65          |
| Asian    | 17         | 228.65          |
| Mexican  | 16         | 189.45          |
| American | 10         | 99.35           |

نتیجه: دسته‌ی Italian بیشترین مبلغ را در مجموع این پنج سفارش داشته است. این نتیجه درباره‌ی همین پنج سفارش است و به‌تنهایی نشان نمی‌دهد که Italian در کل فروش رستوران نیز پردرآمدترین دسته است.

```sql
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
```

| order_id | category | item_count | avg_item_price | amount_share_pct |
|----------|----------|------------|----------------|------------------|
| 330      | Asian    | 6          | 14.6           | 46.1             |
| 330      | Italian  | 3          | 16.8           | 26.6             |
| 330      | Mexican  | 4          | 10.7           | 22.6             |
| 330      | American | 1          | 9.0            | 4.7              |
| 440      | Italian  | 8          | 16.5           | 68.8             |
| 440      | Asian    | 2          | 11.5           | 11.9             |
| 440      | Mexican  | 2          | 10.5           | 10.9             |
| 440      | American | 2          | 8.0            | 8.3              |
| 1957     | Italian  | 5          | 16.9           | 44.3             |
| 1957     | Mexican  | 3          | 14.3           | 22.5             |
| 1957     | Asian    | 3          | 12.2           | 19.2             |
| 1957     | American | 3          | 8.8            | 13.9             |
| 2075     | Italian  | 6          | 16.6           | 52.2             |
| 2075     | Asian    | 3          | 14.5           | 22.7             |
| 2075     | Mexican  | 3          | 11.3           | 17.7             |
| 2075     | American | 1          | 14.0           | 7.3              |
| 2675     | Italian  | 4          | 16.0           | 34.5             |
| 2675     | Mexican  | 4          | 12.2           | 26.4             |
| 2675     | Asian    | 3          | 12.8           | 20.8             |
| 2675     | American | 3          | 11.3           | 18.3             |

- هر پنج سفارش برتر شامل هر چهار دسته‌بندی منو هستند؛ بنابراین، این سفارش‌ها از نظر دسته‌بندی تنوع دارند.
- دسته Italian در چهار سفارش از پنج سفارش، بیشترین سهم را از مبلغ کل دارد. سفارش 330 استثناست که دسته Asian با سهم 46.1٪ در آن غالب است.
- میانگین مبلغ هر آیتم از دسته Italian در این سفارش‌ها نسبتاً بالاست؛ این موضوع می‌تواند یکی از عوامل سهم مالی بالای این دسته باشد.
- در سفارش‌های 440، 1957 و 2075، دسته Italian بیشترین تعداد آیتم را نیز دارد؛ اما در سفارش‌های 330 و 2675، دسته‌های Asian و Mexican به‌ترتیب از نظر تعداد آیتم‌ها پیشتازند.
- این یافته‌ها صرفاً مربوط به پنج سفارش با بیشترین مبلغ هستند و برای نتیجه‌گیری درباره الگوی کلی سفارش مشتریان یا عملکرد کلی دسته‌بندی‌ها، باید تمام سفارش‌ها بررسی شوند.

```sql
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
```

| category |item_name | order_count | ratio_total_order_count | item_count | ratio_total_item_count | item_amount | ratio_total_amount |
|----------|----------|-------------|-------------------------|------------|------------------------|-------------|--------------------|
| Asian    | Korean Beef Bowl | 566 | 4.80 | 588 | 4.86 | 10554.60 | 6.63 |
| Italian  | Spaghetti & Meatballs | 460 | 3.90 | 470 | 3.89 | 8436.50 | 5.30 |
| Asian    | Tofu Pad Thai | 542 | 4.60 | 562 | 4.65 | 8149.00 | 5.12 |
| American | Cheeseburger | 559 | 4.74 | 583 | 4.82 | 8132.85 | 5.11 |
| American | Hamburger | 595 | 5.05 | 622 | 5.14 | 8054.90 | 5.06 |
| Asian    | Orange Chicken | 456 | 3.87 | 456 | 3.77 | 7524.00 | 4.73 |
| Italian  | Eggplant Parmesan | 408 | 3.46 | 420 | 3.47 | 7119.00 | 4.47 |
| Mexican  | Steak Torta | 471 | 3.99 | 489 | 4.04 | 6821.55 | 4.28 |
| Italian  | Chicken Parmesan | 354 | 3.00 | 364 | 3.01 | 6533.80 | 4.10 |
| Asian    | Pork Ramen | 351 | 2.98 | 360 | 2.98 | 6462.00 | 4.06 |
| Mexican  | Chicken Burrito | 441 | 3.74 | 455 | 3.76 | 5892.25 | 3.70 |
| Italian  | Mushroom Ravioli | 356 | 3.02 | 359 | 2.97 | 5564.50 | 3.49 |
| Italian  | Shrimp Scampi | 235 | 1.99 | 239 | 1.98 | 4768.05 | 2.99 |
| Mexican  | Chicken Torta | 369 | 3.13 | 379 | 3.13 | 4529.05 | 2.84 |
| Asian    | California Roll | 348 | 2.95 | 355 | 2.93 | 4242.25 | 2.66 |
| American | French Fries | 547 | 4.64 | 571 | 4.72 | 3997.00 | 2.51 |
| Italian  | Fettuccine Alfredo | 246 | 2.09 | 249 | 2.06 | 3610.50 | 2.27 |
| American | Mac & Cheese | 450 | 3.82 | 463 | 3.83 | 3241.00 | 2.04 |
| American | Veggie Burger | 235 | 1.99 | 238 | 1.97 | 2499.00 | 1.57 |
| Mexican  | Cheese Quesadillas | 229 | 1.94 | 233 | 1.93 | 2446.50 | 1.54 |
| American | Hot Dog | 256 | 2.17 | 257 | 2.12 | 2313.00 | 1.45 |
| Mexican  | Chips & Guacamole | 231 | 1.96 | 237 | 1.96 | 2133.00 | 1.34 |
| Asian    | Potstickers | 201 | 1.70 | 205 | 1.69 | 1845.00 | 1.16 |
| Mexican  | Chicken Tacos | 123 | 1.04 | 123 | 1.02 | 1469.85 | 0.92 |

آیتم Korean Beef Bowl با 566 سفارش، 588 بار ثبت و سهم 6.63٪ از مبلغ کل، پُرمبلغ‌ترین آیتم منو است؛ درحالی‌که Hamburger با 622 بار ثبت، پرتکرارترین آیتم است.

آیتم Tofu Pad Thai، Cheeseburger و Steak Torta نیز از آیتم‌های پُرتکرار هستند؛ در مقابل، Chicken Tacos با سهم 0.92٪ کمترین سهم را از مبلغ کل دارد.

تفاوت رتبه آیتم‌ها در تعداد دفعات ثبت و مبلغ فروش نشان می‌دهد که قیمت هر آیتم نیز در عملکرد مالی آن مؤثر است؛ بنابراین پرتکرارترین آیتم لزوماً پُرفروش‌ترین آیتم از نظر مبلغ نیست.

### بازه زمانی سفارش‌ها در چه ساعاتی است؟

```sql
SELECT min(order_time) AS min_order_time, 
       max(order_time) AS max_order_time 
FROM order_details;
```

| min_order_time | max_order_time |
|----------------|----------------|
| 10:50:46       | 23:05:24       |

```sql
SELECT   DATEPART(HOUR, order_time) AS order_hour,
         COUNT(DISTINCT order_id) AS order_count
FROM     dbo.order_details
GROUP BY DATEPART(HOUR, order_time)
ORDER BY order_hour;
```

| order_hour | order_count |
|------------|-------------|
| 10         | 2           |
| 11         | 288         |
| 12         | 647         |
| 13         | 595         |
| 14         | 426         |
| 15         | 357         |
| 16         | 480         |
| 17         | 623         |
| 18         | 596         |
| 19         | 498         |
| 20         | 413         |
| 21         | 289         |
| 22         | 152         |
| 23         | 4           |

نتیجه:
رستوران در بازه زمانی 10:50 صبح تا 11:05 شب سفارش دارد. بیشترین سفارشات بین ساعت 12 تا 1 بعد از ظهر و 5 تا 6 بعد از ظهر ثبت شده است. کمترین سفارشات در ساعت 10 صبح و 11 شب ثبت شده است.

```sql
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
```

| day_name | order_count | item_count | total_amount | avg_order_value |
|----------|-------------|------------|--------------|-----------------|
| Sunday   | 775         | 1703       | 22451.40     | 28.97           |
| Monday   | 909         | 2054       | 26910.60     | 29.60           |
| Tuesday  | 869         | 2016       | 26677.15     | 30.70           |
| Wednesday| 641         | 1473       | 19498.10     | 30.42           |
| Thursday | 640         | 1426       | 18795.20     | 29.37           |
| Friday   | 786         | 1797       | 23363.00     | 29.72           |
| Saturday | 723         | 1628       | 21522.45     | 29.77           |

نتیجه:

- بیشترین تعداد سفارش در روزهای دوشنبه و سه‌شنبه ثبت شده است.
- کمترین تعداد سفارش در روزهای چهارشنبه و پنج‌شنبه ثبت شده است.

> منو از نظر تنوع، وضعیت قابل‌قبولی دارد و با ۳۲ آیتم در چهار دسته، فعلاً شواهدی برای بازطراحی کامل آن دیده نمی‌شود؛ تعداد آیتم‌ها در دسته‌های ایتالیایی، مکزیکی، آسیایی و آمریکایی به‌ترتیب ۹، ۹، ۸ و ۶ است.
> آیتم Korean Beef Bowl بیشترین مبلغ فروش محاسبه‌شده را دارد و Hamburger پرتکرارترین آیتم است؛ در مقابل، Chicken Tacos کمترین تعداد ثبت و کمترین سهم از مبلغ فروش را دارد.
> پیشنهاد من حفظ آیتم‌های موفق و بررسی هدفمند آیتم‌های ضعیف‌تر، به‌ویژه Chicken Tacos، است؛ اما پیش از حذف یا تغییر قیمت باید هزینه مواد اولیه، حاشیه سود و بازخورد مشتریان هم بررسی شود، چون داده فعلی سود واقعی رستوران را نشان نمی‌دهد.
