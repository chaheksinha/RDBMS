-- Experiment 10
-- Five slow query shapes on an orders database, then the
-- same questions rewritten so an index can be used.

DROP DATABASE IF EXISTS OptimizationDB;
CREATE DATABASE OptimizationDB;
USE OptimizationDB;

DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers (
    customer_id     INT AUTO_INCREMENT PRIMARY KEY,
    customer_name   VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL,
    city            VARCHAR(50)  NOT NULL,
    signup_date     DATE         NOT NULL
);

CREATE TABLE Orders (
    order_id        INT AUTO_INCREMENT PRIMARY KEY,
    customer_id     INT NOT NULL,
    order_date      DATETIME NOT NULL,
    order_status    VARCHAR(20) NOT NULL,
    payment_method  VARCHAR(20) NOT NULL,
    total_amount    DECIMAL(10,2) NOT NULL,
    shipping_city   VARCHAR(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

DROP PROCEDURE IF EXISTS GenerateEcommerceData;

DELIMITER //

CREATE PROCEDURE GenerateEcommerceData()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE rand_cust_id INT;
    DECLARE rand_status VARCHAR(20);
    DECLARE rand_payment VARCHAR(20);
    DECLARE rand_city VARCHAR(50);
    DECLARE rand_amount DECIMAL(10,2);
    DECLARE rand_dt DATETIME;

    SET autocommit = 0;

    WHILE i <= 2000 DO
        INSERT INTO Customers (customer_name, email, city, signup_date)
        VALUES (
            CONCAT('Customer_', i),
            CONCAT('user', i, '@', ELT(FLOOR(1 + RAND() * 4), 'gmail.com', 'yahoo.com', 'outlook.com', 'company.in')),
            ELT(FLOOR(1 + (RAND() * 5)), 'Mumbai', 'Delhi', 'Bangalore', 'Pune', 'Hyderabad'),
            DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 700) DAY)
        );
        SET i = i + 1;
    END WHILE;

    COMMIT;
    SET i = 1;

    WHILE i <= 12000 DO
        SET rand_cust_id = 1 + FLOOR(RAND() * 2000);
        SET rand_status  = ELT(FLOOR(1 + (RAND() * 3)), 'COMPLETED', 'PENDING', 'CANCELLED');
        SET rand_payment = ELT(FLOOR(1 + (RAND() * 4)), 'CREDIT_CARD', 'UPI', 'NET_BANKING', 'COD');
        SET rand_city    = ELT(FLOOR(1 + (RAND() * 5)), 'Mumbai', 'Delhi', 'Bangalore', 'Pune', 'Hyderabad');
        SET rand_amount  = ROUND(100.00 + (RAND() * 9900.00), 2);
        SET rand_dt      = DATE_ADD('2024-01-01 08:00:00', INTERVAL FLOOR(RAND() * 730 * 24 * 60) MINUTE);

        INSERT INTO Orders (
            customer_id, order_date, order_status, payment_method, total_amount, shipping_city
        ) VALUES (
            rand_cust_id, rand_dt, rand_status, rand_payment, rand_amount, rand_city
        );

        SET i = i + 1;
    END WHILE;

    COMMIT;
    SET autocommit = 1;
END //

DELIMITER ;

CALL GenerateEcommerceData();

-- A few fixed rows so the prefix search and the year filter
-- have a known target even when the random dates miss 2025.
INSERT INTO Customers (customer_name, email, city, signup_date)
VALUES ('User One Hundred', 'user100@gmail.com', 'Delhi', '2024-04-01');

INSERT INTO Orders (customer_id, order_date, order_status, payment_method, total_amount, shipping_city)
SELECT customer_id, '2025-06-15 10:00:00', 'COMPLETED', 'UPI', 2500.00, 'Delhi'
FROM Customers
WHERE email = 'user100@gmail.com';

-- CAPTURE output-01
SELECT 'Customers' AS entity, COUNT(*) AS row_count FROM Customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM Orders;

-- =====================================================
-- 1. YEAR(order_date) cannot use an index. A range can.
-- =====================================================

