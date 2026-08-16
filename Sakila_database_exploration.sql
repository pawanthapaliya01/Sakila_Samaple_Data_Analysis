/* ============================================================
   SAKILA DVD RENTAL BUSINESS ANALYSIS
   Database: Sakila
   SQL: MySQL
   Purpose: Portfolio / Data Analyst SQL Project
   ============================================================ */


/* ============================================================
   1. DATABASE EXPLORATION
   ============================================================ */

SHOW DATABASES;

USE sakila;

SELECT DATABASE();

SHOW TABLES;

DESCRIBE customer;
DESCRIBE film;
DESCRIBE rental;
DESCRIBE payment;
DESCRIBE inventory;
DESCRIBE category;
DESCRIBE store;


/* ============================================================
   2. BUSINESS OVERVIEW / KEY PERFORMANCE INDICATORS
   ============================================================ */

-- Total customers
SELECT
    COUNT(*) AS total_customers
FROM customer;


-- Total films
SELECT
    COUNT(*) AS total_films
FROM film;


-- Total rentals
SELECT
    COUNT(*) AS total_rentals
FROM rental;


-- Total revenue
SELECT
    ROUND(SUM(amount), 2) AS total_revenue
FROM payment;


-- Average, minimum and maximum payment
SELECT
    ROUND(AVG(amount), 2) AS average_payment,
    ROUND(MIN(amount), 2) AS minimum_payment,
    ROUND(MAX(amount), 2) AS maximum_payment
FROM payment;


/* ============================================================
   3. BASIC FILTERING
   WHERE, AND, OR, NOT, IN, BETWEEN, LIKE
   ============================================================ */

-- Films with rental rate between $2 and $4
SELECT
    film_id,
    title,
    rental_rate
FROM film
WHERE rental_rate BETWEEN 2 AND 4
ORDER BY rental_rate DESC;


-- PG and PG-13 films
SELECT
    film_id,
    title,
    rating
FROM film
WHERE rating IN ('PG', 'PG-13')
ORDER BY title;


-- Films that are NOT rated R
SELECT
    film_id,
    title,
    rating
FROM film
WHERE NOT rating = 'R'
ORDER BY title;


-- Films with rental rate greater than $3 OR replacement cost greater than $20
SELECT
    film_id,
    title,
    rental_rate,
    replacement_cost
FROM film
WHERE rental_rate > 3
   OR replacement_cost > 20
ORDER BY rental_rate DESC;


-- Films with "LOVE" in the title
SELECT
    film_id,
    title
FROM film
WHERE title LIKE '%LOVE%';


/* ============================================================
   4. DISTINCT
   ============================================================ */

-- Different movie ratings
SELECT DISTINCT
    rating
FROM film
ORDER BY rating;


-- Different rental rates
SELECT DISTINCT
    rental_rate
FROM film
ORDER BY rental_rate;


/* ============================================================
   5. ORDER BY AND LIMIT
   ============================================================ */

-- Top 10 most expensive films to rent
SELECT
    title,
    rental_rate
FROM film
ORDER BY rental_rate DESC
LIMIT 10;


-- 10 films with the lowest rental rate
SELECT
    title,
    rental_rate
FROM film
ORDER BY rental_rate ASC
LIMIT 10;


/* ============================================================
   6. CUSTOMER ANALYSIS
   INNER JOIN + GROUP BY + COUNT
   ============================================================ */

-- Number of rentals per customer
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(r.rental_id) AS total_rentals
FROM customer c
INNER JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_rentals DESC;


-- Top 10 customers by rentals
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(r.rental_id) AS total_rentals
FROM customer c
INNER JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY total_rentals DESC
LIMIT 10;


/* ============================================================
   7. CUSTOMER REVENUE
   SUM + HAVING
   ============================================================ */

-- Customers generating more than $100
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(p.amount), 2) AS total_revenue
FROM customer c
INNER JOIN payment p
    ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
HAVING SUM(p.amount) > 100
ORDER BY total_revenue DESC;


