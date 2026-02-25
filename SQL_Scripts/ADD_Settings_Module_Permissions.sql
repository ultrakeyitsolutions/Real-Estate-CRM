-- Add Settings Module and Permissions
-- This script adds the Settings module to the permission system and grants Partner role access

-- Insert Settings Module
IF NOT EXISTS (SELECT 1 FROM Modules WHERE ModuleName = 'Settings')
BEGIN
    INSERT INTO Modules (ModuleName, DisplayName, Icon, SortOrder) VALUES
    ('Settings', 'System Settings', 'fa-cog', 12);
END

-- Get the ModuleId for Settings
DECLARE @SettingsModuleId INT = (SELECT ModuleId FROM Modules WHERE ModuleName = 'Settings');

-- Insert Settings Pages
IF NOT EXISTS (SELECT 1 FROM Pages WHERE Controller = 'Settings' AND Action = 'Index')
BEGIN
    INSERT INTO Pages (ModuleId, PageName, DisplayName, Controller, Action, SortOrder) VALUES
    (@SettingsModuleId, 'Index', 'Settings', 'Settings', 'Index', 1),
    (@SettingsModuleId, 'UpdateSettings', 'Update Settings', 'Settings', 'UpdateSettings', 2);
END

-- Get PageIds for Settings
DECLARE @SettingsIndexPageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Settings' AND Action = 'Index');
DECLARE @SettingsUpdatePageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Settings' AND Action = 'UpdateSettings');

-- Grant Partner role full access to Settings
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) VALUES
-- Partner role - Settings/Index permissions
('Partner', @SettingsIndexPageId, 1, 1, 'System', NULL), -- View Access
('Partner', @SettingsIndexPageId, 2, 1, 'System', NULL), -- Create Access
('Partner', @SettingsIndexPageId, 3, 1, 'System', NULL), -- Edit Access
('Partner', @SettingsIndexPageId, 4, 1, 'System', NULL), -- Delete Access
('Partner', @SettingsIndexPageId, 5, 1, 'System', NULL), -- Export Access
('Partner', @SettingsIndexPageId, 6, 1, 'System', NULL), -- Bulk Upload Access

-- Partner role - Settings/UpdateSettings permissions
('Partner', @SettingsUpdatePageId, 1, 1, 'System', NULL), -- View Access
('Partner', @SettingsUpdatePageId, 2, 1, 'System', NULL), -- Create Access
('Partner', @SettingsUpdatePageId, 3, 1, 'System', NULL), -- Edit Access
('Partner', @SettingsUpdatePageId, 4, 1, 'System', NULL), -- Delete Access
('Partner', @SettingsUpdatePageId, 5, 1, 'System', NULL), -- Export Access
('Partner', @SettingsUpdatePageId, 6, 1, 'System', NULL); -- Bulk Upload Access

-- Verify the setup
SELECT 
    'Settings Module Added' as Status,
    m.DisplayName as Module,
    p.DisplayName as Page,
    p.Controller,
    p.Action
FROM Pages p
JOIN Modules m ON p.ModuleId = m.ModuleId
WHERE m.ModuleName = 'Settings';

-- Show Partner permissions for Settings
SELECT 
    rpp.RoleName,
    m.DisplayName as Module,
    p.DisplayName as Page,
    p.Controller + '/' + p.Action as ControllerAction,
    perm.PermissionName,
    rpp.IsGranted,
    rpp.ChannelPartnerId
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Modules m ON p.ModuleId = m.ModuleId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName = 'Partner' AND m.ModuleName = 'Settings'
ORDER BY p.SortOrder, perm.SortOrder;