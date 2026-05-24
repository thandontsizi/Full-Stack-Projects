import random

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

	order_ids = get_ids("Orders", "oreder_id")

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

		for produxt in selected_products:

			product_id = product[0]
			unit_price = product[1]
			unit_cost = product[2]

			quantity = random.randint(1, 5)

			item_discount = round(
				random.uniform(0, 50),
				2
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
# Main Pipeline:
# ----------------------------------------
if __name__ == "__main__":

	generate_customers(20)
	generate_stores(5)
	generate_suppliers(10)
	generate_products(30)

	cur.close()
	conn.close()

	print("Data generation complete.")
