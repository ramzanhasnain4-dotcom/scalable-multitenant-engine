import pytest
from httpx import AsyncClient
from main import app

@pytest.mark.asyncio
async def test_health_check():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy", "engine": "running"}

@pytest.mark.asyncio
async def test_invalid_task_payload():
    # Verify that invalid UUID formats are caught by Pydantic validation
    async with AsyncClient(app=app, base_url="http://test") as ac:
        response = await ac.post("/tasks", json={
            "tenant_id": "invalid-uuid",
            "project_id": "invalid-uuid",
            "title": "Test Task"
        })
    assert response.status_code == 422