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
