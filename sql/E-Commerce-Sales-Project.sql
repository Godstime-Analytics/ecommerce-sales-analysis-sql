-- ====================
-- CREATE TABLE
-- ====================
CREATE TABLE customers (
			customer_id SERIAL PRIMARY KEY,
			First_name VARCHAR(50),
			Last_name VARCHAR(50),
			email VARCHAR(100),
			city VARCHAR(50),
			signup_date date
);

CREATE TABLE products (
			product_id SERIAL PRIMARY KEY,
			product_name VARCHAR(100),
			category VARCHAR(50),
			price NUMERIC(10,2)
);

CREATE TABLE orders (
			order_id SERIAL PRIMARY KEY,
			customer_id INT REFERENCES customers(customer_id),
			order_date DATE
);

CREATE TABLE order_items (
			order_item_id SERIAL PRIMARY KEY,
			order_id INT REFERENCES orders(order_id),
			product_id INT REFERENCES products(product_id),
			quantity INT
);

-- ============
-- INSERT DATA
-- ============
INSERT INTO customers (first_name, last_name, email, city, signup_date) 
	VALUES
		('David', 'Okoro', 'david.okoro@email.com', 'Lagos', '2024-01-15'),
		('Sarah', 'Adebayo', 'sarah.adebayo@email.com', 'Abuja', '2024-02-10'),
		('Michael', 'Ibrahim', 'michael.ibrahim@email.com', 'Kano', '2024-03-05'),
		('Grace', 'Mensah', 'grace.mensah@email.com', 'Accra', '2024-01-25'),
		('Daniel', 'Eze', 'daniel.eze@email.com', 'Port Harcourt', '2024-04-12'),
		('Joy', 'Balogun', 'joy.balogun@email.com', 'Lagos', '2024-05-01'),
		('Samuel', 'Osei', 'samuel.osei@email.com', 'Accra', '2024-02-18'),
		('Esther', 'Nwosu', 'esther.nwosu@email.com', 'Abuja', '2024-06-20'),
		('Paul', 'Adeyemi', 'paul.adeyemi@email.com', 'Ibadan', '2024-07-10'),
		('Linda', 'Okafor', 'linda.okafor@email.com', 'Lagos', '2024-08-03');

INSERT INTO products (product_name, category, price)
	VALUES
		('iPhone 14', 	'Electronics', 900.00),
		('Samsung TV', 	'Electronics', 650.00),
		('HP Laptop', 	'Electronics', 750.00),
		('Office Chair', 'Furniture', 120.00),
		('Standing Desk', 'Furniture', 300.00),
		('Nike Sneakers', 'Fashion', 150.00),
		('Leather Bag',  'Fashion', 200.00),
		('Wrist Watch', 'Accessories', 180.00),
		('Bluetooth Speaker', 'Electronics', 85.00),
		('Backpack', 'Fashion', 75.00);

INSERT INTO orders (customer_id, order_date) 
	VALUES
		(1, '2024-09-01'),
		(2, '2024-09-02'),
		(3, '2024-09-05'),
		(1, '2024-09-10'),
		(5, '2024-09-12'),
		(6, '2024-09-15'),
		(7, '2024-09-18'),
		(8, '2024-09-20'),
		(9, '2024-09-25'),
		(10, '2024-09-28'),
		(4, '2024-10-01'),
		(2, '2024-10-03'),
		(3, '2024-10-05');

INSERT INTO order_items (order_id, product_id, quantity)
	VALUES
		(1, 1, 1),
		(1, 9, 2),
		(2, 2, 1),
		(3, 3, 1),
		(4, 6, 2),
		(5, 5, 1),
		(6, 7, 1),
		(7, 4, 2),
		(8, 8, 1),
		(9, 10, 3),
		(10, 1, 1),
		(11, 2, 1),
		(12, 6, 1),
		(13, 3, 2),
		(13, 9, 1);

INSERT INTO customers (first_name, last_name, email, city, signup_date)
	VALUES ('David', 'Okoro', 'david.okoro@email.com', 'Lagos', '2024-01-15');

