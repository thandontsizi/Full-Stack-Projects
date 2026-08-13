-- ----------------------------------------------------
-- Retail Insights Engine:
-- Dataset Audit Script:
-- ----------------------------------------------------


-- ----------------------------------------------------
-- Customer Table Audit:
-- ----------------------------------------------------

SELECT '==================== CUSTOMER TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of customers:
SELECT COUNT(*) AS total_customers
FROM Customer;

-- Customers with missing required fields:
SELECT 'Customers with missing required fields:' AS audit_check;

SELECT *
FROM Customer
WHERE full_name IS NULL
	OR email_address IS NULL
	OR phone_number IS NULL;

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
SELECT COUNT(*) AS total_stores
FROM Store;

-- Stores with missing required fields:
SELECT 'Stores with missing required fields:' AS audit_check;

SELECT *
FROM Store
WHERE store_name IS NULL
	OR street_address IS NULL
	OR city IS NULL
	OR state IS NULL
	OR postal_code IS NULL
	OR country IS NULL;


-- ----------------------------------------------------
-- Customer_Store Table Audit:
-- ----------------------------------------------------

SELECT '=================== CUSTOMER STORE TABLE AUDIT: ===================' AS Audit_Section;

-- Total number of customer store records:
SELECT COUNT(*) AS total_customer_stores
FROM Customer_Store;

-- Customer Store records with missing required fields:
SELECT 'Customer_Store records with missing required fields:' AS audit_check;

SELECT *
FROM Customer_Store
WHERE customer_id IS NULL
	OR store_id IS NULL;

-- Duplicate customer-store relationships:
SELECT 'Duplicate customer-store relationships:' AS audit_check;

SELECT
	customer_id,
	store_id,
	COUNT(*) AS duplicate_count
FROM Customer_Store
GROUP BY customer_id, store_id
HAVING COUNT(*) > 1;


-- ----------------------------------------------------
-- Supplier Table Audit:
-- ----------------------------------------------------

SELECT '==================== SUPPLIER TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of suppliers:
SELECT COUNT(*) AS total_suppliers
FROM Supplier;

-- Suppliers with missing required fields:
SELECT 'Suppliers with missing required fields:' AS audit_check;

SELECT *
FROM Supplier
WHERE supplier_name IS NULL
	OR contact_full_name IS NULL
	OR phone_number IS NULL
	OR email_address IS NULL
	OR street_address IS NULL
	OR city IS NULL
	OR state IS NULL
	OR postal_code IS NULL
	OR country IS NULL;

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
SELECT COUNT(*) AS total_products
FROM Product;

-- Products with missing required fields:
SELECT 'Products with missing required fields:' AS audit_check;

SELECT *
FROM Product
WHERE supplier_id IS NULL
	OR product_name IS NULL
	OR unit_cost IS NULL
	OR unit_price IS NULL;

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
SELECT COUNT(*) AS total_orders
FROM Orders;

-- Orders with missing required fields:
SELECT 'Orders with missing required fields:' AS audit_check;

SELECT *
FROM Orders
WHERE customer_id IS NULL
	OR store_id IS NULL
	OR shipping_address IS NULL;
	
-- Orders with negative total amounts:
SELECT 'Orders with negative total amounts:' AS audit_check;

SELECT *
FROM Orders
WHERE total_amount < 0;


-- ----------------------------------------------------
-- Order_Item Table Audit:
-- ----------------------------------------------------

SELECT '==================== ORDER ITEM TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of order items:
SELECT COUNT(*) AS total_order_items
FROM Order_Item;

-- Order items with missing required fields:
SELECT 'Order items with missing required fields:' AS audit_check;

SELECT *
FROM Order_Item
WHERE order_id IS NULL
	OR product_id IS NULL
	OR quantity IS NULL
	OR unit_price IS NULL
	OR unit_cost IS NULL;

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


-- ----------------------------------------------------
-- Stock Table Audit:
-- ----------------------------------------------------

SELECT '==================== STOCK TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of stock records:
SELECT COUNT(*) AS total_stock_records
FROM Stock;

-- Stock with missing required fields:
SELECT 'Stock with missing required fields:' AS audit_check;

SELECT *
FROM Stock
WHERE store_id IS NULL
	OR product_id IS NULL
	OR quantity_on_hand IS NULL
	OR reorder_level IS NULL;

-- Stock records with negative quantities:
SELECT 'Stock records with negative quantities:' AS audit_check;

SELECT
	product_id,
	store_id,
	quantity_on_hand
FROM Stock
WHERE quantity_on_hand < 0
ORDER BY quantity_on_hand ASC;

-- Stock records with negative reorder levels:
SELECT 'Stock records with negative reorder levels:' AS audit_check;

SELECT
	product_id,
	store_id,
	reorder_level
FROM Stock
WHERE reorder_level < 0
ORDER BY reorder_level ASC;


-- ----------------------------------------------------
-- Refund Table Audit:
-- ----------------------------------------------------

SELECT '==================== REFUND TABLE AUDIT: ====================' AS Audit_Section;

-- Total number of refunds:
SELECT COUNT(*) AS total_refunds
FROM Refund;

-- Refunds with missing required fields:
SELECT 'Refunds with missing required fields:' AS audit_check;

SELECT *
FROM Refund
WHERE order_item_id IS NULL
	OR refund_amount IS NULL;

-- Refunds with negative amounts:
SELECT 'Refunds with negative amounts:' AS audit_check;

SELECT *
FROM Refund
WHERE refund_amount < 0;


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

-- Orders with invalid store references:
SELECT 'Orders with invalid store references:' AS audit_check;

SELECT COUNT(*) AS orders_with_invalid_store_references
FROM Orders o
LEFT JOIN Store s
ON o.store_id = s.store_id
WHERE s.store_id IS NULL;

-- Products with invalid supplier references:
SELECT 'Products with invalid supplier references:' AS audit_check;

SELECT COUNT(*) AS products_with_invalid_supplier_references
FROM Product p
LEFT JOIN Supplier s
ON p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;

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

-- Customer stores with invalid customer references:
SELECT 'Customer stores with invalid customer references:' AS audit_check;

SELECT COUNT(*) AS customer_stores_with_invalid_customer_references
FROM Customer_Store cs
LEFT JOIN Customer c
ON cs.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Customer stores with invalid store references:
SELECT 'Customer stores with invalid store references:' AS audit_check;
SELECT COUNT(*) AS customer_stores_with_invalid_store_references
FROM Customer_Store cs
LEFT JOIN Store s
ON cs.store_id = s.store_id
WHERE s.store_id IS NULL;
