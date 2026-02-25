-- Execute this script to set up complete permission system
EXEC('
-- Clear existing data
DELETE FROM RolePagePermissions;
DELETE FROM Pages;
DELETE FROM Modules;
DELETE FROM Permissions;

-- Reset identity seeds
DBCC CHECKIDENT (''RolePagePermissions'', RESEED, 0);
DBCC CHECKIDENT (''Pages'', RESEED, 0);
DBCC CHECKIDENT (''Modules'', RESEED, 0);
DBCC CHECKIDENT (''Permissions'', RESEED, 0);

-- Insert Permissions
INSERT INTO Permissions (PermissionName, DisplayName, Description, SortOrder) VALUES
(''View'', ''View Access'', ''Can view the page and data'', 1),
(''Create'', ''Create Access'', ''Can create new records'', 2),
(''Edit'', ''Edit Access'', ''Can modify existing records'', 3),
(''Delete'', ''Delete Access'', ''Can delete records'', 4),
(''Export'', ''Export Access'', ''Can export data to Excel/CSV'', 5),
(''BulkUpload'', ''Bulk Upload Access'', ''Can upload multiple records'', 6);

-- Insert Modules
INSERT INTO Modules (ModuleName, DisplayName, Icon, SortOrder) VALUES
(''Leads'', ''Lead Management'', ''fa-users'', 1),
(''Properties'', ''Property Management'', ''fa-building'', 2),
(''Tasks'', ''Task Management'', ''fa-tasks'', 3),
(''SalesPipelines'', ''Sales Pipeline'', ''fa-trello'', 4),
(''Quotations'', ''Quotation Management'', ''fa-file-invoice'', 5),
(''Bookings'', ''Booking Management'', ''fa-calendar-check'', 6),
(''Invoices'', ''Invoice Management'', ''fa-file-invoice-dollar'', 7),
(''Payments'', ''Payment Management'', ''fa-credit-card'', 8),
(''Revenue'', ''Revenue Management'', ''fa-coins'', 9),
(''Expenses'', ''Expense Management'', ''fa-money-bill-wave'', 10),
(''Settings'', ''System Settings'', ''fa-cog'', 11);

-- Insert Pages
INSERT INTO Pages (ModuleId, PageName, DisplayName, Controller, Action, SortOrder) VALUES
-- Leads Module (1)
(1, ''Index'', ''Lead List'', ''Leads'', ''Index'', 1),
(1, ''Details'', ''Lead Details'', ''Leads'', ''Details'', 2),
-- Properties Module (2)
(2, ''Index'', ''Property List'', ''Properties'', ''Index'', 1),
(2, ''Details'', ''Property Details'', ''Properties'', ''Details'', 2),
-- Tasks Module (3)
(3, ''Index'', ''Task List'', ''Tasks'', ''Index'', 1),
-- SalesPipelines Module (4)
(4, ''Index'', ''Sales Pipeline'', ''SalesPipelines'', ''Index'', 1),
-- Quotations Module (5)
(5, ''Index'', ''Quotation List'', ''Quotations'', ''Index'', 1),
-- Bookings Module (6)
(6, ''Index'', ''Booking List'', ''Bookings'', ''Index'', 1),
-- Invoices Module (7)
(7, ''Index'', ''Invoice List'', ''Invoices'', ''Index'', 1),
-- Payments Module (8)
(8, ''Index'', ''Payment List'', ''Payments'', ''Index'', 1),
-- Revenue Module (9)
(9, ''Index'', ''Revenue List'', ''Revenue'', ''Index'', 1),
-- Expenses Module (10)
(10, ''Index'', ''Expense List'', ''Expenses'', ''Index'', 1),
-- Settings Module (11) - Admin only
(11, ''Index'', ''Settings'', ''Settings'', ''Index'', 1);

-- Grant permissions to Sales/Agent roles
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy) VALUES
-- Sales role permissions
(''Sales'', 1, 1, 1, ''System''), -- View Leads
(''Sales'', 1, 2, 1, ''System''), -- Create Leads
(''Sales'', 1, 3, 1, ''System''), -- Edit Leads
(''Sales'', 1, 5, 1, ''System''), -- Export Leads
(''Sales'', 2, 1, 1, ''System''), -- View Lead Details
(''Sales'', 3, 1, 1, ''System''), -- View Properties
(''Sales'', 3, 2, 1, ''System''), -- Create Properties
(''Sales'', 3, 3, 1, ''System''), -- Edit Properties
(''Sales'', 3, 5, 1, ''System''), -- Export Properties
(''Sales'', 4, 1, 1, ''System''), -- View Property Details
(''Sales'', 5, 1, 1, ''System''), -- View Tasks
(''Sales'', 6, 1, 1, ''System''), -- View SalesPipelines
(''Sales'', 7, 1, 1, ''System''), -- View Quotations
(''Sales'', 7, 2, 1, ''System''), -- Create Quotations
(''Sales'', 7, 3, 1, ''System''), -- Edit Quotations
(''Sales'', 7, 4, 1, ''System''), -- Delete Quotations
(''Sales'', 8, 1, 1, ''System''), -- View Bookings
(''Sales'', 8, 2, 1, ''System''), -- Create Bookings
(''Sales'', 8, 3, 1, ''System''), -- Edit Bookings
(''Sales'', 8, 4, 1, ''System''), -- Delete Bookings
(''Sales'', 9, 1, 1, ''System''), -- View Invoices
(''Sales'', 9, 2, 1, ''System''), -- Create Invoices
(''Sales'', 9, 3, 1, ''System''), -- Edit Invoices
(''Sales'', 9, 4, 1, ''System''), -- Delete Invoices
(''Sales'', 10, 1, 1, ''System''), -- View Payments
(''Sales'', 10, 2, 1, ''System''), -- Create Payments
(''Sales'', 10, 4, 1, ''System''), -- Delete Payments
(''Sales'', 11, 1, 1, ''System''), -- View Revenue
(''Sales'', 11, 2, 1, ''System''), -- Create Revenue
(''Sales'', 11, 3, 1, ''System''), -- Edit Revenue
(''Sales'', 11, 4, 1, ''System''), -- Delete Revenue
(''Sales'', 11, 5, 1, ''System''), -- Export Revenue
(''Sales'', 12, 1, 1, ''System''), -- View Expenses
(''Sales'', 12, 2, 1, ''System''), -- Create Expenses
(''Sales'', 12, 3, 1, ''System''), -- Edit Expenses
(''Sales'', 12, 4, 1, ''System''), -- Delete Expenses
(''Sales'', 12, 5, 1, ''System''), -- Export Expenses

