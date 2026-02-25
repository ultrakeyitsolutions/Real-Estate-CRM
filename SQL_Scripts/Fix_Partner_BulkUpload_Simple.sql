-- Simple Fix for Partner BulkUpload Permission
-- Grant Partner role the BulkUpload permission for Leads/Index

DECLARE @LeadsIndexPageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Index');
DECLARE @BulkUploadPermissionId INT = (SELECT PermissionId FROM Permissions WHERE PermissionName = 'BulkUpload');

-- Check if permission already exists
IF NOT EXISTS (
    SELECT 1 FROM RolePagePermissions 
    WHERE RoleName = 'Partner' 
    AND PageId = @LeadsIndexPageId 
    AND PermissionId = @BulkUploadPermissionId 
    AND ChannelPartnerId IS NULL
    AND IsGranted = 1
)
BEGIN
    -- Remove any existing BulkUpload permission for Partner on Leads/Index to avoid duplicates
    DELETE FROM RolePagePermissions 
    WHERE RoleName = 'Partner' 
    AND PageId = @LeadsIndexPageId 
    AND PermissionId = @BulkUploadPermissionId;

    -- Grant global BulkUpload permission to Partner role
    INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) 
    VALUES ('Partner', @LeadsIndexPageId, @BulkUploadPermissionId, 1, 'System', NULL);

    PRINT 'Partner BulkUpload permission granted successfully';
END
ELSE
BEGIN
    PRINT 'Partner already has BulkUpload permission';
END

-- Verification
SELECT 
    'Verification: Partner BulkUpload Permission' as Status,
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
AND perm.PermissionName = 'BulkUpload';