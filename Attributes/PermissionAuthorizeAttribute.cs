using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using CRM.Services;
using CRM.Models;

namespace CRM.Attributes
{
    public class PermissionAuthorizeAttribute : ActionFilterAttribute
    {
        private readonly string _permissionName;

        public PermissionAuthorizeAttribute(string permissionName = "View")
        {
            _permissionName = permissionName;
        }

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            var httpContext = context.HttpContext;
            var token = httpContext.Request.Cookies["jwtToken"];

            if (string.IsNullOrEmpty(token))
            {
                context.Result = new RedirectToActionResult("Login", "Account", null);
                return;
            }

            try
            {
                var tokenHandler = new JwtSecurityTokenHandler();
                var jwt = tokenHandler.ReadJwtToken(token);
                var roleClaim = jwt.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;
                var userIdClaim = jwt.Claims.FirstOrDefault(c => c.Type == "UserId")?.Value;

                if (string.IsNullOrEmpty(roleClaim))
                {
                    context.Result = new RedirectToActionResult("Error", "Home", null);
                    return;
                }

                // Admin always has full access to everything
                if (roleClaim.Equals("Admin", StringComparison.OrdinalIgnoreCase))
                    return;

                // Get controller and action names
                var controllerName = context.RouteData.Values["controller"]?.ToString();
                var actionName = context.RouteData.Values["action"]?.ToString();

                // Get user's channel partner ID for permission checking
                int? userChannelPartnerId = null;
                if (int.TryParse(userIdClaim, out int userId))
                {
                    var dbContext = httpContext.RequestServices.GetService<AppDbContext>();
                    if (dbContext != null)
                    {
                        var user = dbContext.Users.FirstOrDefault(u => u.UserId == userId);
                        userChannelPartnerId = user?.ChannelPartnerId;
                    }
                }

                // For all other roles, check permissions from database
                var permissionService = httpContext.RequestServices.GetService<PermissionService>();
                if (permissionService != null)
                {
                    Console.WriteLine($"DEBUG: Checking permission - Role: {roleClaim}, Controller: {controllerName}, Action: {actionName}, Permission: {_permissionName}, ChannelPartnerId: {userChannelPartnerId}");
                    var hasPermission = permissionService.HasPermissionAsync(roleClaim, controllerName, actionName, _permissionName, userChannelPartnerId).Result;
                    Console.WriteLine($"DEBUG: Permission result: {hasPermission}");
                    if (!hasPermission)
                    {
                        Console.WriteLine($"DEBUG: Access denied for {roleClaim} - redirecting to AccessDenied");
                        context.Result = new RedirectToActionResult("AccessDenied", "Home", null);
                        return;
                    }
                }
                else
                {
                    // If permission service is not available, deny access for non-admin roles
                    context.Result = new RedirectToActionResult("AccessDenied", "Home", null);
                }
            }
            catch
            {
                context.Result = new RedirectToActionResult("Login", "Account", null);
            }
        }
    }
}