-- Agent role permissions (same as Sales)
(''Agent'', 1, 1, 1, ''System''), -- View Leads
(''Agent'', 1, 2, 1, ''System''), -- Create Leads
(''Agent'', 1, 3, 1, ''System''), -- Edit Leads
(''Agent'', 1, 5, 1, ''System''), -- Export Leads
(''Agent'', 2, 1, 1, ''System''), -- View Lead Details
(''Agent'', 3, 1, 1, ''System''), -- View Properties
(''Agent'', 3, 2, 1, ''System''), -- Create Properties
(''Agent'', 3, 3, 1, ''System''), -- Edit Properties
(''Agent'', 3, 5, 1, ''System''), -- Export Properties
(''Agent'', 4, 1, 1, ''System''), -- View Property Details
(''Agent'', 5, 1, 1, ''System''), -- View Tasks
(''Agent'', 6, 1, 1, ''System''), -- View SalesPipelines
(''Agent'', 7, 1, 1, ''System''), -- View Quotations
(''Agent'', 7, 2, 1, ''System''), -- Create Quotations
(''Agent'', 7, 3, 1, ''System''), -- Edit Quotations
(''Agent'', 7, 4, 1, ''System''), -- Delete Quotations
(''Agent'', 8, 1, 1, ''System''), -- View Bookings
(''Agent'', 8, 2, 1, ''System''), -- Create Bookings
(''Agent'', 8, 3, 1, ''System''), -- Edit Bookings
(''Agent'', 8, 4, 1, ''System''), -- Delete Bookings
(''Agent'', 9, 1, 1, ''System''), -- View Invoices
(''Agent'', 9, 2, 1, ''System''), -- Create Invoices
(''Agent'', 9, 3, 1, ''System''), -- Edit Invoices
(''Agent'', 9, 4, 1, ''System''), -- Delete Invoices
(''Agent'', 10, 1, 1, ''System''), -- View Payments
(''Agent'', 10, 2, 1, ''System''), -- Create Payments
(''Agent'', 10, 4, 1, ''System''), -- Delete Payments
(''Agent'', 11, 1, 1, ''System''), -- View Revenue
(''Agent'', 11, 2, 1, ''System''), -- Create Revenue
(''Agent'', 11, 3, 1, ''System''), -- Edit Revenue
(''Agent'', 11, 4, 1, ''System''), -- Delete Revenue
(''Agent'', 11, 5, 1, ''System''), -- Export Revenue
(''Agent'', 12, 1, 1, ''System''), -- View Expenses
(''Agent'', 12, 2, 1, ''System''), -- Create Expenses
(''Agent'', 12, 3, 1, ''System''), -- Edit Expenses
(''Agent'', 12, 4, 1, ''System''), -- Delete Expenses
(''Agent'', 12, 5, 1, ''System''), -- Export Expenses

