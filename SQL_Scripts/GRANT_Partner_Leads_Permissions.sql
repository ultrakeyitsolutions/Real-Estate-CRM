-- Grant Partner role comprehensive permissions for Leads module
-- This script ensures Partner role has access to Add Lead and Bulk Upload buttons

-- Step 1: Remove existing Partner permissions for Leads (to avoid duplicates)
DELETE FROM RolePagePermissions 
WHERE RoleName = 'Partner' 
AND PageId IN (
    SELECT PageId FROM Pages WHERE Controller = 'Leads'
);

-- Step 2: Get Page IDs for Leads module
DECLARE @LeadsIndexPageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Index');
DECLARE @LeadsDetailsPageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Details');
DECLARE @LeadsCreatePageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Create');
DECLARE @LeadsEditPageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Leads' AND Action = 'Edit');

-- Step 3: Grant Partner permissions for each existing ChannelPartner
DECLARE @ChannelPartnerId INT;
DECLARE channel_cursor CURSOR FOR 
SELECT DISTINCT PartnerId FROM ChannelPartners WHERE Status = 'Approved';

OPEN channel_cursor;
FETCH NEXT FROM channel_cursor INTO @ChannelPartnerId;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Grant permissions for Leads/Index
    INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) VALUES
    ('Partner', @LeadsIndexPageId, 1, 1, 'System', @ChannelPartnerId), -- View Access
    ('Partner', @LeadsIndexPageId, 2, 1, 'System', @ChannelPartnerId), -- Create Access
    ('Partner', @LeadsIndexPageId, 3, 1, 'System', @ChannelPartnerId), -- Edit Access
    ('Partner', @LeadsIndexPageId, 4, 1, 'System', @ChannelPartnerId), -- Delete Access
    ('Partner', @LeadsIndexPageId, 5, 1, 'System', @ChannelPartnerId), -- Export Access
    ('Partner', @LeadsIndexPageId, 6, 1, 'System', @ChannelPartnerId); -- Bulk Upload Access

    -- Grant permissions for Leads/Details
    INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) VALUES
    ('Partner', @LeadsDetailsPageId, 1, 1, 'System', @ChannelPartnerId), -- View Access
    ('Partner', @LeadsDetailsPageId, 2, 1, 'System', @ChannelPartnerId), -- Create Access
    ('Partner', @LeadsDetailsPageId, 3, 1, 'System', @ChannelPartnerId), -- Edit Access
    ('Partner', @LeadsDetailsPageId, 4, 1, 'System', @ChannelPartnerId), -- Delete Access
    ('Partner', @LeadsDetailsPageId, 5, 1, 'System', @ChannelPartnerId), -- Export Access
    ('Partner', @LeadsDetailsPageId, 6, 1, 'System', @ChannelPartnerId); -- Bulk Upload Access

    -- Grant permissions for Leads/Create (if exists)
    IF @LeadsCreatePageId IS NOT NULL
    BEGIN
        INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) VALUES
        ('Partner', @LeadsCreatePageId, 1, 1, 'System', @ChannelPartnerId), -- View Access
        ('Partner', @LeadsCreatePageId, 2, 1, 'System', @ChannelPartnerId); -- Create Access
    END

    -- Grant permissions for Leads/Edit (if exists)
    IF @LeadsEditPageId IS NOT NULL
    BEGIN
        INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) VALUES
        ('Partner', @LeadsEditPageId, 1, 1, 'System', @ChannelPartnerId), -- View Access
        ('Partner', @LeadsEditPageId, 3, 1, 'System', @ChannelPartnerId); -- Edit Access
    END

    FETCH NEXT FROM channel_cursor INTO @ChannelPartnerId;
END

CLOSE channel_cursor;
DEALLOCATE channel_cursor;

PRINT 'Partner permissions for Leads granted successfully';

-- Grant permissions for specific Partner IDs: 3, 4, 5 (from your data)
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) VALUES
('Partner', @LeadsIndexPageId, 1, 1, 'System', 3), -- View Access
('Partner', @LeadsIndexPageId, 2, 1, 'System', 3), -- Create Access
('Partner', @LeadsIndexPageId, 3, 1, 'System', 3), -- Edit Access
('Partner', @LeadsIndexPageId, 4, 1, 'System', 3), -- Delete Access
('Partner', @LeadsIndexPageId, 5, 1, 'System', 3), -- Export Access
('Partner', @LeadsIndexPageId, 6, 1, 'System', 3), -- Bulk Upload Access
('Partner', @LeadsIndexPageId, 1, 1, 'System', 4), -- View Access
('Partner', @LeadsIndexPageId, 2, 1, 'System', 4), -- Create Access
('Partner', @LeadsIndexPageId, 3, 1, 'System', 4), -- Edit Access
('Partner', @LeadsIndexPageId, 4, 1, 'System', 4), -- Delete Access
('Partner', @LeadsIndexPageId, 5, 1, 'System', 4), -- Export Access
('Partner', @LeadsIndexPageId, 6, 1, 'System', 4), -- Bulk Upload Access
('Partner', @LeadsIndexPageId, 1, 1, 'System', 5), -- View Access
('Partner', @LeadsIndexPageId, 2, 1, 'System', 5), -- Create Access
('Partner', @LeadsIndexPageId, 3, 1, 'System', 5), -- Edit Access
('Partner', @LeadsIndexPageId, 4, 1, 'System', 5), -- Delete Access
('Partner', @LeadsIndexPageId, 5, 1, 'System', 5), -- Export Access
('Partner', @LeadsIndexPageId, 6, 1, 'System', 5); -- Bulk Upload Access

-- Step 7: Verification - Show current Partner permissions for Leads
SELECT 
    'VERIFICATION: Partner Leads Permissions' as Status,
    rpp.RoleName,
    m.DisplayName as Module,
    p.DisplayName as Page,
    p.Controller + '/' + p.Action as ControllerAction,
    perm.PermissionName,
    rpp.IsGranted,
    CASE WHEN rpp.ChannelPartnerId IS NULL THEN 'Global' ELSE CAST(rpp.ChannelPartnerId AS VARCHAR) END as Scope
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Modules m ON p.ModuleId = m.ModuleId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName = 'Partner' 
AND p.Controller = 'Leads'
AND rpp.IsGranted = 1
ORDER BY p.SortOrder, perm.SortOrder;

-- Step 8: Show permission check for specific actions
-- Step 8: Show permission check for each channel partner
SELECT 
    'PERMISSION CHECK: Partner Permissions by ChannelPartnerId' as CheckType,
    rpp.ChannelPartnerId,
    perm.PermissionName,
    COUNT(*) as PermissionCount
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName = 'Partner' 
AND p.Controller = 'Leads' 
AND p.Action = 'Index'
AND perm.PermissionName IN ('Create', 'BulkUpload')
AND rpp.IsGranted = 1
GROUP BY rpp.ChannelPartnerId, perm.PermissionName
ORDER BY rpp.ChannelPartnerId, perm.PermissionName;