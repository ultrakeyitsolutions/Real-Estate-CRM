-- Check Partner Permissions for Bulk Upload
-- This script will show what permissions the Partner role currently has

-- Check if Partner role has BulkUpload permission for Leads/Index
SELECT 
    'Current Partner Permissions' as Status,
    rpp.RoleName,
    p.Controller + '/' + p.Action as Page,
    perm.PermissionName,
    rpp.IsGranted,
    CASE WHEN rpp.ChannelPartnerId IS NULL THEN 'Global' ELSE CAST(rpp.ChannelPartnerId AS VARCHAR) END as Scope
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName = 'Partner' 
AND p.Controller = 'Leads'
AND p.Action = 'Index'
ORDER BY perm.SortOrder;

-- Check if BulkUpload permission exists
SELECT 'BulkUpload Permission Check' as Status, * FROM Permissions WHERE PermissionName = 'BulkUpload';

-- Check Leads/Index page
SELECT 'Leads/Index Page Check' as Status, * FROM Pages WHERE Controller = 'Leads' AND Action = 'Index';

-- Show all Partner permissions
SELECT 
    'All Partner Permissions' as Status,
    rpp.RoleName,
    p.Controller + '/' + p.Action as Page,
    perm.PermissionName,
    rpp.IsGranted,
    CASE WHEN rpp.ChannelPartnerId IS NULL THEN 'Global' ELSE CAST(rpp.ChannelPartnerId AS VARCHAR) END as Scope
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName = 'Partner' 
AND rpp.IsGranted = 1
ORDER BY p.Controller, p.Action, perm.SortOrder;