-- Add comprehensive permissions for Sales role
-- First, ensure we have the basic pages
IF NOT EXISTS (SELECT 1 FROM Pages WHERE Controller = 'Leads' AND Action = 'Create')
BEGIN
    INSERT INTO Pages (ModuleId, PageName, DisplayName, Controller, Action, SortOrder) VALUES
    (1, 'Create', 'Add New Lead', 'Leads', 'Create', 3);
END

IF NOT EXISTS (SELECT 1 FROM Pages WHERE Controller = 'Leads' AND Action = 'Edit')
BEGIN
    INSERT INTO Pages (ModuleId, PageName, DisplayName, Controller, Action, SortOrder) VALUES
    (1, 'Edit', 'Edit Lead', 'Leads', 'Edit', 4);
END

-- Clear existing Sales permissions to avoid duplicates
DELETE FROM RolePagePermissions WHERE RoleName = 'Sales';

-- Add comprehensive permissions for Sales role
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy) VALUES
-- Leads Index page permissions
('Sales', (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Index'), 1, 1, 'System'), -- View
('Sales', (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Index'), 2, 1, 'System'), -- Create
('Sales', (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Index'), 3, 1, 'System'), -- Edit
('Sales', (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Index'), 5, 1, 'System'), -- Export

-- Leads Details page permissions
('Sales', (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Details'), 1, 1, 'System'), -- View

-- Leads Create page permissions (if exists)
('Sales', (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Create'), 1, 1, 'System'), -- View
('Sales', (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Create'), 2, 1, 'System'), -- Create

-- Leads Edit page permissions (if exists)
('Sales', (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Edit'), 1, 1, 'System'), -- View
('Sales', (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Edit'), 3, 1, 'System'); -- Edit

-- Verify the permissions were added
SELECT 
    rpp.RoleName,
    p.Controller,
    p.Action,
    p.DisplayName,
    perm.PermissionName,
    rpp.IsGranted
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName = 'Sales'
ORDER BY p.Controller, p.Action, perm.SortOrder;