-- Channel Partner role permissions (limited access)
(''Partner'', 1, 1, 1, ''System''), -- View Leads (own only)
(''Partner'', 1, 2, 1, ''System''), -- Create Leads
(''Partner'', 1, 3, 1, ''System''), -- Edit Leads (own only)
(''Partner'', 2, 1, 1, ''System''), -- View Lead Details (own only)
(''Partner'', 3, 1, 1, ''System''), -- View Properties
(''Partner'', 5, 1, 1, ''System''), -- View Tasks (own only)
(''Partner'', 6, 1, 1, ''System''), -- View SalesPipelines (own only)
(''Partner'', 7, 1, 1, ''System''), -- View Quotations (own only)
(''Partner'', 7, 2, 1, ''System''), -- Create Quotations
(''Partner'', 8, 1, 1, ''System''), -- View Bookings (own only)
(''Partner'', 8, 2, 1, ''System''), -- Create Bookings
(''Partner'', 9, 1, 1, ''System''), -- View Invoices (own only)
(''Partner'', 10, 1, 1, ''System''), -- View Payments (own only)
(''Partner'', 11, 1, 1, ''System''), -- View Settings (own only)
(''Partner'', 11, 3, 1, ''System''); -- Edit Settings (own only)

-- Insert Role entries for ManageUsers/Roles page
IF NOT EXISTS (SELECT 1 FROM RolePermissions WHERE RoleName = ''Admin'')
    INSERT INTO RolePermissions (RoleName, CanView, CanCreate, CanEdit, CanDelete, CreatedAt) VALUES (''Admin'', 1, 1, 1, 1, GETDATE());

IF NOT EXISTS (SELECT 1 FROM RolePermissions WHERE RoleName = ''Sales'')
    INSERT INTO RolePermissions (RoleName, CanView, CanCreate, CanEdit, CanDelete, CreatedAt) VALUES (''Sales'', 1, 1, 1, 0, GETDATE());

IF NOT EXISTS (SELECT 1 FROM RolePermissions WHERE RoleName = ''Agent'')
    INSERT INTO RolePermissions (RoleName, CanView, CanCreate, CanEdit, CanDelete, CreatedAt) VALUES (''Agent'', 1, 1, 1, 0, GETDATE());

IF NOT EXISTS (SELECT 1 FROM RolePermissions WHERE RoleName = ''Partner'')
    INSERT INTO RolePermissions (RoleName, CanView, CanCreate, CanEdit, CanDelete, CreatedAt) VALUES (''Partner'', 1, 1, 0, 0, GETDATE());
')

-- Verify setup
SELECT 'Setup Complete' as Status, COUNT(*) as TotalPermissions FROM RolePagePermissions WHERE RoleName IN ('Sales', 'Agent', 'Partner');