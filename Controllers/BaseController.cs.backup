using CRM.Attributes;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CRM.Controllers
{
    [Authorize]
    public class BaseController : Controller
    {
        protected bool HasPermission(string controller, string action, string permission)
        {
            var role = User.FindFirst(ClaimTypes.Role)?.Value;
            if (string.IsNullOrEmpty(role) || role == "Admin") return true;

            var context = HttpContext.RequestServices.GetService<AppDbContext>();
            return context.RolePagePermissions
                .Include(rpp => rpp.Page)
                .Include(rpp => rpp.Permission)
                .Any(rpp => rpp.RoleName == role &&
                           rpp.Page.Controller == controller &&
                           rpp.Page.Action == action &&
                           rpp.Permission.PermissionName == permission &&
                           rpp.IsGranted);
        }
    }
}