/* ============================================================
   8. CUSTOMER SEGMENTATION
   CASE
   ============================================================ */

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(p.amount), 2) AS total_spending,

    CASE
        WHEN SUM(p.amount) >= 150 THEN 'High Value'
        WHEN SUM(p.amount) >= 100 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment

FROM customer c
INNER JOIN payment p
    ON c.customer_id = p.customer_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name

ORDER BY total_spending DESC;


/* ============================================================
   9. LEFT JOIN
   Find customers and their rental activity
   ============================================================ */

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY rental_count;


/* ============================================================
   10. FILM ANALYSIS
   ============================================================ */

-- Film rental duration
SELECT
    title,
    rental_duration
FROM film
ORDER BY rental_duration DESC;


-- Films with above-average rental rate
SELECT
    title,
    rental_rate
FROM film
WHERE rental_rate > (
    SELECT AVG(rental_rate)
    FROM film
)
ORDER BY rental_rate DESC;


/* ============================================================
   11. MOST RENTED FILMS
   film -> inventory -> rental
   ============================================================ */

SELECT
    f.film_id,
    f.title,
    COUNT(r.rental_id) AS total_rentals
FROM film f
INNER JOIN inventory i
    ON f.film_id = i.film_id
INNER JOIN rental r
    ON i.inventory_id = r.inventory_id
GROUP BY
    f.film_id,
    f.title
ORDER BY total_rentals DESC;


-- Top 10 most rented films
SELECT
    f.film_id,
    f.title,
    COUNT(r.rental_id) AS total_rentals
FROM film f
INNER JOIN inventory i
    ON f.film_id = i.film_id
INNER JOIN rental r
    ON i.inventory_id = r.inventory_id
GROUP BY
    f.film_id,
    f.title
ORDER BY total_rentals DESC
LIMIT 10;


/* ============================================================
   12. CATEGORY ANALYSIS
   ============================================================ */

SELECT
    c.name AS category,
    COUNT(r.rental_id) AS total_rentals
FROM category c
INNER JOIN film_category fc
    ON c.category_id = fc.category_id
INNER JOIN film f
    ON fc.film_id = f.film_id
INNER JOIN inventory i
    ON f.film_id = i.film_id
INNER JOIN rental r
    ON i.inventory_id = r.inventory_id
GROUP BY
    c.category_id,
    c.name
ORDER BY total_rentals DESC;


/* ============================================================
   13. REVENUE BY CATEGORY
   ============================================================ */

SELECT
    c.name AS category,
    COUNT(p.payment_id) AS total_transactions,
    ROUND(SUM(p.amount), 2) AS total_revenue
FROM category c
INNER JOIN film_category fc
    ON c.category_id = fc.category_id
INNER JOIN film f
    ON fc.film_id = f.film_id
INNER JOIN inventory i
    ON f.film_id = i.film_id
INNER JOIN rental r
    ON i.inventory_id = r.inventory_id
INNER JOIN payment p
    ON r.rental_id = p.rental_id
GROUP BY
    c.category_id,
    c.name
ORDER BY total_revenue DESC;


/* ============================================================
   14. CATEGORY HAVING
   Categories with more than 500 rentals
   ============================================================ */

SELECT
    c.name AS category,
    COUNT(r.rental_id) AS total_rentals
FROM category c
INNER JOIN film_category fc
    ON c.category_id = fc.category_id
INNER JOIN film f
    ON fc.film_id = f.film_id
INNER JOIN inventory i
    ON f.film_id = i.film_id
INNER JOIN rental r
    ON i.inventory_id = r.inventory_id
GROUP BY
    c.category_id,
    c.name
HAVING COUNT(r.rental_id) > 500
ORDER BY total_rentals DESC;


/* ============================================================
   15. DATE ANALYSIS
   YEAR, MONTH, MONTHNAME
   ============================================================ */

-- Rentals by year and month
SELECT
    YEAR(rental_date) AS rental_year,
    MONTH(rental_date) AS rental_month,
    MONTHNAME(rental_date) AS month_name,
    COUNT(*) AS total_rentals
FROM rental
GROUP BY
    YEAR(rental_date),
    MONTH(rental_date),
    MONTHNAME(rental_date)
ORDER BY
    rental_year,
    rental_month;


