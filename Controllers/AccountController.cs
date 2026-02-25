using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using CRM.Attributes;
using CRM.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Mail;
using System.Security.Claims;
using System.Text;
using static System.Runtime.InteropServices.JavaScript.JSType;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace CRM.Controllers
{
    public class AccountController : Controller
    {
        private readonly AppDbContext _db;
        private readonly IConfiguration _config;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly Services.EmailService _emailService;
        private readonly Services.SeedDataService _seedDataService;


        public AccountController(AppDbContext db, IConfiguration config, IHttpContextAccessor httpContextAccessor, Services.EmailService emailService, Services.SeedDataService seedDataService)
        {
            _db = db;
            _config = config;
            _httpContextAccessor = httpContextAccessor;
            _emailService = emailService;
            _seedDataService = seedDataService;
        }


        public IActionResult Register()
        {
            bool adminExists = _db.Users.Any(u => u.Role == "Admin");

            ViewBag.Roles = adminExists
                ? _db.RolePermissions
                     .Where(r => r.RoleName != "Admin")
                     .Select(r => r.RoleName)
                     .Distinct()
                     .ToList()
                : new List<string> { "Admin" };
            
            var branding = _db.Branding.AsNoTracking().FirstOrDefault();
            ViewBag.CompanyLogo = branding?.CompanyLogo;
            
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Register(RegisterModel model)
        {
bool adminExists = _db.Users.Any(u => u.Role == "Admin");

            if (adminExists && model.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                ViewBag.Message = "Admin user already exists. You cannot create another Admin.";
                ViewBag.Roles = new List<string> { model.Role };
                var branding = _db.Branding.AsNoTracking().FirstOrDefault();
                ViewBag.CompanyLogo = branding?.CompanyLogo;
                return View();
            }
            
            if (_db.Users.Any(u => u.Username == model.Username))
            {
                ViewBag.Message = "Username already exists!";
                ViewBag.Roles = adminExists
                    ? _db.RolePermissions.Where(r => r.RoleName != "Admin").Select(r => r.RoleName).Distinct().ToList()
                    : new List<string> { "Admin" };
                var branding = _db.Branding.AsNoTracking().FirstOrDefault();
                ViewBag.CompanyLogo = branding?.CompanyLogo;
                return View();
            }

            if (_db.Users.Any(u => u.Email == model.Email))
            {
                ViewBag.Message = "Email already exists!";
                ViewBag.Roles = adminExists
                    ? _db.RolePermissions.Where(r => r.RoleName != "Admin").Select(r => r.RoleName).Distinct().ToList()
                    : new List<string> { "Admin" };
                var branding = _db.Branding.AsNoTracking().FirstOrDefault();
                ViewBag.CompanyLogo = branding?.CompanyLogo;
                return View();
            }

            var isFirstUser = !_db.Users.Any();
            bool requiresApproval = model.Role.Equals("Agent", StringComparison.OrdinalIgnoreCase) || 
                                   model.Role.Equals("Sales", StringComparison.OrdinalIgnoreCase) || 
                                   model.Role.Equals("Partner", StringComparison.OrdinalIgnoreCase);

            var newUser = new UserModel
            {
                Username = model.Username,
                Email = model.Email,
                Password = model.Password,
                Role = model.Role,
                IsActive = !requiresApproval,
                CreatedDate = DateTime.Now
            };

            _db.Users.Add(newUser);
            _db.SaveChanges();

            // Create Agent or Partner record
            if (model.Role.Equals("Agent", StringComparison.OrdinalIgnoreCase) || 
                model.Role.Equals("Sales", StringComparison.OrdinalIgnoreCase))
            {
                var agent = new AgentModel
                {
                    FullName = model.Username,
                    Email = model.Email,
                    Phone = "",
                    AgentType = "Commission",
                    CommissionRules = "0.0% of sale",
                    Status = "Pending",
                    CreatedOn = DateTime.Now
                };
                _db.Agents.Add(agent);
                _db.SaveChanges();
            }
            else if (model.Role.Equals("Partner", StringComparison.OrdinalIgnoreCase))
            {
                var partner = new ChannelPartnerModel
                {
                    CompanyName = model.Username,
                    ContactPerson = model.Username,
                    Email = model.Email,
                    Phone = "",
                    CommissionScheme = "0% of sale",
                    Status = "Pending",
                    CreatedOn = DateTime.Now
                };
                _db.ChannelPartners.Add(partner);
                _db.SaveChanges();
            }

            if (isFirstUser)
            {
                await _seedDataService.SeedRolePermissionsAsync();
            }

            if (requiresApproval)
            {
                TempData["RegistrationMessage"] = "Registration successful! Your account is pending approval. You will be notified once approved.";
            }

            return RedirectToAction("Login");
        }

        [HttpGet]
        public async Task<IActionResult> Login()
        {
            // Only sign out from authentication, don't delete cookies
            if (User.Identity?.IsAuthenticated == true)
            {
                await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            }
            
            if (!_db.Users.Any())
            {
                return RedirectToAction(nameof(Register));
            }

            // Get branding data
            var branding = _db.Branding.AsNoTracking().FirstOrDefault();
            ViewBag.CompanyLogo = branding?.CompanyLogo;

            return View();
        }
        [HttpPost]
        public async Task<IActionResult> Login(LoginModel model)
        {
            // Validate model first
            if (!ModelState.IsValid)
            {
                ViewBag.Message = "Please fill in all required fields";
                return View();
            }

            var users = _db.Users.ToList();
            var user = users.FirstOrDefault(u => u.Username.Equals(model.Username, StringComparison.Ordinal) && u.Password.Equals(model.Password, StringComparison.Ordinal));
            if (user == null)
            {
                ViewBag.Message = "Invalid credentials!";
                return View();
            }

            if (!user.IsActive)
            {
                ViewBag.Message = "Your account is pending approval. Please wait for admin approval.";
                return View();
            }

            // Clear any existing authentication data AFTER validation succeeds
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            HttpContext.Session.Clear();
            
            // Clear only authentication cookies, NOT anti-forgery token
            var cookiesToDelete = Request.Cookies.Keys
                .Where(key => key != ".AspNetCore.Antiforgery" && 
                             !key.StartsWith("__RequestVerificationToken"))
                .ToList();
            
            foreach (var cookie in cookiesToDelete)
            {
                Response.Cookies.Delete(cookie);
            }

            var token = GenerateJwtToken(user);

            // Store JWT token in cookie with unique path
            Response.Cookies.Append("jwtToken", token, new CookieOptions
            {
                HttpOnly = false,      
                Secure = true,        
                IsEssential = true,
                SameSite = SameSiteMode.None,
                Expires = DateTimeOffset.UtcNow.AddHours(8)
            });

            // Sign in user with Cookie Authentication (required for [Authorize] attribute)
            var claims = new List<Claim>
            {
                new Claim("UserId", user.UserId.ToString()),
                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, user.Role),
                new Claim("ChannelPartnerId", user.ChannelPartnerId?.ToString() ?? ""),
                new Claim("token", token)
            };

            var claimsIdentity = new ClaimsIdentity(claims, Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationDefaults.AuthenticationScheme);
            var authProperties = new Microsoft.AspNetCore.Authentication.AuthenticationProperties
            {
                IsPersistent = true, // Remember me
                ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8)
            };

            await HttpContext.SignInAsync(
                Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(claimsIdentity),
                authProperties);

            return user.Role switch
            {
                "Admin" => RedirectToAction("Index", "Profile"),
                "Manager" => RedirectToAction("Dashboard", "Manager"),
                "Sales" => RedirectToAction("Index", "Profile"),
                "Agent" => RedirectToAction("Index", "Profile"),
                "Partner" => RedirectToAction("Index", "Profile"),
                _ => RedirectToAction("Login")
            };
        }

        private string GenerateJwtToken(UserModel user)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim("UserId", user.UserId.ToString()),   // ? UserId stored

                new Claim(ClaimTypes.Name, user.Username),
                new Claim(ClaimTypes.Role, user.Role)
            };

            var token = new JwtSecurityToken(
                _config["Jwt:Issuer"],
                _config["Jwt:Audience"],
                claims,
                expires: DateTime.Now.AddHours(1),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
        [HttpGet]
        public IActionResult ForgotPassword()
        {
            try
            {
                // Load Admin logo by default (ChannelPartnerId = null)
                var logoSetting = _db.Settings.AsNoTracking().FirstOrDefault(s => s.SettingKey == "CompanyLogo" && s.ChannelPartnerId == null);
                ViewBag.CompanyLogo = logoSetting?.SettingValue;

                var companyNameSetting = _db.Settings.AsNoTracking().FirstOrDefault(s => s.SettingKey == "CompanyName" && s.ChannelPartnerId == null);
                ViewBag.CompanyName = companyNameSetting?.SettingValue ?? "CRM System";
            }
            catch
            {
                // Fallback if ChannelPartnerId column doesn't exist yet
                var logoSetting = _db.Settings.AsNoTracking().FirstOrDefault(s => s.SettingKey == "CompanyLogo");
                ViewBag.CompanyLogo = logoSetting?.SettingValue;
                ViewBag.CompanyName = "CRM System";
            }

            return View();
        }
        [HttpPost]
        public async Task<IActionResult> ForgotPassword([FromForm] ForgotPasswordModel model)
        {
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Email == model.Email);
            if (user == null)
            {
                // don't reveal presence
                ViewBag.Message = "If the email exists, a reset link was sent.";
                return View();
            }

            var token = Guid.NewGuid().ToString("N");
            user.ResetToken = token;
            user.ResetTokenExpiry = DateTime.UtcNow.AddHours(1); // Token expires in 1 hour
            await _db.SaveChangesAsync();

            // send reset email
            try
            {
                var (from, pass) = await _emailService.GetEmailCredentials(user.UserId);
                
                if (string.IsNullOrEmpty(from) || string.IsNullOrEmpty(pass))
                {
                    ViewBag.Message = "If the email exists, a reset link was sent.";
                    return View();
                }
                
                var resetLink = Url.Action("ResetPasswordWithToken", "Account", new { token }, Request.Scheme);

                var mail = new MailMessage();
                mail.From = new MailAddress(from);
                mail.To.Add(user.Email);
                mail.Subject = "Reset Your Password";
                mail.Body = $@"
                    <h2>Password Reset Request</h2>
                    <p>You requested to reset your password. Click the link below to reset it:</p>
                    <p><a href='{resetLink}' style='padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px;'>Reset Password</a></p>
                    <p>This link will expire in 1 hour.</p>
                    <p>If you didn't request this, please ignore this email.</p>
                ";
                mail.IsBodyHtml = true;

                //using var smtp = new SmtpClient("smtp.gmail.com", 587)
                //{
                //    Credentials = new NetworkCredential(from, pass),
                //    EnableSsl = true,
                //    Timeout = 10000 // 10 seconds timeout
                //};

                //// Use Task.Run to prevent hanging
                //_ = Task.Run(async () =>
                //{
                //    try
                //    {
                //        await smtp.SendMailAsync(mail);
                //    }
                //    catch
                //    {
                //        // Log error if needed
                //    }
                //});
                using var smtp = new SmtpClient("smtp.gmail.com", 587)
                {
                    Credentials = new NetworkCredential(from, pass),
                    EnableSsl = true,
                    Timeout = 10000
                };

                await smtp.SendMailAsync(mail);

            }
            catch
            {
                // ignore errors here
            }

            ViewBag.Message = "If the email exists, a reset link was sent.";
            return View();

        }

        [HttpGet]
        public async Task<IActionResult> ResetPasswordWithToken(string token)
        {
            if (string.IsNullOrEmpty(token))
            {
                ViewBag.Error = "Invalid reset link.";
                return View("ResetPasswordTokenExpired");
            }

            var user = await _db.Users.FirstOrDefaultAsync(u => u.ResetToken == token);
            if (user == null)
            {
                ViewBag.Error = "Invalid or expired reset link.";
                return View("ResetPasswordTokenExpired");
            }

            // Check token expiry
            if (user.ResetTokenExpiry.HasValue && user.ResetTokenExpiry.Value < DateTime.UtcNow)
            {
                ViewBag.Error = "This reset link has expired. Please request a new one.";
                return View("ResetPasswordTokenExpired");
            }

            var model = new ResetPasswordModel { Username = user.Username };
            ViewBag.Token = token;
            return View("ResetPasswordWithToken", model);
        }

        [HttpPost]
        public async Task<IActionResult> ResetPasswordWithToken([FromForm] string token, [FromForm] string newPassword, [FromForm] string confirmPassword)
        {
            if (string.IsNullOrEmpty(token) || string.IsNullOrEmpty(newPassword))
            {
                ViewBag.Error = "Invalid request.";
                return View("ResetPasswordTokenExpired");
            }

            if (newPassword != confirmPassword)
            {
                ViewBag.Error = "Passwords do not match.";
                ViewBag.Token = token;
                return View("ResetPasswordWithToken", new ResetPasswordModel());
            }

            var user = await _db.Users.FirstOrDefaultAsync(u => u.ResetToken == token);
            if (user == null || (user.ResetTokenExpiry.HasValue && user.ResetTokenExpiry.Value < DateTime.UtcNow))
            {
                ViewBag.Error = "Invalid or expired reset link.";
                return View("ResetPasswordTokenExpired");
            }

            // Reset password
            user.Password = newPassword;
            user.ResetToken = null;
            user.ResetTokenExpiry = null;

            var userSettings = await _db.UserSettings.FirstOrDefaultAsync(us => us.Username == user.Username);
            if (userSettings != null)
            {
                userSettings.PasswordLastChanged = DateTime.Now;
                _db.UserSettings.Update(userSettings);
            }

            _db.Users.Update(user);
            await _db.SaveChangesAsync();

            TempData["PasswordResetSuccess"] = "Password reset successfully. Please login with your new password.";
            return RedirectToAction(nameof(Login));
        }

        private string GetUsernameFromToken()
        {
            string token = _httpContextAccessor.HttpContext?.Request.Cookies["jwtToken"];
            if (string.IsNullOrEmpty(token)) return null;

            try
            {
                var handler = new JwtSecurityTokenHandler();
                var jwt = handler.ReadJwtToken(token);
                return jwt.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Name || c.Type == "name")?.Value;
            }
            catch
            {
                return null;
            }
        }
        [HttpGet]
        public IActionResult ResetPassword()
        {
            string username = GetUsernameFromToken(); // however you get username
            var vm = new ResetPasswordModel { Username = username };
            return View(vm);
        }

        // --- Reset password POST
        [HttpPost]
        public async Task<IActionResult> ResetPassword([FromForm] ResetPasswordModel model)
        {
            // Get current user's username from claims if not provided
            if (string.IsNullOrEmpty(model.Username))
            {
                var userIdClaim = User.FindFirst("UserId")?.Value;
                if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                {
                    TempData["Error"] = "User session expired. Please login again.";
                    return RedirectToAction("Login");
                }
                
                var currentUser = await _db.Users.FirstOrDefaultAsync(u => u.UserId == userId);
                if (currentUser == null)
                {
                    TempData["Error"] = "User not found.";
                    return RedirectToAction("Login");
                }
                model.Username = currentUser.Username;
            }

            // Validate password confirmation
            if (model.NewPassword != model.ConfirmPassword)
            {
                TempData["Error"] = "New password and confirm password do not match.";
                return RedirectToAction("Index", "Profile");
            }

            // Validate current password
            var users = _db.Users.ToList();
            var user = users.FirstOrDefault(u => u.Username.Equals(model.Username, StringComparison.Ordinal) && u.Password.Equals(model.oldPassword, StringComparison.Ordinal));
            if (user == null)
            {
                TempData["Error"] = "Current password is incorrect.";
                return RedirectToAction("Index", "Profile");
            }

            // Update password
            user.Password = model.NewPassword;
            user.ResetToken = null;
            user.ResetTokenExpiry = null;

            var userSettings = await _db.UserSettings.FirstOrDefaultAsync(us => us.Username == user.Username);
            if (userSettings != null)
            {
                userSettings.PasswordLastChanged = DateTime.Now;
                _db.UserSettings.Update(userSettings);
            }

            _db.Users.Update(user);
            await _db.SaveChangesAsync();

            TempData["Success"] = "Password updated successfully!";
            return RedirectToAction("Index", "Profile");
        }

        [HttpGet]
        public async Task<IActionResult> Logout()
        {
            // Check if currently impersonating and warn
            var isImpersonating = HttpContext.Session.GetString("IsImpersonating");
            if (isImpersonating == "true")
            {
                // Clear impersonation data before logout
                HttpContext.Session.Remove("OriginalAdminId");
                HttpContext.Session.Remove("OriginalAdminUsername");
                HttpContext.Session.Remove("IsImpersonating");
            }

            // Sign out from Cookie Authentication
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            
            HttpContext.Session.Clear();

            // ?? Clear cookies
            foreach (var cookie in Request.Cookies.Keys)
            {
                Response.Cookies.Delete(cookie);
            }

            // ?? Disable browser cache
            Response.Headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
            Response.Headers["Pragma"] = "no-cache";
            Response.Headers["Expires"] = "0";

            // Redirect to Login
            return RedirectToAction("Landing", "Home");
        }

        public async Task<IActionResult> DeleteAccount()
        {
            string username = GetUsernameFromToken(); // get logged-in user
            var user = await _db.Users.FirstOrDefaultAsync(u => u.Username == username);

            if (user == null)
            {
                TempData["Error"] = "User not found.";
                return RedirectToAction("Index", "Settings");
            }
            var userSettings = await _db.UserSettings.FirstOrDefaultAsync(us => us.Username == user.Username);
            if (userSettings != null)
            {
                userSettings.AccountDeletedAt = DateTime.Now; // or DateTime.UtcNow
                _db.UserSettings.Update(userSettings);
            }


            _db.Users.Remove(user);
            await _db.SaveChangesAsync();

            return RedirectToAction("Login", "Account");
        }



        [HttpPost]
        public void ClearSessionOnClose()
        {
            HttpContext.Session.Clear();
            Response.Cookies.Delete("jwtToken");
            Response.Cookies.Delete("Username");
            Response.Cookies.Delete("UserRole");
        }

        private (int? userId, string username, string role) GetUserDetailsFromToken()
        {
            string token = _httpContextAccessor.HttpContext?.Request.Cookies["jwtToken"];
            if (string.IsNullOrEmpty(token)) return (null, null, null);

            try
            {
                var handler = new JwtSecurityTokenHandler();
                var jwt = handler.ReadJwtToken(token);

                var userId = jwt.Claims.FirstOrDefault(c => c.Type == "UserId")?.Value;
                var username = jwt.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Name)?.Value;
                var role = jwt.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;

                return (int.Parse(userId), username, role);
            }
            catch
            {
                return (null, null, null);
            }
        }

        public IActionResult Dashboard()
        {
            var userInfo = GetUserDetailsFromToken();

            ViewBag.UserId = userInfo.userId;
            ViewBag.Username = userInfo.username;
            ViewBag.Role = userInfo.role;

            return View();
        }

        // Impersonation methods
        [HttpGet]
        public async Task<IActionResult> GetUsersForImpersonation()
        {
            var currentUser = GetUserDetailsFromToken();
            if (currentUser.role != "Admin")
            {
                return Json(new { success = false, message = "Unauthorized" });
            }

            var users = await _db.Users
                .Where(u => u.Username != currentUser.username && u.IsActive)
                .Select(u => new { u.UserId, u.Username, u.Role })
                .OrderBy(u => u.Role).ThenBy(u => u.Username)
                .ToListAsync();

            var groupedUsers = users.GroupBy(u => u.Role)
                .ToDictionary(g => g.Key, g => g.ToList());

            return Json(new { success = true, users = groupedUsers });
        }

        [HttpPost]
        public async Task<IActionResult> StartImpersonation(int userId)
        {
            var currentUser = GetUserDetailsFromToken();
            if (currentUser.role != "Admin")
            {
                return Json(new { success = false, message = "Unauthorized" });
            }

            var targetUser = await _db.Users.FindAsync(userId);
            if (targetUser == null || !targetUser.IsActive)
            {
                return Json(new { success = false, message = "User not found or inactive" });
            }

            // Store original admin info in session
            HttpContext.Session.SetString("OriginalAdminId", currentUser.userId.ToString());
            HttpContext.Session.SetString("OriginalAdminUsername", currentUser.username);
            HttpContext.Session.SetString("IsImpersonating", "true");

            // Generate new token for target user
            var token = GenerateJwtToken(targetUser);

            // Update JWT cookie
            Response.Cookies.Append("jwtToken", token, new CookieOptions
            {
                HttpOnly = false,
                Secure = true,
                IsEssential = true,
                SameSite = SameSiteMode.None
            });

            // Update authentication claims
            var claims = new List<Claim>
            {
                new Claim("UserId", targetUser.UserId.ToString()),
                new Claim(ClaimTypes.Name, targetUser.Username),
                new Claim(ClaimTypes.Role, targetUser.Role),
                new Claim("ChannelPartnerId", targetUser.ChannelPartnerId?.ToString() ?? ""),
                new Claim("token", token)
            };

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            var authProperties = new AuthenticationProperties
            {
                IsPersistent = true,
                ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8)
            };

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(claimsIdentity),
                authProperties);

            return Json(new { success = true, message = $"Now impersonating {targetUser.Username}" });
        }

        [HttpPost]
        public async Task<IActionResult> StopImpersonation()
        {
            var isImpersonating = HttpContext.Session.GetString("IsImpersonating");
            if (isImpersonating != "true")
            {
                return Json(new { success = false, message = "Not currently impersonating" });
            }

            var originalAdminId = HttpContext.Session.GetString("OriginalAdminId");
            var originalAdminUsername = HttpContext.Session.GetString("OriginalAdminUsername");

            if (string.IsNullOrEmpty(originalAdminId))
            {
                return Json(new { success = false, message = "Original admin info not found" });
            }

            var adminUser = await _db.Users.FindAsync(int.Parse(originalAdminId));
            if (adminUser == null)
            {
                return Json(new { success = false, message = "Original admin user not found" });
            }

            // Clear impersonation session data
            HttpContext.Session.Remove("OriginalAdminId");
            HttpContext.Session.Remove("OriginalAdminUsername");
            HttpContext.Session.Remove("IsImpersonating");

            // Generate new token for admin user
            var token = GenerateJwtToken(adminUser);

            // Update JWT cookie
            Response.Cookies.Append("jwtToken", token, new CookieOptions
            {
                HttpOnly = false,
                Secure = true,
                IsEssential = true,
                SameSite = SameSiteMode.None
            });

            // Update authentication claims
            var claims = new List<Claim>
            {
                new Claim("UserId", adminUser.UserId.ToString()),
                new Claim(ClaimTypes.Name, adminUser.Username),
                new Claim(ClaimTypes.Role, adminUser.Role),
                new Claim("ChannelPartnerId", adminUser.ChannelPartnerId?.ToString() ?? ""),
                new Claim("token", token)
            };

            var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            var authProperties = new AuthenticationProperties
            {
                IsPersistent = true,
                ExpiresUtc = DateTimeOffset.UtcNow.AddHours(8)
            };

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                new ClaimsPrincipal(claimsIdentity),
                authProperties);

            return Json(new { success = true, message = "Stopped impersonation, back to admin", redirectUrl = "/Settings/Impersonation" });
        }

    }
}
