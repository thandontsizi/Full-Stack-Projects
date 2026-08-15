-- ----------------------------------------
-- Retail Insights Engine:
-- Dataset Cleaning Script:
-- ----------------------------------------


-- ----------------------------------------
-- Customer Table Cleaning:
-- ----------------------------------------

-- Replace missing customer names:
UPDATE Customer
SET full_name = 'Unknown'
WHERE full_name IS NULL;

-- Replace missing customer email addresses:
UPDATE Customer
SET email_address = 'Unknown'
WHERE email_address IS NULL;

-- Replace missing customer phone number:
UPDATE Customer
SET phone_number = 'Unknown'
WHERE phone_number IS NULL;


-- ----------------------------------------
-- Store Table Cleaning:
-- ----------------------------------------

-- Replace missing store name:
UPDATE Store
SET store_name = 'Unknown'
WHERE store_name IS NULL;

-- Replace missing store street address:
UPDATE Store
SET street_address = 'Unknown'
WHERE street_address IS NULL;

-- Replace missing city 
