-- =============================================
-- COMPLETE SEED DATA FOR ROLE PERMISSIONS SYSTEM
-- Run this script AFTER creating all tables
-- =============================================

-- Step 1: Insert Modules
SET IDENTITY_INSERT Modules ON;

INSERT INTO Modules (ModuleId, ModuleName, DisplayName, Icon, DisplayOrder, IsActive, CreatedOn)
VALUES 
(1, 'Dashboard', 'Dashboard', 'home', 1, 1, GETDATE()),
(2, 'Leads', 'Lead Management', 'users', 2, 1, GETDATE()),
(3, 'Properties', 'Property Management', 'building', 3, 1, GETDATE()),
(4, 'Bookings', 'Booking Management', 'book-open', 4, 1, GETDATE()),
(5, 'Finance', 'Finance & Payments', 'dollar-sign', 5, 1, GETDATE()),
(6, 'Agents', 'Agent Management', 'user-check', 6, 1, GETDATE()),
(7, 'Reports', 'Reports & Analytics', 'bar-chart', 7, 1, GETDATE()),
(8, 'Settings', 'Settings', 'settings', 8, 1, GETDATE()),
(9, 'Users', 'User Management', 'users', 9, 1, GETDATE()),
(10, 'Subscription', 'Subscription', 'credit-card', 10, 1, GETDATE());

SET IDENTITY_INSERT Modules OFF;

-- Step 2: Insert Pages
SET IDENTITY_INSERT Pages ON;

INSERT INTO Pages (PageId, ModuleId, PageName, DisplayName, Controller, Action, Icon, DisplayOrder, IsActive, CreatedOn)
VALUES 
-- Dashboard Module
(1, 1, 'Dashboard', 'Dashboard', 'Home', 'Index', 'home', 1, 1, GETDATE()),

-- Leads Module
(2, 2, 'LeadsList', 'All Leads', 'Leads', 'Index', 'list', 1, 1, GETDATE()),
(3, 2, 'LeadDetails', 'Lead Details', 'Leads', 'Details', 'eye', 2, 1, GETDATE()),
(4, 2, 'CreateLead', 'Create Lead', 'Leads', 'Create', 'plus', 3, 1, GETDATE()),
(5, 2, 'EditLead', 'Edit Lead', 'Leads', 'Edit', 'edit', 4, 1, GETDATE()),
(6, 2, 'DeleteLead', 'Delete Lead', 'Leads', 'Delete', 'trash', 5, 1, GETDATE()),
(7, 2, 'BulkUpload', 'Bulk Upload', 'Leads', 'BulkUpload', 'upload', 6, 1, GETDATE()),
(8, 2, 'WebhookLeads', 'Webhook Leads', 'WebhookLeads', 'Index', 'link', 7, 1, GETDATE()),

-- Properties Module
(9, 3, 'PropertiesList', 'All Properties', 'Properties', 'Index', 'list', 1, 1, GETDATE()),
(10, 3, 'PropertyDetails', 'Property Details', 'Properties', 'Details', 'eye', 2, 1, GETDATE()),
(11, 3, 'CreateProperty', 'Create Property', 'Properties', 'Create', 'plus', 3, 1, GETDATE()),
(12, 3, 'EditProperty', 'Edit Property', 'Properties', 'Edit', 'edit', 4, 1, GETDATE()),
(13, 3, 'DeleteProperty', 'Delete Property', 'Properties', 'Delete', 'trash', 5, 1, GETDATE()),
(14, 3, 'PropertyBulkUpload', 'Bulk Upload', 'Properties', 'BulkUpload', 'upload', 6, 1, GETDATE()),

-- Bookings Module
(15, 4, 'BookingsList', 'All Bookings', 'Bookings', 'Index', 'list', 1, 1, GETDATE()),
(16, 4, 'BookingDetails', 'Booking Details', 'Bookings', 'Details', 'eye', 2, 1, GETDATE()),
(17, 4, 'CreateBooking', 'Create Booking', 'Bookings', 'Create', 'plus', 3, 1, GETDATE()),
(18, 4, 'EditBooking', 'Edit Booking', 'Bookings', 'Edit', 'edit', 4, 1, GETDATE()),
(19, 4, 'DeleteBooking', 'Delete Booking', 'Bookings', 'Delete', 'trash', 5, 1, GETDATE()),

