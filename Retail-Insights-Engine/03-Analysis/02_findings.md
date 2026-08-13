# Retail Insights Engine:
## Dataset Audit Findings:

### Overview:
The dataset was audited using '01_dataset_audit.sql' for data-quality, constraint, and referential-integrity issues.

---

### Record Counts:
- **Customer:** 300
- **Store:** 225
- **Customer_Store:** 0
- **Supplier:** 150
- **Product:** 450
- **Orders:** 600
- **Order_Item:** 71,804
- **Stock:** 101,250
- **Refund:** 0

---
## Audit Results:
### Customer Table:
- **Missing required fields:** 0
- **Duplicate email addresses:** 0
- **Duplicate phone numbers:** 0
```bash
	Result: No issues found.
```

### Store Table:
- **Missing required fields:** 0
```bash
	Result: No issues found.
```

### Customer_Store Table:
- **Records:** 0
- **Missing required fields:** 0
- **Duplicate customer-store relationships:** 0
```bash
	Result: Table is empty. No data-quality issues found.
```

### Supplier Table:
- **Missing required fields:** 0
- **Duplicate email addresses:** 0
```bash
	Result: No issues found.
```

### Product Table:
- **Missing required fields:** 0
- **Unit price below unit cost:** 0
```bash
	Result: No issues found.
```

### Orders Table:
- **Missing required fields:** 0
- **Negative total amounts:** 0
```bash
	Result: No issues found.
```

### Order_Item Table:
- **Missing required fields:** 0
- **Invalid quantities:** 0
- **Negative total prices:** 0
- **Unit price below unit cost:** 0
```bash
	Result: No issues found.
```

### Stock Table:
- **Missing required fields:** 0
- **Negative quantities:** 0
- **Negative reorder levels:** 0
```bash
	Result: No issues found.
```

### Refund Table:
- **Records:** 0
- **Missing required fields:** 0
- **Negative refund amounts:** 0
```bash
	Result: Table is empty. No data-quality issues found.
```

---

## Referential Integrity Check Results:
- **Order -> Customer:** 0 invalid references.
- **Order -> Store:** 0 invalid references.
- **Product -> Supplier:** 0 invalid references.
- **Order_Item -> Order:** 0 invalid references.
- **Order_Item -> Product:** 0 invalid references.
- **Stock -> Product:** 0 invalid references.
- **Refund -> Order_Item:** 0 invalid references.
- **Customer_Store -> Customer:** 0 invalid references.
- **Customer_Store -> Store:** 0 invalid references.
```bash
	Result: No referential integrity issues found.
```

---

## Overall Findings:
- The dataset passed all audit checks.
- No data-quality or referential-integrity issues were identified.
- Customer_Store and Refund contain no records and will therefore have limited or no data available for analysis.
```bash
	NEXT STEP: Dataset Cleaning.
```
