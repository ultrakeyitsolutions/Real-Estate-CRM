using Microsoft.AspNetCore.Mvc;
using CRM.Models;
using System.Linq;
using Microsoft.AspNetCore.Authorization;
using CRM.Attributes;

namespace CRM.Controllers
{
    [Authorize]
    [PermissionAuthorize("View")]
    public class SettingsController : Controller
    {
        private readonly AppDbContext _db;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public SettingsController(AppDbContext db, IHttpContextAccessor httpContextAccessor)
        {
            _db = db;
            _httpContextAccessor = httpContextAccessor;
        }

        // GET: Settings
        public IActionResult Index()
        {
            var role = User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid, out int userId);
            var currentUser = _db.Users.FirstOrDefault(u => u.UserId == userId);
            var channelPartnerId = currentUser?.ChannelPartnerId;

            var settingsQuery = _db.Settings.AsQueryable();
            if (role?.ToLower() == "partner")
                settingsQuery = settingsQuery.Where(s => s.ChannelPartnerId == channelPartnerId);
            else if (role?.ToLower() == "admin")
                settingsQuery = settingsQuery.Where(s => s.ChannelPartnerId == null);

            var settings = settingsQuery.ToList();
            
            // Convert list to dictionary for easier access in view
            var settingsDict = settings.ToDictionary(s => s.SettingKey, s => s.SettingValue ?? "");
            
            return View(settingsDict);
        }