-- Finance Module
(20, 5, 'Expenses', 'Expenses', 'Expenses', 'Index', 'trending-down', 1, 1, GETDATE()),
(21, 5, 'Revenue', 'Revenue', 'Revenue', 'Index', 'trending-up', 2, 1, GETDATE()),
(22, 5, 'Profit', 'Profit', 'Profit', 'Index', 'dollar-sign', 3, 1, GETDATE()),
(23, 5, 'Payments', 'Payments', 'Payments', 'Index', 'credit-card', 4, 1, GETDATE()),
(24, 5, 'Invoices', 'Invoices', 'Invoices', 'Index', 'file-text', 5, 1, GETDATE()),
(25, 5, 'Quotations', 'Quotations', 'Quotations', 'Index', 'file', 6, 1, GETDATE()),
(26, 5, 'Transactions', 'Transactions', 'RazorpayTransactions', 'Index', 'list', 7, 1, GETDATE()),

-- Agents Module
(27, 6, 'AgentsList', 'All Agents', 'Agent', 'List', 'list', 1, 1, GETDATE()),
(28, 6, 'AgentDetails', 'Agent Details', 'Agent', 'Details', 'eye', 2, 1, GETDATE()),
(29, 6, 'OnboardAgent', 'Onboard Agent', 'Agent', 'Onboard', 'user-plus', 3, 1, GETDATE()),
(30, 6, 'AgentPayout', 'Agent Payout', 'AgentPayout', 'Index', 'dollar-sign', 4, 1, GETDATE()),
(31, 6, 'Attendance', 'Attendance', 'Attendance', 'Calendar', 'calendar', 5, 1, GETDATE()),

-- Reports Module
(32, 7, 'SalesPipeline', 'Sales Pipeline', 'SalesPipelines', 'Index', 'trending-up', 1, 1, GETDATE()),
(33, 7, 'PartnerCommission', 'Partner Commission', 'PartnerCommission', 'Index', 'percent', 2, 1, GETDATE()),
(34, 7, 'PartnerTracking', 'Partner Tracking', 'PartnerTracking', 'Index', 'activity', 3, 1, GETDATE()),
(35, 7, 'MilestoneTracking', 'Milestone Tracking', 'MilestoneTracking', 'Index', 'target', 4, 1, GETDATE()),

-- Settings Module
(36, 8, 'GeneralSettings', 'General Settings', 'Settings', 'Index', 'settings', 1, 1, GETDATE()),
(37, 8, 'Branding', 'Branding', 'Settings', 'Branding', 'image', 2, 1, GETDATE()),
(38, 8, 'Impersonation', 'Impersonation', 'Settings', 'Impersonation', 'user-check', 3, 1, GETDATE()),
(39, 8, 'BankAccounts', 'Bank Accounts', 'Financial', 'BankAccounts', 'credit-card', 4, 1, GETDATE()),
(40, 8, 'PaymentGateways', 'Payment Gateways', 'Financial', 'PaymentGateways', 'dollar-sign', 5, 1, GETDATE()),

-- Users Module
(41, 9, 'UsersList', 'All Users', 'ManageUsers', 'Index', 'list', 1, 1, GETDATE()),
(42, 9, 'CreateUser', 'Create User', 'ManageUsers', 'AddUser', 'user-plus', 2, 1, GETDATE()),
(43, 9, 'EditUser', 'Edit User', 'ManageUsers', 'EditUser', 'edit', 3, 1, GETDATE()),
(44, 9, 'DeleteUser', 'Delete User', 'ManageUsers', 'Delete', 'trash', 4, 1, GETDATE()),
(45, 9, 'RolePermissions', 'Role Permissions', 'ManageUsers', 'RolePermissions', 'shield', 5, 1, GETDATE()),
(46, 9, 'PartnerApproval', 'Partner Approval', 'ManageUsers', 'PartnerApproval', 'check-circle', 6, 1, GETDATE()),

-- Subscription Module
(47, 10, 'MyPlan', 'My Plan', 'Subscription', 'MyPlan', 'package', 1, 1, GETDATE()),
(48, 10, 'Plans', 'All Plans', 'Subscription', 'Plans', 'list', 2, 1, GETDATE()),
(49, 10, 'Transactions', 'Transactions', 'Subscription', 'Transactions', 'credit-card', 3, 1, GETDATE()),
(50, 10, 'ManagePlans', 'Manage Plans', 'Subscription', 'CreatePlan', 'settings', 4, 1, GETDATE());

SET IDENTITY_INSERT Pages OFF;

-- Step 3: Insert Permissions
SET IDENTITY_INSERT Permissions ON;

INSERT INTO Permissions (PermissionId, PageId, PermissionName, DisplayName, Description, IsActive, CreatedOn)
VALUES 
-- Dashboard Permissions
(1, 1, 'View', 'View Dashboard', 'Can view dashboard', 1, GETDATE()),

