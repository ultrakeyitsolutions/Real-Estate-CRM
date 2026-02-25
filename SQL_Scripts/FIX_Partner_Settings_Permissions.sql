-- Fix Partner Settings Permissions
-- This script ensures Partner role has proper access to Settings module

-- Step 1: Ensure Settings Module exists
IF NOT EXISTS (SELECT 1 FROM Modules WHERE ModuleName = 'Settings')
BEGIN
    INSERT INTO Modules (ModuleName, DisplayName, Icon, SortOrder, IsActive) VALUES
    ('Settings', 'System Settings', 'fa-cog', 12, 1);
    PRINT 'Settings module added';
END
ELSE
BEGIN
    PRINT 'Settings module already exists';
END

-- Step 2: Get Settings ModuleId
DECLARE @SettingsModuleId INT = (SELECT ModuleId FROM Modules WHERE ModuleName = 'Settings');

-- Step 3: Ensure Settings Pages exist
IF NOT EXISTS (SELECT 1 FROM Pages WHERE Controller = 'Settings' AND Action = 'Index')
BEGIN
    INSERT INTO Pages (ModuleId, PageName, DisplayName, Controller, Action, SortOrder, IsActive) VALUES
    (@SettingsModuleId, 'Index', 'Settings', 'Settings', 'Index', 1, 1);
    PRINT 'Settings/Index page added';
END

IF NOT EXISTS (SELECT 1 FROM Pages WHERE Controller = 'Settings' AND Action = 'UpdateSettings')
BEGIN
    INSERT INTO Pages (ModuleId, PageName, DisplayName, Controller, Action, SortOrder, IsActive) VALUES
    (@SettingsModuleId, 'UpdateSettings', 'Update Settings', 'Settings', 'UpdateSettings', 2, 1);
    PRINT 'Settings/UpdateSettings page added';
END

-- Step 4: Get Page IDs
DECLARE @SettingsIndexPageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Settings' AND Action = 'Index');
DECLARE @SettingsUpdatePageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Settings' AND Action = 'UpdateSettings');

-- Step 5: Remove existing Partner permissions for Settings (to avoid duplicates)
DELETE FROM RolePagePermissions 
WHERE RoleName = 'Partner' 
AND PageId IN (@SettingsIndexPageId, @SettingsUpdatePageId);

-- Step 6: Grant Partner role comprehensive access to Settings
-- For Settings/Index
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) VALUES
('Partner', @SettingsIndexPageId, 1, 1, 'System', NULL), -- View Access
('Partner', @SettingsIndexPageId, 2, 1, 'System', NULL), -- Create Access
('Partner', @SettingsIndexPageId, 3, 1, 'System', NULL), -- Edit Access
('Partner', @SettingsIndexPageId, 4, 1, 'System', NULL), -- Delete Access
('Partner', @SettingsIndexPageId, 5, 1, 'System', NULL), -- Export Access
('Partner', @SettingsIndexPageId, 6, 1, 'System', NULL); -- Bulk Upload Access

-- For Settings/UpdateSettings
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) VALUES
('Partner', @SettingsUpdatePageId, 1, 1, 'System', NULL), -- View Access
('Partner', @SettingsUpdatePageId, 2, 1, 'System', NULL), -- Create Access
('Partner', @SettingsUpdatePageId, 3, 1, 'System', NULL), -- Edit Access
('Partner', @SettingsUpdatePageId, 4, 1, 'System', NULL), -- Delete Access
('Partner', @SettingsUpdatePageId, 5, 1, 'System', NULL), -- Export Access
('Partner', @SettingsUpdatePageId, 6, 1, 'System', NULL); -- Bulk Upload Access

PRINT 'Partner permissions for Settings granted successfully';

-- Step 7: Verification - Show current Partner permissions for Settings
SELECT 
    'VERIFICATION: Partner Settings Permissions' as Status,
    rpp.RoleName,
    m.DisplayName as Module,
    p.DisplayName as Page,
    p.Controller + '/' + p.Action as ControllerAction,
    perm.PermissionName,
    rpp.IsGranted,
    CASE WHEN rpp.ChannelPartnerId IS NULL THEN 'Admin/Global' ELSE CAST(rpp.ChannelPartnerId AS VARCHAR) END as Scope
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Modules m ON p.ModuleId = m.ModuleId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName = 'Partner' 
AND m.ModuleName = 'Settings'
AND rpp.IsGranted = 1
ORDER BY p.SortOrder, perm.SortOrder;

-- Step 8: Show all modules and pages for reference
SELECT 
    'ALL MODULES AND PAGES' as Status,
    m.ModuleName,
    m.DisplayName as ModuleDisplay,
    p.PageName,
    p.DisplayName as PageDisplay,
    p.Controller,
    p.Action
FROM Modules m
LEFT JOIN Pages p ON m.ModuleId = p.ModuleId
WHERE m.IsActive = 1 AND (p.IsActive = 1 OR p.IsActive IS NULL)
ORDER BY m.SortOrder, p.SortOrder;