-- Complete Permission System Setup
-- Clear existing data to start fresh
DELETE FROM RolePagePermissions;
DELETE FROM Pages;
DELETE FROM Modules;
DELETE FROM Permissions;

-- Reset identity seeds
DBCC CHECKIDENT ('RolePagePermissions', RESEED, 0);
DBCC CHECKIDENT ('Pages', RESEED, 0);
DBCC CHECKIDENT ('Modules', RESEED, 0);
DBCC CHECKIDENT ('Permissions', RESEED, 0);

-- Insert Permissions
INSERT INTO Permissions (PermissionName, DisplayName, Description, SortOrder) VALUES
('View', 'View Access', 'Can view the page and data', 1),
('Create', 'Create Access', 'Can create new records', 2),
('Edit', 'Edit Access', 'Can modify existing records', 3),
('Delete', 'Delete Access', 'Can delete records', 4),
('Export', 'Export Access', 'Can export data to Excel/CSV', 5),
('BulkUpload', 'Bulk Upload Access', 'Can upload multiple records', 6);

-- Insert Modules
INSERT INTO Modules (ModuleName, DisplayName, Icon, SortOrder) VALUES
('Leads', 'Lead Management', 'fa-users', 1),
('Properties', 'Property Management', 'fa-building', 2),
('Revenue', 'Revenue Management', 'fa-coins', 3),
('Expenses', 'Expense Management', 'fa-money-bill-wave', 4),
('Bookings', 'Booking Management', 'fa-calendar-check', 5),
('Payments', 'Payment Management', 'fa-credit-card', 6),
('Quotations', 'Quotation Management', 'fa-file-invoice', 7),
('Invoices', 'Invoice Management', 'fa-receipt', 8),
('Tasks', 'Task Management', 'fa-tasks', 9),
('Reports', 'Reports & Analytics', 'fa-chart-bar', 10),
('Users', 'User Management', 'fa-user-cog', 11);

-- Insert Pages for all modules
INSERT INTO Pages (ModuleId, PageName, DisplayName, Controller, Action, SortOrder) VALUES
-- Leads Module (1)
(1, 'Index', 'Lead List', 'Leads', 'Index', 1),
(1, 'Details', 'Lead Details', 'Leads', 'Details', 2),
(1, 'Create', 'Add New Lead', 'Leads', 'Create', 3),
(1, 'Edit', 'Edit Lead', 'Leads', 'Edit', 4),

-- Properties Module (2)
(2, 'Index', 'Property List', 'Properties', 'Index', 1),
(2, 'Details', 'Property Details', 'Properties', 'Details', 2),
(2, 'Create', 'Add Property', 'Properties', 'Create', 3),
(2, 'Edit', 'Edit Property', 'Properties', 'Edit', 4),

-- Revenue Module (3)
(3, 'Index', 'Revenue List', 'Revenue', 'Index', 1),
(3, 'Create', 'Add Revenue', 'Revenue', 'Create', 2),
(3, 'Edit', 'Edit Revenue', 'Revenue', 'Edit', 3),

-- Expenses Module (4)
(4, 'Index', 'Expense List', 'Expenses', 'Index', 1),
(4, 'Create', 'Add Expense', 'Expenses', 'Create', 2),
(4, 'Edit', 'Edit Expense', 'Expenses', 'Edit', 3),

-- Bookings Module (5)
(5, 'Index', 'Booking List', 'Bookings', 'Index', 1),
(5, 'Create', 'New Booking', 'Bookings', 'Create', 2),
(5, 'Edit', 'Edit Booking', 'Bookings', 'Edit', 3),

-- Payments Module (6)
(6, 'Index', 'Payment List', 'Payments', 'Index', 1),
(6, 'Create', 'Add Payment', 'Payments', 'Create', 2),
(6, 'Edit', 'Edit Payment', 'Payments', 'Edit', 3),

-- Quotations Module (7)
(7, 'Index', 'Quotation List', 'Quotations', 'Index', 1),
(7, 'Create', 'New Quotation', 'Quotations', 'Create', 2),
(7, 'Edit', 'Edit Quotation', 'Quotations', 'Edit', 3),

-- Invoices Module (8)
(8, 'Index', 'Invoice List', 'Invoices', 'Index', 1),
(8, 'Create', 'New Invoice', 'Invoices', 'Create', 2),
(8, 'Edit', 'Edit Invoice', 'Invoices', 'Edit', 3),

-- Tasks Module (9)
(9, 'Index', 'Task List', 'Tasks', 'Index', 1),

-- Users Module (11)
(11, 'Index', 'User List', 'ManageUsers', 'Index', 1),
(11, 'Roles', 'Role Management', 'ManageUsers', 'Roles', 2);

-- Grant comprehensive permissions to Sales/Agent role
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy) VALUES
-- Sales role - Leads permissions
('Sales', 1, 1, 1, 'System'), -- View Leads/Index
('Sales', 1, 2, 1, 'System'), -- Create Leads/Index
('Sales', 1, 3, 1, 'System'), -- Edit Leads/Index
('Sales', 1, 5, 1, 'System'), -- Export Leads/Index
('Sales', 2, 1, 1, 'System'), -- View Leads/Details
('Sales', 3, 1, 1, 'System'), -- View Leads/Create
('Sales', 3, 2, 1, 'System'), -- Create Leads/Create
('Sales', 4, 1, 1, 'System'), -- View Leads/Edit
('Sales', 4, 3, 1, 'System'), -- Edit Leads/Edit

-- Sales role - Properties permissions
('Sales', 5, 1, 1, 'System'), -- View Properties/Index
('Sales', 6, 1, 1, 'System'), -- View Properties/Details

-- Sales role - Tasks permissions
('Sales', 17, 1, 1, 'System'), -- View Tasks/Index

-- Agent role - same permissions as Sales
('Agent', 1, 1, 1, 'System'), -- View Leads/Index
('Agent', 1, 2, 1, 'System'), -- Create Leads/Index
('Agent', 1, 3, 1, 'System'), -- Edit Leads/Index
('Agent', 1, 5, 1, 'System'), -- Export Leads/Index
('Agent', 2, 1, 1, 'System'), -- View Leads/Details
('Agent', 3, 1, 1, 'System'), -- View Leads/Create
('Agent', 3, 2, 1, 'System'), -- Create Leads/Create
('Agent', 4, 1, 1, 'System'), -- View Leads/Edit
('Agent', 4, 3, 1, 'System'), -- Edit Leads/Edit

-- Agent role - Properties permissions
('Agent', 5, 1, 1, 'System'), -- View Properties/Index
('Agent', 6, 1, 1, 'System'), -- View Properties/Details

-- Agent role - Tasks permissions
('Agent', 17, 1, 1, 'System'); -- View Tasks/Index

-- Verify the setup
SELECT 'Permissions' as TableName, COUNT(*) as Count FROM Permissions
UNION ALL
SELECT 'Modules', COUNT(*) FROM Modules
UNION ALL
SELECT 'Pages', COUNT(*) FROM Pages
UNION ALL
SELECT 'RolePagePermissions', COUNT(*) FROM RolePagePermissions;

-- Show Sales/Agent permissions
SELECT 
    rpp.RoleName,
    m.DisplayName as Module,
    p.DisplayName as Page,
    perm.PermissionName,
    rpp.IsGranted
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Modules m ON p.ModuleId = m.ModuleId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName IN ('Sales', 'Agent')
ORDER BY rpp.RoleName, m.SortOrder, p.SortOrder, perm.SortOrder;