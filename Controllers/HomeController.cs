using CRM.Models;
using CRM.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

public class ContactFormModel
{
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Subject { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}

namespace CRM.Controllers
{
    public class HomeController : Controller
    {
        [Authorize]
        public IActionResult TeamDashboard()
        {
            return View();
        }

        [Authorize]
        public IActionResult SalesOverview()
        {
            return View();
        }
        private readonly ILogger<HomeController> _logger;
        private readonly AppDbContext _context;
        private readonly INotificationService _notificationService;
        private readonly IWebHostEnvironment _env;
        private readonly Services.EmailService _emailService;

        public HomeController(ILogger<HomeController> logger, AppDbContext context, INotificationService notificationService, IWebHostEnvironment env, Services.EmailService emailService)
        {
            _logger = logger;
            _context = context;
            _notificationService = notificationService;
            _env = env;
            _emailService = emailService;
        }

        [Authorize]
        public IActionResult Index()
        {
            var role = User?.FindFirst(ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid ?? "0", out int userId);

            if (role?.ToLower() == "admin" || role?.ToLower() == "manager")
            {
                return View("AdminDashboard");
            }
            else if (role?.ToLower() == "partner")
            {
                return View("PartnerDashboard");
            }
            else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
            {
                return View("SalesDashboard");
            }
            
            return RedirectToAction("Landing");
        }

        [AllowAnonymous]
        public IActionResult Landing()
        {
            var settings = _context.Settings.Where(s => s.ChannelPartnerId == null).ToDictionary(s => s.SettingKey, s => s.SettingValue ?? "");
            
            // Get branding data
            var branding = _context.Branding.FirstOrDefault() ?? new BrandingModel();
            ViewBag.Branding = branding;
            
            var properties = _context.Properties
                .Where(p => p.IsActive == true)
                .Take(6)
                .ToList();
            
            var propertyData = properties.Select(p => {
                var flats = _context.PropertyFlats.Where(f => f.PropertyId == p.PropertyId).ToList();
                var availableFlats = flats.Count(f => f.Status == "Available");
                var prices = flats.Where(f => f.Price.HasValue).Select(f => f.Price.Value).ToList();
                var uploads = _context.PropertyUploads.Where(u => u.PropertyId == p.PropertyId).ToList();
                var imageIds = uploads.Select(u => u.UploadId).ToList();
                
#pragma warning disable CS8629
                return new {
                    p.PropertyId,
                    p.PropertyName,
                    p.Location,
                    p.Price,
                    p.AreaSqft,
                    p.PropertyImage,
                    p.CreatedOn,
                    p.Developer,
                    FlatsCount = flats.Count,
                    AvailableFlats = availableFlats,
                    MinPrice = prices.Any() ? prices.Min() : p.Price ?? 100000m,
                    MaxPrice = prices.Any() ? prices.Max() : p.Price ?? 500000m,
                    Images = imageIds
                };
#pragma warning restore CS8629
            }).ToList();
            
            ViewBag.Properties = propertyData;
            ViewBag.LeadsCount = _context.Leads.Count();
            ViewBag.ProjectsCount = _context.Properties.Where(p => p.IsActive).Count();
            return View("~/Views/Home/Landing.cshtml", settings);
        }

        [AllowAnonymous]
        public IActionResult ProjectDetails(int id)
        {
            var property = _context.Properties.FirstOrDefault(p => p.PropertyId == id && p.IsActive);
            if (property == null)
            {
                return NotFound();
            }
            
            var flats = _context.PropertyFlats.Where(f => f.PropertyId == id).ToList();
            var uploads = _context.PropertyUploads.Where(u => u.PropertyId == id).ToList();
            var settings = _context.Settings.Where(s => s.ChannelPartnerId == null).ToDictionary(s => s.SettingKey, s => s.SettingValue ?? "");
            
            // Get branding data
            var branding = _context.Branding.FirstOrDefault();
            ViewBag.CompanyLogo = branding?.CompanyLogo;
            
            var projectData = new {
                property.PropertyId,
                property.PropertyName,
                property.Location,
                property.Price,
                property.AreaSqft,
                property.Developer,
                property.CreatedOn,
                FlatsCount = flats.Count,
                AvailableFlats = flats.Where(f => f.Status == "Available").Count(),
                Images = uploads.Select(u => u.UploadId).ToList(),
                Flats = flats
            };
            
            ViewBag.Settings = settings;
            return View(projectData);
        }

