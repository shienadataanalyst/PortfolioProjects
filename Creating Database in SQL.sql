-- Creating the customers table.

	CREATE TABLE customers (
	customer_id INT PRIMARY KEY,
	customer_firstname VARCHAR(50) NOT NULL,
	customer_lastname VARCHAR(50) NOT NULL
	);

-- Creating the address table.

	CREATE TABLE address (
	address_id INT PRIMARY KEY,
	delivery_address VARCHAR(200) NOT NULL, 
    delivery_city VARCHAR(50) NOT NULL,
    delivery_zipcode VARCHAR(50)
	);

-- Creating the orders table with customer_id and address_id defined as foreign keys referencing the customer_id column in the customers table and address_id column in the address table.

	CREATE TABLE orders (
    order_id VARCHAR(10) PRIMARY KEY, 
    order_date DATE NOT NULL,
    item_name VARCHAR(50) NOT NULL,
    item_category VARCHAR(50) NOT NULL,
    item_size VARCHAR(50),
    item_price DECIMAL(8,2) CHECK (item_price > 0),
    quantity INT CHECK (quantity > 0),
    customer_id INT NOT NULL,
    address_id INT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
	FOREIGN KEY (address_id) REFERENCES address(address_id)
	);

-- Adding values into the tables.

	INSERT INTO customers (customer_id, customer_firstname, customer_lastname)
	VALUES (1, 'Olivia', 'Smith');

	INSERT INTO address (address_id, delivery_address, delivery_city, delivery_zipcode)
	VALUES (101, '123 Main St', 'New York', '10001');

	INSERT INTO orders (order_id, order_date, item_name, item_category, item_size, item_price, quantity, customer_id, address_id)
	VALUES ('O001', '2024-11-17', 'Laptop', 'Electronics', '15-inch', 1200.00, 1, 1, 101);

	INSERT INTO customers (customer_id, customer_firstname, customer_lastname)
	VALUES (2, 'Giselle', 'Brown'),
			(3, 'Jennie', 'Kim'),
			(4, 'Lisa', 'Williams'),
			(5, 'Rose', 'Miller');

	INSERT INTO address (address_id, delivery_address, delivery_city, delivery_zipcode)
	VALUES (102, '456 Oak Street', 'Los Angeles', '90001'),
			(103, '789 Pine Avenue', 'Chicago', '60601'),
			(104, '101 Maple Drive', 'Houston', '77001'),
			(105, '202 Birch Lane', 'Phoenix', '85001');

	INSERT INTO orders (order_id, order_date, item_name, item_category, item_size, item_price, quantity, customer_id, address_id)
	VALUES ('O002', '2024-11-17', 'Laptop', 'Electronics', '15-inch', 1200.00, 1, 2, 102),
			('O003', '2024-11-18', 'Wireless Mouse', 'Electronics', 'Standard', 25.00, 2, 2, 102);

	INSERT INTO orders (order_id, order_date, item_name, item_category, item_size, item_price, quantity, customer_id, address_id)
	VALUES ('O004', '2024-11-20', 'Coffee Maker', 'Appliances', '1L', 100.00, 2, 3, 103),
			('O005', '2024-11-21', 'Blender', 'Appliances', '1.5L', 75.00, 1, 3, 103),
			('O006', '2024-11-22', 'T-shirt', 'Clothing', 'Large', 15.00, 4, 3, 103);

	INSERT INTO orders (order_id, order_date, item_name, item_category, item_size, item_price, quantity, customer_id, address_id)
	VALUES ('O007', '2024-11-17', 'Laptop', 'Electronics', '15-inch', 1200.00, 2, 4, 104),
			('O008', '2024-11-18', 'Headphones', 'Electronics', 'Over-ear', 60.00, 2, 4, 104);

	INSERT INTO orders (order_id, order_date, item_name, item_category, item_size, item_price, quantity, customer_id, address_id)
	VALUES ('O009', '2024-11-20', 'Wireless Mouse', 'Electronics', 'Standard', 25.00, 2, 5, 105),
			('O010', '2024-11-21', 'Blender', 'Appliances', '1.5L', 75.00, 1, 5, 105);

-- Checking the tables.

	SELECT *
	FROM customers;

	SELECT *
	FROM address;

	SELECT *
	FROM orders;

-- List of item names and their total sales quantity.

	SELECT item_name, SUM(quantity) AS total_quantity
	FROM orders
	GROUP BY item_name
	ORDER BY total_quantity DESC;

-- List of item categories along with their total sales value.

	SELECT item_category, SUM(item_price) AS total_sales
	FROM orders
	GROUP BY item_category
	ORDER BY total_sales DESC;
	
-- List of customers along with the items they purchased and the quantity of each item.

	SELECT c.customer_id, c.customer_firstname, c.customer_lastname, o.item_name, SUM(o.quantity) AS total_quantity
	FROM orders AS o
	JOIN customers AS c
	ON o.customer_id = c.customer_id
	GROUP BY c.customer_id, c.customer_firstname, c.customer_lastname, o.item_name
	ORDER BY total_quantity DESC;

-- List of customers and their respective addresses.

	SELECT o.customer_id, c.customer_firstname, c.customer_lastname, a.delivery_address, a.delivery_city, a.delivery_zipcode
	FROM customers AS c
	JOIN orders AS o
	ON c.customer_id = o.customer_id
	JOIN address AS a
	ON o.address_id = a.address_id
	GROUP BY o.customer_id, c.customer_firstname, c.customer_lastname, a.delivery_address, a.delivery_city, a.delivery_zipcode;