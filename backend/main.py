import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
import asyncpg
from dotenv import load_dotenv

from app.routers import tasks

load_dotenv()

@asynccontextmanager
async def lifespan(app: FastAPI):
    db_url = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@127.0.0.1:54322/postgres")
    app.state.db_pool = await asyncpg.create_pool(dsn=db_url, min_size=2, max_size=10)
    print("Database connection pool established.")
    
    yield
    
    if hasattr(app.state, "db_pool") and app.state.db_pool:
        await app.state.db_pool.close()
        print("Database connection pool closed.")

app = FastAPI(title="Multi-Tenant Event Engine Core", lifespan=lifespan)

# Register endpoints
app.include_router(tasks.router)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "engine": "running"}