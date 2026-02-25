-- Debug Partner BulkUpload Issue
-- This script will help identify why Partner bulk upload isn't working

-- 1. Check if BulkUpload permission exists
SELECT 'Step 1: BulkUpload Permission' as Step, * FROM Permissions WHERE PermissionName = 'BulkUpload';

-- 2. Check if Leads/Index page exists
SELECT 'Step 2: Leads/Index Page' as Step, * FROM Pages WHERE Controller = 'Leads' AND Action = 'Index';

-- 3. Check Partner role permissions for Leads/Index
SELECT 
    'Step 3: Partner Permissions for Leads/Index' as Step,
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
ORDER BY perm.PermissionName;

-- 4. Check if Partner has BulkUpload permission specifically
SELECT 
    'Step 4: Partner BulkUpload Permission Check' as Step,
    COUNT(*) as PermissionCount
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName = 'Partner' 
AND p.Controller = 'Leads'
AND p.Action = 'Index'
AND perm.PermissionName = 'BulkUpload'
AND rpp.IsGranted = 1;

-- 5. Show what permissions Partner role has globally
SELECT 
    'Step 5: All Partner Global Permissions' as Step,
    p.Controller + '/' + p.Action as Page,
    perm.PermissionName,
    rpp.IsGranted
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName = 'Partner' 
AND rpp.ChannelPartnerId IS NULL
AND rpp.IsGranted = 1
ORDER BY p.Controller, p.Action, perm.PermissionName;