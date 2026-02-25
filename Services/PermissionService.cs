using CRM.Models;
using Microsoft.EntityFrameworkCore;

namespace CRM.Services
{
    public class PermissionService
    {
        private readonly AppDbContext _context;

        public PermissionService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<ModuleModel>> GetModulesWithPagesAsync()
        {
            return await _context.Modules
                .Include(m => m.Pages)
                .Where(m => m.IsActive)
                .OrderBy(m => m.SortOrder)
                .ToListAsync();
        }

        public async Task<List<PermissionModel>> GetPermissionsAsync()
        {
            return await _context.Permissions
                .Where(p => p.IsActive)
                .OrderBy(p => p.SortOrder)
                .ToListAsync();
        }

        public async Task<Dictionary<string, bool>> GetRolePermissionsAsync(string roleName, int pageId, int? channelPartnerId = null)
        {
            // Get all available permissions
            var allPermissions = await _context.Permissions
                .Where(p => p.IsActive)
                .ToListAsync();

            // Get granted permissions for this role and page, considering channel partner context
            var grantedPermissions = await _context.RolePagePermissions
                .Include(rpp => rpp.Permission)
                .Where(rpp => rpp.RoleName == roleName && 
                             rpp.PageId == pageId && 
                             rpp.IsGranted &&
                             rpp.ChannelPartnerId == channelPartnerId)
                .Select(rpp => rpp.Permission.PermissionName)
                .ToListAsync();

            // Create dictionary with all permissions, marking granted ones as true
            var result = new Dictionary<string, bool>();
            foreach (var permission in allPermissions)
            {
                result[permission.PermissionName] = grantedPermissions.Contains(permission.PermissionName);
            }

            return result;
        }

        public async Task SaveRolePermissionsAsync(string roleName, Dictionary<int, Dictionary<int, bool>> permissions, string createdBy, int? channelPartnerId = null)
        {
            // Remove existing permissions for this role and channel partner context
            var existingPermissions = await _context.RolePagePermissions
                .Where(rpp => rpp.RoleName == roleName && rpp.ChannelPartnerId == channelPartnerId)
                .ToListAsync();
            
            _context.RolePagePermissions.RemoveRange(existingPermissions);

            // Add new permissions - only save granted permissions (true values)
            foreach (var pagePermissions in permissions)
            {
                int pageId = pagePermissions.Key;
                foreach (var permission in pagePermissions.Value)
                {
                    int permissionId = permission.Key;
                    bool isGranted = permission.Value;

                    // Only save if permission is granted
                    if (isGranted)
                    {
                        _context.RolePagePermissions.Add(new RolePagePermissionModel
                        {
                            RoleName = roleName,
                            PageId = pageId,
                            PermissionId = permissionId,
                            IsGranted = true,
                            CreatedBy = createdBy,
                            ChannelPartnerId = channelPartnerId
                        });
                    }
                }
            }

            await _context.SaveChangesAsync();
        }

        public async Task<bool> HasPermissionAsync(string roleName, string controller, string action, string permissionName, int? userChannelPartnerId = null)
        {
            // Simple check: if user has Create permission for any Leads page, allow access
            if (controller == "Leads" && permissionName == "Create")
            {
                // Check if user has Create permission for any Leads page
                var hasCreatePermission = await _context.RolePagePermissions
                    .Include(rpp => rpp.Page)
                    .Include(rpp => rpp.Permission)
                    .AnyAsync(rpp => 
                        rpp.RoleName == roleName &&
                        rpp.Page.Controller == controller &&
                        rpp.Permission.PermissionName == permissionName &&
                        rpp.IsGranted &&
                        (rpp.ChannelPartnerId == userChannelPartnerId || rpp.ChannelPartnerId == null));
                
                return hasCreatePermission;
            }
            
            // For partner users, check partner-specific permissions first
            if (userChannelPartnerId.HasValue)
            {
                var partnerPermission = await _context.RolePagePermissions
                    .Include(rpp => rpp.Page)
                    .Include(rpp => rpp.Permission)
                    .FirstOrDefaultAsync(rpp => 
                        rpp.RoleName == roleName &&
                        rpp.Page.Controller == controller &&
                        rpp.Page.Action == action &&
                        rpp.Permission.PermissionName == permissionName &&
                        rpp.IsGranted &&
                        rpp.ChannelPartnerId == userChannelPartnerId);
                
                if (partnerPermission != null) return true;
            }
            
            // Check global permissions (ChannelPartnerId = null)
            var globalPermission = await _context.RolePagePermissions
                .Include(rpp => rpp.Page)
                .Include(rpp => rpp.Permission)
                .FirstOrDefaultAsync(rpp => 
                    rpp.RoleName == roleName &&
                    rpp.Page.Controller == controller &&
                    rpp.Page.Action == action &&
                    rpp.Permission.PermissionName == permissionName &&
                    rpp.IsGranted &&
                    rpp.ChannelPartnerId == null);

            return globalPermission != null;
        }

        public async Task<bool> UpdateRoleNameAsync(string oldRoleName, string newRoleName)
        {
            try
            {
                var permissions = await _context.RolePagePermissions
                    .Where(rpp => rpp.RoleName == oldRoleName)
                    .ToListAsync();
                
                foreach (var permission in permissions)
                {
                    permission.RoleName = newRoleName;
                }
                
                await _context.SaveChangesAsync();
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}