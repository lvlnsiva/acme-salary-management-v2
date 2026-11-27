# ACME Salary Management

A full-stack employee and salary management application for ACME's HR team. The system is designed for an organization with approximately 10,000 employees across multiple countries.

## Stack

- **Backend:** Ruby on Rails 7.2, Ruby 3.1, PostgreSQL
- **Frontend:** React 19, Vite
- **API:** JSON REST endpoints under `/api/v1`

## Features

- Employee create, view, update and delete workflows.
- Search by employee name, email or employee number.
- Optional employment-status, country and department filters.
- Server-side pagination (20 records by default; maximum 100 per page).
- Former employees remain searchable and available for historical enquiries.
- Country and department lookup endpoints.
- Effective-dated salary records and salary history.
- Validation for positive amounts, currency codes, date ranges and overlapping salary periods.
- Dashboard headcount and current compensation summaries by currency, country and department.
- Deterministic seed data for 10,000 employees and salary histories.

Salary aggregates are kept separate by currency. The application does not add or average amounts across different currencies.

## Prerequisites

- Ruby 3.1.x
- Bundler
- PostgreSQL
- Node.js 18 or later and npm

## Run locally

### Backend

```bash
cd backend
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails server
```

The API will be available at `http://localhost:3000/api/v1`.

### Frontend

In a second terminal:

```bash
cd frontend
npm install
npm run dev
```

Open the Vite URL printed in the terminal (normally `http://localhost:5173`). The development server proxies `/api` requests to Rails on port 3000.

For a separately hosted API, set `VITE_API_URL` to the API base URL, for example `https://api.example.com/api/v1`.

## Tests and build

```bash
cd backend
bin/rails test
```

```bash
cd frontend
npm run build
npm run lint
```

## API overview

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/v1/employees` | Search, filter and paginate employees |
| POST | `/api/v1/employees` | Create an employee |
| GET | `/api/v1/employees/:id` | Employee details and salary history |
| PATCH/PUT | `/api/v1/employees/:id` | Update an employee |
| DELETE | `/api/v1/employees/:id` | Delete an employee without salary history |
| GET | `/api/v1/employees/:employee_id/salaries` | List salary history |
| POST | `/api/v1/employees/:employee_id/salaries` | Add a salary record |
| GET | `/api/v1/countries` | Country lookup |
| GET | `/api/v1/departments` | Department lookup |
| GET | `/api/v1/insights` | Workforce and compensation summaries |

Employee list query parameters: `search`, `employment_status` (`active` or `inactive`), `country`, `department`, `page`, and `per_page`. When status is omitted, both active and inactive employees are returned.

## Data model notes

- An employee belongs to one country and one department in the initial release.
- Salary history is retained as separate effective-dated records.
- A salary record with no `effective_to` date is ongoing.
- Salary periods for one employee may not overlap.
- Deleting an employee with salary history is restricted to preserve financial history.
- International transfers and effective-dated employee assignments are future enhancements.

## Security and production considerations

This assessment application does not implement authentication or authorization. Before production use, add appropriate HR role access, audit logging, secure deployment configuration, and controls for personal and compensation data.

See [Product Requirements](docs/product_requirements.md) for scope, business rules, assumptions and exclusions.
