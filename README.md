# Scalable Multi-Tenant Engine

A backend system for multi-tenant SaaS apps, built with **FastAPI**, **PostgreSQL**, **Supabase**, and **Docker**. The main goal here is strict tenant isolation — every tenant's data stays completely separate, auditing happens automatically at the DB level, and background tasks run without blocking the API.

---

## How It Works

```text
                          ┌──────────────────────────┐
                          │   FastAPI Client / API   │
                          └────────────┬─────────────┘
                                       │
                    ┌──────────────────┴──────────────────┐
                    │                                     │
         ┌──────────▼───────────┐             ┌───────────▼──────────┐
         │ Async Event Worker   │             │   PostgreSQL Engine  │
         │  (Background Tasks)  │             │   (RLS & Triggers)   │
         └──────────────────────┘             └──────────────────────┘
```

A few things worth calling out:

- **Tenant isolation is enforced at two layers.** The database uses Row Level Security (RLS) and composite foreign keys so tenants physically can't access each other's rows. On top of that, the API layer validates tenant ownership through Pydantic schemas before anything hits the DB.
- **Audit logs are automatic.** There's a PL/pgSQL trigger (`process_audit_log`) that captures before/after JSON snapshots on every write to the operational tables. No need to sprinkle logging code throughout the app.
- **RLS doesn't kill performance.** A `SECURITY DEFINER` function (`get_my_tenant()`) marked `STABLE` handles tenant context resolution — this avoids re-evaluating the tenant check on every single row during reads.
- **Everything is async.** DB calls go through `asyncpg`, and long-running work gets handed off to FastAPI's background tasks so the API stays responsive.

---

## Tech Stack

- **FastAPI** (Python 3.11) — API framework
- **PostgreSQL / Supabase** — database + auth
- **asyncpg** — async DB driver
- **Docker & Docker Compose** — containerization
- **pytest + httpx** — testing

---

## Project Structure

```text
scalable-multitenant-engine/
├── backend/
│   ├── app/
│   │   ├── routers/
│   │   │   └── tasks.py        # Task endpoints & tenant validation
│   │   ├── workers.py          # Background event processor
│   │   └── __init__.py
│   ├── tests/
│   │   └── test_main.py        # Integration tests
│   ├── Dockerfile
│   ├── main.py                 # App entrypoint, DB connection pool
│   └── requirements.txt
├── supabase/
│   ├── migrations/             # SQL migrations (schema, RLS, triggers)
│   └── seed.sql                # Test seed data
├── docker-compose.yml
└── README.md
```

---

## Getting Started

### What You'll Need

- [Docker Desktop](https://www.docker.com/) running
- [Supabase CLI](https://supabase.com/docs/guides/cli) (`supabase.exe`)
- Python 3.11+

### Setup

**1. Clone it:**
```bash
git clone https://github.com/ramzanhasnain4-dotcom/scalable-multitenant-engine.git
cd scalable-multitenant-engine
```

**2. Start the local Supabase instance:**
```bash
./supabase.exe start
```
This spins up the Docker stack, runs all the migrations in order, and seeds the DB with test data from `supabase/seed.sql`.

**3. Build and run the backend:**
```bash
docker-compose up --build
```

Once it's up:
- API → `http://localhost:8000`
- Health check → `http://localhost:8000/health`
- Supabase Studio → `http://127.0.0.1:54323`

---

## API Endpoints

### `GET /health`

Basic health check.

```json
{
  "status": "healthy",
  "engine": "running"
}
```

### `POST /tasks`

Creates a new task scoped to a tenant and project.

**Request:**
```json
{
  "tenant_id": "11111111-1111-1111-1111-111111111111",
  "project_id": "33333333-3333-3333-3333-333333333333",
  "title": "Configure payment gateway",
  "status": "in_progress"
}
```

**Response (201):**
```json
{
  "id": "a5d8f9e0-1234-5678-9abc-def012345678",
  "tenant_id": "11111111-1111-1111-1111-111111111111",
  "project_id": "33333333-3333-3333-3333-333333333333",
  "title": "Configure payment gateway",
  "status": "in_progress"
}
```

If the `project_id` doesn't belong to the given `tenant_id`, you'll get a **400** back with details about the constraint violation.

---

## Tests

```bash
cd backend
pytest
```

Runs the integration tests against the API using `httpx`.