/* ============================================================
   16. RENTAL DURATION
   DATEDIFF
   ============================================================ */

SELECT
    rental_id,
    rental_date,
    return_date,
    DATEDIFF(return_date, rental_date) AS rental_days
FROM rental
WHERE return_date IS NOT NULL
ORDER BY rental_days DESC;


/* ============================================================
   17. AVERAGE RENTAL DURATION
   ============================================================ */

SELECT
    ROUND(
        AVG(DATEDIFF(return_date, rental_date)),
        2
    ) AS average_rental_days
FROM rental
WHERE return_date IS NOT NULL;


/* ============================================================
   18. STRING FUNCTIONS
   CONCAT, UPPER, LOWER, LENGTH
   ============================================================ */

SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    UPPER(first_name) AS first_name_upper,
    LOWER(last_name) AS last_name_lower,
    LENGTH(first_name) AS first_name_length
FROM customer;


/* ============================================================
   19. NULL HANDLING
   IS NULL, IS NOT NULL, COALESCE
   ============================================================ */

-- Rentals that have not been returned
SELECT
    rental_id,
    customer_id,
    rental_date,
    return_date
FROM rental
WHERE return_date IS NULL;


-- Rentals that have been returned
SELECT
    rental_id,
    customer_id,
    rental_date,
    return_date
FROM rental
WHERE return_date IS NOT NULL;


-- Replace NULL return dates with text
SELECT
    rental_id,
    customer_id,
    rental_date,
    COALESCE(
        CAST(return_date AS CHAR),
        'Not Returned'
    ) AS return_status
FROM rental;


/* ============================================================
   20. STORE ANALYSIS
   ============================================================ */

-- Revenue by store
SELECT
    s.store_id,
    ROUND(SUM(p.amount), 2) AS total_revenue
FROM store s
INNER JOIN staff st
    ON s.store_id = st.store_id
INNER JOIN payment p
    ON st.staff_id = p.staff_id
GROUP BY
    s.store_id
ORDER BY total_revenue DESC;


-- Rentals by store
SELECT
    i.store_id,
    COUNT(r.rental_id) AS total_rentals
FROM inventory i
INNER JOIN rental r
    ON i.inventory_id = r.inventory_id
GROUP BY
    i.store_id
ORDER BY total_rentals DESC;


/* ============================================================
   21. STAFF PERFORMANCE
   ============================================================ */

SELECT
    st.staff_id,
    CONCAT(st.first_name, ' ', st.last_name) AS staff_name,
    COUNT(p.payment_id) AS transactions,
    ROUND(SUM(p.amount), 2) AS total_revenue
FROM staff st
INNER JOIN payment p
    ON st.staff_id = p.staff_id
GROUP BY
    st.staff_id,
    st.first_name,
    st.last_name
ORDER BY total_revenue DESC;


/* ============================================================
   22. CUSTOMER REVENUE CTE
   ============================================================ */

WITH customer_revenue AS (

    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(p.amount) AS total_revenue

    FROM customer c

    INNER JOIN payment p
        ON c.customer_id = p.customer_id

    GROUP BY
        c.customer_id,
        c.first_name,
        c.last_name
)

SELECT
    customer_id,
    customer_name,
    ROUND(total_revenue, 2) AS total_revenue
FROM customer_revenue
ORDER BY total_revenue DESC;


/* ============================================================
   23. CTE + HAVING
   ============================================================ */

WITH customer_revenue AS (

    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id

)

SELECT
    customer_id,
    ROUND(total_revenue, 2) AS total_revenue
FROM customer_revenue
WHERE total_revenue > 100
ORDER BY total_revenue DESC;


/* ============================================================
   24. WINDOW FUNCTIONS
   RANK, DENSE_RANK, ROW_NUMBER
   ============================================================ */

WITH customer_revenue AS (

    SELECT
        customer_id,
        SUM(amount) AS total_revenue
    FROM payment
    GROUP BY customer_id

)

SELECT
    customer_id,
    ROUND(total_revenue, 2) AS total_revenue,

    RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank,

    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS dense_revenue_rank,

    ROW_NUMBER() OVER (
        ORDER BY total_revenue DESC
    ) AS all_row_number

