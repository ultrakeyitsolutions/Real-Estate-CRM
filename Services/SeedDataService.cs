using CRM;
using Microsoft.EntityFrameworkCore;

namespace CRM.Services
{
    public class SeedDataService
    {
        private readonly AppDbContext _context;

        public SeedDataService(AppDbContext context)
        {
            _context = context;
        }

        public async Task SeedRolePermissionsAsync()
        {
            if (await _context.Modules.AnyAsync()) return;

            await _context.Database.ExecuteSqlRawAsync(@"
                SET IDENTITY_INSERT Modules ON;
                INSERT INTO Modules (ModuleId, ModuleName, DisplayName, Icon, SortOrder, IsActive)
                VALUES 
                (1, 'Dashboard', 'Dashboard', 'home', 1, 1),
                (2, 'Leads', 'Lead Management', 'users', 2, 1),
                (3, 'Properties', 'Property Management', 'building', 3, 1),
                (4, 'Bookings', 'Booking Management', 'book-open', 4, 1),
                (5, 'Finance', 'Finance & Payments', 'dollar-sign', 5, 1),
                (6, 'Agents', 'Agent Management', 'user-check', 6, 1),
                (7, 'Reports', 'Reports & Analytics', 'bar-chart', 7, 1),
                (8, 'Settings', 'Settings', 'settings', 8, 1),
                (9, 'Users', 'User Management', 'users', 9, 1),
                (10, 'Subscription', 'Subscription', 'credit-card', 10, 1);
                SET IDENTITY_INSERT Modules OFF;
            ");

            await _context.Database.ExecuteSqlRawAsync(@"
                SET IDENTITY_INSERT Pages ON;
                INSERT INTO Pages (PageId, ModuleId, PageName, DisplayName, Controller, Action, SortOrder, IsActive)
                VALUES 
                (1, 1, 'Dashboard', 'Dashboard', 'Home', 'Index',  1, 1),
                (2, 2, 'LeadsList', 'All Leads', 'Leads', 'Index',  1, 1),
                (3, 2, 'LeadDetails', 'Lead Details', 'Leads', 'Details',2, 1),
                (4, 2, 'CreateLead', 'Create Lead', 'Leads', 'Create', 3, 1),
                (5, 2, 'EditLead', 'Edit Lead', 'Leads', 'Edit',4, 1),
                (6, 2, 'DeleteLead', 'Delete Lead', 'Leads', 'Delete', 5, 1),
                (7, 2, 'BulkUpload', 'Bulk Upload', 'Leads', 'BulkUpload', 6, 1),
                (8, 2, 'WebhookLeads', 'Webhook Leads', 'WebhookLeads', 'Index',7, 1),
                (9, 3, 'PropertiesList', 'All Properties', 'Properties', 'Index', 1, 1),
                (10, 3, 'PropertyDetails', 'Property Details', 'Properties', 'Details', 2, 1),
                (11, 3, 'CreateProperty', 'Create Property', 'Properties', 'Create', 3, 1),
                (12, 3, 'EditProperty', 'Edit Property', 'Properties', 'Edit', 4, 1),
                (13, 3, 'DeleteProperty', 'Delete Property', 'Properties', 'Delete', 5, 1),
                (14, 3, 'PropertyBulkUpload', 'Bulk Upload', 'Properties', 'BulkUpload', 6, 1),
                (15, 4, 'BookingsList', 'All Bookings', 'Bookings', 'Index', 1, 1),
                (16, 4, 'BookingDetails', 'Booking Details', 'Bookings', 'Details', 2, 1),
                (17, 4, 'CreateBooking', 'Create Booking', 'Bookings', 'Create', 3, 1),
                (18, 4, 'EditBooking', 'Edit Booking', 'Bookings', 'Edit', 4, 1),
                (19, 4, 'DeleteBooking', 'Delete Booking', 'Bookings', 'Delete', 5, 1),
                (20, 5, 'Expenses', 'Expenses', 'Expenses', 'Index', 1, 1),
                (21, 5, 'Revenue', 'Revenue', 'Revenue', 'Index', 2, 1),
                (22, 5, 'Profit', 'Profit', 'Profit', 'Index',3, 1),
                (23, 5, 'Payments', 'Payments', 'Payments', 'Index',4, 1),
                (24, 5, 'Invoices', 'Invoices', 'Invoices', 'Index',5, 1),
                (25, 5, 'Quotations', 'Quotations', 'Quotations', 'Index', 6, 1),
                (26, 5, 'Transactions', 'Transactions', 'RazorpayTransactions', 'Index',  7, 1),
                (27, 6, 'AgentsList', 'All Agents', 'Agent', 'List', 1, 1),
                (28, 6, 'AgentDetails', 'Agent Details', 'Agent', 'Details', 2, 1),
                (29, 6, 'OnboardAgent', 'Onboard Agent', 'Agent', 'Onboard',3, 1),
                (30, 6, 'AgentPayout', 'Agent Payout', 'AgentPayout', 'Index',4, 1),
                (31, 6, 'Attendance', 'Attendance', 'Attendance', 'Calendar', 5, 1),
                (32, 7, 'SalesPipeline', 'Sales Pipeline', 'SalesPipelines', 'Index',1, 1),
                (33, 7, 'PartnerCommission', 'Partner Commission', 'PartnerCommission', 'Index', 2, 1),
                (34, 7, 'PartnerTracking', 'Partner Tracking', 'PartnerTracking', 'Index', 3, 1),
                (35, 7, 'MilestoneTracking', 'Milestone Tracking', 'MilestoneTracking', 'Index', 4, 1),
                (36, 8, 'GeneralSettings', 'General Settings', 'Settings', 'Index', 1, 1),
                (37, 8, 'Branding', 'Branding', 'Settings', 'Branding', 2, 1),
                (38, 8, 'Impersonation', 'Impersonation', 'Settings', 'Impersonation', 3, 1),
                (39, 8, 'BankAccounts', 'Bank Accounts', 'Financial', 'BankAccounts', 4, 1),
                (40, 8, 'PaymentGateways', 'Payment Gateways', 'Financial', 'PaymentGateways',5, 1),
                (41, 9, 'UsersList', 'All Users', 'ManageUsers', 'Index', 1, 1),
                (42, 9, 'CreateUser', 'Create User', 'ManageUsers', 'AddUser',2, 1),
                (43, 9, 'EditUser', 'Edit User', 'ManageUsers', 'EditUser', 3, 1),
                (44, 9, 'DeleteUser', 'Delete User', 'ManageUsers', 'Delete', 4, 1),
                (45, 9, 'RolePermissions', 'Role Permissions', 'ManageUsers', 'RolePermissions', 5, 1),
                (46, 9, 'PartnerApproval', 'Partner Approval', 'ManageUsers', 'PartnerApproval',6, 1),
                (47, 10, 'MyPlan', 'My Plan', 'Subscription', 'MyPlan', 1, 1),
                (48, 10, 'Plans', 'All Plans', 'Subscription', 'Plans', 2, 1),
                (49, 10, 'Transactions', 'Transactions', 'Subscription', 'Transactions', 3, 1),
                (50, 10, 'ManagePlans', 'Manage Plans', 'Subscription', 'CreatePlan',4, 1);
                SET IDENTITY_INSERT Pages OFF;
            ");

            await _context.Database.ExecuteSqlRawAsync(@"
                SET IDENTITY_INSERT Permissions ON;
                INSERT INTO Permissions
                (
                    PermissionId,PermissionName,DisplayName, Description,SortOrder,IsActive
                )
                VALUES
                (1, 'View', 'View Access', 'Can view the page and data', 1, 1),
                (2, 'Create', 'Create Access', 'Can create new records', 2, 1),
                (3, 'Edit', 'Edit Access', 'Can modify existing records', 3, 1),
                (4, 'Delete', 'Delete Access', 'Can delete records', 4, 1),
                (5, 'Export', 'Export Access', 'Can export data to Excel/CSV', 5, 1),
                (6, 'BulkUpload', 'Bulk Upload Access', 'Can upload multiple records', 6, 1);

                SET IDENTITY_INSERT Permissions OFF;
            ");

            await _context.Database.ExecuteSqlRawAsync(@"
                SET IDENTITY_INSERT RolePermissions ON;

                INSERT INTO RolePermissions
                (Id, RoleName, CanCreate, CanEdit, CanDelete, CanView, CreatedAt)
                VALUES
                (1, 'Admin', 1, 1, 1, 1, '2025-11-28 22:11:10.500'),
                (14, 'Partner', 0, 0, 0, 1, '2025-12-15 23:25:18.143'),
                (4, 'Sales', 1, 1, 0, 1, '2025-11-28 18:08:14.510'),
                (7, 'Agent', 1, 1, 0, 1, '2025-11-29 12:00:57.277');

                SET IDENTITY_INSERT RolePermissions OFF; 
            ");
        }
    }
}