-- Lead Permissions
(2, 2, 'View', 'View Leads', 'Can view leads list', 1, GETDATE()),
(3, 3, 'View', 'View Lead Details', 'Can view lead details', 1, GETDATE()),
(4, 4, 'Create', 'Create Lead', 'Can create new lead', 1, GETDATE()),
(5, 5, 'Edit', 'Edit Lead', 'Can edit lead', 1, GETDATE()),
(6, 6, 'Delete', 'Delete Lead', 'Can delete lead', 1, GETDATE()),
(7, 7, 'Upload', 'Bulk Upload Leads', 'Can bulk upload leads', 1, GETDATE()),
(8, 8, 'View', 'View Webhook Leads', 'Can view webhook leads', 1, GETDATE()),

-- Property Permissions
(9, 9, 'View', 'View Properties', 'Can view properties', 1, GETDATE()),
(10, 10, 'View', 'View Property Details', 'Can view property details', 1, GETDATE()),
(11, 11, 'Create', 'Create Property', 'Can create property', 1, GETDATE()),
(12, 12, 'Edit', 'Edit Property', 'Can edit property', 1, GETDATE()),
(13, 13, 'Delete', 'Delete Property', 'Can delete property', 1, GETDATE()),
(14, 14, 'Upload', 'Bulk Upload Properties', 'Can bulk upload properties', 1, GETDATE()),

-- Booking Permissions
(15, 15, 'View', 'View Bookings', 'Can view bookings', 1, GETDATE()),
(16, 16, 'View', 'View Booking Details', 'Can view booking details', 1, GETDATE()),
(17, 17, 'Create', 'Create Booking', 'Can create booking', 1, GETDATE()),
(18, 18, 'Edit', 'Edit Booking', 'Can edit booking', 1, GETDATE()),
(19, 19, 'Delete', 'Delete Booking', 'Can delete booking', 1, GETDATE()),

-- Finance Permissions
(20, 20, 'View', 'View Expenses', 'Can view expenses', 1, GETDATE()),
(21, 20, 'Create', 'Create Expense', 'Can create expense', 1, GETDATE()),
(22, 21, 'View', 'View Revenue', 'Can view revenue', 1, GETDATE()),
(23, 21, 'Create', 'Create Revenue', 'Can create revenue', 1, GETDATE()),
(24, 22, 'View', 'View Profit', 'Can view profit', 1, GETDATE()),
(25, 23, 'View', 'View Payments', 'Can view payments', 1, GETDATE()),
(26, 23, 'Create', 'Create Payment', 'Can create payment', 1, GETDATE()),
(27, 24, 'View', 'View Invoices', 'Can view invoices', 1, GETDATE()),
(28, 24, 'Create', 'Create Invoice', 'Can create invoice', 1, GETDATE()),
(29, 25, 'View', 'View Quotations', 'Can view quotations', 1, GETDATE()),
(30, 25, 'Create', 'Create Quotation', 'Can create quotation', 1, GETDATE()),
(31, 26, 'View', 'View Transactions', 'Can view transactions', 1, GETDATE()),

-- Agent Permissions
(32, 27, 'View', 'View Agents', 'Can view agents', 1, GETDATE()),
(33, 28, 'View', 'View Agent Details', 'Can view agent details', 1, GETDATE()),
(34, 29, 'Create', 'Onboard Agent', 'Can onboard agent', 1, GETDATE()),
(35, 30, 'View', 'View Agent Payout', 'Can view agent payout', 1, GETDATE()),
(36, 31, 'View', 'View Attendance', 'Can view attendance', 1, GETDATE()),

-- Report Permissions
(37, 32, 'View', 'View Sales Pipeline', 'Can view sales pipeline', 1, GETDATE()),
(38, 33, 'View', 'View Partner Commission', 'Can view partner commission', 1, GETDATE()),
(39, 34, 'View', 'View Partner Tracking', 'Can view partner tracking', 1, GETDATE()),
(40, 35, 'View', 'View Milestone Tracking', 'Can view milestone tracking', 1, GETDATE()),

-- Settings Permissions
(41, 36, 'View', 'View Settings', 'Can view settings', 1, GETDATE()),
(42, 36, 'Edit', 'Edit Settings', 'Can edit settings', 1, GETDATE()),
(43, 37, 'View', 'View Branding', 'Can view branding', 1, GETDATE()),
(44, 37, 'Edit', 'Edit Branding', 'Can edit branding', 1, GETDATE()),
(45, 38, 'Use', 'Use Impersonation', 'Can impersonate users', 1, GETDATE()),
(46, 39, 'View', 'View Bank Accounts', 'Can view bank accounts', 1, GETDATE()),
(47, 39, 'Edit', 'Edit Bank Accounts', 'Can edit bank accounts', 1, GETDATE()),
(48, 40, 'View', 'View Payment Gateways', 'Can view payment gateways', 1, GETDATE()),
(49, 40, 'Edit', 'Edit Payment Gateways', 'Can edit payment gateways', 1, GETDATE()),

