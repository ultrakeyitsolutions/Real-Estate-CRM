using CRM.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CRM.Controllers
{
    [Authorize]
    public class DashboardController : Controller
    {
        private readonly AppDbContext _db;

        public DashboardController(AppDbContext db)
        {
            _db = db;
        }

        public IActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public async Task<IActionResult> GetAnalyticsData()
        {
            var role = User?.FindFirst(ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid, out int userId);
            var currentUser = await _db.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            var channelPartnerId = currentUser?.ChannelPartnerId;

            // Lead Statistics
            var leadsQuery = _db.Leads.AsQueryable();
            if (role?.ToLower() == "partner")
                leadsQuery = leadsQuery.Where(l => l.ChannelPartnerId == channelPartnerId);
            else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                leadsQuery = leadsQuery.Where(l => l.ExecutiveId == userId);

            var totalLeads = await leadsQuery.CountAsync();
            var newLeadsToday = await leadsQuery.Where(l => l.CreatedOn.Date == DateTime.Today).CountAsync();
            var newLeadsThisMonth = await leadsQuery.Where(l => l.CreatedOn.Month == DateTime.Now.Month && l.CreatedOn.Year == DateTime.Now.Year).CountAsync();

            // Lead Status Breakdown
            var leadsByStatus = await leadsQuery
                .GroupBy(l => l.Status)
                .Select(g => new { Status = g.Key, Count = g.Count() })
                .ToListAsync();

            // Lead Stage Funnel
            var leadsByStage = await leadsQuery
                .GroupBy(l => l.Stage)
                .Select(g => new { Stage = g.Key, Count = g.Count() })
                .OrderBy(x => x.Stage)
                .ToListAsync();

            // Lead Sources
            var leadsBySource = await leadsQuery
                .GroupBy(l => l.Source)
                .Select(g => new { Source = g.Key ?? "Unknown", Count = g.Count() })
                .OrderByDescending(x => x.Count)
                .Take(10)
                .ToListAsync();

            // Monthly Trend (Last 12 months)
            var monthlyTrend = await leadsQuery
                .Where(l => l.CreatedOn >= DateTime.Now.AddMonths(-12))
                .GroupBy(l => new { l.CreatedOn.Year, l.CreatedOn.Month })
                .Select(g => new { 
                    Month = $"{g.Key.Year}-{g.Key.Month:D2}", 
                    Count = g.Count() 
                })
                .OrderBy(x => x.Month)
                .ToListAsync();

            // Booking Statistics
            var bookingsQuery = _db.Bookings.Include(b => b.Lead).AsQueryable();
            if (role?.ToLower() == "partner")
                bookingsQuery = bookingsQuery.Where(b => b.Lead != null && b.Lead.ChannelPartnerId == channelPartnerId);
            else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                bookingsQuery = bookingsQuery.Where(b => b.Lead != null && b.Lead.ExecutiveId == userId);

            var totalBookings = await bookingsQuery.CountAsync();
            var bookingsThisMonth = await bookingsQuery
                .Where(b => b.BookingDate.Month == DateTime.Now.Month && b.BookingDate.Year == DateTime.Now.Year)
                .CountAsync();

            var totalBookingValue = await bookingsQuery.SumAsync(b => b.TotalAmount);

            // Revenue Statistics
            var revenueQuery = _db.Payments.Include(p => p.Booking).ThenInclude(b => b!.Lead).AsQueryable();
            if (role?.ToLower() == "partner")
                revenueQuery = revenueQuery.Where(p => p.Booking != null && p.Booking.Lead != null && p.Booking.Lead.ChannelPartnerId == channelPartnerId);
            else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                revenueQuery = revenueQuery.Where(p => p.Booking != null && p.Booking.Lead != null && p.Booking.Lead.ExecutiveId == userId);

            var totalRevenue = await revenueQuery.SumAsync(p => p.Amount);
            var revenueThisMonth = await revenueQuery
                .Where(p => p.PaymentDate.Month == DateTime.Now.Month && p.PaymentDate.Year == DateTime.Now.Year)
                .SumAsync(p => p.Amount);

            // Monthly Revenue Trend
            var revenueMonthlyTrend = await revenueQuery
                .Where(p => p.PaymentDate >= DateTime.Now.AddMonths(-12))
                .GroupBy(p => new { p.PaymentDate.Year, p.PaymentDate.Month })
                .Select(g => new { 
                    Month = $"{g.Key.Year}-{g.Key.Month:D2}", 
                    Revenue = g.Sum(p => p.Amount) 
                })
                .OrderBy(x => x.Month)
                .ToListAsync();

            // Conversion Rate
            var convertedLeads = await leadsQuery.Where(l => l.Stage == "Closed Won").CountAsync();
            var conversionRate = totalLeads > 0 ? (convertedLeads * 100.0 / totalLeads) : 0;

            // Top Performing Agents (Admin/Partner only)
            List<object> topAgents = new List<object>();
            if (role?.ToLower() == "admin" || role?.ToLower() == "partner")
            {
                topAgents = await leadsQuery
                    .Where(l => l.ExecutiveId.HasValue)
                    .GroupBy(l => l.ExecutiveId)
                    .Select(g => new { 
                        ExecutiveId = g.Key,
                        LeadCount = g.Count(),
                        ConvertedCount = g.Count(l => l.Stage == "Closed Won")
                    })
                    .OrderByDescending(x => x.ConvertedCount)
                    .Take(5)
                    .ToListAsync<object>();

                // Get agent names
                var agentIds = topAgents.Select(a => ((dynamic)a).ExecutiveId).ToList();
                var agents = await _db.Users.Where(u => agentIds.Contains(u.UserId)).ToListAsync();
                var agentProfiles = await _db.UserProfiles.Where(up => agentIds.Contains(up.UserId)).ToListAsync();

                topAgents = topAgents.Select(a => {
                    var agentId = ((dynamic)a).ExecutiveId;
                    var agent = agents.FirstOrDefault(ag => ag.UserId == agentId);
                    var profile = agentProfiles.FirstOrDefault(p => p.UserId == agentId);
                    var name = profile != null ? $"{profile.FirstName} {profile.LastName}".Trim() : agent?.Username ?? "Unknown";
                    
                    return new {
                        AgentName = name,
                        LeadCount = ((dynamic)a).LeadCount,
                        ConvertedCount = ((dynamic)a).ConvertedCount,
                        ConversionRate = ((dynamic)a).LeadCount > 0 ? (((dynamic)a).ConvertedCount * 100.0 / ((dynamic)a).LeadCount) : 0
                    };
                }).Cast<object>().ToList();
            }

            return Json(new
            {
                success = true,
                data = new
                {
                    overview = new
                    {
                        totalLeads,
                        newLeadsToday,
                        newLeadsThisMonth,
                        totalBookings,
                        bookingsThisMonth,
                        totalBookingValue,
                        totalRevenue,
                        revenueThisMonth,
                        conversionRate = Math.Round(conversionRate, 2)
                    },
                    leadsByStatus,
                    leadsByStage,
                    leadsBySource,
                    monthlyTrend,
                    revenueMonthlyTrend,
                    topAgents
                }
            });
        }

        [HttpGet]
        public async Task<IActionResult> GetRecentActivities()
        {
            var role = User?.FindFirst(ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid, out int userId);
            var currentUser = await _db.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            var channelPartnerId = currentUser?.ChannelPartnerId;

            // Get recent leads
            var leadsQuery = _db.Leads.AsQueryable();
            if (role?.ToLower() == "partner")
                leadsQuery = leadsQuery.Where(l => l.ChannelPartnerId == channelPartnerId);
            else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                leadsQuery = leadsQuery.Where(l => l.ExecutiveId == userId);

            var recentLeads = await leadsQuery
                .OrderByDescending(l => l.CreatedOn)
                .Take(5)
                .Select(l => new
                {
                    l.LeadId,
                    l.Name,
                    l.Email,
                    Contact = l.Contact,
                    l.Status,
                    l.Stage,
                    l.CreatedOn,
                    Type = "Lead"
                })
                .ToListAsync();

            // Get recent bookings
            var bookingsQuery = _db.Bookings.Include(b => b.Lead).AsQueryable();
            if (role?.ToLower() == "partner")
                bookingsQuery = bookingsQuery.Where(b => b.Lead != null && b.Lead.ChannelPartnerId == channelPartnerId);
            else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                bookingsQuery = bookingsQuery.Where(b => b.Lead != null && b.Lead.ExecutiveId == userId);

            var recentBookings = await bookingsQuery
                .OrderByDescending(b => b.BookingDate)
                .Take(5)
                .Select(b => new
                {
                    b.BookingId,
                    CustomerName = b.Lead != null ? b.Lead.Name : "Unknown",
                    b.TotalAmount,
                    b.BookingDate,
                    b.Status,
                    Type = "Booking"
                })
                .ToListAsync();

            return Json(new
            {
                success = true,
                data = new
                {
                    recentLeads,
                    recentBookings
                }
            });
        }

        [HttpGet]
        public async Task<IActionResult> GetUpcomingFollowUps()
        {
            var role = User?.FindFirst(ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid, out int userId);
            var currentUser = await _db.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            var channelPartnerId = currentUser?.ChannelPartnerId;

            var followUpsQuery = _db.LeadFollowUps
                .Where(f => f.FollowUpDate >= DateTime.Today && f.Status != "Completed")
                .AsQueryable();

            if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                followUpsQuery = followUpsQuery.Where(f => f.ExecutiveId == userId);

            var followUpLeads = await followUpsQuery
                .OrderBy(f => f.FollowUpDate)
                .Take(10)
                .Join(_db.Leads,
                    f => f.LeadId,
                    l => l.LeadId,
                    (f, l) => new { FollowUp = f, Lead = l })
                .ToListAsync();

            // Filter by partner if needed
            if (role?.ToLower() == "partner")
            {
                followUpLeads = followUpLeads.Where(x => x.Lead.ChannelPartnerId == channelPartnerId).ToList();
            }

            var upcomingFollowUps = followUpLeads.Select(x => new
                {
                    x.FollowUp.FollowUpId,
                    x.FollowUp.LeadId,
                    LeadName = x.Lead.Name,
                    LeadContact = x.Lead.Contact,
                    x.FollowUp.FollowUpDate,
                    Notes = x.FollowUp.Comments,
                    x.FollowUp.Status,
                    Priority = x.FollowUp.Stage,
                    IsOverdue = x.FollowUp.FollowUpDate < DateTime.Today
                })
                .ToList();

            return Json(new
            {
                success = true,
                data = upcomingFollowUps
            });
        }
    }
}
