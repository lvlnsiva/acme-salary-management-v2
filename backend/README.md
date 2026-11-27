# Rails API

## Requirements

- Ruby 3.1.x
- Bundler
- PostgreSQL

## Setup

```bash
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

Start the API:

```bash
bin/rails server
```

The API is available under `/api/v1`. The root health endpoint is `/up`.

## Tests

```bash
bin/rails test
```

The test suite covers employee CRUD/search/filtering/pagination, salary history and validations, reference data endpoints, and insights response structure.

## Seed data

`db/seeds.rb` creates reference countries/departments and 10,000 deterministic demo employees with varied employment statuses and salary histories. Demo employee numbers use the `DEMO-` prefix. Re-running the seed removes and recreates only those demo employees and their salary rows; other employee records are preserved.

## API conventions

Validation failures return HTTP 422 with an `errors` array. Missing records return HTTP 404. Invalid employment status filters return HTTP 400. Employee list responses include pagination metadata.
