-- Trigger function that formats and logs record changes into public.audit_logs
CREATE OR REPLACE FUNCTION public.process_audit_log()
RETURNS TRIGGER 
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_tenant_id UUID;
    v_user_id UUID;
BEGIN
    -- Extract the acting user ID from Supabase auth session context
    v_user_id := auth.uid();

    -- Determine tenant context depending on the operation type
    IF (TG_OP = 'DELETE') THEN
        v_tenant_id := OLD.tenant_id;
    ELSE
        v_tenant_id := NEW.tenant_id;
    END IF;

    -- Record snapshot into central audit log
    INSERT INTO public.audit_logs (
        tenant_id,
        table_name,
        action,
        row_id,
        old_data,
        new_data,
        changed_by
    ) VALUES (
        v_tenant_id,
        TG_TABLE_NAME,
        TG_OP,
        COALESCE(NEW.id, OLD.id),
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END,
        v_user_id
    );

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    END IF;
    RETURN NEW;
END;
$$;
