-- Central audit log table to track changes across all tenant resources
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.tenants(id) ON DELETE SET NULL,
    table_name TEXT NOT NULL,
    action TEXT NOT NULL, -- e.g. INSERT, UPDATE, DELETE
    row_id UUID NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_by UUID, -- Stores auth.uid() when called within a user session
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index audit logs by tenant for fast dashboard querying
CREATE INDEX idx_audit_logs_tenant ON public.audit_logs(tenant_id);

-- Speed up filtering by action type (useful for security review screens)
CREATE INDEX idx_audit_logs_action ON public.audit_logs(action);