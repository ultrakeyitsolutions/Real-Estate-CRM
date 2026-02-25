-- Permission System Tables
CREATE TABLE Modules (
    ModuleId INT IDENTITY(1,1) PRIMARY KEY,
    ModuleName NVARCHAR(50) NOT NULL,
    DisplayName NVARCHAR(100) NOT NULL,
    Icon NVARCHAR(50),
    SortOrder INT DEFAULT 0,
    IsActive BIT DEFAULT 1
);

CREATE TABLE Pages (
    PageId INT IDENTITY(1,1) PRIMARY KEY,
    ModuleId INT NOT NULL,
    PageName NVARCHAR(50) NOT NULL,
    DisplayName NVARCHAR(100) NOT NULL,
    Controller NVARCHAR(50) NOT NULL,
    Action NVARCHAR(50) NOT NULL,
    SortOrder INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    FOREIGN KEY (ModuleId) REFERENCES Modules(ModuleId)
);

CREATE TABLE Permissions (
    PermissionId INT IDENTITY(1,1) PRIMARY KEY,
    PermissionName NVARCHAR(50) NOT NULL,
    DisplayName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    SortOrder INT DEFAULT 0,
    IsActive BIT DEFAULT 1
);

CREATE TABLE RolePagePermissions (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL,
    PageId INT NOT NULL,
    PermissionId INT NOT NULL,
    IsGranted BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    CreatedBy NVARCHAR(100),
    FOREIGN KEY (PageId) REFERENCES Pages(PageId),
    FOREIGN KEY (PermissionId) REFERENCES Permissions(PermissionId)
);

-- Insert Default Permissions
INSERT INTO Permissions (PermissionName, DisplayName, Description, SortOrder) VALUES
('View', 'View Access', 'Can view the page and data', 1),
('Create', 'Create Access', 'Can create new records', 2),
('Edit', 'Edit Access', 'Can modify existing records', 3),
('Delete', 'Delete Access', 'Can delete records', 4),
('Export', 'Export Access', 'Can export data to Excel/CSV', 5),
('BulkUpload', 'Bulk Upload Access', 'Can upload multiple records', 6);

-- Insert Default Modules
INSERT INTO Modules (ModuleName, DisplayName, Icon, SortOrder) VALUES
('Leads', 'Lead Management', 'fa-users', 1),
('Revenue', 'Revenue Management', 'fa-coins', 2),
('Expenses', 'Expense Management', 'fa-money-bill-wave', 3),
('Properties', 'Property Management', 'fa-building', 4),
('Bookings', 'Booking Management', 'fa-calendar-check', 5),
('Payments', 'Payment Management', 'fa-credit-card', 6),
('Reports', 'Reports & Analytics', 'fa-chart-bar', 7),
('Users', 'User Management', 'fa-user-cog', 8);

-- Insert Default Pages
INSERT INTO Pages (ModuleId, PageName, DisplayName, Controller, Action, SortOrder) VALUES
-- Leads Module
(1, 'Index', 'Lead List', 'Leads', 'Index', 1),
(1, 'Details', 'Lead Details', 'Leads', 'Details', 2),
(1, 'Create', 'Add New Lead', 'Leads', 'Create', 3),
(1, 'Edit', 'Edit Lead', 'Leads', 'Edit', 4),
(1, 'Delete', 'Delete Lead', 'Leads', 'Delete', 5),
-- Revenue Module  
(2, 'Index', 'Revenue List', 'Revenue', 'Index', 1),
(2, 'Create', 'Add Revenue', 'Revenue', 'Create', 2),
(2, 'Edit', 'Edit Revenue', 'Revenue', 'Edit', 3),
(2, 'Delete', 'Delete Revenue', 'Revenue', 'Delete', 4),
-- Expenses Module
(3, 'Index', 'Expense List', 'Expenses', 'Index', 1),
(3, 'Create', 'Add Expense', 'Expenses', 'Create', 2),
(3, 'Edit', 'Edit Expense', 'Expenses', 'Edit', 3),
(3, 'Delete', 'Delete Expense', 'Expenses', 'Delete', 4),
-- Properties Module
(4, 'Index', 'Property List', 'Properties', 'Index', 1),
(4, 'Details', 'Property Details', 'Properties', 'Details', 2),
(4, 'Create', 'Add Property', 'Properties', 'Create', 3),
(4, 'Edit', 'Edit Property', 'Properties', 'Edit', 4),
(4, 'Delete', 'Delete Property', 'Properties', 'Delete', 5),
-- Bookings Module
(5, 'Index', 'Booking List', 'Bookings', 'Index', 1),
(5, 'Create', 'New Booking', 'Bookings', 'Create', 2),
(5, 'Edit', 'Edit Booking', 'Bookings', 'Edit', 3),
(5, 'Delete', 'Delete Booking', 'Bookings', 'Delete', 4),
-- Payments Module
(6, 'Index', 'Payment List', 'Payments', 'Index', 1),
(6, 'Create', 'Add Payment', 'Payments', 'Create', 2),
(6, 'Edit', 'Edit Payment', 'Payments', 'Edit', 3),
(6, 'Delete', 'Delete Payment', 'Payments', 'Delete', 4),
-- Users Module
(8, 'Index', 'User List', 'ManageUsers', 'Index', 1),
(8, 'Roles', 'Role Management', 'ManageUsers', 'Roles', 2);

-- Grant comprehensive permissions to Sales/Agent role
INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy) VALUES
-- Sales role - Leads permissions
('Sales', 1, 1, 1, 'System'), -- View Leads/Index
('Sales', 1, 2, 1, 'System'), -- Create Leads/Index
('Sales', 1, 3, 1, 'System'), -- Edit Leads/Index
('Sales', 2, 1, 1, 'System'), -- View Leads/Details
('Sales', 3, 1, 1, 'System'), -- View Leads/Create
('Sales', 3, 2, 1, 'System'), -- Create Leads/Create
('Sales', 4, 1, 1, 'System'), -- View Leads/Edit
('Sales', 4, 3, 1, 'System'), -- Edit Leads/Edit
-- Agent role - same permissions as Sales
('Agent', 1, 1, 1, 'System'), -- View Leads/Index
('Agent', 1, 2, 1, 'System'), -- Create Leads/Index
('Agent', 1, 3, 1, 'System'), -- Edit Leads/Index
('Agent', 2, 1, 1, 'System'), -- View Leads/Details
('Agent', 3, 1, 1, 'System'), -- View Leads/Create
('Agent', 3, 2, 1, 'System'), -- Create Leads/Create
('Agent', 4, 1, 1, 'System'), -- View Leads/Edit
('Agent', 4, 3, 1, 'System'); -- Edit Leads/Edit
