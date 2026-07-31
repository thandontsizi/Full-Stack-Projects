import random
from decimal import Decimal

import psycopg2
from faker import Faker

# ----------------------------------------
# Setup:
# ----------------------------------------

fake = Faker()
try:

	conn = psycopg2.connect(
		dbname="retail_insights_engine",
		user="thando",
		password="thando123",
		host="localhost",
		port="5432"
	)

	print("Connection successful.")

except Exception as e:
	print("Connection failed.")
	print(e)

cur = conn.cursor()


# ----------------------------------------
# Utility Functions:
# ----------------------------------------
def get_ids(table_name, column_name):
	"""
	Fetches all IDs from  a table column.
	"""

	cur.execute(f"""
		SELECT {column_name}
		FROM {table_name}
	""")

	return [row[0] for row in cur.fetchall()]


# ----------------------------------------
# Customer Generator:
# ----------------------------------------
def generate_customers(n=20):
	"""
	Generates customer records.
	"""

	customers = []

	for _ in range(n):

		customers.append((
			fake.name(),
			fake.email(),
			fake.phone_number(),
			fake.street_address(),
			fake.city(),
			fake.state(),
			fake.postcode(),
			fake.country()
		))

	cur.executemany("""
		INSERT INTO Customer (
			full_name,
			email_address,
			phone_number,
			street_address,
			city,
			state,
			postal_code,
			country
		)
		VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
	""", customers)

	conn.commit()

	print(f"{n} customers inserted.")


# ----------------------------------------
# Store Generator:
# ----------------------------------------
def generate_stores(n=5):
	"""
	Generates store records.
	"""

	stores = []

	for _ in range(n):

		stores.append((
			fake.company(),
			fake.street_address(),
			fake.city(),
			fake.state(),
			fake.postcode(),
			fake.country()
		))

		cur.executemany("""
			INSERT INTO Store (
				store_name,
				street_address,
				city,
				state,
				postal_code,
				country
			)
			VALUES (%s, %s, %s, %s, %s, %s)
		""", stores)

	conn.commit()

	print(f"{n} stores inserted.")


# ----------------------------------------
# Supplier Generator:
# ----------------------------------------
def generate_suppliers(n=10):
	"""
	Generates supplier records.
	"""

	suppliers = []
	used_emails = set()

	while len(suppliers) < n:

		email = fake.email()

		if email in used_emails:
			continue

		used_emails.add(email)


		suppliers.append((
			fake.company(),
			fake.name(),
			fake.phone_number(),
			email,
			fake.street_address(),
			fake.city(),
			fake.state(),
			fake.postcode(),
			fake.country()
		))

	cur.executemany("""
		INSERT INTO Supplier (
			supplier_name,
			contact_full_name,
			phone_number,
			email_address,
			street_address,
			city,
			state,
			postal_code,
			country
		)
		VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
	""", suppliers)

	conn.commit()

	print(f"{n} suppliers inserted.")


# ----------------------------------------
# Product Generator:
# ----------------------------------------
def generate_products(n=30):

	supplier_ids = get_ids("Supplier", "supplier_id")

	if not supplier_ids:
		print("No suppliers found. Run supplier generation first.")
		return

	products = []

	categories = [
		"Electronics",
		"Groceries",
		"Clothing",
		"Home",
		"Beauty",
		"Sports"
	]

	for _ in range(n):
		product_name = fake.word().title()
		category = random.choice(categories)

		description = fake.sentence(nb_words=10)

		unit_cost = round(random.uniform(10, 2000), 2)
		unit_price = round(unit_cost * 1.3, 2)

		supplier_id = random.choice(supplier_ids)

		products.append((
			product_name,
			category,
			description,
			unit_cost,
			unit_price,
			supplier_id
		))

	cur.executemany("""
		INSERT INTO Product (
			product_name,
			category,
			description,
			unit_cost,
			unit_price,
			supplier_id
		)
		VALUES (%s, %s, %s, %s, %s, %s)
	""", products)

	conn.commit()

	print(f"{n} products inserted.")


# ----------------------------------------
# Order Genarator:
# ----------------------------------------
def generate_orders(n=50):

	customer_ids = get_ids("Customer", "customer_id")
	store_ids = get_ids("Store", "store_id")

	if not customer_ids or not store_ids:
		print("Missing customers or stores. Generate them first.")
		return

	orders = []

	statuses = ["pending", "completed", "cancelled"]

	for _ in range(n):

		customer_id = random.choice(customer_ids)
		store_id = random.choice(store_ids)

		order_date = fake.date_time_this_year()

		order_status = random.choice(statuses)

		total_amount = round(random.uniform(50, 5000), 2)

		shipping_address = fake.address()

		orders.append((
			customer_id,
			store_id,
			order_date,
			order_status,
			total_amount,
			shipping_address
		))

	cur.executemany("""
		INSERT INTO Orders (
			customer_id,
			store_id,
			order_date,
			order_status,
			total_amount,
			shipping_address
		)
		VALUES (%s, %s, %s, %s, %s, %s)
	""", orders)

	conn.commit()

	print(f"{n} orders inserted.")


