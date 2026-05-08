CREATE DATABASE SalesManagement;
USE SalesManagement;

CREATE TABLE Customer(
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    gender INT DEFAULT 1 CHECK(gender IN (0,1)),
    birth_date DATE,
    email VARCHAR(100) UNIQUE,
    customer_type VARCHAR(50)
);

CREATE TABLE Category(
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Product(
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(15,2) NOT NULL CHECK(price > 0),
    stock INT DEFAULT 0 CHECK(stock >= 0),
    category_id INT,
    FOREIGN KEY(category_id) REFERENCES Category(category_id)
);

CREATE TABLE Orders(
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE DEFAULT(CURRENT_DATE),
    status_order VARCHAR(50),
    FOREIGN KEY(customer_id) REFERENCES Customer(customer_id)
);

CREATE TABLE Order_Detail(
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL CHECK(quantity > 0),
    unit_price DECIMAL(15,2) NOT NULL CHECK(unit_price > 0),
    FOREIGN KEY(order_id) REFERENCES Orders(order_id),
    FOREIGN KEY(product_id) REFERENCES Product(product_id)
);

INSERT INTO Customer(customer_name, gender, birth_date, email, customer_type)
VALUES
('Nguyen Van A', 1, '2000-05-10', 'a@gmail.com', 'VIP'),
('Tran Thi B', 0, '1998-08-15', 'b@gmail.com', 'Normal'),
('Le Van C', 1, '2003-12-20', 'c@gmail.com', 'VIP'),
('Pham Thi D', 0, '1995-03-25', 'd@gmail.com', 'Normal'),
('Hoang Van E', 1, '2001-11-11', 'e@gmail.com', 'VIP');

INSERT INTO Category(category_name)
VALUES
('Điện tử'),
('Thời trang'),
('Gia dụng'),
('Sách'),
('Thể thao');

INSERT INTO Product(product_name, price, stock, category_id)
VALUES
('Laptop Dell', 2000, 10, 1),
('Iphone 15', 3000, 15, 1),
('Áo Hoodie', 500, 20, 2),
('Nồi cơm điện', 700, 12, 3),
('Giày thể thao', 1200, 8, 5),
('Tai nghe Bluetooth', 800, 25, 1);

INSERT INTO Orders(customer_id, order_date, status_order)
VALUES
(1, '2025-01-01', 'Completed'),
(2, '2025-01-05', 'Completed'),
(3, '2025-01-10', 'Pending'),
(4, '2025-01-15', 'Completed'),
(5, '2025-01-20', 'Cancelled');

INSERT INTO Order_Detail(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 1, 2000),
(1, 3, 2, 500),
(2, 2, 1, 3000),
(3, 4, 1, 700),
(4, 5, 1, 1200),
(5, 6, 2, 800);

UPDATE Product
SET price = 2500
WHERE product_id = 1;

UPDATE Customer
SET email = 'newemail@gmail.com'
WHERE customer_id = 2;

DELETE FROM Order_Detail
WHERE order_detail_id = 5;

SELECT 
    customer_name AS full_name,
    email,
    CASE
        WHEN gender = 1 THEN 'Nam'
        ELSE 'Nữ'
    END AS gender_name
FROM Customer;

SELECT 
    customer_name,
    YEAR(NOW()) - YEAR(birth_date) AS age
FROM Customer
ORDER BY age ASC
LIMIT 3;

SELECT 
    o.order_id,
    c.customer_name,
    o.order_date,
    o.status_order
FROM Orders o
INNER JOIN Customer c
ON o.customer_id = c.customer_id;

SELECT 
    c.category_name,
    COUNT(p.product_id) AS total_product
FROM Category c
INNER JOIN Product p
ON c.category_id = p.category_id
GROUP BY c.category_name
HAVING COUNT(p.product_id) >= 2;

SELECT *
FROM Product
WHERE price > (
    SELECT AVG(price)
    FROM Product
);

SELECT *
FROM Customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM Orders o
    WHERE o.customer_id = c.customer_id
);

SELECT 
    c.category_name,
    SUM(od.quantity * od.unit_price) AS total_revenue
FROM Category c
INNER JOIN Product p
ON c.category_id = p.category_id
INNER JOIN Order_Detail od
ON p.product_id = od.product_id
GROUP BY c.category_name
HAVING SUM(od.quantity * od.unit_price) > (
    SELECT AVG(total_rev) * 1.2
    FROM (
        SELECT 
            SUM(od2.quantity * od2.unit_price) AS total_rev
        FROM Product p2
        INNER JOIN Order_Detail od2
        ON p2.product_id = od2.product_id
        GROUP BY p2.category_id
    ) temp
);

SELECT *
FROM Product p1
WHERE price = (
    SELECT MAX(p2.price)
    FROM Product p2
    WHERE p1.category_id = p2.category_id
);

SELECT customer_name
FROM Customer
WHERE customer_type = 'VIP'
AND customer_id IN (
    SELECT customer_id
    FROM Orders
    WHERE order_id IN (
        SELECT order_id
        FROM Order_Detail
        WHERE product_id IN (
            SELECT product_id
            FROM Product
            WHERE category_id = (
                SELECT category_id
                FROM Category
                WHERE category_name = 'Điện tử'
            )
        )
    )
);