using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using CRM.Models;

namespace CRM.Controllers
{
    [Authorize]
    public class SearchController : Controller
    {
        private readonly AppDbContext _context;

        public SearchController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GlobalSearch(string query)
        {
            if (string.IsNullOrWhiteSpace(query) || query.Length < 2)
                return Json(new { success = false, message = "Query too short" });

            var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            var role = User.FindFirst(ClaimTypes.Role)?.Value ?? "";
            var channelPartnerId = _context.Users.FirstOrDefault(u => u.UserId == userId)?.ChannelPartnerId;

            var results = new List<SearchResult>();
            query = query.ToLower();

            // Search Sidebar Menu Items/Pages
            var menuItems = new List<SearchResult>();
            // Dashboard
            if (query.Contains("dash")) menuItems.Add(new SearchResult { Title = "Dashboard", Subtitle = "Main Dashboard", Type = "Page", Icon = "home", Url = "/Home/Index" });
            if (query.Contains("sales") || query.Contains("overview")) menuItems.Add(new SearchResult { Title = "Sales Overview", Subtitle = "Dashboard - Sales Overview", Type = "Page", Icon = "trending-up", Url = "/Home/SalesOverview" });
            if (query.Contains("team")) menuItems.Add(new SearchResult { Title = "Team Dashboard", Subtitle = "Dashboard - Team Performance", Type = "Page", Icon = "users", Url = "/Home/TeamDashboard" });
            if (query.Contains("milestone") || query.Contains("track")) menuItems.Add(new SearchResult { Title = "Milestone Payment Tracking", Subtitle = "Dashboard - Milestones", Type = "Page", Icon = "check-square", Url = "/MilestoneTracking/Index" });
            
            // Leads & Properties
            if (query.Contains("lead")) menuItems.Add(new SearchResult { Title = "Leads", Subtitle = "Manage Leads", Type = "Page", Icon = "users", Url = "/Leads/Index" });
            if (query.Contains("pipe") || query.Contains("sales")) menuItems.Add(new SearchResult { Title = "Sales Pipeline", Subtitle = "Leads - Pipeline View", Type = "Page", Icon = "trello", Url = "/SalesPipelines/Index" });
            if (query.Contains("task")) menuItems.Add(new SearchResult { Title = "Tasks", Subtitle = "Leads - Task Management", Type = "Page", Icon = "calendar", Url = "/Tasks/Index" });
            if (query.Contains("unassign") || query.Contains("webhook")) menuItems.Add(new SearchResult { Title = "Unassigned Leads", Subtitle = "Leads - Unassigned", Type = "Page", Icon = "user-plus", Url = "/WebhookLeads/Index" });
            if (query.Contains("prop")) menuItems.Add(new SearchResult { Title = "Properties", Subtitle = "Property Management", Type = "Page", Icon = "home", Url = "/Properties/Index" });
            
            // Sales
            if (query.Contains("quot")) menuItems.Add(new SearchResult { Title = "Quotations", Subtitle = "Sales - Quotations", Type = "Page", Icon = "file-text", Url = "/Quotations/Index" });
            if (query.Contains("book")) menuItems.Add(new SearchResult { Title = "Bookings", Subtitle = "Sales - Bookings", Type = "Page", Icon = "book-open", Url = "/Bookings/Index" });
            if (query.Contains("invo")) menuItems.Add(new SearchResult { Title = "Invoices", Subtitle = "Sales - Invoices", Type = "Page", Icon = "file-text", Url = "/Invoices/Index" });
            if (query.Contains("pay")) menuItems.Add(new SearchResult { Title = "Payments", Subtitle = "Sales - Payments", Type = "Page", Icon = "credit-card", Url = "/Payments/Index" });
            
            // Finance
            if (query.Contains("fin") || query.Contains("finance")) menuItems.Add(new SearchResult { Title = "Finance", Subtitle = "Financial Management", Type = "Page", Icon = "dollar-sign", Url = "/Expenses/Index" });
            if (query.Contains("exp")) menuItems.Add(new SearchResult { Title = "Expenses", Subtitle = "Finance - Expenses", Type = "Page", Icon = "minus-circle", Url = "/Expenses/Index" });
            if (query.Contains("rev")) menuItems.Add(new SearchResult { Title = "Revenue", Subtitle = "Finance - Revenue", Type = "Page", Icon = "plus-circle", Url = "/Revenue/Index" });
            if (query.Contains("prof")) menuItems.Add(new SearchResult { Title = "Profit", Subtitle = "Finance - Profit", Type = "Page", Icon = "trending-up", Url = "/Profit/Index" });
            
            // Team Management
            if (query.Contains("age")) menuItems.Add(new SearchResult { Title = "Agent List", Subtitle = "Team - Agents", Type = "Page", Icon = "user", Url = "/Agent/List" });
            if (query.Contains("channel") || query.Contains("partner")) menuItems.Add(new SearchResult { Title = "Channel Partners", Subtitle = "Team - Partners", Type = "Page", Icon = "briefcase", Url = "/ManageUsers/PartnerApproval" });
            
            // Attendance
            if (query.Contains("att") || query.Contains("my")) menuItems.Add(new SearchResult { Title = "My Attendance", Subtitle = "Attendance - Personal", Type = "Page", Icon = "calendar", Url = "/Attendance/Calendar" });
            if (query.Contains("agent") && query.Contains("att")) menuItems.Add(new SearchResult { Title = "Agent Attendance", Subtitle = "Attendance - Team", Type = "Page", Icon = "user-check", Url = "/Attendance/AgentList" });
            
            // Payouts
            if (query.Contains("payout") || query.Contains("agent")) menuItems.Add(new SearchResult { Title = "Agent Payouts", Subtitle = "Payouts - Agents", Type = "Page", Icon = "credit-card", Url = "/AgentPayout/Index" });
            if (query.Contains("partner") || query.Contains("commission")) menuItems.Add(new SearchResult { Title = "Partner Payouts", Subtitle = "Payouts - Partners", Type = "Page", Icon = "briefcase", Url = "/PartnerCommission/Index" });
            
            // User Management
            if (query.Contains("user")) menuItems.Add(new SearchResult { Title = "Manage Users", Subtitle = "User Management", Type = "Page", Icon = "users", Url = "/ManageUsers/Index" });
            if (query.Contains("role")) menuItems.Add(new SearchResult { Title = "Roles Management", Subtitle = "User - Roles", Type = "Page", Icon = "shield", Url = "/ManageUsers/Roles" });
            
            // Settings
            if (query.Contains("sett")) menuItems.Add(new SearchResult { Title = "System Settings", Subtitle = "Settings", Type = "Page", Icon = "settings", Url = "/Settings/Index" });
            if (query.Contains("brand")) menuItems.Add(new SearchResult { Title = "Branding", Subtitle = "Settings - Branding", Type = "Page", Icon = "image", Url = "/Settings/Branding" });
            if (query.Contains("imper")) menuItems.Add(new SearchResult { Title = "Impersonation", Subtitle = "Settings - User Impersonation", Type = "Page", Icon = "user-check", Url = "/Settings/Impersonation" });
            if (query.Contains("prof")) menuItems.Add(new SearchResult { Title = "My Profile", Subtitle = "User Profile", Type = "Page", Icon = "user", Url = "/Profile/Index" });
            
            // Subscriptions
            if (query.Contains("sub") || query.Contains("plan")) menuItems.Add(new SearchResult { Title = "Subscriptions", Subtitle = "Subscription Plans", Type = "Page", Icon = "credit-card", Url = role == "Admin" ? "/Subscription/Plans" : "/Subscription/MyPlan" });
            if (query.Contains("my") && query.Contains("plan")) menuItems.Add(new SearchResult { Title = "My Plan", Subtitle = "Subscriptions - Current Plan", Type = "Page", Icon = "star", Url = "/Subscription/MyPlan" });
            if (query.Contains("trans")) menuItems.Add(new SearchResult { Title = "Transactions", Subtitle = "Payment Transactions", Type = "Page", Icon = "credit-card", Url = role == "Admin" ? "/RazorpayTransactions/Index" : "/PartnerTransactions/Index" });
            if (query.Contains("refund") || query.Contains("pending")) menuItems.Add(new SearchResult { Title = "Pending Refunds", Subtitle = "Subscriptions - Refunds", Type = "Page", Icon = "dollar-sign", Url = "/Subscription/PendingRefunds" });
            
            // Financial Settings
            if (query.Contains("gateway")) menuItems.Add(new SearchResult { Title = "Payment Gateways", Subtitle = "Financial Settings", Type = "Page", Icon = "credit-card", Url = "/Financial/PaymentGateways" });
            if (query.Contains("bank")) menuItems.Add(new SearchResult { Title = "Bank Accounts", Subtitle = "Financial Settings", Type = "Page", Icon = "home", Url = "/Financial/BankAccounts" });
            
            results.AddRange(menuItems);

            // Search Leads
            var leads = await _context.Leads
                .Where(l => (role == "Admin" || l.ExecutiveId == userId || l.ChannelPartnerId == channelPartnerId) &&
                           (l.Name.ToLower().Contains(query) || l.Contact.Contains(query) || l.Email.ToLower().Contains(query)))
                .Take(5)
                .Select(l => new SearchResult
                {
                    Id = l.LeadId,
                    Title = l.Name,
                    Subtitle = l.Contact + " - " + l.Stage,
                    Type = "Lead",
                    Icon = "users",
                    Url = "/Leads/Details/" + l.LeadId
                }).ToListAsync();
            results.AddRange(leads);

            // Search Properties
            var properties = await _context.Properties
                .Where(p => (role == "Admin" || p.AssignedTo == userId) &&
                           (p.PropertyName.ToLower().Contains(query) || p.Location.ToLower().Contains(query)))
                .Take(5)
                .Select(p => new SearchResult
                {
                    Id = p.PropertyId,
                    Title = p.PropertyName,
                    Subtitle = p.Location + " - " + p.PurchaseType,
                    Type = "Property",
                    Icon = "home",
                    Url = "/Properties/Details/" + p.PropertyId
                }).ToListAsync();
            results.AddRange(properties);

            // Search Agents
            if (role == "Admin" || role == "Manager" || role == "Partner")
            {
                var agents = await _context.Agents
                    .Where(a => (role == "Admin" || a.ChannelPartnerId == channelPartnerId) &&
                               (a.FullName.ToLower().Contains(query) || a.Phone.Contains(query) || a.Email.ToLower().Contains(query)))
                    .Take(5)
                    .Select(a => new SearchResult
                    {
                        Id = a.AgentId,
                        Title = a.FullName,
                        Subtitle = a.Phone + " - " + a.AgentType,
                        Type = "Agent",
                        Icon = "user",
                        Url = "/Agent/Details/" + a.AgentId
                    }).ToListAsync();
                results.AddRange(agents);
            }

            // Search Bookings
            var bookings = await _context.Bookings
                .Include(b => b.Lead)
                .Where(b => (role == "Admin" || b.ChannelPartnerId == channelPartnerId) &&
                           (b.Lead.Name.ToLower().Contains(query) || b.BookingNumber.ToLower().Contains(query)))
                .Take(5)
                .Select(b => new SearchResult
                {
                    Id = b.BookingId,
                    Title = "Booking #" + b.BookingNumber,
                    Subtitle = b.Lead.Name + " - " + b.Status,
                    Type = "Booking",
                    Icon = "book-open",
                    Url = "/Bookings/Details/" + b.BookingId
                }).ToListAsync();
            results.AddRange(bookings);

            // Search Agent Documents
            if (role == "Admin" || role == "Manager" || role == "Partner")
            {
                var agentDocs = await _context.AgentDocuments
                    .Include(d => d.Agent)
                    .Where(d => (role == "Admin" || d.Agent.ChannelPartnerId == channelPartnerId) &&
                               (d.DocumentName.ToLower().Contains(query) || d.DocumentType.ToLower().Contains(query) || d.FileName.ToLower().Contains(query)))
                    .Take(5)
                    .Select(d => new SearchResult
                    {
                        Id = d.DocumentId,
                        Title = d.DocumentName,
                        Subtitle = d.Agent.FullName + " - " + d.DocumentType,
                        Type = "Agent Document",
                        Icon = "file-text",
                        Url = "/Agent/Details/" + d.AgentId
                    }).ToListAsync();
                results.AddRange(agentDocs);
            }

            // Search Property Documents
            var propertyDocs = await _context.PropertyDocuments
                .Include(d => d.Property)
                .Where(d => (role == "Admin" || d.Property.AssignedTo == userId) &&
                           (d.FileName.ToLower().Contains(query) || d.DocumentType.ToLower().Contains(query)))
                .Take(5)
                .Select(d => new SearchResult
                {
                    Id = d.DocumentId,
                    Title = d.FileName,
                    Subtitle = d.Property.PropertyName + " - " + d.DocumentType,
                    Type = "Property Document",
                    Icon = "file-text",
                    Url = "/Properties/Details/" + d.PropertyId
                }).ToListAsync();
            results.AddRange(propertyDocs);

            // Search Channel Partner Documents
            if (role == "Admin")
            {
                var partnerDocs = await _context.ChannelPartnerDocuments
                    .Where(d => d.DocumentName.ToLower().Contains(query) || d.DocumentType.ToLower().Contains(query) || d.FileName.ToLower().Contains(query))
                    .Take(5)
                    .Select(d => new SearchResult
                    {
                        Id = d.DocumentId,
                        Title = d.DocumentName,
                        Subtitle = "Partner Document - " + d.DocumentType,
                        Type = "Partner Document",
                        Icon = "file-text",
                        Url = "/ManageUsers/PartnerDetails/" + d.ChannelPartnerId
                    }).ToListAsync();
                results.AddRange(partnerDocs);
            }

            return Json(new { success = true, results = results.Take(20) });
        }

