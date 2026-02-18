from uuid import UUID
from fastapi import APIRouter, HTTPException, Request
from pydantic import BaseModel, Field

router = APIRouter(prefix="/tasks", tags=["tasks"])

class TaskCreate(BaseModel):
    tenant_id: UUID
    project_id: UUID
    title: str = Field(..., min_length=1, max_length=255)
    status: str = Field(default="backlog")

class TaskResponse(BaseModel):
    id: UUID
    tenant_id: UUID
    project_id: UUID
    title: str
    status: str

@router.post("", response_model=TaskResponse, status_code=21)
async def create_task(task: TaskCreate, request: Request):
    db_pool = request.app.state.db_pool
    
    query = """
        INSERT INTO public.tasks (tenant_id, project_id, title, status)
        VALUES ($1, $2, $3, $4)
        RETURNING id, tenant_id, project_id, title, status;
    """
    
    async with db_pool.acquire() as conn:
        try:
            row = await conn.fetchrow(
                query, 
                task.tenant_id, 
                task.project_id, 
                task.title, 
                task.status
            )
            return dict(row)
        except Exception as e:
            # Handle foreign key constraint violations (cross-tenant assignment rejection)
            if "fk_task_project_tenant" in str(e):
                raise HTTPException(
                    status_code=400, 
                    detail="Invalid project_id for the specified tenant_id"
                )
            raise HTTPException(status_code=500, detail=str(e))