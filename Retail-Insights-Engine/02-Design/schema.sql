-- DEV ONLY: reset schema
-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;

-- =========================================================
-- Retail-Insight-Engine Database Schema:
-- Author: Thando Ntsizi
-- Purpose: PostgreSQL schema for full-stack retail project.
-- =========================================================

-- =========================================================
-- TABLE: Customer
-- Stores customer information.
-- =========================================================
CREATE TABLE Customer (
	customer_id SERIAL PRIMARY KEY,
	full_name VARCHAR(50) NOT NULL,
	email_address VARCHAR(100) UNIQUE NOT NULL,
	phone_number VARCHAR(20) UNIQUE NOT NULL,
	street_address VARCHAR(150),
	city VARCHAR(50),
	state VARCHAR(50),
	postal_code VARCHAR(20),
	country VARCHAR(50)
);

COMMENT ON TABLE Customer IS 'Stores all customers.';


-- ========================================================
-- TABLE: Store
-- Stores physical retail store information.
-- ========================================================
CREATE TABLE Store (
	store_id SERIAL PRIMARY KEY,
	store_name VARCHAR(100) NOT NULL,
	street_address VARCHAR(150) NOT NULL,
	city VARCHAR(50) NOT NULL,
	state VARCHAR(50) NOT NULL,
	postal_code VARCHAR(50) NOT NULL,
	country VARCHAR(50) NOT NULL
);

COMMENT ON TABLE Store IS 'Stores retail store information';


-- =========================================================
-- TABLE: Customer_Store
-- Links customers to stores (loyalty info).
-- =========================================================
CREATE TABLE Customer_Store (
	customer_store_id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL,
	store_id INT NOT NULL,
	loyalty_level VARCHAR(20),
	join_date DATE DEFAULT CURRENT_DATE,

	CONSTRAINT fk_custore_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),

	CONSTRAINT fk_custore_store FOREIGN KEY (store_id) REFERENCES Store(store_id),

	CONSTRAINT uq_custore_customer_store UNIQUE (customer_id, store_id)
);

COMMENT ON TABLE Customer_Store IS 'Links customers to stores';


-- =============================================================
-- Table: Supplier
-- Description: Stores supplier contact and address information.
-- =============================================================
CREATE TABLE Supplier (
	supplier_id SERIAL PRIMARY KEY,
	supplier_name VARCHAR(100) NOT NULL,
	contact_full_name VARCHAR(100) NOT NULL,
	phone_number VARCHAR(20) UNIQUE NOT NULL,
	email_address VARCHAR(100) UNIQUE,
	street_address VARCHAR(150) NOT NULL,
	city VARCHAR(50) NOT NULL,
	state VARCHAR(50) NOT NULL,
	postal_code VARCHAR(20) NOT NULL,
	country VARCHAR(50) NOT NULL
);

COMMENT ON TABLE Supplier IS 'Stores supplier contact and address information.';


-- ===============================================================
-- Table: Product
-- Description: Stores product catalog and supplier relationships.
-- ===============================================================
CREATE TABLE Product (
	product_id SERIAL PRIMARY KEY,
	supplier_id INT NOT NULL,
	product_name VARCHAR(100) NOT NULL,
	category VARCHAR(100),
	unit_cost NUMERIC(10, 2) NOT NULL,
	unit_price NUMERIC(10, 2) NOT NULL,
	description TEXT,

	CONSTRAINT fk_product FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

COMMENT ON TABLE Product IS 'Stores product catalog and supplier relationships.';


-- =================================================================
-- Table: Orders
-- Description: Stores order-level transaction details.
-- =================================================================
CREATE TABLE Orders (
	order_id SERIAL PRIMARY KEY,
	customer_id INT NOT NULL,
	store_id INT NOT NULL,
	order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	order_status VARCHAR(20) DEFAULT 'Pending',
	total_amount NUMERIC(12, 2) DEFAULT 0,
	shipping_address VARCHAR(200) NOT NULL,

	CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),

	CONSTRAINT fk_order_store FOREIGN KEY (store_id) REFERENCES Store(store_id)
);

COMMENT ON TABLE Orders IS 'Stores order-level transaction details.';


-- ==================================================================
-- Table: Order_Item
-- Description: Stores individual product items within each order.
-- ==================================================================
CREATE TABLE Order_Item (
	order_item_id SERIAL PRIMARY KEY,
	order_id INT NOT NULL,
	product_id INT NOT NULL,
	quantity INT NOT NULL CHECK (quantity > 0),
	unit_price NUMERIC(10, 2) NOT NULL,
	unit_cost NUMERIC(10, 2) NOT NULL,
	item_discount NUMERIC(10, 2) DEFAULT 0,
	total_price NUMERIC(12, 2) GENERATED ALWAYS AS (quantity * unit_price - item_discount) STORED,

	CONSTRAINT fk_orderitem_order FOREIGN KEY (order_id) REFERENCES Orders(order_id),

	CONSTRAINT fk_orderitem_product FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

COMMENT ON TABLE Order_Item IS 'Stores individual product items within each order.';


-- ==================================================================
-- Table: Stock
-- Description: Tracks inventory levels of products per store.
-- ==================================================================
CREATE TABLE Stock (
	stock_id SERIAL PRIMARY KEY,
	store_id INT NOT NULL,
	product_id INT NOT NULL,
	quantity_on_hand INT DEFAULT 0 CHECK (quantity_on_hand >= 0),
	reorder_level INT DEFAULT 0 CHECK (reorder_level >= 0),
	last_restock_date DATE,

	CONSTRAINT fk_stock_store FOREIGN KEY (store_id) REFERENCES Store(store_id),

	CONSTRAINT fk_stock_product FOREIGN KEY (product_id) REFERENCES Product(product_id),

	CONSTRAINT uq_stock_store_product UNIQUE (store_id, product_id)
);

COMMENT ON TABLE Stock IS 'Tracks inventory levels of products per store.';


-- ====================================================================
-- Table: Refund
-- Description: Stores refunds issued for specific order items.
-- ====================================================================
CREATE TABLE Refund (
	refund_id SERIAL PRIMARY KEY,
	order_item_id INT NOT NULL,
	refund_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	refund_amount NUMERIC(10, 2) NOT NULL CHECK (refund_amount >= 0),
	refund_reason TEXT,

	CONSTRAINT fk_refund_orderitem FOREIGN KEY (order_item_id) REFERENCES Order_Item(order_item_id)
);

COMMENT ON TABLE Refund IS 'Stores refunds issued for specific order items.';
