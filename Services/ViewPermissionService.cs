using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CRM.Services
{
    public class ViewPermissionService
    {
        private readonly AppDbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public ViewPermissionService(AppDbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        public bool HasPermission(string controller, string action, string permission)
        {
            var user = _httpContextAccessor.HttpContext?.User;
            if (user == null) return false;

            var role = user.FindFirst(ClaimTypes.Role)?.Value;
            if (string.IsNullOrEmpty(role)) return false;

            // Admin has all permissions
            if (role == "Admin") return true;

            // Get user's channel partner ID
            var channelPartnerIdClaim = user.FindFirst("ChannelPartnerId")?.Value;
            int? userChannelPartnerId = null;
            if (!string.IsNullOrEmpty(channelPartnerIdClaim) && int.TryParse(channelPartnerIdClaim, out int partnerId))
            {
                userChannelPartnerId = partnerId;
            }

            // For partner agents, check both partner-specific AND global permissions
            if (userChannelPartnerId.HasValue)
            {
                return _context.RolePagePermissions
                    .Include(rpp => rpp.Page)
                    .Include(rpp => rpp.Permission)
                    .Any(rpp => rpp.RoleName == role &&
                               rpp.Page.Controller == controller &&
                               rpp.Page.Action == action &&
                               rpp.Permission.PermissionName == permission &&
                               rpp.IsGranted &&
                               (rpp.ChannelPartnerId == userChannelPartnerId || rpp.ChannelPartnerId == null));
            }
            
            // For admin agents, check admin permissions (ChannelPartnerId = null)
            return _context.RolePagePermissions
                .Include(rpp => rpp.Page)
                .Include(rpp => rpp.Permission)
                .Any(rpp => rpp.RoleName == role &&
                           rpp.Page.Controller == controller &&
                           rpp.Page.Action == action &&
                           rpp.Permission.PermissionName == permission &&
                           rpp.IsGranted &&
                           rpp.ChannelPartnerId == null);
        }
    }
}