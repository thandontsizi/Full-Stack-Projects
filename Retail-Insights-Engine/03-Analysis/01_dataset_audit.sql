-- ----------------------------------------------------
-- Retail Insights Engine:
-- Dataset Audit Script:
-- ----------------------------------------------------


-- ----------------------------------------------------
-- Customer Table Audit:
-- ----------------------------------------------------

SELECT '==================== CUSTOMER TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of customers:
SELECT 'Total number of customers:' AS audit_check;

SELECT COUNT(*) AS total_customers
FROM Customer;

-- Customers with missing email addresses:
SELECT 'Customers with missing email addresses:' AS audit_check;

SELECT *
FROM Customer
WHERE email_address IS NULL;

-- Duplicate customer email addresses:
SELECT 'Duplicate customer email addresses:' AS audit_check;

SELECT
	email_address,
	COUNT(*) AS duplicate_count
FROM Customer
GROUP BY email_address
HAVING COUNT(*) > 1;

-- Duplicate customer phone numbers:
SELECT 'Duplicate customer phone numbers:' AS audit_check;

SELECT
	phone_number,
	COUNT(*) AS duplicate_count
FROM Customer
GROUP BY phone_number
HAVING COUNT(*) > 1;


-- ----------------------------------------------------
-- Store Table Audit:
-- ----------------------------------------------------

SELECT '==================== STORE TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of stores:
SELECT 'Total number of stores:' AS audit_check;

SELECT COUNT(*) AS total_stores
FROM Store;

-- Stores with missing store names:
SELECT 'Stores with missing store names:' AS audit_check;

SELECT *
FROM Store
WHERE store_name IS NULL;

-- Number of stores per city:
SELECT 'Number of stores per city:' AS audit_check;

SELECT
	city,
	COUNT(*) AS total_stores
FROM Store
GROUP BY city
ORDER BY total_stores DESC;


-- ----------------------------------------------------
-- Supplier Table Audit:
-- ----------------------------------------------------

SELECT '==================== SUPPLIER TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of suppliers:
SELECT 'Total number of suppliers:' AS audit_check;

SELECT COUNT(*) AS total_suppliers
FROM Supplier;

-- Suppliers with missing supplier names:
SELECT 'Suppliers with missing supplier names:' AS audit_check;

SELECT *
FROM Supplier
WHERE supplier_name IS NULL;

-- Duplicate supplier email addresses:
SELECT 'Duplicate supplier email addresses:' AS audit_check;

SELECT
	email_address,
	COUNT(*) AS duplicate_count
FROM Supplier
GROUP BY email_address
HAVING COUNT(*) > 1;


-- ----------------------------------------------------
-- Product Table Audit:
-- ----------------------------------------------------

SELECT '==================== PRODUCT TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of products:
SELECT 'Total number of products:' AS audit_check;

SELECT COUNT(*) total_products
FROM Product;

-- Products with missing product names:
SELECT 'Products with missing product names:' AS audit_check;

SELECT *
FROM Product
WHERE product_name IS NULL;

-- Product distribution by category:
SELECT 'Product distribution by category:' AS audit_check;

SELECT
	category,
	COUNT(*) AS total_products
FROM Product
GROUP BY category
ORDER BY total_products DESC;

-- Product selling price range:
SELECT 'Product selling price range:' AS audit_check;

SELECT
	MIN(unit_price) AS minimum_price,
	MAX(unit_price) AS maximum_price,
	ROUND(AVG(unit_price), 2) AS average_price
FROM Product;

-- Product cost range:
SELECT 'Product cost range:' AS audit_check;

SELECT
	MIN(unit_cost) AS minimum_cost,
	MAX(unit_cost) AS maximum_cost,
	ROUND(AVG(unit_cost), 2) AS average_cost
FROM Product;

-- Products where selling price is below cost
SELECT 'Products where unit price is below unit cost:' AS audit_check;

SELECT *
FROM Product
WHERE unit_price < unit_cost;


-- ----------------------------------------------------
-- Orders Table Audit:
-- ----------------------------------------------------

SELECT '==================== ORDERS TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of orders:
SELECT 'Total number of orders:' AS audit_check;

SELECT COUNT(*) AS total_orders
FROM Orders;

-- Orders with negative total amounts:
SELECT 'Orders with negative total amounts:' AS audit_check;

SELECT *
FROM Orders
WHERE total_amount < 0;

-- Order distribution by status:
SELECT 'Order distribution by status:' AS audit_check;

SELECT
	order_status,
	COUNT(*) AS total_orders
FROM Orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- Order total range:
SELECT 'Order total range:' AS audit_check;

SELECT
	MIN(total_amount) AS minimum_order_total,
	MAX(total_amount) AS maximum_order_total,
	ROUND(AVG(total_amount), 2) AS average_order_total
FROM Orders;

-- Order amounts per order day:
SELECT 'Order amounts per order day:' AS audit_check;

SELECT
	DATE(order_date) AS order_day,
	COUNT(*) AS total_orders,
	ROUND(SUM(total_amount), 2) AS daily_revenue
FROM Orders
GROUP BY order_day
ORDER BY order_day;


-- ----------------------------------------------------
-- Order_Item Table Audit:
-- ----------------------------------------------------

SELECT '==================== ORDER ITEM TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of order items:
SELECT 'Total number of order items:' AS audit_check;

SELECT COUNT(*) AS total_order_items
FROM Order_Item;

