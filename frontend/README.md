# React frontend

## Requirements

- Node.js 18+
- npm

## Setup

```bash
npm install
npm run dev
```

The Vite development server proxies `/api` to Rails at `http://localhost:3000`. Start the Rails API before using the application.

For another API host, set `VITE_API_URL` to the full API base URL, including `/api/v1`.

## Quality checks

```bash
npm run build
npm run lint
```

The UI includes employee search and filters, employee CRUD, employee details, salary history, salary creation, headcount cards and compensation breakdowns.