        [AllowAnonymous]
        public IActionResult GetPropertyImage(int id)
        {
            var upload = _context.PropertyUploads.FirstOrDefault(u => u.UploadId == id);
            if (upload?.FileBytes != null)
            {
                return File(upload.FileBytes, upload.ContentType ?? "image/jpeg");
            }
            return NotFound();
        }

        [AllowAnonymous]
        [HttpPost]
        public async Task<IActionResult> SubmitInterest([FromForm] ProjectInterest model)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    _context.ProjectInterests.Add(model);
                    await _context.SaveChangesAsync();
                    return Json(new { success = true });
                }
                return Json(new { success = false, message = "Invalid data" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error submitting project interest");
                return Json(new { success = false, message = "Server error" });
            }
        }

        [AllowAnonymous]
        [HttpPost]
        public async Task<IActionResult> SendContactEmail([FromBody] ContactFormModel model)
        {
            try
            {
                if (string.IsNullOrEmpty(model.Name) || string.IsNullOrEmpty(model.Email) || string.IsNullOrEmpty(model.Message))
                {
                    return Json(new { success = false, message = "Please fill all required fields" });
                }

                var companyEmail = "maheswarim257@gmail.com";
                var companyName = _context.Settings.FirstOrDefault(s => s.SettingKey == "CompanyName")?.SettingValue ?? "CRM";
                
                var adminUser = _context.Users.FirstOrDefault(u => u.Role == "Admin");
                var (fromEmail, password) = adminUser != null ? await _emailService.GetEmailCredentials(adminUser.UserId) : (null, null);
                
                if (string.IsNullOrEmpty(fromEmail) || string.IsNullOrEmpty(password))
                {
                    return Json(new { success = false, message = "Email settings not configured" });
                }

                // Create email body
                var emailBody = $@"
                    <h3>New Contact Form Submission</h3>
                    <p><strong>Name:</strong> {model.Name}</p>
                    <p><strong>Email:</strong> {model.Email}</p>
                    <p><strong>Subject:</strong> {model.Subject}</p>
                    <p><strong>Message:</strong></p>
                    <p>{model.Message.Replace("\n", "<br/>")}</p>
                    <hr/>
                    <p><small>This message was sent from the contact form on {companyName} website.</small></p>
                ";

                // Send email using SMTP
                using (var client = new System.Net.Mail.SmtpClient("smtp.gmail.com", 587))
                {
                    client.EnableSsl = true;
                    client.Credentials = new System.Net.NetworkCredential(fromEmail, password);
                    
                    var mailMessage = new System.Net.Mail.MailMessage
                    {
                        From = new System.Net.Mail.MailAddress(fromEmail, $"{companyName} Contact Form"),
                        Subject = $"Contact Form: {model.Subject}",
                        Body = emailBody,
                        IsBodyHtml = true
                    };
                    
                    mailMessage.To.Add(companyEmail);
                    mailMessage.ReplyToList.Add(new System.Net.Mail.MailAddress(model.Email, model.Name));
                    
                    await client.SendMailAsync(mailMessage);
                }

                _logger.LogInformation($"Contact form email sent from {model.Name} ({model.Email}): {model.Subject}");
                return Json(new { success = true, message = "Thank you for your message. We will get back to you soon!" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error sending contact email: {Error}", ex.Message);
                return Json(new { success = false, message = "Error sending message. Please try again." });
            }
        }

        [Authorize]
        public IActionResult Privacy()
        {
            var branding = _context.Branding.FirstOrDefault() ?? new BrandingModel();
            var settings = _context.Settings.Where(s => s.ChannelPartnerId == null).ToDictionary(s => s.SettingKey, s => s.SettingValue ?? "");
            ViewBag.Branding = branding;
            ViewBag.Settings = settings;
            return View();
        }

        [Authorize]
        public IActionResult Support()
        {
            var branding = _context.Branding.FirstOrDefault() ?? new BrandingModel();
            var settings = _context.Settings.Where(s => s.ChannelPartnerId == null).ToDictionary(s => s.SettingKey, s => s.SettingValue ?? "");
            ViewBag.Branding = branding;
            ViewBag.Settings = settings;
            return View();
        }

        [Authorize]
        public IActionResult HelpCenter()
        {
            var branding = _context.Branding.FirstOrDefault() ?? new BrandingModel();
            var settings = _context.Settings.Where(s => s.ChannelPartnerId == null).ToDictionary(s => s.SettingKey, s => s.SettingValue ?? "");
            ViewBag.Branding = branding;
            ViewBag.Settings = settings;
            return View();
        }

        [Authorize]
        public IActionResult Terms()
        {
            var branding = _context.Branding.FirstOrDefault() ?? new BrandingModel();
            var settings = _context.Settings.Where(s => s.ChannelPartnerId == null).ToDictionary(s => s.SettingKey, s => s.SettingValue ?? "");
            ViewBag.Branding = branding;
            ViewBag.Settings = settings;
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        public IActionResult AccessDenied()
        {
            return View();
        }

        [Authorize]
        public IActionResult DebugClaims()
        {
            // Only allow in development environment
            if (!_env.IsDevelopment())
            {
                return NotFound();
            }
            
            // Only allow Admin users
            if (!User.IsInRole("Admin"))
            {
                return Forbid();
            }
            
            return View("~/Views/Shared/DebugClaims.cshtml");
        }
            [HttpGet]
            [Authorize]
            public async Task<IActionResult> GetAdminNotifications()
            {
                try
                {
                    // Get current user ID from claims (using "UserId" custom claim, not ClaimTypes.NameIdentifier)
                    var userIdClaim = User.FindFirst("UserId")?.Value;
                    var userRoleClaim = User.FindFirst(ClaimTypes.Role)?.Value;
                    
                    _logger.LogInformation($"Claims - UserId: {userIdClaim}, Role: {userRoleClaim}");
                    
                    if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                    {
                        _logger.LogWarning("GetAdminNotifications called without valid user ID");
                        return Json(new List<object>());
                    }

                    // Get user role
                    var userRole = User.FindFirst(ClaimTypes.Role)?.Value ?? "Agent";

                    _logger.LogInformation($"Loading notifications for UserId={userId}, Role={userRole}");

                    // Get notifications using the service
                    var notifications = await _notificationService.GetUserNotificationsAsync(userId, userRole);

                    _logger.LogInformation($"Found {notifications.Count} notifications for UserId={userId}");

                    var result = notifications.Select(n => new {
                        n.NotificationId,
                        n.Title,
                        n.Message,
                        n.Type,
                        n.Priority,
                        CreatedOn = n.CreatedOn.ToString("MMM dd, yyyy hh:mm tt"),
                        n.Link,
                        n.RelatedEntityId,
                        n.RelatedEntityType
                    }).ToList();

                    return Json(result);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error loading notifications");
                    return Json(new List<object>());
                }
            }

            [HttpPost]
            [Authorize]
            public async Task<IActionResult> MarkNotificationRead(int notificationId)
            {
                try
                {
                    await _notificationService.MarkAsReadAsync(notificationId);
                    return Json(new { success = true });
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error marking notification as read");
                    return Json(new { success = false, message = ex.Message });
                }
            }

            [HttpPost]
            [Authorize]
            public async Task<IActionResult> MarkAllNotificationsRead()
            {
                try
                {
                    var userIdClaim = User.FindFirst("UserId")?.Value;
                    if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                    {
                        return Json(new { success = false, message = "User not found" });
                    }

                    await _notificationService.MarkAllAsReadAsync(userId);
                    return Json(new { success = true });
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error marking all notifications as read");
                    return Json(new { success = false, message = ex.Message });
                }
            }

            [HttpGet]
            [Authorize]
            public IActionResult GetDashboardData()
            {
                var role = User?.FindFirst(ClaimTypes.Role)?.Value;
                var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                int.TryParse(uid ?? "0", out int userId);
                var currentUser = _context.Users.FirstOrDefault(u => u.UserId == userId);
                var channelPartnerId = currentUser?.ChannelPartnerId;

                var query = _context.Leads.AsQueryable();
                if (role?.ToLower() == "partner")
                    query = query.Where(l => l.ChannelPartnerId == channelPartnerId);
                else if (role?.ToLower() == "admin")
                    query = query.Where(l => l.ChannelPartnerId == null);
                else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                    query = query.Where(l => l.ExecutiveId == userId);

                var totalLeads = query.Count();
                var facebookLeads = query.Count(l => l.Source == "Facebook Webhook" || l.Source == "Facebook API");
                
                var monthlyLeads = Enumerable.Range(0, 6).Select(i =>
                {
                    var date = DateTime.Now.AddMonths(-i);
                    var count = query.Count(l => l.CreatedOn.Month == date.Month && l.CreatedOn.Year == date.Year);
                    return new { month = date.ToString("MMM"), count };
                }).Reverse().ToList();

                var sources = query.GroupBy(l => l.Source ?? "Unknown")
                    .Select(g => new { source = g.Key, count = g.Count() })
                    .OrderByDescending(x => x.count)
                    .ToList();

                var stages = new[] { "New", "Office Meeting", "Site Visit Requested", "Site Visit Done", "Quotation", "Quotation Sent", "Negotiation", "Booked" };
                var pipeline = stages.Select(stage => new { stage, count = query.Count(l => l.Stage == stage) }).ToList();

                var newLeads = query.OrderByDescending(l => l.CreatedOn).Take(5)
                    .Select(l => new { l.LeadId, l.Name, l.Contact, l.Stage, CreatedOn = l.CreatedOn.ToString("MMM dd, yyyy") }).ToList();

                var bookingsQuery = _context.Bookings.AsQueryable();
                var paymentsQuery = _context.Payments.AsQueryable();
                var expensesQuery = _context.Expenses.AsQueryable();
                
                if (role?.ToLower() == "partner")
                {
                    var partnerLeadIds = _context.Leads.Where(l => l.ChannelPartnerId == channelPartnerId).Select(l => l.LeadId).ToList();
                    bookingsQuery = bookingsQuery.Where(b => partnerLeadIds.Contains(b.LeadId));
                    var partnerBookingIds = bookingsQuery.Select(b => b.BookingId).ToList();
                    paymentsQuery = paymentsQuery.Where(p => partnerBookingIds.Contains(p.BookingId));
                    expensesQuery = expensesQuery.Where(e => e.ChannelPartnerId == channelPartnerId);
                }
                else if (role?.ToLower() == "admin")
                {
                    var adminLeadIds = _context.Leads.Where(l => l.ChannelPartnerId == null || l.HandoverStatus == "ReadyToBook" || l.HandoverStatus == "HandedOver").Select(l => l.LeadId).ToList();
                    bookingsQuery = bookingsQuery.Where(b => adminLeadIds.Contains(b.LeadId));
                    var adminBookingIds = bookingsQuery.Select(b => b.BookingId).ToList();
                    paymentsQuery = paymentsQuery.Where(p => adminBookingIds.Contains(p.BookingId));
                    expensesQuery = expensesQuery.Where(e => e.ChannelPartnerId == null);
                }
                else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                {
                    var myLeadIds = query.Select(l => l.LeadId).ToList();
                    bookingsQuery = bookingsQuery.Where(b => myLeadIds.Contains(b.LeadId));
                    var myBookingIds = bookingsQuery.Select(b => b.BookingId).ToList();
                    paymentsQuery = paymentsQuery.Where(p => myBookingIds.Contains(p.BookingId));
                }
                
                var totalRevenue = paymentsQuery.Sum(p => (decimal?)p.Amount) ?? 0;
                var totalExpenses = expensesQuery.Sum(e => (decimal?)e.Amount) ?? 0;
                var totalProfit = totalRevenue - totalExpenses;

                var revenueExpenses = Enumerable.Range(0, 6).Select(i =>
                {
                    var date = DateTime.Now.AddMonths(-i);
                    var revenue = paymentsQuery.Where(p => p.PaymentDate.Month == date.Month && p.PaymentDate.Year == date.Year).Sum(p => (decimal?)p.Amount) ?? 0;
                    var expenses = expensesQuery.Where(e => e.Date.Month == date.Month && e.Date.Year == date.Year).Sum(e => (decimal?)e.Amount) ?? 0;
                    return new { month = date.ToString("MMM"), revenue, expenses };
                }).Reverse().ToList();

                var recentTransactions = paymentsQuery.OrderByDescending(p => p.PaymentDate).Take(5)
                    .Select(p => new { p.PaymentId, p.Amount, PaymentDate = p.PaymentDate.ToString("MMM dd, yyyy"), p.PaymentMethod }).ToList();

                return Json(new { totalLeads, facebookLeads, monthlyLeads, sources, pipeline, newLeads, totalRevenue, totalExpenses, totalProfit, revenueExpenses, recentTransactions });
            }

            [HttpGet]
            [Authorize]
            public IActionResult GetSalesDashboardData()
            {
                var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                int.TryParse(uid ?? "0", out int userId);

                var myLeads = _context.Leads.Where(l => l.ExecutiveId == userId);
                var myLeadIds = myLeads.Select(l => l.LeadId).ToList();
                var myBookings = _context.Bookings.Where(b => myLeadIds.Contains(b.LeadId));
                var myBookingIds = myBookings.Select(b => b.BookingId).ToList();
                var myPayments = _context.Payments.Where(p => myBookingIds.Contains(p.BookingId));
                
                var totalEarning = myPayments.Sum(p => (decimal?)p.Amount) ?? 0;
                var totalExpenses = 0m;
                var totalProfit = totalEarning;

                var salesReport = Enumerable.Range(0, 6).Select(i =>
                {
                    var date = DateTime.Now.AddMonths(-i);
                    var sales = myBookings.Count(b => b.CreatedOn.Month == date.Month && b.CreatedOn.Year == date.Year);
                    return new { month = date.ToString("MMM"), sales };
                }).Reverse().ToList();

                var recentBookings = myBookings.OrderByDescending(b => b.CreatedOn).Take(5)
                    .Select(b => new { b.BookingId, b.BookingAmount, b.Status, CreatedOn = b.CreatedOn.ToString("MMM dd, yyyy") }).ToList();

                var paidCount = myBookings.Count(b => b.Status == "Paid");
                var pendingCount = myBookings.Count(b => b.Status == "Pending");
                var overdueCount = myBookings.Count(b => b.Status == "Overdue");

                return Json(new { totalEarning, totalExpenses, totalProfit, salesReport, recentBookings, salesStatus = new { paidCount, pendingCount, overdueCount } });
            }

            [HttpGet]
            [Authorize]
            public IActionResult GetTeamDashboardData()
            {
                var role = User?.FindFirst(ClaimTypes.Role)?.Value;
                var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                int.TryParse(uid ?? "0", out int userId);
                var currentUser = _context.Users.FirstOrDefault(u => u.UserId == userId);
                var channelPartnerId = currentUser?.ChannelPartnerId;

                var usersQuery = _context.Users.Where(u => u.Role == "Sales" || u.Role == "Agent");
                if (role?.ToLower() == "partner")
                    usersQuery = usersQuery.Where(u => u.ChannelPartnerId == channelPartnerId);
                else if (role?.ToLower() == "admin")
                    usersQuery = usersQuery.Where(u => u.ChannelPartnerId == null);

                var totalTeamMembers = usersQuery.Count();
                var newTeamMembers = usersQuery.Count(u => u.CreatedDate >= DateTime.Now.AddDays(-7));

                var teamPerformance = usersQuery
                    .Select(u => new { u.UserId, u.Username, leadsCount = _context.Leads.Count(l => l.ExecutiveId == u.UserId), bookingsCount = _context.Bookings.Count(b => _context.Leads.Any(l => l.LeadId == b.LeadId && l.ExecutiveId == u.UserId)) })
                    .OrderByDescending(x => x.bookingsCount).Take(10).ToList();

                var topPerformers = teamPerformance.Take(5).ToList();

                return Json(new { totalTeamMembers, newTeamMembers, teamPerformance, topPerformers });
            }

            [HttpGet]
            [Authorize]
            public IActionResult GetAllLeads()
            {
                var role = User?.FindFirst(ClaimTypes.Role)?.Value;
                var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                int.TryParse(uid ?? "0", out int userId);
                var currentUser = _context.Users.FirstOrDefault(u => u.UserId == userId);
                var channelPartnerId = currentUser?.ChannelPartnerId;

                var query = _context.Leads.AsQueryable();
                if (role?.ToLower() == "partner")
                    query = query.Where(l => l.ChannelPartnerId == channelPartnerId);
                else if (role?.ToLower() == "admin")
                    query = query.Where(l => l.ChannelPartnerId == null);
                else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                    query = query.Where(l => l.ExecutiveId == userId);

                var allLeads = query.OrderByDescending(l => l.CreatedOn)
                    .Select(l => new { l.LeadId, l.Name, l.Contact, l.Stage, CreatedOn = l.CreatedOn.ToString("MMM dd, yyyy") })
                    .ToList();

                return Json(allLeads);
            }

            [HttpGet]
            [Authorize]
            public IActionResult GetAllTransactions()
            {
                var role = User?.FindFirst(ClaimTypes.Role)?.Value;
                var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                int.TryParse(uid ?? "0", out int userId);
                var currentUser = _context.Users.FirstOrDefault(u => u.UserId == userId);
                var channelPartnerId = currentUser?.ChannelPartnerId;

                var paymentsQuery = _context.Payments.AsQueryable();
                
                if (role?.ToLower() == "partner")
                {
                    var partnerLeadIds = _context.Leads.Where(l => l.ChannelPartnerId == channelPartnerId).Select(l => l.LeadId).ToList();
                    var partnerBookingIds = _context.Bookings.Where(b => partnerLeadIds.Contains(b.LeadId)).Select(b => b.BookingId).ToList();
                    paymentsQuery = paymentsQuery.Where(p => partnerBookingIds.Contains(p.BookingId));
                }
                else if (role?.ToLower() == "admin")
                {
                    var adminLeadIds = _context.Leads.Where(l => l.ChannelPartnerId == null || l.HandoverStatus == "ReadyToBook" || l.HandoverStatus == "HandedOver").Select(l => l.LeadId).ToList();
                    var adminBookingIds = _context.Bookings.Where(b => adminLeadIds.Contains(b.LeadId)).Select(b => b.BookingId).ToList();
                    paymentsQuery = paymentsQuery.Where(p => adminBookingIds.Contains(p.BookingId));
                }
                else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                {
                    var myLeadIds = _context.Leads.Where(l => l.ExecutiveId == userId).Select(l => l.LeadId).ToList();
                    var myBookingIds = _context.Bookings.Where(b => myLeadIds.Contains(b.LeadId)).Select(b => b.BookingId).ToList();
                    paymentsQuery = paymentsQuery.Where(p => myBookingIds.Contains(p.BookingId));
                }

                var allTransactions = paymentsQuery.OrderByDescending(p => p.PaymentDate)
                    .Select(p => new { p.PaymentId, p.Amount, PaymentDate = p.PaymentDate.ToString("MMM dd, yyyy"), p.PaymentMethod })
                    .ToList();

                return Json(allTransactions);
            }

            [HttpGet]
            [Authorize]
            public IActionResult GetSalesOverviewData()
            {
                try
                {
                    var role = User?.FindFirst(ClaimTypes.Role)?.Value;
                    var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    int.TryParse(uid ?? "0", out int userId);
                    var currentUser = _context.Users.FirstOrDefault(u => u.UserId == userId);
                    var channelPartnerId = currentUser?.ChannelPartnerId;
                    var isPartner = role != null && role.ToLower() == "partner";

                var allBookings = _context.Bookings.AsQueryable();
                var paymentsQuery = _context.Payments.AsQueryable();
                var expensesQuery = _context.Expenses.AsQueryable();
                
                if (role?.ToLower() == "partner")
                {
                    var partnerLeadIds = _context.Leads.Where(l => l.ChannelPartnerId == channelPartnerId).Select(l => l.LeadId).ToList();
                    allBookings = allBookings.Where(b => partnerLeadIds.Contains(b.LeadId));
                    var partnerBookingIds = allBookings.Select(b => b.BookingId).ToList();
                    paymentsQuery = paymentsQuery.Where(p => partnerBookingIds.Contains(p.BookingId));
                    expensesQuery = expensesQuery.Where(e => e.ChannelPartnerId == channelPartnerId);
                }
                else if (role?.ToLower() == "admin")
                {
                    var adminLeadIds = _context.Leads.Where(l => l.ChannelPartnerId == null || l.HandoverStatus == "ReadyToBook" || l.HandoverStatus == "HandedOver").Select(l => l.LeadId).ToList();
                    allBookings = allBookings.Where(b => adminLeadIds.Contains(b.LeadId));
                    var adminBookingIds = allBookings.Select(b => b.BookingId).ToList();
                    paymentsQuery = paymentsQuery.Where(p => adminBookingIds.Contains(p.BookingId));
                    expensesQuery = expensesQuery.Where(e => e.ChannelPartnerId == null);
                }
                else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                {
                    var myLeadIds = _context.Leads.Where(l => l.ExecutiveId == userId).Select(l => l.LeadId).ToList();
                    allBookings = allBookings.Where(b => myLeadIds.Contains(b.LeadId));
                    var myBookingIds = allBookings.Select(b => b.BookingId).ToList();
                    paymentsQuery = paymentsQuery.Where(p => myBookingIds.Contains(p.BookingId));
                }
                
                decimal totalEarning;
                if (isPartner)
                {
                    totalEarning = allBookings.Sum(b => (decimal?)(b.BookingAmount * 0.05m)) ?? 0;
                }
                else
                {
                    totalEarning = paymentsQuery.Sum(p => (decimal?)p.Amount) ?? 0;
                }
                var totalExpenses = expensesQuery.Sum(e => (decimal?)e.Amount) ?? 0;
                var totalProfit = totalEarning - totalExpenses;

                var salesReport = Enumerable.Range(0, 6).Select(i =>
                {
                    var date = DateTime.Now.AddMonths(-i);
                    if (isPartner)
                    {
                        var monthlyCommission = allBookings
                            .Where(b => b.CreatedOn.Month == date.Month && b.CreatedOn.Year == date.Year)
                            .Sum(b => (decimal?)(b.BookingAmount * 0.05m)) ?? 0;
                        return new { month = date.ToString("MMM"), sales = (int)monthlyCommission };
                    }
                    else
                    {
                        var sales = allBookings.Count(b => b.CreatedOn.Month == date.Month && b.CreatedOn.Year == date.Year);
                        return new { month = date.ToString("MMM"), sales };
                    }
                }).Reverse().ToList();

                var recentBookings = allBookings.OrderByDescending(b => b.CreatedOn).Take(5)
                    .Select(b => new { 
                        b.BookingId, 
                        BookingAmount = isPartner ? (b.BookingAmount * 0.05m) : b.BookingAmount,
                        b.Status, 
                        CreatedOn = b.CreatedOn.ToString("MMM dd, yyyy") 
                    }).ToList();

                var paidCount = allBookings.Count(b => b.Status == "Paid");
                var pendingCount = allBookings.Count(b => b.Status == "Pending");
                var overdueCount = allBookings.Count(b => b.Status == "Overdue");

                return Json(new { totalEarning, totalExpenses, totalProfit, salesReport, recentBookings, salesStatus = new { paidCount, pendingCount, overdueCount } });
                }
                catch (Exception ex)
                {
                    return Json(new { error = ex.Message });
                }
            }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetPartnerSubscriptionStatus()
        {
            try
            {
                var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!int.TryParse(uid, out int userId))
                    return Json(new { hasSubscription = false });

                var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
                if (user?.ChannelPartnerId == null)
                    return Json(new { hasSubscription = false });

                var subscription = await _context.PartnerSubscriptions
                    .Include(s => s.Plan)
                    .Where(s => s.ChannelPartnerId == user.ChannelPartnerId && s.Status == "Active")
                    .FirstOrDefaultAsync();

                if (subscription == null)
                    return Json(new { hasSubscription = false });

                var daysUntilExpiry = (subscription.EndDate - DateTime.Now).Days;

                return Json(new
                {
                    hasSubscription = true,
                    planName = subscription.Plan?.PlanName,
                    billingCycle = subscription.BillingCycle,
                    amount = subscription.Amount,
                    startDate = subscription.StartDate.ToString("yyyy-MM-dd"),
                    endDate = subscription.EndDate.ToString("yyyy-MM-dd"),
                    daysUntilExpiry = daysUntilExpiry,
                    isTrial = subscription.BillingCycle == "Trial"
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting partner subscription status");
                return Json(new { hasSubscription = false, error = ex.Message });
            }
        }
    }
}