        [HttpPost]
        public async Task<IActionResult> ToggleFavorite([FromBody] FavoriteRequest request)
        {
            var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            var existing = await _context.UserFavorites.FirstOrDefaultAsync(f => f.UserId == userId && f.PageName == request.PageName);
            
            if (existing != null)
            {
                _context.UserFavorites.Remove(existing);
                await _context.SaveChangesAsync();
                return Json(new { success = true, isFavorite = false });
            }
            else
            {
                _context.UserFavorites.Add(new UserFavorite { UserId = userId, PageName = request.PageName, PageUrl = request.PageUrl, PageIcon = request.PageIcon, PageColor = request.PageColor });
                await _context.SaveChangesAsync();
                return Json(new { success = true, isFavorite = true });
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetFavorites()
        {
            var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            var favorites = await _context.UserFavorites.Where(f => f.UserId == userId).ToListAsync();
            return Json(new { success = true, favorites });
        }

        [HttpPost]
        public async Task<IActionResult> SaveRecentSearch([FromBody] RecentSearchRequest request)
        {
            var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            var existing = await _context.UserRecentSearches.Where(r => r.UserId == userId && r.SearchTerm == request.SearchTerm).FirstOrDefaultAsync();
            
            if (existing != null)
            {
                _context.UserRecentSearches.Remove(existing);
            }
            
            _context.UserRecentSearches.Add(new UserRecentSearch { UserId = userId, SearchTerm = request.SearchTerm, SearchedAt = DateTime.Now });
            
            var allRecent = await _context.UserRecentSearches.Where(r => r.UserId == userId).OrderByDescending(r => r.SearchedAt).ToListAsync();
            if (allRecent.Count > 5)
            {
                _context.UserRecentSearches.RemoveRange(allRecent.Skip(5));
            }
            
            await _context.SaveChangesAsync();
            return Json(new { success = true });
        }

        [HttpGet]
        public async Task<IActionResult> GetRecentSearches()
        {
            var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            var recent = await _context.UserRecentSearches.Where(r => r.UserId == userId).OrderByDescending(r => r.SearchedAt).Take(5).Select(r => r.SearchTerm).ToListAsync();
            return Json(new { success = true, searches = recent });
        }

        [HttpPost]
        public async Task<IActionResult> RemoveRecentSearch([FromBody] RecentSearchRequest request)
        {
            var userId = int.Parse(User.FindFirst("UserId")?.Value ?? "0");
            var existing = await _context.UserRecentSearches.FirstOrDefaultAsync(r => r.UserId == userId && r.SearchTerm == request.SearchTerm);
            
            if (existing != null)
            {
                _context.UserRecentSearches.Remove(existing);
                await _context.SaveChangesAsync();
            }
            
            return Json(new { success = true });
        }
    }

    public class SearchResult
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Subtitle { get; set; }
        public string Type { get; set; }
        public string Icon { get; set; }
        public string Url { get; set; }
    }

    public class FavoriteRequest
    {
        public string PageName { get; set; }
        public string PageUrl { get; set; }
        public string PageIcon { get; set; }
        public string PageColor { get; set; }
    }

    public class RecentSearchRequest
    {
        public string SearchTerm { get; set; }
    }
}
