-- Try to create a task assigned to Acme Corp's Tenant ID (11111111-...) 
-- but pointed at Stark Industries' Project ID (44444444-...)
INSERT INTO public.tasks (tenant_id, project_id, title, status) 
VALUES (
    '11111111-1111-1111-1111-111111111111', 
    '44444444-4444-4444-4444-444444444444', 
    'Malicious Cross-Tenant Task', 
    'backlog'
);