-- CAPTURE output-02
EXPLAIN SELECT COUNT(*), SUM(total_amount)
FROM Orders
WHERE YEAR(order_date) = 2025;

CREATE INDEX idx_orders_order_date ON Orders(order_date);

-- A one-month range is selective enough for the optimizer to use the index.
-- CAPTURE output-03
EXPLAIN SELECT COUNT(*), SUM(total_amount)
FROM Orders
WHERE order_date >= '2025-06-01 00:00:00'
  AND order_date <  '2025-07-01 00:00:00';

-- CAPTURE output-04
SELECT COUNT(*) AS orders_in_june_2025, SUM(total_amount) AS amount_in_june_2025
FROM Orders
WHERE order_date >= '2025-06-01 00:00:00'
  AND order_date <  '2025-07-01 00:00:00';

-- =====================================================
-- 2. A leading wildcard cannot walk a B-tree.
-- A prefix can.
-- =====================================================

-- CAPTURE output-05
EXPLAIN SELECT customer_id, customer_name, email
FROM Customers
WHERE email LIKE '%@gmail.com';

CREATE INDEX idx_customers_email ON Customers(email);

-- CAPTURE output-06
EXPLAIN SELECT customer_id, customer_name, email
FROM Customers
WHERE email LIKE 'user100%';

-- CAPTURE output-07
SELECT customer_id, customer_name, email
FROM Customers
WHERE email LIKE 'user100%';

-- =====================================================
-- 3. NOT IN against a subquery, then an anti-join.
-- =====================================================

-- CAPTURE output-08
EXPLAIN SELECT customer_id, customer_name
FROM Customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM Orders
    WHERE order_status = 'COMPLETED'
);

CREATE INDEX idx_orders_cust_status ON Orders(customer_id, order_status);

-- CAPTURE output-09
EXPLAIN SELECT c.customer_id, c.customer_name
FROM Customers c
LEFT JOIN Orders o
       ON c.customer_id = o.customer_id
      AND o.order_status = 'COMPLETED'
WHERE o.order_id IS NULL;

-- CAPTURE output-10
SELECT COUNT(*) AS customers_without_completed_order
FROM Customers c
LEFT JOIN Orders o
       ON c.customer_id = o.customer_id
      AND o.order_status = 'COMPLETED'
WHERE o.order_id IS NULL;

-- =====================================================
-- 4. ORDER BY ... LIMIT without an index, then with one.
-- =====================================================

-- CAPTURE output-11
EXPLAIN SELECT order_id, customer_id, total_amount, order_date
FROM Orders
WHERE order_status = 'COMPLETED'
ORDER BY total_amount DESC
LIMIT 10;

CREATE INDEX idx_status_amount ON Orders(order_status, total_amount);

-- CAPTURE output-12
EXPLAIN SELECT order_id, customer_id, total_amount, order_date
FROM Orders
WHERE order_status = 'COMPLETED'
ORDER BY total_amount DESC
LIMIT 10;

-- CAPTURE output-13
SELECT order_id, customer_id, total_amount, order_date
FROM Orders
WHERE order_status = 'COMPLETED'
ORDER BY total_amount DESC
LIMIT 10;

-- =====================================================
-- 5. Join and GROUP BY, then covering indexes.
-- =====================================================

-- CAPTURE output-14
EXPLAIN SELECT c.city, COUNT(o.order_id) AS total_orders, SUM(o.total_amount) AS revenue
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'COMPLETED'
GROUP BY c.city
ORDER BY revenue DESC;

CREATE INDEX idx_customers_id_city ON Customers(customer_id, city);
CREATE INDEX idx_orders_covering ON Orders(customer_id, order_status, total_amount);

-- CAPTURE output-15
EXPLAIN SELECT c.city, COUNT(o.order_id) AS total_orders, SUM(o.total_amount) AS revenue
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'COMPLETED'
GROUP BY c.city
ORDER BY revenue DESC;

-- CAPTURE output-16
SELECT c.city, COUNT(o.order_id) AS total_orders, SUM(o.total_amount) AS revenue
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'COMPLETED'
GROUP BY c.city
ORDER BY revenue DESC;