-- =============
-- DATA CLEANING
-- =============

-- Find Duplicate rows
SELECT * 
FROM	(SELECT *,
				ROW_NUMBER() OVER (PARTITION BY first_name, last_name, email, city, signup_date
												ORDER BY customer_id) AS rn
		FROM customers
)t
where rn > 1;

-- Delete duplicate rows 
WITH duplicates AS (SELECT customer_id,
				ROW_NUMBER() OVER (PARTITION BY first_name, last_name, email, city, signup_date
												ORDER BY customer_id) AS rn
		FROM customers
)

DELETE FROM customers
WHERE customer_id IN (SELECT customer_id
						FROM duplicates
						WHERE rn > 1);

-- Check if duplicate still exit
SELECT first_name, last_name, email, city, signup_date, count(*)
FROM customers
GROUP BY first_name, last_name, email, city, signup_date
HAVING count(*) >1;

select * from customers;

-- ========
-- ANALYSIS
-- ========

SELECT *
FROM orders
where order_date between '2024-01-01' and '2025-01-01'
ORDER BY order_date;

SELECT *
FROM customers
WHERE city = 'Lagos';

SELECT *
FROM products
WHERE category = 'Electronics';

-- REVENUE

SELECT SUM(oi.quantity * p.price) AS Total_Revenue
FROM order_items oi
join products p
on p.product_id = oi.product_id;

-- Revenue by category

SELECT p.category, SUM(oi.quantity * p.price) AS Total_Revenue
FROM order_items oi
join products p
on p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_revenue desc;

-- TOP Customers

SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, sum(quantity * price) AS total_spent
FROM customers c
JOIN orders o 		ON o.customer_id = c.customer_id
JOIN order_items oi 	ON o.order_id = oi.order_id
JOIN products p 		ON p.product_id = oi.product_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent desc
LIMIT 5;

-- Order by city

SELECT c.city, count(o.order_id) AS Total_orders
FROM customers c
JOIN orders o
ON o.customer_id = c.customer_id
GROUP BY c.city
ORDER BY Total_orders DESC;

-- Top 3 product by revenue
SELECT p.product_id, SUM(oi.quantity * p.price) as revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY revenue DESC
LIMIT 3;

-- rank product by revenue
SELECT product_id, revenue,
RANK() OVER (ORDER BY revenue DESC) AS product_rank
	FROM (SELECT p.product_id, SUM(oi.quantity * p.price) as revenue
			FROM products p
			JOIN order_items oi
			ON p.product_id = oi.product_id
			GROUP BY p.product_id) AS product_revenue;

-- Best selling category
SELECT p.category, SUM(oi.quantity * p.price) as revenue
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY revenue DESC
LIMIT 1;

-- Customers lifetime value
SELECT  c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
		SUM(oi.quantity * p.price) as Customers_lifetime_value
FROM customers c
JOIN orders o 		ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p 	ON p.product_id = oi.product_id
GROUP BY c.customer_id;

-- Rank customers by Lifetime value
SELECT customer_id, customer_name, customers_lifetime_value,
	RANK() OVER (ORDER BY customers_lifetime_value DESC) AS customer_rank
FROM (
SELECT  c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
		SUM(oi.quantity * p.price) as Customers_lifetime_value
FROM customers c
JOIN orders o 		ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p 	ON p.product_id = oi.product_id
GROUP BY c.customer_id
) AS customer_clv;

-- Monthly revenue
SELECT DATE_TRUNC('month', o.order_date) AS month, SUM(oi.quantity * p.price) as revenue
FROM orders o
JOIN order_items oi
ON o.order_id = oi.order_id
JOIN products p
ON p.product_id = oi.product_id
GROUP BY month
ORDER BY month;

-- Master dataset
SELECT  oi.order_item_id, o.order_id, o.order_date, c.customer_id, 
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name, c.city, 
		p.product_id, p.product_name, p.category, oi.quantity, p.price, 
		(oi.quantity * p.price) AS revenue
FROM customers c
JOIN orders o 		ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p 	ON p.product_id = oi.product_id;








