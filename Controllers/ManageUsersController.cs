using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CRM.Attributes;
using CRM.Models;
using CRM.Services;
using System.Linq;
using System.Threading.Tasks;
using CRM;
using System.Net;
using System.Net.Mail;

namespace CRM.Controllers
{
    [RoleAuthorize("Admin", "Partner", "Agent", "Sales")]

    public class ManageUsersController : Controller
    {
        private readonly AppDbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;
        private readonly Services.PermissionService _permissionService;
        private readonly SubscriptionService _subscriptionService;
        private readonly IWebHostEnvironment _webHostEnvironment;
        private readonly IConfiguration _configuration;
        
        public ManageUsersController(AppDbContext context, IHttpContextAccessor httpContextAccessor, Services.PermissionService permissionService, SubscriptionService subscriptionService, IWebHostEnvironment webHostEnvironment, IConfiguration configuration)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
            _permissionService = permissionService;
            _subscriptionService = subscriptionService;
            _webHostEnvironment = webHostEnvironment;
            _configuration = configuration;
        }
        
        private (int? UserId, string? Role, int? ChannelPartnerId) GetCurrentUserContext()
        {
            var token = _httpContextAccessor.HttpContext?.Request.Cookies["jwtToken"];
            if (string.IsNullOrEmpty(token)) return (null, null, null);
            
            var jwt = new System.IdentityModel.Tokens.Jwt.JwtSecurityTokenHandler().ReadJwtToken(token);
            var userIdClaim = jwt.Claims.FirstOrDefault(c => c.Type == "UserId")?.Value;
            var role = jwt.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.Role)?.Value;
            
            if (!int.TryParse(userIdClaim, out int userId)) return (null, role, null);
            