# ------------------------------------------------
# Order_Item Generator:
# ------------------------------------------------
def generate_order_items(max_items_per_order=5):

	order_ids = get_ids("Orders", "order_id")

	cur.execute("""
		SELECT
			product_id,
			unit_price,
			unit_cost
		FROM Product
	""")

	products = cur.fetchall()

	if not order_ids or not products:
		print("Missing orders or products.")
		return

	order_items = []

	for order_id in order_ids:

		num_items = random.randint(1, max_items_per_order)

		selected_products = random.sample(
			products,
			min(num_items, len(products))
		)

		for product in selected_products:

			product_id = product[0]
			unit_price = product[1]
			unit_cost = product[2]

			quantity = random.randint(1, 5)

			item_discount = Decimal(
				str(round(random.uniform(0, 50), 2))
			)

			total_price = (
				quantity * unit_price
			) - item_discount

			order_items.append((
				order_id,
				product_id,
				quantity,
				unit_price,
				unit_cost,
				item_discount,
				total_price
			))

	cur.executemany("""
		INSERT INTO Order_Item (
			order_id,
			product_id,
			quantity,
			unit_price,
			unit_cost,
			item_discount,
			total_price
		)
		VALUES (%s, %s, %s, %s, %s, %s, %s)
	""", order_items)

	conn.commit()

	print(f"{len(order_items)} order items inserted.")


# ----------------------------------------
# Order_Total Generator:
# ----------------------------------------
def update_order_totals():

	cur.execute("""
		UPDATE Orders o
		SET total_amount = sub.total
		FROM (
			SELECT
				order_id,
				SUM(total_price) AS total
			FROM Order_Item
			GROUP BY order_id
		) sub
		WHERE o.order_id = sub.order_id
	""")

	conn.commit()

	print("Order totals updated.")


# ----------------------------------------
# Stock Generator:
# ----------------------------------------
def generate_stock():

	cur.execute("TRUNCATE Stock RESTART IDENTITY CASCADE;")
	conn.commit()

	store_ids = get_ids("Store", "store_id")
	product_ids = get_ids("Product", "product_id")

	if not store_ids or not product_ids:
		print("Missing stores or products.")
		return

	stock_records = []

	for store_id in store_ids:

		for product_id in product_ids:

			quantity_on_hand = random.randint(0, 500)

			reorder_level = random.randint(10, 100)

			last_restock_date = fake.date_this_year()

			stock_records.append((
				store_id,
				product_id,
				quantity_on_hand,
				reorder_level,
				last_restock_date
			))

	cur.executemany("""
		INSERT INTO Stock (
			store_id,
			product_id,
			quantity_on_hand,
			reorder_level,
			last_restock_date
		)
		VALUES (%s, %s, %s, %s, %s)
	""", stock_records)

	conn.commit()

	print(f"{len(stock_records)} stock records inserted.")


# ----------------------------------------
# Refund Generator:
# ----------------------------------------
def generate_refunds(refund_probability=0.1):

	cur.execute("""
		SELECT
			order_item_id,
			total_price
		FROM Order_Item
	""")

	order_items = cur.fetchall()

	if not order_items:
		print("No order items found.")
		return

	refunds = []

	refund_reasons = [
		"Damaged item.",
		"Wrong product.",
		"Customer changed their mind.",
		"Late delivery.",
		"Defective product."
	]

	for order_item in order_items:

		if random.random() < refund_probability:

			order_item_id = order_item[0]
			total_price = order_item[1]

			refund_date = fake.date_this_year()

			refund_amount = round(
				min(
					float(total_price),
					abs(float(total_price) * random.uniform(0.3, 1.0))
				),
				2
			)

			refund_reason = random.choice(refund_reasons)

			refunds.append((
				order_item_id,
				refund_date,
				refund_amount,
				refund_reason,
			))

	cur.executemany("""
		INSERT INTO Refund (
			order_item_id,
			refund_date,
			refund_amount,
			refund_reason
		)
		VALUES (%s, %s, %s, %s)
	""", refunds)

	conn.commit()

	print(f"{len(refunds)} refunds inserted.")


# ----------------------------------------
# Main Pipeline:
# ----------------------------------------
if __name__ == "__main__":

	generate_customers(20)
	generate_stores(5)
	generate_suppliers(10)
	generate_products(30)
	generate_orders(50)
	generate_order_items()
	update_order_totals()
	generate_stock()
	generate_refunds()

	cur.close()
	conn.close()

	print("Data generation complete.")
