-- Clean seed file for local multi-tenancy verification

-- 1. Create Mock Tenants
INSERT INTO public.tenants (id, name) VALUES 
    ('11111111-1111-1111-1111-111111111111', 'Acme Corp'),
    ('22222222-2222-2222-2222-222222222222', 'Stark Industries');

-- 2. Create Mock Tenant Projects
-- Note: Both tenants use project code 'ALPHA' to demonstrate tenant-scoped unique constraints.
INSERT INTO public.projects (id, tenant_id, name, code) VALUES
    ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', 'Acme E-Commerce Platform', 'ALPHA'),
    ('44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 'Arc Reactor Refactoring', 'ALPHA');

-- 3. Create Mock Project Tasks
INSERT INTO public.tasks (tenant_id, project_id, title, status) VALUES
    ('11111111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'Configure payment gateway', 'in_progress'),
    ('22222222-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444', 'Optimize thermal output algorithms', 'backlog');