            var user = _context.Users.FirstOrDefault(u => u.UserId == userId);
            return (userId, role, user?.ChannelPartnerId);
        }

        public async Task<IActionResult> Index()
        {
            var (userId, role, channelPartnerId) = GetCurrentUserContext();
            
            IQueryable<UserModel> usersQuery = _context.Users;
            
            if (role?.ToLower() == "partner")
            {
                // Partner sees only their agents (exclude themselves)
                usersQuery = usersQuery.Where(u => u.ChannelPartnerId == channelPartnerId && u.UserId != userId);
            }
            else if (role?.ToLower() == "admin")
            {
                // Admin sees all users
                // No filtering
            }
            
            var users = await usersQuery.ToListAsync();
            
            // Filter roles based on current user
            var allowedRoles = role?.ToLower() == "partner" 
                ? new List<string> { "Sales", "Agent" } 
                : _context.RolePermissions.Select(r => r.RoleName).ToList();
            
            ViewBag.Roles = allowedRoles;
            return View(users);
        }
        // AJAX endpoint for modal population
        [HttpGet]
        public async Task<IActionResult> GetUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return Json(new { success = false, message = "User not found." });

            return Json(new
            {
                success = true,
                userId = user.UserId,
                username = user.Username,
                email = user.Email,
                role = user.Role,
                phone = user.Phone,
                isActive = user.IsActive
            });
        }
        [HttpGet]
        public IActionResult AddUser(string email = null, string phone = null)
        {
            var roles = _context.RolePermissions.Select(r => r.RoleName).ToList();
            ViewBag.Roles = roles;
            string password = "";
            if (!string.IsNullOrEmpty(email) && !string.IsNullOrEmpty(phone))
            {
                var first4 = email.Length >= 4 ? email.Substring(0, 4).ToUpper() : email.ToUpper();
                var digits = new string(phone.Where(char.IsDigit).ToArray());
                var lastDigits = digits.Length >= 4 ? digits.Substring(digits.Length - 4) : digits;
                password = first4 + "@" + lastDigits;
            }
            ViewBag.Password = password;
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> AddUser(UserModel user, IFormFile? uploadFile)
        {
            if (ModelState.IsValid)
            {
                // Get current user context first
                var (userId, role, channelPartnerId) = GetCurrentUserContext();
                
                // ✅ Handle file upload
                if (uploadFile != null)
                {
                    // Check storage limits for partners
                    if (role?.ToLower() == "partner" && channelPartnerId.HasValue)
                    {
                        var canUploadResult = await _subscriptionService.CanUploadFileAsync(channelPartnerId.Value, uploadFile.Length);
                        bool canUpload = canUploadResult.CanUpload;
                        string storageMessage = canUploadResult.Message;
                        double currentUsageGB = canUploadResult.CurrentUsageGB;
                        double limitGB = canUploadResult.LimitGB;
                        if (!canUpload)
                        {
                            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                            {
                                // Get available plans for upgrade options
                                var availablePlans = await _subscriptionService.GetAvailablePlansAsync();
                                return Json(new { 
                                    success = false, 
                                    storageLimitReached = true,
                                    message = storageMessage,
                                    currentUsageGB = currentUsageGB,
                                    limitGB = limitGB,
                                    availablePlans = availablePlans.Select(p => new {
                                        planId = p.PlanId,
                                        planName = p.PlanName,
                                        monthlyPrice = p.MonthlyPrice,
                                        yearlyPrice = p.YearlyPrice,
                                        maxStorageGB = p.MaxStorageGB
                                    }).ToList()
                                });
                            }
                            
                            ModelState.AddModelError("", storageMessage);
                            ViewBag.ShowUpgrade = true;
                            ViewBag.UpgradePrompt = storageMessage;
                            return View(user);
                        }
                    }
                    
                    var uploadFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/uploads");
                    if (!Directory.Exists(uploadFolder))
                        Directory.CreateDirectory(uploadFolder);

                    var filePath = Path.Combine(uploadFolder, uploadFile.FileName);
                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await uploadFile.CopyToAsync(stream);
                    }
                }

                // ✅ Set audit fields
                user.CreatedDate = DateTime.UtcNow;
                user.LastActivity = DateTime.UtcNow;
                user.IsActive = user.IsActive;
                
                // Auto-assign ChannelPartnerId if current user is Partner
                if (role?.ToLower() == "partner")
                {
                    user.ChannelPartnerId = channelPartnerId;
                    
                    // Check subscription limits for partners creating Sales/Agent users
                    if (user.Role == "Sales" || user.Role == "Agent")
                    {
                        var (canAdd, message) = await _subscriptionService.CanAddAgentAsync(channelPartnerId.Value);
                        if (!canAdd)
                        {
                            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                            {
                                // Get available plans for upgrade options
                                var availablePlans = await _subscriptionService.GetAvailablePlansAsync();
                                return Json(new { 
                                    success = false, 
                                    agentLimitReached = true,
                                    message = message,
                                    availablePlans = availablePlans.Select(p => new {
                                        planId = p.PlanId,
                                        planName = p.PlanName,
                                        monthlyPrice = p.MonthlyPrice,
                                        yearlyPrice = p.YearlyPrice,
                                        maxAgents = p.MaxAgents
                                    }).ToList()
                                });
                            }
                            
                            ModelState.AddModelError("", message);
                            ViewBag.ShowUpgrade = true;
                            ViewBag.UpgradePrompt = message;
                            return View(user);
                        }
                    }
                }

                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                // Support AJAX
                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    return Json(new { success = true });

                return RedirectToAction(nameof(Index));
            }

            // Support AJAX error
            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                return Json(new { success = false, errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage) });

            return View(user);
        }


        //[HttpGet]
        //public async Task<IActionResult> EditUser(int id)
        //{
        //    var user = await _context.Users.FindAsync(id);
        //    if (user == null) return NotFound();
        //    var roles = _context.RolePermissions.Select(r => r.RoleName).ToList();
        //    ViewBag.Roles = roles;
        //    return View(user);
        //}

        //[HttpPost]
        //public async Task<IActionResult> EditUser(UserModel user)
        //{

        //    var existingUser = await _context.Users.FirstOrDefaultAsync(x => x.UserId == user.UserId);

        //    if (existingUser == null)
        //    {
        //        return NotFound();
        //    }

        //    // Update only the role
        //    existingUser.Role = user.Role;

        //    await _context.SaveChangesAsync();

        //    return RedirectToAction(nameof(Index));
        //}

        [HttpGet]
        public async Task<IActionResult> EditUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return NotFound();

            // Load roles
            ViewBag.Roles = _context.RolePermissions
                                    .Select(r => r.RoleName)
                                    .ToList();

            return View(user);
        }


        [HttpPost]
        public async Task<IActionResult> EditUser(UserModel user)
        {
            var existingUser = await _context.Users.FirstOrDefaultAsync(x => x.UserId == user.UserId);
            if (existingUser == null)
            {
                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    return Json(new { success = false, message = "User not found." });
                return NotFound();
            }

            // Update all editable fields except password
            existingUser.Username = user.Username;
            existingUser.Email = user.Email;
            existingUser.Phone = user.Phone;
            existingUser.Role = user.Role;
            existingUser.IsActive = user.IsActive;
            // Only update password if provided
            if (!string.IsNullOrWhiteSpace(user.Password))
            {
                existingUser.Password = user.Password;
            }

            await _context.SaveChangesAsync();

            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                return Json(new { success = true });

            return RedirectToAction(nameof(Index));
        }

        [HttpPost]
        public async Task<IActionResult> DeleteUser(int id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return Json(new { success = false, message = "User not found." });

            // Instead of deleting, mark as inactive
            user.IsActive = false;
            await _context.SaveChangesAsync();
            return RedirectToAction("Index");
        }


        //********************************************************************************

        public IActionResult Roles(string? search, string? sort)
        {
            var (userId, role, channelPartnerId) = GetCurrentUserContext();
            
            var roles = _context.RolePermissions.AsQueryable();
            
            // Partner should only see Sales and Agent roles
            if (role?.ToLower() == "partner")
            {
                roles = roles.Where(r => r.RoleName == "Sales" || r.RoleName == "Agent");
            }
            // Admin sees all roles
            else if (role?.ToLower() == "admin")
            {
                // Admin can see all roles - no filtering needed
            }

            if (!string.IsNullOrEmpty(search))
                roles = roles.Where(r => r.RoleName.Contains(search));

            roles = sort switch
            {
                "asc" => roles.OrderBy(r => r.RoleName),
                "desc" => roles.OrderByDescending(r => r.RoleName),
                "recent" => roles.OrderByDescending(r => r.CreatedAt),
                _ => roles.OrderBy(r => r.RoleName)
            };

            return View(roles.ToList());
        }

        [HttpGet]
        public IActionResult AddRoles(int? id)
        {
            RolePermission model;

            if (id == null)
            {
                // Create a new empty model when adding
                model = new RolePermission();
            }
            else
            {
                // Fetch from database when editing
                model = _context.RolePermissions.Find(id);
                if (model == null)
                    return NotFound();
            }

            return View(model);
        }

        [HttpPost]
        public async Task<IActionResult> AddRoles(RolePermission model)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                        return Json(new { success = false, message = "Invalid data provided" });
                    return View(model);
                }

                if (model.CreatedAt < new DateTime(1753, 1, 1))
                {
                    model.CreatedAt = DateTime.Now;
                }

                if (model.Id == 0)
                {
                    model.CreatedAt = DateTime.Now;
                    _context.RolePermissions.Add(model);
                }
                else
                {
                    var existingRole = await _context.RolePermissions.FindAsync(model.Id);
                    if (existingRole != null)
                    {
                        if (existingRole.RoleName != model.RoleName)
                        {
                            // Update role name in permission system
                            await _permissionService.UpdateRoleNameAsync(existingRole.RoleName, model.RoleName);
                            
                            // Update all users who have the old role name
                            var usersWithOldRole = _context.Users.Where(u => u.Role == existingRole.RoleName).ToList();
                            foreach (var user in usersWithOldRole)
                            {
                                user.Role = model.RoleName;
                            }
                            _context.Users.UpdateRange(usersWithOldRole);
                        }
                        existingRole.RoleName = model.RoleName;
                        _context.RolePermissions.Update(existingRole);
                    }
                    else
                    {
                        if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                            return Json(new { success = false, message = "Role not found" });
                        return NotFound();
                    }
                }

                await _context.SaveChangesAsync();
                
                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    return Json(new { success = true, message = "Role saved successfully" });
                    
                return RedirectToAction("Roles");
            }
            catch (Exception ex)
            {
                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    return Json(new { success = false, message = ex.Message });
                throw;
            }
        }


        // 🔹 Delete Role
        [HttpGet]
        public async Task<IActionResult> DeleteRoles(int id)
        {
            var role = await _context.RolePermissions.FindAsync(id);
            if (role != null)
            {
                _context.RolePermissions.Remove(role);
                await _context.SaveChangesAsync();
            }
            return RedirectToAction(nameof(Roles)); // ✅ FIXED
        }

        [HttpPost]
        public IActionResult SavePermissions(RolePermission model)
        {
            var existingRole = _context.RolePermissions.FirstOrDefault(r => r.Id == model.Id);
            if (existingRole == null)
                return NotFound();

            // ✅ Update permission values
            existingRole.CanCreate = model.CanCreate;
            existingRole.CanEdit = model.CanEdit;
            existingRole.CanDelete = model.CanDelete;
            existingRole.CanView = model.CanView;

            _context.RolePermissions.Update(existingRole);
            _context.SaveChanges();

            // Redirect or show success message
            TempData["Success"] = "Permissions updated successfully!";
            return RedirectToAction("Roles");
        }
        [HttpGet]
        public JsonResult GetRole(int id)
        {
            var role = _context.RolePermissions.Find(id);
            if (role == null)
                return Json(new { success = false, message = "Role not found." });

            return Json(new
            {
                success = true,
                id = role.Id,
                roleName = role.RoleName,
                canCreate = role.CanCreate,
                canEdit = role.CanEdit,
                canDelete = role.CanDelete,
                canView = role.CanView
            });
        }

        [HttpGet]
        [RoleAuthorize("Admin")]
        public IActionResult PartnerApproval(int? notificationId)
        {
            var (userId, role, channelPartnerId) = GetCurrentUserContext();
            if (role?.ToLower() != "admin")
            {
                return RedirectToAction("AccessDenied", "Home");
            }
            
            var partners = _context.ChannelPartners
                .Select(p => new ChannelPartnerModel
                {
                    PartnerId = p.PartnerId,
                    CompanyName = p.CompanyName ?? "",
                    ContactPerson = p.ContactPerson ?? "",
                    Email = p.Email ?? "",
                    Phone = p.Phone ?? "",
                    Address = p.Address ?? "",
                    CommissionScheme = p.CommissionScheme ?? "",
                    Documents = p.Documents ?? "",
                    Status = p.Status ?? "Pending",
                    CreatedOn = p.CreatedOn,
                    ApprovedBy = p.ApprovedBy,
                    ApprovedOn = p.ApprovedOn,
                    UserId = p.UserId,
                    CommissionPercentage = p.CommissionPercentage,
                    SubscriptionPlan = p.SubscriptionPlan ?? "Basic"
                })
                .ToList();
            ViewBag.NotificationId = notificationId;
            return View(partners);
        }





        [HttpPost]
        [RoleAuthorize("Admin")]
        public async Task<IActionResult> CreatePartner(ChannelPartnerModel model, List<IFormFile> DocumentFiles)
        {
            try
            {
                var (userId, role, channelPartnerId) = GetCurrentUserContext();
                if (role?.ToLower() != "admin")
                {
                    return Json(new { success = false, message = "Access denied" });
                }
                
                using var transaction = await _context.Database.BeginTransactionAsync();
                
                model.Status = "Approved";
                model.ApprovedBy = userId;
                model.ApprovedOn = DateTime.Now;
                model.CreatedOn = DateTime.Now;
                model.Documents = DocumentFiles?.Count > 0 ? "Uploaded" : "Not Uploaded";
                model.CommissionPercentage = 5.0m;
                
                _context.ChannelPartners.Add(model);
                await _context.SaveChangesAsync();
                
                if (DocumentFiles != null && DocumentFiles.Count > 0)
                {
                    await SavePartnerDocumentsAsync(model.PartnerId, DocumentFiles);
                }
                
                var phoneDigits = new string(model.Phone.Where(char.IsDigit).ToArray());
                var lastDigits = phoneDigits.Length >= 4 ? phoneDigits.Substring(phoneDigits.Length - 4) : phoneDigits;
                var password = model.Email.Substring(0, Math.Min(4, model.Email.Length)).ToUpper() + "@" + lastDigits;
                
                var user = new UserModel
                {
                    Username = model.ContactPerson,
                    Email = model.Email,
                    Password = password,
                    Role = "Partner",
                    Phone = model.Phone,
                    IsActive = true,
                    CreatedDate = DateTime.Now,
                    LastActivity = DateTime.Now,
                    ChannelPartnerId = model.PartnerId
                };
                
                _context.Users.Add(user);
                await _context.SaveChangesAsync();
                
                model.UserId = user.UserId;
                await _context.SaveChangesAsync();
                
                var basicPlan = await _context.SubscriptionPlans
                    .Where(p => p.IsActive)
                    .OrderBy(p => p.MonthlyPrice)
                    .FirstOrDefaultAsync();
                    
                if (basicPlan != null)
                {
                    var trialSubscription = new PartnerSubscriptionModel
                    {
                        ChannelPartnerId = model.PartnerId,
                        PlanId = basicPlan.PlanId,
                        BillingCycle = "Trial",
                        Amount = 0,
                        StartDate = DateTime.Now,
                        EndDate = DateTime.Now.AddDays(7),
                        Status = "Active",
                        PaymentMethod = "Trial",
                        PaymentTransactionId = $"trial_{DateTime.Now.Ticks}",
                        LastPaymentDate = DateTime.Now,
                        NextPaymentDate = DateTime.Now.AddDays(7),
                        AutoRenew = false,
                        CreatedOn = DateTime.Now,
                        UpdatedOn = DateTime.Now
                    };
                    
                    _context.PartnerSubscriptions.Add(trialSubscription);
                    await _context.SaveChangesAsync();
                }
                
                await transaction.CommitAsync();
                
                return Json(new { success = true, message = "Partner created successfully!" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }
        
        private async Task SavePartnerDocumentsAsync(int partnerId, List<IFormFile> files)
        {
            foreach (var file in files)
            {
                if (file.Length > 0)
                {
                    using (var memoryStream = new MemoryStream())
                    {
                        await file.CopyToAsync(memoryStream);
                        var fileContent = memoryStream.ToArray();

                        var document = new ChannelPartnerDocumentModel
                        {
                            ChannelPartnerId = partnerId,
                            FileName = Path.GetFileName(file.FileName),
                            DocumentName = Path.GetFileName(file.FileName),
                            DocumentType = "General",
                            FileContent = fileContent,
                            FileSize = file.Length,
                            ContentType = file.ContentType,
                            UploadedOn = DateTime.Now
                        };
                        _context.ChannelPartnerDocuments.Add(document);
                    }
                }
            }
            await _context.SaveChangesAsync();
        }



        [HttpPost]
        [RoleAuthorize("Admin")]
        public async Task<IActionResult> ApprovePartner(int partnerId)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var (userId, role, channelPartnerId) = GetCurrentUserContext();
                
                var partner = await _context.ChannelPartners.FindAsync(partnerId);
                if (partner == null) return RedirectToAction("PartnerApproval");
                if (partner.Status == "Approved") return RedirectToAction("PartnerApproval");

                partner.Status = "Approved";
                partner.ApprovedBy = userId ?? 1;
                partner.ApprovedOn = DateTime.Now;

                var existingUser = await _context.Users.FirstOrDefaultAsync(u => u.Email == partner.Email);
                if (existingUser == null)
                {
                    var password = (partner.Email.Length >= 4 ? partner.Email.Substring(0, 4).ToUpper() : partner.Email.ToUpper()) + "@" + (partner.Phone.Length >= 4 ? partner.Phone.Substring(partner.Phone.Length - 4) : partner.Phone);
                    var user = new UserModel
                    {
                        Username = partner.ContactPerson,
                        Email = partner.Email,
                        Password = password,
                        Role = "Partner",
                        Phone = partner.Phone,
                        IsActive = true,
                        CreatedDate = DateTime.Now,
                        LastActivity = DateTime.Now,
                        ChannelPartnerId = partnerId
                    };
                    _context.Users.Add(user);
                    await _context.SaveChangesAsync();
                    partner.UserId = user.UserId;
                }

                await _context.SaveChangesAsync();

                var existingSubscription = await _context.PartnerSubscriptions.FirstOrDefaultAsync(ps => ps.ChannelPartnerId == partnerId);
                if (existingSubscription == null)
                {
                    var trialPlan = await _context.SubscriptionPlans.Where(p => p.IsActive).OrderBy(p => p.MonthlyPrice).FirstOrDefaultAsync();
                    if (trialPlan != null)
                    {
                        var trialSubscription = new PartnerSubscriptionModel
                        {
                            ChannelPartnerId = partnerId,
                            PlanId = trialPlan.PlanId,
                            BillingCycle = "Trial",
                            Amount = 0,
                            StartDate = DateTime.Now,
                            EndDate = DateTime.Now.AddDays(7),
                            Status = "Active",
                            PaymentMethod = "Trial",
                            PaymentTransactionId = $"trial_{DateTime.Now.Ticks}",
                            LastPaymentDate = DateTime.Now,
                            NextPaymentDate = DateTime.Now.AddDays(7),
                            AutoRenew = false,
                            CreatedOn = DateTime.Now,
                            UpdatedOn = DateTime.Now
                        };
                        _context.PartnerSubscriptions.Add(trialSubscription);
                        await _context.SaveChangesAsync();
                    }
                }

                await transaction.CommitAsync();
                return RedirectToAction("PartnerApproval");
            }
            catch
            {
                await transaction.RollbackAsync();
                return RedirectToAction("PartnerApproval");
            }
        }

        [HttpPost]
        [RoleAuthorize("Admin")]
        public async Task<IActionResult> RejectPartner(int partnerId)
        {
            var (userId, role, channelPartnerId) = GetCurrentUserContext();
            
            var partner = _context.ChannelPartners.Find(partnerId);
            if (partner != null)
            {
                partner.Status = "Rejected";
                partner.ApprovedBy = userId ?? 1;
                partner.ApprovedOn = DateTime.Now;
                await _context.SaveChangesAsync();
            }
            return RedirectToAction("PartnerApproval");
        }

        [HttpGet]
        [RoleAuthorize("Admin")]
        public async Task<IActionResult> GetPartner(int id)
        {
            var partner = await _context.ChannelPartners.FindAsync(id);
            if (partner == null)
                return Json(new { success = false, message = "Partner not found" });

            return Json(new
            {
                success = true,
                partnerId = partner.PartnerId,
                companyName = partner.CompanyName,
                contactPerson = partner.ContactPerson,
                email = partner.Email,
                phone = partner.Phone,
                address = partner.Address,
                commissionScheme = partner.CommissionScheme
            });
        }

        [HttpPost]
        [RoleAuthorize("Admin")]
        public async Task<IActionResult> UpdatePartner(int id, ChannelPartnerModel model, List<IFormFile> DocumentFiles)
        {
            try
            {
                var partner = await _context.ChannelPartners.FindAsync(id);
                if (partner == null)
                    return Json(new { success = false, message = "Partner not found" });

                partner.CompanyName = model.CompanyName;
                partner.ContactPerson = model.ContactPerson;
                partner.Email = model.Email;
                partner.Phone = model.Phone;
                partner.Address = model.Address;
                partner.CommissionScheme = model.CommissionScheme;

                if (DocumentFiles != null && DocumentFiles.Count > 0)
                {
                    await SavePartnerDocumentsAsync(partner.PartnerId, DocumentFiles);
                    partner.Documents = "Uploaded";
                }

                await _context.SaveChangesAsync();

                return Json(new { success = true, message = "Partner updated successfully!" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        // Permission Management Methods
        [HttpGet]
        public async Task<IActionResult> RolePermissions(string roleName)
        {
            if (string.IsNullOrEmpty(roleName))
                return BadRequest("Role name is required");

            var (userId, role, channelPartnerId) = GetCurrentUserContext();
            
            var modules = await _permissionService.GetModulesWithPagesAsync();
            var permissions = await _permissionService.GetPermissionsAsync();
            
            // Get existing role permissions with partner context
            var rolePermissions = new Dictionary<int, Dictionary<string, bool>>();
            foreach (var module in modules)
            {
                foreach (var page in module.Pages)
                {
                    var pagePermissions = await _permissionService.GetRolePermissionsAsync(roleName, page.PageId, channelPartnerId);
                    rolePermissions[page.PageId] = pagePermissions;
                }
            }

            ViewBag.RoleName = roleName;
            ViewBag.Modules = modules;
            ViewBag.Permissions = permissions;
            ViewBag.RolePermissions = rolePermissions;
            ViewBag.ChannelPartnerId = channelPartnerId;
            ViewBag.IsPartner = role?.ToLower() == "partner";
            
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> SaveRolePermissions()
        {
            try
            {
                var roleName = Request.Form["roleName"].ToString();
                if (string.IsNullOrEmpty(roleName))
                {
                    return Json(new { success = false, message = "Role name is required" });
                }

                // Parse permissions from form data
                var permissions = new Dictionary<int, Dictionary<int, bool>>();
                var debugInfo = new List<string>();
                
                foreach (var key in Request.Form.Keys)
                {
                    debugInfo.Add($"Key: {key}, Value: {Request.Form[key]}");
                    
                    if (key.StartsWith("permissions["))
                    {
                        // Extract pageId and permissionId from key like "permissions[1][2]"
                        var matches = System.Text.RegularExpressions.Regex.Match(key, @"permissions\[(\d+)\]\[(\d+)\]");
                        if (matches.Success)
                        {
                            var pageId = int.Parse(matches.Groups[1].Value);
                            var permissionId = int.Parse(matches.Groups[2].Value);
                            var isGranted = Request.Form[key].ToString().ToLower() == "true";
                            
                            if (!permissions.ContainsKey(pageId))
                                permissions[pageId] = new Dictionary<int, bool>();
                                
                            permissions[pageId][permissionId] = isGranted;
                        }
                    }
                }
                
                // Debug: Log what we parsed
                var permissionCount = permissions.Sum(p => p.Value.Count);
                
                if (permissionCount == 0)
                {
                    return Json(new { success = false, message = $"No permissions parsed. Debug: {string.Join(", ", debugInfo)}" });
                }
                
                var currentUser = GetCurrentUserContext();
                await _permissionService.SaveRolePermissionsAsync(roleName, permissions, currentUser.UserId?.ToString() ?? "System", currentUser.ChannelPartnerId);
                
                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    return Json(new { success = true, message = $"Permissions saved successfully! Processed {permissionCount} permissions." });
                    
                TempData["Success"] = "Permissions saved successfully!";
                return RedirectToAction("Roles");
            }
            catch (Exception ex)
            {
                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                    return Json(new { success = false, message = ex.Message });
                    
                TempData["Error"] = "Failed to save permissions: " + ex.Message;
                return RedirectToAction("Roles");
            }
        }

        [HttpGet]
        public IActionResult PartnerDetails(int id)
        {
            var (userId, role, channelPartnerId) = GetCurrentUserContext();
            
            // If id is 0, it's a direct admin agent viewing their own details
            if (id == 0)
            {
                return RedirectToAction("Index", "Profile");
            }
            
            // Admin can view any partner, Partner/Agent can only view their own
            if (role?.ToLower() != "admin" && channelPartnerId != id)
            {
                return RedirectToAction("AccessDenied", "Home");
            }
            
            var partner = _context.ChannelPartners
                .Select(p => new ChannelPartnerModel
                {
                    PartnerId = p.PartnerId,
                    CompanyName = p.CompanyName ?? "",
                    ContactPerson = p.ContactPerson ?? "",
                    Email = p.Email ?? "",
                    Phone = p.Phone ?? "",
                    Address = p.Address ?? "",
                    CommissionScheme = p.CommissionScheme ?? "",
                    Documents = p.Documents ?? "",
                    Status = p.Status ?? "Pending",
                    CreatedOn = p.CreatedOn,
                    ApprovedBy = p.ApprovedBy,
                    ApprovedOn = p.ApprovedOn,
                    UserId = p.UserId,
                    CommissionPercentage = p.CommissionPercentage,
                    SubscriptionPlan = p.SubscriptionPlan ?? "Basic"
                })
                .FirstOrDefault(p => p.PartnerId == id);
            
            if (partner == null)
            {
                return NotFound();
            }
            
            ViewBag.Documents = _context.ChannelPartnerDocuments
                .Where(d => d.ChannelPartnerId == id)
                .OrderByDescending(d => d.UploadedOn)
                .ToList();
            
            // Get lead statistics for this partner
            var totalLeads = _context.Leads.Count(l => l.ChannelPartnerId == id);
            var processingLeads = _context.Leads.Count(l => l.ChannelPartnerId == id && l.Status == "Processing");
            var convertedLeads = _context.Leads.Count(l => l.ChannelPartnerId == id && l.Status == "Converted");
            var closedLeads = _context.Leads.Count(l => l.ChannelPartnerId == id && l.Status == "Closed");
            
            ViewBag.TotalLeads = totalLeads;
            ViewBag.ProcessingLeads = processingLeads;
            ViewBag.ConvertedLeads = convertedLeads;
            ViewBag.ClosedLeads = closedLeads;
            ViewBag.IsAdmin = role?.ToLower() == "admin";
            
            return View(partner);
        }

        [HttpGet]
        [RoleAuthorize("Admin")]
        public IActionResult DownloadPartnerDocument(int documentId)
        {
            var document = _context.ChannelPartnerDocuments.Find(documentId);
            if (document == null)
            {
                return NotFound();
            }

            return File(document.FileContent, document.ContentType, document.FileName);
        }

        [HttpPost]
        [RoleAuthorize("Admin")]
        public async Task<IActionResult> UploadPartnerDocument(int partnerId, string documentName, string documentType, IFormFile documentFile)
        {
            if (documentFile == null || documentFile.Length == 0)
            {
                return BadRequest("No file uploaded");
            }

            var partner = await _context.ChannelPartners.FindAsync(partnerId);
            if (partner == null)
            {
                return NotFound("Partner not found");
            }

            // Check storage limits for partner
            var (canUpload, storageMessage, currentUsageGB, limitGB) = await _subscriptionService.CanUploadFileAsync(partnerId, documentFile.Length);
            if (!canUpload)
            {
                if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
                {
                    // Get available plans for upgrade options
                    var availablePlans = await _subscriptionService.GetAvailablePlansAsync();
                    return Json(new { 
                        success = false, 
                        storageLimitReached = true,
                        message = storageMessage,
                        currentUsageGB = currentUsageGB,
                        limitGB = limitGB,
                        availablePlans = availablePlans.Select(p => new {
                            planId = p.PlanId,
                            planName = p.PlanName,
                            monthlyPrice = p.MonthlyPrice,
                            yearlyPrice = p.YearlyPrice,
                            maxStorageGB = p.MaxStorageGB
                        }).ToList()
                    });
                }
                
                return BadRequest(storageMessage);
            }

            // Read file into byte array
            byte[] fileContent;
            using (var memoryStream = new MemoryStream())
            {
                await documentFile.CopyToAsync(memoryStream);
                fileContent = memoryStream.ToArray();
            }

            var document = new ChannelPartnerDocumentModel
            {
                ChannelPartnerId = partnerId,
                FileName = Path.GetFileName(documentFile.FileName),
                DocumentName = documentName ?? Path.GetFileName(documentFile.FileName),
                DocumentType = documentType ?? "General",
                FileContent = fileContent,
                FileSize = documentFile.Length,
                ContentType = documentFile.ContentType,
                UploadedOn = DateTime.Now
            };
            
            _context.ChannelPartnerDocuments.Add(document);
            await _context.SaveChangesAsync();

            if (Request.Headers["X-Requested-With"] == "XMLHttpRequest")
            {
                return Ok(new { success = true, message = "Document uploaded successfully" });
            }
            
            return RedirectToAction("PartnerDetails", new { id = partnerId });
        }

        // P0-D3: Partner Document Verification Endpoints
        [HttpPost]
        [RoleAuthorize("Admin")]
        public async Task<IActionResult> ApprovePartnerDocument(int documentId)
        {
            try
            {
                var (userId, role, channelPartnerId) = GetCurrentUserContext();
                if (!userId.HasValue)
                {
                    return Json(new { success = false, message = "User not authenticated" });
                }

                var document = await _context.ChannelPartnerDocuments.FindAsync(documentId);
                if (document == null)
                {
                    return Json(new { success = false, message = "Document not found" });
                }

                document.VerificationStatus = "Approved";
                document.VerifiedBy = userId.Value;
                document.VerifiedOn = DateTime.Now;
                document.RejectionReason = null;

                await _context.SaveChangesAsync();

                return Json(new { success = true, message = "Document approved successfully" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        [HttpPost]
        [RoleAuthorize("Admin")]
        public async Task<IActionResult> RejectPartnerDocument(int documentId, string reason)
        {
            try
            {
                var (userId, role, channelPartnerId) = GetCurrentUserContext();
                if (!userId.HasValue)
                {
                    return Json(new { success = false, message = "User not authenticated" });
                }

                if (string.IsNullOrWhiteSpace(reason))
                {
                    return Json(new { success = false, message = "Rejection reason is required" });
                }

                var document = await _context.ChannelPartnerDocuments.FindAsync(documentId);
                if (document == null)
                {
                    return Json(new { success = false, message = "Document not found" });
                }

                document.VerificationStatus = "Rejected";
                document.VerifiedBy = userId.Value;
                document.VerifiedOn = DateTime.Now;
                document.RejectionReason = reason;

                await _context.SaveChangesAsync();

                return Json(new { success = true, message = "Document rejected successfully" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }
        
        /// <summary>
        /// Sends welcome email with login credentials to the partner
        /// </summary>
        private async Task<bool> SendPartnerWelcomeEmailAsync(string email, string contactPerson, string username, string password, string planName, DateTime trialEndDate)
        {
            try
            {
                var from = _configuration["EmailSettings:From"];
                var pass = _configuration["EmailSettings:Password"];
                
                if (string.IsNullOrEmpty(from) || string.IsNullOrEmpty(pass))
                {
                    Console.WriteLine("Email settings not configured");
                    return false;
                }
                
                var companyName = _context.Settings.FirstOrDefault(s => s.SettingKey == "CompanyName")?.SettingValue ?? "Real Estate CRM";

                var mail = new MailMessage();
                mail.From = new MailAddress(from, companyName);
                mail.To.Add(email);
                mail.Subject = $"Welcome to {companyName} - Channel Partner Access Granted";
                mail.Body = $@"
                    <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                        <div style='background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; text-align: center;'>
                            <h1 style='color: white; margin: 0;'>Welcome to {companyName}!</h1>
                        </div>
                        
                        <div style='background: #f8f9fa; padding: 30px; border: 1px solid #dee2e6;'>
                            <h2 style='color: #333;'>Hello {contactPerson},</h2>
                            
                            <p style='color: #555; line-height: 1.6;'>
                                Congratulations! Your Channel Partner account has been successfully created. 
                                We're excited to have you as part of our network.
                            </p>
                            
                            <div style='background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #667eea;'>
                                <h3 style='color: #667eea; margin-top: 0;'>🎉 7-Day Free Trial Activated</h3>
                                <p style='color: #555; margin: 10px 0;'>
                                    <strong>Plan:</strong> {planName}<br/>
                                    <strong>Trial Period:</strong> {DateTime.Now:MMM dd, yyyy} - {trialEndDate:MMM dd, yyyy}<br/>
                                    <strong>Status:</strong> <span style='color: #28a745; font-weight: bold;'>Active</span>
                                </p>
                            </div>
                            
                            <div style='background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #28a745;'>
                                <h3 style='color: #28a745; margin-top: 0;'>🔐 Your Login Credentials</h3>
                                <p style='color: #555; margin: 10px 0;'>
                                    <strong>Username:</strong> {username}<br/>
                                    <strong>Password:</strong> <code style='background: #f8f9fa; padding: 4px 8px; border-radius: 4px; color: #e83e8c;'>{password}</code><br/>
                                    <strong>Login URL:</strong> <a href='https://localhost:44383/Account/Login' style='color: #667eea;'>Click here to login</a>
                                </p>
                            </div>
                            
                            <div style='background: #fff3cd; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #ffc107;'>
                                <p style='color: #856404; margin: 0;'>
                                    <strong>⚠️ Important:</strong> Please change your password after your first login for security purposes.
                                </p>
                            </div>
                            
                            <div style='margin: 30px 0; text-align: center;'>
                                <a href='https://localhost:44383/Account/Login' 
                                   style='display: inline-block; padding: 15px 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                                          color: white; text-decoration: none; border-radius: 5px; font-weight: bold;'>
                                    Access Your Dashboard
                                </a>
                            </div>
                            
                            <div style='background: white; padding: 20px; border-radius: 8px; margin: 20px 0;'>
                                <h3 style='color: #333; margin-top: 0;'>📋 What's Next?</h3>
                                <ol style='color: #555; line-height: 1.8;'>
                                    <li>Log in to your dashboard using the credentials above</li>
                                    <li>Complete your profile and upload necessary documents</li>
                                    <li>Explore the CRM features during your 7-day trial</li>
                                    <li>Start adding leads and tracking commissions</li>
                                    <li>Choose a subscription plan before trial expires</li>
                                </ol>
                            </div>
                            
                            <p style='color: #555; line-height: 1.6;'>
                                If you have any questions or need assistance, please don't hesitate to reach out to our support team.
                            </p>
                            
                            <p style='color: #555; line-height: 1.6;'>
                                Best regards,<br/>
                                <strong>{companyName} Team</strong>
                            </p>
                        </div>
                        
                        <div style='background: #343a40; padding: 20px; text-align: center; color: #adb5bd; font-size: 12px;'>
                            <p style='margin: 5px 0;'>© {DateTime.Now.Year} {companyName}. All rights reserved.</p>
                            <p style='margin: 5px 0;'>This is an automated email. Please do not reply.</p>
                        </div>
                    </div>
                ";
                mail.IsBodyHtml = true;

                using var smtp = new SmtpClient("smtp.gmail.com", 587)
                {
                    Credentials = new NetworkCredential(from, pass),
                    EnableSsl = true
                };
                
                await smtp.SendMailAsync(mail);
                return true;
            }
            catch (Exception ex)
            {
                // Log error but don't fail the partner creation
                Console.WriteLine($"Failed to send welcome email: {ex.Message}");
                return false;
            }
        }
    }
}
