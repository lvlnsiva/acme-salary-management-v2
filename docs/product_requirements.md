cat > docs/requirements.md <<'EOF'
# ACME Salary Management — Requirements

## 1. Goal
Build a maintainable, fully functional web application that enables an HR Manager at ACME to manage salary information for 10,000 employees across multiple countries and understand how the organization pays its employees.

## 2. User and Problem
**Primary user:** HR Manager.

ACME currently manages salary information for approximately 10,000 employees across multiple countries using Excel spreadsheets. This makes employee information difficult to maintain, search, analyze and report.

The application provides a centralized system for managing employees, salary records and salary insights.

**Organization scope:** The initial release supports one organization (ACME) operating across multiple countries. It is not a multi-tenant SaaS product.

## 3. In Scope
- Employee creation, viewing and updating.
- Salary management and salary history.
- Country and department management.
- Employee search, filtering and server-side pagination.
- Dashboard with employee and salary insights.
- Multiple salary currencies.
- Seed data for 10,000 employees.
- Rails API, React frontend and PostgreSQL database.

## 4. Core User Stories
- As an HR Manager, I can view employees in a paginated list.
- I can search by name, email or employee number.
- I can filter employees by country and department.
- I can view employee details, current salary and salary history.
- I can add a salary record with an effective date.
- I can view employee counts and salary insights by country and department.
- I can understand salary distribution without maintaining Excel spreadsheets.

## 5. Functional Requirements

### Employees
- Each employee has an employee number, name, email, job title, employment status, country and department.
- Employee number and email must be unique.
- An employee belongs to one country and one department in the initial version.
- Search, filtering and pagination are handled by the backend/database.

### Salaries
- An employee can have multiple salary records.
- Each record contains amount, currency code, effective-from date and effective-to date.
- Salary amounts cannot be negative.
- Current salary is determined by its effective period.
- Salary effective periods for the same employee must not overlap.

### Countries and Departments
- Countries contain a name and country code.
- Departments contain a name.
- Employees are associated with one country and department.

### Dashboard
- Employee count by country and department.
- Average salary by country and department.
- Salary distribution.
- Amounts in different currencies must not be combined without a defined conversion strategy.

## 6. Non-Functional Requirements
- Use Ruby on Rails for the backend API, ReactJS for the frontend and PostgreSQL as the relational database.
- Maintain readable, modular and maintainable code.
- Use database constraints and indexes for data integrity and query performance.
- Avoid N+1 queries and unnecessary data loading.
- Provide clear API validation and error responses.
- Include meaningful, deterministic automated tests for core business rules and API functionality.
- Support at least 10,000 employees without loading all records into the browser.

## 7. Out of Scope and Assumptions
Excluded from the initial release:
- Multi-tenant SaaS and multiple independent organizations.
- Payroll processing and bank transfers.
- Tax calculations and country-specific statutory compliance.
- Benefits, insurance, loans and settlements.
- Salary approval workflows.
- Attendance, leave management and employee self-service.
- Currency conversion and cross-currency salary aggregation.
- Complex role-based access control.

Assumptions:
- ACME is the only organization using the initial application.
- An employee belongs to one country and one department.
- An employee can have multiple salary records.
- Salary currency is stored with each salary record.
- Complex authentication and authorization are not part of the initial release.

## 8. Deliverables and Success Criteria
- Working Rails API and React application.
- PostgreSQL schema and seed script for 10,000 employees.
- Meaningful automated tests.
- Deployed application and video demonstration.
- Incremental Git commits.
- Supporting documentation for architecture, design decisions, trade-offs, performance and AI-assisted development.

The solution is successful when an HR Manager can manage employee information, search and filter 10,000 employees, manage salary records, view salary history and understand salary insights.

## 9. Future Enhancements

### International Employee Transfers
An employee may move from one country to another while continuing employment with ACME.

A future implementation may introduce Employee Assignments to maintain:
- Country and work-location history.
- Department and assignment history.
- Effective start and end dates.
- Salary changes associated with international transfers.
- Historical records without creating duplicate employee profiles.

**Reason for deferral:** The initial assessment does not explicitly require international transfer workflows. The initial version maintains one country and one department per employee to keep implementation focused.
EOF