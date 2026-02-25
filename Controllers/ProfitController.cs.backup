using CRM.Models;
using CRM.ViewModels;
using Microsoft.AspNetCore.Mvc;
using System.Linq;
using Microsoft.AspNetCore.Authorization;

namespace CRM.Controllers
{
    public class ProfitController : Controller
    {
        private readonly AppDbContext _db;
        public ProfitController(AppDbContext db) { _db = db; }

        public IActionResult Index()
        {
            var role = User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid, out int userId);
            var currentUser = _db.Users.FirstOrDefault(u => u.UserId == userId);
            var channelPartnerId = currentUser?.ChannelPartnerId;

            var expensesQuery = _db.Expenses.AsQueryable();
            var bookingsQuery = _db.Bookings.AsQueryable();
            var paymentsQuery = _db.Payments.AsQueryable();
            
            if (role?.ToLower() == "partner")
            {
                var partnerLeadIds = _db.Leads.Where(l => l.ChannelPartnerId == channelPartnerId).Select(l => l.LeadId).ToList();
                bookingsQuery = bookingsQuery.Where(b => partnerLeadIds.Contains(b.LeadId));
                var partnerBookingIds = bookingsQuery.Select(b => b.BookingId).ToList();
                paymentsQuery = paymentsQuery.Where(p => partnerBookingIds.Contains(p.BookingId));
                expensesQuery = expensesQuery.Where(e => e.ChannelPartnerId == channelPartnerId);
            }
            else if (role?.ToLower() == "admin")
            {
                var adminLeadIds = _db.Leads.Where(l => l.ChannelPartnerId == null).Select(l => l.LeadId).ToList();
                bookingsQuery = bookingsQuery.Where(b => adminLeadIds.Contains(b.LeadId));
                var adminBookingIds = bookingsQuery.Select(b => b.BookingId).ToList();
                paymentsQuery = paymentsQuery.Where(p => adminBookingIds.Contains(p.BookingId));
                expensesQuery = expensesQuery.Where(e => e.ChannelPartnerId == null);
            }
            else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
            {
                var myLeadIds = _db.Leads.Where(l => l.ExecutiveId == userId).Select(l => l.LeadId).ToList();
                bookingsQuery = bookingsQuery.Where(b => myLeadIds.Contains(b.LeadId));
                var myBookingIds = bookingsQuery.Select(b => b.BookingId).ToList();
                paymentsQuery = paymentsQuery.Where(p => myBookingIds.Contains(p.BookingId));
            }

            var expenses = expensesQuery.ToList();
            var payments = paymentsQuery.ToList();
            var totalExpenses = expenses.Sum(e => e.Amount);
            var totalRevenue = payments.Sum(p => p.Amount);
            var profit = totalRevenue - totalExpenses;
            var vm = new ExpenseRevenueProfitViewModel
            {
                Expenses = expenses,
                Revenues = payments.Select(p => new RevenueModel { Amount = p.Amount, Description = $"Payment #{p.PaymentId}", Type = "Payment", Date = p.PaymentDate }).ToList(),
                TotalExpenses = totalExpenses,
                TotalRevenue = totalRevenue,
                Profit = profit
            };
            return View(vm);
        }
    }
}
