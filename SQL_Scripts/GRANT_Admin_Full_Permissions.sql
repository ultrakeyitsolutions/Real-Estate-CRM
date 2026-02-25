-- Grant Admin role full permissions to all pages
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy)
SELECT 'Admin', p.PageId, perm.PermissionId, 1, 'System'
FROM Pages p
CROSS JOIN Permissions perm
WHERE NOT EXISTS (
    SELECT 1 FROM RolePagePermissions rpp 
    WHERE rpp.RoleName = 'Admin' 
    AND rpp.PageId = p.PageId 
    AND rpp.PermissionId = perm.PermissionId
);