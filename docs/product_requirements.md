# ACME Salary Management — Product Requirements

## Goal and user

Build a maintainable application for ACME's HR Manager to manage employee information, salary history, and compensation insights for approximately 10,000 employees across multiple countries.

ACME currently relies on spreadsheets. The application centralizes employee and salary records and makes them searchable and reportable.

The initial release supports one organization (ACME), not multiple tenants.

## Scope

- Employee creation, viewing, updating, and deletion.
- Search by employee name, email, and employee number.
- Filtering by country and department.
- Server-side pagination.
- Country and department reference data.
- Effective-dated salary records and salary history.
- Compensation insights grouped by country, department, and currency.
- Seed data representing 10,000 employees.

## Core user stories

As an HR Manager, I can:
- Browse employees without loading the entire dataset into the browser.
- Find an employee by name, email, or employee number.
- Filter employees by country and department.
- View employee details and salary history.
- Add a salary record with an effective date.
- Review employee counts and salary averages by country and department.

## Functional rules

### Employees

An employee has an employee number, first name, last name, email, job title, employment status, country, department, and optional last working date.

Employee number and email are unique. Each employee belongs to one country and one department in the initial version. Inactive employees remain in the system for historical and reference enquiries.

Search, filters, and pagination are applied by the backend/database.

### Salaries

A salary record contains amount, three-letter currency code, effective-from date, and optional effective-to date.

Amounts must be greater than zero. The end date cannot precede the start date. Salary periods belonging to the same employee must not overlap. Salary history is retained rather than overwritten.

Salary reporting must keep currencies separate. The application does not calculate cross-currency averages without an agreed exchange-rate source and conversion policy.

### Insights

The intended reporting includes employee counts by country and department and average salary by country and department, grouped by currency. Salary distribution needs a precise business definition before it is treated as an implemented report.

## Non-functional expectations

- Readable, maintainable Rails and React code.
- Database constraints and indexes for important integrity and lookup requirements.
- Database-side search, filtering, pagination, and aggregation.
- Bounded API responses and avoidance of N+1 queries.
- Clear validation and error responses.
- Fast, deterministic automated tests, including edge cases.
- Support the assessment dataset without loading all employees into the browser.

## Deliberate exclusions

Payroll processing, tax calculations, benefits, insurance, loans, salary approvals, attendance, leave management, employee self-service, currency conversion, complex role-based access control, and multi-tenant SaaS are outside the initial assessment scope.

A production HR deployment would still require appropriate authentication, authorization, audit logging, and protection of sensitive employee and salary information.

## Assumptions and future evolution

An employee has one country and one department in the initial model. International transfers are deferred. A future design could introduce effective-dated employee assignments to preserve country, work location, and department history without creating duplicate employee profiles.

## Success criteria

An HR Manager can manage employee records, search and filter the target dataset, view salary history, add salary records, and review currency-aware compensation insights without relying on spreadsheets for those workflows.
