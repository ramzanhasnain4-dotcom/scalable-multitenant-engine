-- Enable Row Level Security on target application tables
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- PROJECTS POLICIES
-- -----------------------------------------------------------------------------

CREATE POLICY "Users can view projects belonging to their tenant"
    ON public.projects FOR SELECT TO authenticated
    USING (tenant_id = (SELECT public.get_my_tenant()));

CREATE POLICY "Users can insert projects into their own tenant"
    ON public.projects FOR INSERT TO authenticated
    WITH CHECK (tenant_id = (SELECT public.get_my_tenant()));

CREATE POLICY "Users can update projects within their tenant"
    ON public.projects FOR UPDATE TO authenticated
    USING (tenant_id = (SELECT public.get_my_tenant()))
    WITH CHECK (tenant_id = (SELECT public.get_my_tenant()));

CREATE POLICY "Users can delete projects within their tenant"
    ON public.projects FOR DELETE TO authenticated
    USING (tenant_id = (SELECT public.get_my_tenant()));

-- -----------------------------------------------------------------------------
-- TASKS POLICIES
-- -----------------------------------------------------------------------------

CREATE POLICY "Users can view tasks belonging to their tenant"
    ON public.tasks FOR SELECT TO authenticated
    USING (tenant_id = (SELECT public.get_my_tenant()));

CREATE POLICY "Users can manage tasks within their tenant"
    ON public.tasks FOR ALL TO authenticated
    USING (tenant_id = (SELECT public.get_my_tenant()))
    WITH CHECK (tenant_id = (SELECT public.get_my_tenant()));