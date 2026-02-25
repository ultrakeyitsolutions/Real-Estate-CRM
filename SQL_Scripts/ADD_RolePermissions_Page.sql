-- Add RolePermissions page to the Users module
INSERT INTO Pages (ModuleId, PageName, DisplayName, Controller, Action, SortOrder) 
VALUES (8, 'RolePermissions', 'Role Permissions', 'ManageUsers', 'RolePermissions', 3);