FROM customer_revenue;


/* ============================================================
   25. PARTITION BY
   Rank customers within each store
   ============================================================ */

WITH customer_revenue AS (

    SELECT
        c.customer_id,
        c.store_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(p.amount) AS total_revenue

    FROM customer c

    INNER JOIN payment p
        ON c.customer_id = p.customer_id

    GROUP BY
        c.customer_id,
        c.store_id,
        c.first_name,
        c.last_name
)

SELECT
    customer_id,
    store_id,
    customer_name,
    ROUND(total_revenue, 2) AS total_revenue,

    RANK() OVER (
        PARTITION BY store_id
        ORDER BY total_revenue DESC
    ) AS store_rank

FROM customer_revenue;


/* ============================================================
   26. WINDOW AGGREGATE
   Running / cumulative revenue
   ============================================================ */

SELECT
    DATE(payment_date) AS payment_day,
    ROUND(SUM(amount), 2) AS daily_revenue,

    ROUND(
        SUM(SUM(amount)) OVER (
            ORDER BY DATE(payment_date)
        ),
        2
    ) AS cumulative_revenue

FROM payment

GROUP BY DATE(payment_date)

ORDER BY payment_day;


/* ============================================================
   27. UNION
   Combine customers and staff
   ============================================================ */

SELECT
    first_name,
    last_name,
    'Customer' AS person_type
FROM customer

UNION

SELECT
    first_name,
    last_name,
    'Staff' AS person_type
FROM staff;


/* ============================================================
   28. SELF JOIN
   Compare customers in the same store
   ============================================================ */

SELECT
    c1.customer_id AS customer_1,
    CONCAT(c1.first_name, ' ', c1.last_name) AS customer_1_name,
    c2.customer_id AS customer_2,
    CONCAT(c2.first_name, ' ', c2.last_name) AS customer_2_name,
    c1.store_id
FROM customer c1
INNER JOIN customer c2
    ON c1.store_id = c2.store_id
   AND c1.customer_id < c2.customer_id
LIMIT 20;


/* ============================================================
   29. VIEW
   Create reusable customer revenue analysis
   ============================================================ */

CREATE OR REPLACE VIEW customer_revenue AS

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(p.amount), 2) AS total_revenue

FROM customer c

INNER JOIN payment p
    ON c.customer_id = p.customer_id

GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name;


/* Use the view */

SELECT *
FROM customer_revenue
ORDER BY total_revenue DESC;


/* ============================================================
   30. VIEW + FILTERING
   ============================================================ */

SELECT
    customer_id,
    customer_name,
    total_revenue
FROM customer_revenue
WHERE total_revenue > 100
ORDER BY total_revenue DESC;


/* ============================================================
   31. INDEX
   Demonstration of indexing for search performance
   ============================================================ */

CREATE INDEX idx_customer_last_name
ON customer(last_name);


/* Check indexes */

SHOW INDEX FROM customer;


/* ============================================================
   32. FINAL EXECUTIVE KPI SUMMARY
   ============================================================ */

SELECT
    (SELECT COUNT(*) FROM customer) AS total_customers,

    (SELECT COUNT(*) FROM film) AS total_films,

    (SELECT COUNT(*) FROM rental) AS total_rentals,

    (SELECT ROUND(SUM(amount), 2)
     FROM payment) AS total_revenue,

    (SELECT ROUND(AVG(amount), 2)
     FROM payment) AS average_payment,

    (SELECT ROUND(MAX(amount), 2)
     FROM payment) AS highest_payment;


/* ============================================================
   33. TOP CUSTOMER
   ============================================================ */

SELECT
    customer_id,
    customer_name,
    total_revenue
FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 1;


/* ============================================================
   34. TOP 10 CUSTOMERS
   ============================================================ */

SELECT
    customer_id,
    customer_name,
    total_revenue
FROM customer_revenue
ORDER BY total_revenue DESC
LIMIT 10;


/* ============================================================
   END OF SAKILA DVD RENTAL BUSINESS ANALYSIS
   ============================================================ */