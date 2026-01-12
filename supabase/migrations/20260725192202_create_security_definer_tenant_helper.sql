-- Helper function to fetch the tenant ID of the currently authenticated user.
-- Marked as STABLE so Postgres caches the lookup result within the same query.
CREATE OR REPLACE FUNCTION public.get_my_tenant()
RETURNS UUID
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT tenant_id 
  FROM public.profiles 
  WHERE id = auth.uid();
$$;