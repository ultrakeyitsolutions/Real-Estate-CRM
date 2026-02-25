-- Grant Agent role basic permissions to Leads pages
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy)
SELECT 'Agent', p.PageId, perm.PermissionId, 1, 'System'
FROM Pages p
CROSS JOIN Permissions perm
WHERE p.Controller = 'Leads' 
AND perm.PermissionName IN ('View', 'Create', 'Edit')
AND NOT EXISTS (
    SELECT 1 FROM RolePagePermissions rpp 
    WHERE rpp.RoleName = 'Agent' 
    AND rpp.PageId = p.PageId 
    AND rpp.PermissionId = perm.PermissionId
);