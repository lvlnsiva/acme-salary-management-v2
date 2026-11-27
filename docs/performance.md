
# Database Seeding and Performance

## Dataset

The application seed data represents an organization with 10,000 employees across six countries and eight departments.

| Record | Count |
|---|---:|
| Countries | 6 |
| Departments | 8 |
| Employees | 10,000 |
| Current salary records | 10,000 |
| Historical salary records | 5,000 |
| Total salary records | 15,000 |

The dataset includes active and inactive employees, six currencies, and salary history for 5,000 employees.

## Seed architecture

Seed logic is separated by responsibility:

- `db/seeds/support.rb`: shared constants and environment configuration.
- `db/seeds/reference_data.rb`: countries and departments.
- `db/seeds/employees.rb`: employee generation.
- `db/seeds/salaries.rb`: current and historical salary generation.
- `db/seeds.rb`: orchestrates seed execution.

## Performance decisions

### Bulk inserts

Rails `insert_all` and `upsert_all` are used instead of creating records individually.

Employee and salary records are inserted in batches of 1,000 employees. This reduces individual database insert operations and memory usage.

### Idempotency

- Countries use their unique country code.
- Departments use their unique name.
- Employees use their unique employee number.
- Salaries use the unique combination of employee ID and effective start date.

Unique indexes and conflict-aware bulk inserts prevent duplicate records when seeds are rerun.

### Database indexes

Existing indexes support employee lookups by employee number, email, employment status, country and department.

Salary history uses a composite index on employee ID and effective start date. A unique constraint on this combination prevents duplicate salary start dates for the same employee.

The separate employee ID index is retained until query plans and workload measurements justify removing it.

### Query efficiency

Employee IDs are fetched in a single query before salary generation. This avoids querying the database separately for every employee.

Insights calculations use database aggregation rather than loading all employee and salary records into application memory.

## Environment safety

Countries and departments are reference data and are loaded in every environment.

Synthetic employee and salary data are enabled automatically in development and test.

In production, synthetic data are skipped unless explicitly enabled:

```bash
SEED_DEMO_DATA=true bin/rails db:seed
```

Production demo-data seeding should only be used intentionally.

## Reproducibility

The dataset uses fixed employee numbers, deterministic names, fixed salary effective dates and predictable country and department assignments.

This makes local testing and assessment demonstrations repeatable without depending on random data generation.

## Verification

The seed dataset was verified with:

- 10,000 employees.
- 15,000 salary records.
- 8,572 active employees.
- 1,428 inactive employees.
- Six salary currencies.
- Zero employees without salary records.
- Repeated seed execution without duplicate records.

No benchmark claim is made until query execution plans and timings have been measured against the target database.