        // POST: Update Settings
        [HttpPost]
        [PermissionAuthorize("Edit")]
        public async Task<IActionResult> UpdateSettings(IFormCollection settings, IFormFile? CompanyLogo, IFormFile? CollapsedLogo)
        {
            System.Diagnostics.Debug.WriteLine("UpdateSettings action HIT");
            try
            {
                var currentUserId = _getCurrentUserId();
                var userRole = User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
                var userIdStr = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                int.TryParse(userIdStr, out int userId);
                var currentUser = _db.Users.FirstOrDefault(u => u.UserId == userId);
                var channelPartnerId = currentUser?.ChannelPartnerId;

                // Handle logo upload
                if (CompanyLogo != null && CompanyLogo.Length > 0)
                {
                    // Validate file size (2MB)
                    if (CompanyLogo.Length > 2 * 1024 * 1024)
                    {
                        return Json(new { success = false, message = "Logo file must be less than 2MB" });
                    }

                    // Validate file type
                    var allowedTypes = new[] { "image/png", "image/jpeg", "image/jpg", "image/gif" };
                    if (!allowedTypes.Contains(CompanyLogo.ContentType.ToLower()))
                    {
                        return Json(new { success = false, message = "Only PNG, JPG, and GIF images are allowed" });
                    }

                    // Convert to base64
                    using (var memoryStream = new MemoryStream())
                    {
                        await CompanyLogo.CopyToAsync(memoryStream);
                        var imageBytes = memoryStream.ToArray();
                        var base64String = Convert.ToBase64String(imageBytes);
                        var logoDataUrl = $"data:{CompanyLogo.ContentType};base64,{base64String}";

                        SettingsModel logoSetting;
                        if (userRole?.ToLower() == "partner")
                            logoSetting = _db.Settings.FirstOrDefault(s => s.SettingKey == "CompanyLogo" && s.ChannelPartnerId == channelPartnerId);
                        else
                            logoSetting = _db.Settings.FirstOrDefault(s => s.SettingKey == "CompanyLogo" && s.ChannelPartnerId == null);
                        
                        if (logoSetting != null)
                        {
                            logoSetting.SettingValue = logoDataUrl;
                            logoSetting.ModifiedOn = DateTime.Now;
                            logoSetting.ModifiedBy = currentUserId;
                        }
                        else
                        {
                            _db.Settings.Add(new SettingsModel
                            {
                                SettingKey = "CompanyLogo",
                                SettingValue = logoDataUrl,
                                SettingType = "Image",
                                ModifiedOn = DateTime.Now,
                                ModifiedBy = currentUserId,
                                ChannelPartnerId = userRole?.ToLower() == "partner" ? channelPartnerId : null
                            });
                        }
                    }
                }

                // Handle collapsed logo upload
                if (CollapsedLogo != null && CollapsedLogo.Length > 0)
                {
                    if (CollapsedLogo.Length > 2 * 1024 * 1024)
                        return Json(new { success = false, message = "Collapsed logo must be less than 2MB" });

                    var allowedTypes = new[] { "image/png", "image/jpeg", "image/jpg", "image/gif" };
                    if (!allowedTypes.Contains(CollapsedLogo.ContentType.ToLower()))
                        return Json(new { success = false, message = "Only PNG, JPG, and GIF images are allowed" });

                    using (var memoryStream = new MemoryStream())
                    {
                        await CollapsedLogo.CopyToAsync(memoryStream);
                        var imageBytes = memoryStream.ToArray();
                        var base64String = Convert.ToBase64String(imageBytes);
                        var logoDataUrl = $"data:{CollapsedLogo.ContentType};base64,{base64String}";

                        SettingsModel collapsedLogoSetting;
                        if (userRole?.ToLower() == "partner")
                            collapsedLogoSetting = _db.Settings.FirstOrDefault(s => s.SettingKey == "CollapsedLogo" && s.ChannelPartnerId == channelPartnerId);
                        else
                            collapsedLogoSetting = _db.Settings.FirstOrDefault(s => s.SettingKey == "CollapsedLogo" && s.ChannelPartnerId == null);
                        
                        if (collapsedLogoSetting != null)
                        {
                            collapsedLogoSetting.SettingValue = logoDataUrl;
                            collapsedLogoSetting.ModifiedOn = DateTime.Now;
                            collapsedLogoSetting.ModifiedBy = currentUserId;
                        }
                        else
                        {
                            _db.Settings.Add(new SettingsModel
                            {
                                SettingKey = "CollapsedLogo",
                                SettingValue = logoDataUrl,
                                SettingType = "Image",
                                ModifiedOn = DateTime.Now,
                                ModifiedBy = currentUserId,
                                ChannelPartnerId = userRole?.ToLower() == "partner" ? channelPartnerId : null
                            });
                        }
                    }
                }

                foreach (var key in settings.Keys)
                {
                    if (key == "CompanyLogo" || key == "CollapsedLogo" || key == "__RequestVerificationToken")
                        continue;

                    var value = settings[key].ToString();
                    
                    SettingsModel existingSetting;
                    if (userRole?.ToLower() == "partner")
                        existingSetting = _db.Settings.FirstOrDefault(s => s.SettingKey == key && s.ChannelPartnerId == channelPartnerId);
                    else
                        existingSetting = _db.Settings.FirstOrDefault(s => s.SettingKey == key && s.ChannelPartnerId == null);
                    
                    if (existingSetting != null)
                    {
                        existingSetting.SettingValue = value;
                        existingSetting.ModifiedOn = DateTime.Now;
                        existingSetting.ModifiedBy = currentUserId;
                    }
                    else
                    {
                        _db.Settings.Add(new SettingsModel
                        {
                            SettingKey = key,
                            SettingValue = value,
                            SettingType = "Text",
                            ModifiedOn = DateTime.Now,
                            ModifiedBy = currentUserId,
                            ChannelPartnerId = userRole?.ToLower() == "partner" ? channelPartnerId : null
                        });
                    }
                }

                await _db.SaveChangesAsync();

                return Json(new { success = true, message = "Settings updated successfully" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}. Inner: {ex.InnerException?.Message}" });
            }
        }

        // POST: Remove Logo
        [HttpPost]
        public IActionResult RemoveLogo()
        {
            try
            {
                var logoSetting = _db.Settings.FirstOrDefault(s => s.SettingKey == "CompanyLogo");
                if (logoSetting != null)
                {
                    _db.Settings.Remove(logoSetting);
                    _db.SaveChanges();
                }

                return Json(new { success = true, message = "Logo removed successfully" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        // GET: Get specific setting value
        [HttpGet]
        public IActionResult GetSetting(string key)
        {
            var setting = _db.Settings.FirstOrDefault(s => s.SettingKey == key);
            
            if (setting != null)
            {
                return Json(new { success = true, value = setting.SettingValue });
            }
            
            return Json(new { success = false, message = "Setting not found" });
        }

        // Helper method to get current user ID from JWT
        private int? _getCurrentUserId()
        {
            try
            {
                string? token = _httpContextAccessor.HttpContext?.Request.Cookies["jwtToken"];
                if (string.IsNullOrEmpty(token)) return null;

                var handler = new System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler();
                var jwt = handler.ReadJwtToken(token);

                var userIdClaim = jwt.Claims.FirstOrDefault(c => c.Type == "UserId" || c.Type == "sub");
                if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int userId))
                {
                    return userId;
                }

                return null;
            }
            catch
            {
                return null;
            }
        }

        // Backward compatible - defaults to Admin settings (channelPartnerId = null)
        public static string GetSettingValue(AppDbContext db, string key, string defaultValue = "")
        {
            var setting = db.Settings.FirstOrDefault(s => s.SettingKey == key && s.ChannelPartnerId == null);
            return setting?.SettingValue ?? defaultValue;
        }

        // New overload with channelPartnerId
        public static string GetSettingValue(AppDbContext db, string key, int? channelPartnerId, string defaultValue = "")
        {
            var setting = db.Settings.FirstOrDefault(s => s.SettingKey == key && s.ChannelPartnerId == channelPartnerId);
            return setting?.SettingValue ?? defaultValue;
        }

        // Backward compatible - defaults to Admin settings
        public static decimal GetSettingValueDecimal(AppDbContext db, string key, decimal defaultValue = 0)
        {
            var setting = db.Settings.FirstOrDefault(s => s.SettingKey == key && s.ChannelPartnerId == null);
            if (setting != null && decimal.TryParse(setting.SettingValue, out decimal value))
            {
                return value;
            }
            return defaultValue;
        }

        // New overload with channelPartnerId
        public static decimal GetSettingValueDecimal(AppDbContext db, string key, int? channelPartnerId, decimal defaultValue = 0)
        {
            var setting = db.Settings.FirstOrDefault(s => s.SettingKey == key && s.ChannelPartnerId == channelPartnerId);
            if (setting != null && decimal.TryParse(setting.SettingValue, out decimal value))
            {
                return value;
            }
            return defaultValue;
        }

        // GET: Branding Settings
        [RoleAuthorize("Admin")]
        [PermissionAuthorize("View")]
        public IActionResult Branding()
        {
            var branding = _db.Branding.FirstOrDefault() ?? new BrandingModel();
            return View(branding);
        }

        // POST: Update Branding
        [HttpPost]
        [RoleAuthorize("Admin")]
        [PermissionAuthorize("Edit")]
        public async Task<IActionResult> UpdateBranding(IFormCollection form, IFormFile? CompanyLogo, IFormFile? AboutUsImage, IFormFile? FooterLogo)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("UpdateBranding called");
                foreach (var key in form.Keys)
                {
                    System.Diagnostics.Debug.WriteLine($"Form Key: {key}, Value: {form[key]}");
                }
                
                var currentUserId = _getCurrentUserId();
                var existingBranding = _db.Branding.FirstOrDefault();

                if (existingBranding == null)
                {
                    existingBranding = new BrandingModel();
                    _db.Branding.Add(existingBranding);
                }

                // Handle Company Logo upload
                if (CompanyLogo != null && CompanyLogo.Length > 0)
                {
                    if (CompanyLogo.Length > 2 * 1024 * 1024)
                        return Json(new { success = false, message = "Company logo must be less than 2MB" });

                    var allowedTypes = new[] { "image/png", "image/jpeg", "image/jpg", "image/gif" };
                    if (!allowedTypes.Contains(CompanyLogo.ContentType.ToLower()))
                        return Json(new { success = false, message = "Only PNG, JPG, and GIF images are allowed" });

                    using (var memoryStream = new MemoryStream())
                    {
                        await CompanyLogo.CopyToAsync(memoryStream);
                        var imageBytes = memoryStream.ToArray();
                        var base64String = Convert.ToBase64String(imageBytes);
                        existingBranding.CompanyLogo = $"data:{CompanyLogo.ContentType};base64,{base64String}";
                    }
                }

                // Handle About Us Image upload
                if (AboutUsImage != null && AboutUsImage.Length > 0)
                {
                    if (AboutUsImage.Length > 2 * 1024 * 1024)
                        return Json(new { success = false, message = "About Us image must be less than 2MB" });

                    var allowedTypes = new[] { "image/png", "image/jpeg", "image/jpg", "image/gif" };
                    if (!allowedTypes.Contains(AboutUsImage.ContentType.ToLower()))
                        return Json(new { success = false, message = "Only PNG, JPG, and GIF images are allowed" });

                    using (var memoryStream = new MemoryStream())
                    {
                        await AboutUsImage.CopyToAsync(memoryStream);
                        var imageBytes = memoryStream.ToArray();
                        var base64String = Convert.ToBase64String(imageBytes);
                        existingBranding.AboutUsImage = $"data:{AboutUsImage.ContentType};base64,{base64String}";
                    }
                }

                // Handle Footer Logo upload
                if (FooterLogo != null && FooterLogo.Length > 0)
                {
                    if (FooterLogo.Length > 2 * 1024 * 1024)
                        return Json(new { success = false, message = "Footer logo must be less than 2MB" });

                    var allowedTypes = new[] { "image/png", "image/jpeg", "image/jpg", "image/gif" };
                    if (!allowedTypes.Contains(FooterLogo.ContentType.ToLower()))
                        return Json(new { success = false, message = "Only PNG, JPG, and GIF images are allowed" });

                    using (var memoryStream = new MemoryStream())
                    {
                        await FooterLogo.CopyToAsync(memoryStream);
                        var imageBytes = memoryStream.ToArray();
                        var base64String = Convert.ToBase64String(imageBytes);
                        existingBranding.FooterLogo = $"data:{FooterLogo.ContentType};base64,{base64String}";
                    }
                }

                // Update text fields from form data - only if provided
                if (form.ContainsKey("TwitterUrl")) existingBranding.TwitterUrl = form["TwitterUrl"].ToString();
                if (form.ContainsKey("WhatsAppNumber")) existingBranding.WhatsAppNumber = form["WhatsAppNumber"].ToString();
                if (form.ContainsKey("FacebookUrl")) existingBranding.FacebookUrl = form["FacebookUrl"].ToString();
                if (form.ContainsKey("InstagramUrl")) existingBranding.InstagramUrl = form["InstagramUrl"].ToString();
                if (form.ContainsKey("LinkedInUrl")) existingBranding.LinkedInUrl = form["LinkedInUrl"].ToString();
                if (form.ContainsKey("AboutUsText")) existingBranding.AboutUsText = form["AboutUsText"].ToString();
                if (form.ContainsKey("CompanyInfo")) existingBranding.CompanyInfo = form["CompanyInfo"].ToString();
                if (form.ContainsKey("TermsAndConditions")) existingBranding.TermsAndConditions = form["TermsAndConditions"].ToString();
                if (form.ContainsKey("PrivacyPolicy")) existingBranding.PrivacyPolicy = form["PrivacyPolicy"].ToString();
                existingBranding.ModifiedOn = DateTime.Now;
                existingBranding.ModifiedBy = currentUserId;

                await _db.SaveChangesAsync();

                return Json(new { success = true, message = "Branding updated successfully" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        // Helper method to get branding data
        public static BrandingModel GetBrandingData(AppDbContext db)
        {
            return db.Branding.FirstOrDefault() ?? new BrandingModel();
        }

        // GET: Impersonation Settings
        [RoleAuthorize("Admin")]
        public IActionResult Impersonation()
        {
            var users = _db.Users.Where(u => u.IsActive).OrderBy(u => u.Role).ThenBy(u => u.Username).ToList();
            var roles = _db.RolePermissions.Select(r => r.RoleName).ToList();
            ViewBag.Roles = roles;
            return View(users);
        }
    }
}