-- User Management Permissions
(50, 41, 'View', 'View Users', 'Can view users', 1, GETDATE()),
(51, 42, 'Create', 'Create User', 'Can create user', 1, GETDATE()),
(52, 43, 'Edit', 'Edit User', 'Can edit user', 1, GETDATE()),
(53, 44, 'Delete', 'Delete User', 'Can delete user', 1, GETDATE()),
(54, 45, 'View', 'View Role Permissions', 'Can view role permissions', 1, GETDATE()),
(55, 45, 'Edit', 'Edit Role Permissions', 'Can edit role permissions', 1, GETDATE()),
(56, 46, 'View', 'View Partner Approval', 'Can view partner approval', 1, GETDATE()),
(57, 46, 'Approve', 'Approve Partner', 'Can approve partner', 1, GETDATE()),

-- Subscription Permissions
(58, 47, 'View', 'View My Plan', 'Can view own plan', 1, GETDATE()),
(59, 48, 'View', 'View All Plans', 'Can view all plans', 1, GETDATE()),
(60, 49, 'View', 'View Transactions', 'Can view transactions', 1, GETDATE()),
(61, 50, 'Manage', 'Manage Plans', 'Can manage subscription plans', 1, GETDATE());

SET IDENTITY_INSERT Permissions OFF;

-- Step 4: Grant ALL Permissions to Admin Role
INSERT INTO RolePagePermissions (Role, PageId, PermissionId, CanView, CanCreate, CanEdit, CanDelete, CreatedOn)
SELECT 
    'Admin' as Role,
    p.PageId,
    perm.PermissionId,
    1 as CanView,
    CASE WHEN perm.PermissionName IN ('Create', 'Upload') THEN 1 ELSE 0 END as CanCreate,
    CASE WHEN perm.PermissionName IN ('Edit', 'Manage') THEN 1 ELSE 0 END as CanEdit,
    CASE WHEN perm.PermissionName = 'Delete' THEN 1 ELSE 0 END as CanDelete,
    GETDATE() as CreatedOn
FROM Pages p
CROSS JOIN Permissions perm
WHERE perm.PageId = p.PageId;

-- Step 5: Grant Basic Permissions to Agent Role
INSERT INTO RolePagePermissions (Role, PageId, PermissionId, CanView, CanCreate, CanEdit, CanDelete, CreatedOn)
SELECT 
    'Agent' as Role,
    p.PageId,
    perm.PermissionId,
    1 as CanView,
    CASE WHEN p.PageId IN (2,4) AND perm.PermissionName = 'Create' THEN 1 ELSE 0 END as CanCreate, -- Can create leads
    CASE WHEN p.PageId IN (3,5) AND perm.PermissionName = 'Edit' THEN 1 ELSE 0 END as CanEdit, -- Can edit own leads
    0 as CanDelete,
    GETDATE() as CreatedOn
FROM Pages p
INNER JOIN Permissions perm ON perm.PageId = p.PageId
WHERE p.PageId IN (1,2,3,9,10,15,16,31,47); -- Dashboard, Leads, Properties (view), Bookings (view), Attendance, My Plan

-- Step 6: Grant Permissions to ChannelPartner Role
INSERT INTO RolePagePermissions (Role, PageId, PermissionId, CanView, CanCreate, CanEdit, CanDelete, CreatedOn)
SELECT 
    'ChannelPartner' as Role,
    p.PageId,
    perm.PermissionId,
    1 as CanView,
    CASE WHEN p.PageId IN (2,4,11,17,21,23,28,30) AND perm.PermissionName = 'Create' THEN 1 ELSE 0 END as CanCreate,
    CASE WHEN p.PageId IN (3,5,12,18,36,37,43) AND perm.PermissionName = 'Edit' THEN 1 ELSE 0 END as CanEdit,
    CASE WHEN p.PageId IN (6,13) AND perm.PermissionName = 'Delete' THEN 1 ELSE 0 END as CanDelete,
    GETDATE() as CreatedOn
FROM Pages p
INNER JOIN Permissions perm ON perm.PageId = p.PageId
WHERE p.ModuleId IN (1,2,3,4,5,6,7,8,10); -- All except User Management

PRINT 'Role Permissions seed data inserted successfully!';
PRINT 'Total Modules: ' + CAST((SELECT COUNT(*) FROM Modules) AS VARCHAR);
PRINT 'Total Pages: ' + CAST((SELECT COUNT(*) FROM Pages) AS VARCHAR);
PRINT 'Total Permissions: ' + CAST((SELECT COUNT(*) FROM Permissions) AS VARCHAR);
PRINT 'Total Role Permissions: ' + CAST((SELECT COUNT(*) FROM RolePagePermissions) AS VARCHAR);
