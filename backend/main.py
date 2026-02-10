import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
import asyncpg
from dotenv import load_dotenv

load_dotenv()

# Global database connection pool
db_pool: asyncpg.Pool = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global db_pool
    # Initialize connection pool using local Postgres container URL
    db_url = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@127.0.0.1:54322/postgres")
    db_pool = await asyncpg.create_pool(dsn=db_url, min_size=2, max_size=10)
    print("Database connection pool established.")
    
    yield
    
    # Clean shutdown of connection pool
    if db_pool:
        await db_pool.close()
        print("Database connection pool closed.")

app = FastAPI(title="Multi-Tenant Event Engine Core", lifespan=lifespan)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "engine": "running"}