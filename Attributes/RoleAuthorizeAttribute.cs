using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace CRM.Attributes
{
    public class RoleAuthorizeAttribute : ActionFilterAttribute
    {
        private readonly string[] _allowedRoles;

        public RoleAuthorizeAttribute(params string[] allowedRoles)
        {
            _allowedRoles = allowedRoles;
        }

        public override void OnActionExecuting(ActionExecutingContext context)
        {
            var httpContext = context.HttpContext;
            var config = httpContext.RequestServices.GetService(typeof(IConfiguration)) as IConfiguration;
            var token = httpContext.Request.Cookies["jwtToken"];

            // 🔒 Prevent caching after logout
            httpContext.Response.Headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
            httpContext.Response.Headers["Pragma"] = "no-cache";
            httpContext.Response.Headers["Expires"] = "0";

            if (string.IsNullOrEmpty(token))
            {
                context.Result = new RedirectToActionResult("Login", "Account", null);
                return;
            }

            try
            {
                var tokenHandler = new JwtSecurityTokenHandler();
                var key = Encoding.UTF8.GetBytes(config["Jwt:Key"]);

                var validationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidIssuer = config["Jwt:Issuer"],
                    ValidAudience = config["Jwt:Audience"],
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero
                };

                // 🔍 Validate and extract claims
                var principal = tokenHandler.ValidateToken(token, validationParameters, out _);
                var roleClaim = principal.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;

                if (string.IsNullOrEmpty(roleClaim))
                {
                    context.Result = new RedirectToActionResult("Error", "Home", null);
                    return;
                }

                // ✅ Check if the current action has its own [RoleAuthorize] (override support)
                var actionDescriptor = context.ActionDescriptor as Microsoft.AspNetCore.Mvc.Controllers.ControllerActionDescriptor;
                var actionAttributes = actionDescriptor?.MethodInfo?
                    .GetCustomAttributes(typeof(RoleAuthorizeAttribute), true)
                    .Cast<RoleAuthorizeAttribute>()
                    .ToList() ?? new List<RoleAuthorizeAttribute>();

                var effectiveRoles = actionAttributes.Any()
                    ? actionAttributes.First()._allowedRoles
                    : _allowedRoles;

                // ✅ Admin and Partner can access everything (with data filtering in controllers)
                if (roleClaim.Equals("Admin", StringComparison.OrdinalIgnoreCase) || 
                    roleClaim.Equals("Partner", StringComparison.OrdinalIgnoreCase))
                    return;

                // 🚫 Block access if user’s role is not in the allowed list
                if (!effectiveRoles.Any(r => r.Equals(roleClaim, StringComparison.OrdinalIgnoreCase)))
                {
                    context.Result = new RedirectToActionResult("Error", "Home", null);
                }
            }
            catch
            {
                // 🧨 Invalid or expired token
                context.Result = new RedirectToActionResult("Login", "Account", null);
            }
        }
    }
}