-- Orders with invalid quantities:
SELECT 'Order items with invalid quantities:' AS audit_check;

SELECT *
FROM Order_Item
WHERE quantity <= 0;

-- Order items with negative total prices:
SELECT 'Order items with negative total prices:' AS audit_check;

SELECT *
FROM Order_Item
WHERE total_price < 0;

-- Order items where selling price is below cost:
SELECT 'Order items where unit price is below unit cost:' AS audit_check;

SELECT *
FROM Order_Item
WHERE unit_price < unit_cost;

-- Top 10 products by units sold:
SELECT 'Top 10 products by units sold:' AS audit_check;

SELECT
	product_id,
	SUM(quantity) AS total_units_sold
FROM Order_Item
GROUP BY product_id
ORDER BY total_units_sold DESC
LIMIT 10;

-- Total sales revenue from order items:
SELECT 'Total sales revenue from order items:' AS audit_check;

SELECT
	COALESCE(ROUND(SUM(total_price), 2), 0.00) AS total_sales_revenue
FROM Order_Item;


-- ----------------------------------------------------
-- Stock Table Audit:
-- ----------------------------------------------------

SELECT '==================== STOCK TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of stock records:
SELECT 'Total number of stock records:' AS audit_check;

SELECT COUNT(*) AS total_stock_records
FROM Stock;

-- Number of stock records below reorder level:
SELECT 'Number of stock records below reorder level:' AS audit_check;

SELECT COUNT(*) AS low_stock_records
FROM Stock
WHERE quantity_on_hand < reorder_level;

-- Low stock records by store:
SELECT 'Low stock records by store:' AS audit_check;

SELECT
	store_id,
	COUNT(*) AS low_stock_records
FROM Stock
WHERE quantity_on_hand < reorder_level
GROUP BY store_id
ORDER BY low_stock_records DESC;

-- Stock quantity range:
SELECT 'Stock quantity range:' AS audit_check;

SELECT
	MIN(quantity_on_hand) AS minimum_stock,
	MAX(quantity_on_hand) AS maximum_stock,
	ROUND(AVG(quantity_on_hand), 2) AS average_stock
FROM Stock;


-- ----------------------------------------------------
-- Refund Table Audit:
-- ----------------------------------------------------

SELECT '==================== REFUND TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of refunds:
SELECT 'Total number of refunds:' AS audit_check;

SELECT COUNT(*) AS total_refunds
FROM Refund;

-- Refunds with negative amounts:
SELECT 'Refunds with negative amounts:' AS audit_check;

SELECT *
FROM Refund
WHERE refund_amount < 0;

-- Total refund amount:
SELECT 'Total refund amount:' AS audit_check;

SELECT
	COALESCE(ROUND(SUM(refund_amount), 2), 0.00) AS total_refund_amount
FROM Refund;

-- Refund distribution by reason:
SELECT 'Refund distribution by reason:' AS audit_check;

SELECT
	refund_reason,
	COUNT(*) AS total_refunds
FROM Refund
GROUP BY refund_reason
ORDER BY total_refunds DESC;


-- ----------------------------------------------------
-- Referential Integrity Checks:
-- ----------------------------------------------------

SELECT '==================== REFERENTIAL INTEGRITY AUDIT: ====================' AS Audit_Section;

-- Orders with invalid customer references:
SELECT 'Orders with invalid customer references:' AS audit_check;

SELECT COUNT(*) AS invalid_customer_references
FROM Orders o
LEFT JOIN Customer c
ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order items referencing non-existent orders:
SELECT 'Order items with invalid order references:' AS audit_check;

SELECT COUNT(*) AS invalid_order_references
FROM Order_Item oi
LEFT JOIN Orders o
ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Order items referencing non-existent products:
SELECT 'Order items with invalid product references:' AS audit_check;

SELECT COUNT(*) AS invalid_product_references
FROM Order_Item oi
LEFT JOIN Product p
ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Stock records referencing non-existent products:
SELECT 'Stock records with invalid product references:' AS audit_check;

SELECT COUNT(*) AS invalid_stock_product_references
FROM Stock s
LEFT JOIN Product p
ON s.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Refunds referencing non-existent order items:
SELECT 'Refunds with invalid order item references:' AS audit_check;

SELECT COUNT(*) AS invalid_order_item_references
FROM Refund r
LEFT JOIN Order_Item oi
ON r.order_item_id = oi.order_item_id
WHERE oi.order_item_id IS NULL;


-- ----------------------------------------------------
-- Revenue and Refund Summary:
-- ----------------------------------------------------

SELECT '==================== REVENUE AND REFUND SUMMARY: ====================' AS Summary_Section;

-- Gross revenue from orders:
SELECT 'Gross revenue from orders:' AS audit_check;

SELECT
	COALESCE(ROUND(SUM(total_amount), 2), 0.00) AS gross_revenue
FROM Orders;

-- Total refunds:
SELECT 'Total refunds:' AS audit_check;

SELECT
	COALESCE(ROUND(SUM(refund_amount), 2), 0.00) AS total_refunds
FROM Refund;

-- Net revenue after refunds
SELECT 'Net revenue after refunds' AS audit_check;
SELECT
	ROUND(
		(
			SELECT COALESCE(SUM(total_amount), 0)
			FROM Orders
		) -
		(
			SELECT COALESCE(SUM(refund_amount), 0)
			FROM Refund
		),
		2
	) AS net_revenue;
