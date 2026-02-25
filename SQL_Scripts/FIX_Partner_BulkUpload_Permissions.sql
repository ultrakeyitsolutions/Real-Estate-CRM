-- Fix Partner BulkUpload Permissions
-- Grant Partner role global permissions for Leads module

-- Get Page IDs
DECLARE @LeadsIndexPageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Index');

-- Remove existing Partner permissions for Leads/Index to avoid duplicates
DELETE FROM RolePagePermissions 
WHERE RoleName = 'Partner' 
AND PageId = @LeadsIndexPageId;

-- Grant global Partner permissions (ChannelPartnerId = NULL)
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) VALUES
('Partner', @LeadsIndexPageId, 1, 1, 'System', NULL), -- View Access
('Partner', @LeadsIndexPageId, 2, 1, 'System', NULL), -- Create Access
('Partner', @LeadsIndexPageId, 3, 1, 'System', NULL), -- Edit Access
('Partner', @LeadsIndexPageId, 4, 1, 'System', NULL), -- Delete Access
('Partner', @LeadsIndexPageId, 5, 1, 'System', NULL), -- Export Access
('Partner', @LeadsIndexPageId, 6, 1, 'System', NULL); -- Bulk Upload Access

PRINT 'Partner global permissions granted successfully';

-- Verification
SELECT 
    'Partner Permissions Check' as Status,
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
AND rpp.IsGranted = 1
ORDER BY perm.SortOrder;