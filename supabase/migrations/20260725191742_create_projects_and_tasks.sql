-- 1. Projects Table
CREATE TABLE public.projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Ensure project codes are unique *within* the same tenant,
-- but different tenants can reuse identical project codes!
ALTER TABLE public.projects 
    ADD CONSTRAINT unique_tenant_project_code UNIQUE (tenant_id, code);

-- 2. Tasks Table (Relational tenant constraint enforced)
CREATE TABLE public.tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    status TEXT DEFAULT 'backlog' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,

    -- Multi-Tenant Foreign Key Constraint:
    -- Guarantees a task cannot be assigned to a project that belongs to a different tenant!
    CONSTRAINT fk_task_project_tenant FOREIGN KEY (tenant_id, project_id) 
        REFERENCES public.projects(tenant_id, id) ON DELETE CASCADE
);

-- Indexes for performance under heavy query load
CREATE INDEX idx_projects_tenant ON public.projects(tenant_id);
CREATE INDEX idx_tasks_tenant ON public.tasks(tenant_id);