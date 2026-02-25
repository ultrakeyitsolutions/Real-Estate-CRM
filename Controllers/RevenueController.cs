using CRM.Models;
using Microsoft.AspNetCore.Mvc;
using CRM.Attributes;
using System.Linq;

namespace CRM.Controllers
{
    public class RevenueController : Controller
    {
        private readonly AppDbContext _db;
        public RevenueController(AppDbContext db) { _db = db; }
        [PermissionAuthorize("View")]

        public IActionResult Index()
        {
            var role = User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid, out int userId);
            var currentUser = _db.Users.FirstOrDefault(u => u.UserId == userId);
            var channelPartnerId = currentUser?.ChannelPartnerId;

            var revenuesQuery = _db.Revenues.AsQueryable();
            if (role?.ToLower() == "partner")
                revenuesQuery = revenuesQuery.Where(r => r.ChannelPartnerId == channelPartnerId);
            else if (role?.ToLower() == "admin")
                revenuesQuery = revenuesQuery.Where(r => r.ChannelPartnerId == null);
            
            var revenues = revenuesQuery.ToList();
            
            var bookingsQuery = _db.Bookings.AsQueryable();
            if (role?.ToLower() == "partner")
                bookingsQuery = bookingsQuery.Where(b => b.ChannelPartnerId == channelPartnerId);
            else if (role?.ToLower() == "admin")
                bookingsQuery = bookingsQuery.Where(b => b.ChannelPartnerId == null);
            else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
            {
                var myLeadIds = _db.Leads.Where(l => l.ExecutiveId == userId).Select(l => l.LeadId).ToList();
                bookingsQuery = bookingsQuery.Where(b => myLeadIds.Contains(b.LeadId));
            }
            var bookings = bookingsQuery.ToList();
            var bookingRevenue = bookings.Sum(b => b.TotalAmount);
            if (bookingRevenue > 0)
            {
                revenues.Add(new RevenueModel {
                    Type = "Booking",
                    Description = "Total Booked Amount (from Bookings)",
                    Amount = bookingRevenue,
                    Date = DateTime.Now
                });
            }
            var paymentsQuery = _db.Payments.AsQueryable();
            if (role?.ToLower() == "partner")
            {
                var partnerBookingIds = bookingsQuery.Select(b => b.BookingId).ToList();
                paymentsQuery = paymentsQuery.Where(p => partnerBookingIds.Contains(p.BookingId));
            }
            else if (role?.ToLower() == "admin")
            {
                var adminBookingIds = _db.Bookings.Where(b => b.ChannelPartnerId == null).Select(b => b.BookingId).ToList();
                paymentsQuery = paymentsQuery.Where(p => adminBookingIds.Contains(p.BookingId));
            }
            else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
            {
                var myLeadIds = _db.Leads.Where(l => l.ExecutiveId == userId).Select(l => l.LeadId).ToList();
                var myBookingIds = _db.Bookings.Where(b => myLeadIds.Contains(b.LeadId)).Select(b => b.BookingId).ToList();
                paymentsQuery = paymentsQuery.Where(p => myBookingIds.Contains(p.BookingId));
            }
            var payments = paymentsQuery.ToList();
            var month = DateTime.Now.Month;
            var year = DateTime.Now.Year;
            var monthlyPayments = payments.Where(p => p.PaymentDate.Month == month && p.PaymentDate.Year == year).ToList();
            var monthlyRevenue = monthlyPayments.Sum(p => p.Amount);
            if (monthlyRevenue > 0)
            {
                revenues.Add(new RevenueModel {
                    Type = "Payment",
                    Description = $"Month Revenue ({DateTime.Now:MMMM yyyy})",
                    Amount = monthlyRevenue,
                    Date = DateTime.Now
                });
            }
            return View(revenues);
        }

        // GET: Revenue/Details/{id}
        public IActionResult Details(int id)
        {
            var revenue = _db.Revenues.FirstOrDefault(r => r.RevenueId == id);
            if (revenue == null)
            {
                return NotFound();
            }
            return View(revenue);
        }

        // GET: Revenue/Delete/{id}
        public IActionResult Delete(int id)
        {
            var revenue = _db.Revenues.FirstOrDefault(r => r.RevenueId == id);
            if (revenue == null)
            {
                return NotFound();
            }
            return View(revenue);
        }

        // POST: Revenue/Delete/{id}
        [HttpPost, ActionName("Delete")]
        public IActionResult DeleteConfirmed(int id)
        {
            var revenue = _db.Revenues.FirstOrDefault(r => r.RevenueId == id);
            if (revenue == null)
            {
                return NotFound();
            }
            _db.Revenues.Remove(revenue);
            _db.SaveChanges();
            return RedirectToAction("Index");
        }

        // POST: Revenue/DeleteRevenue (AJAX)
        [HttpPost]
        public JsonResult DeleteRevenue([FromForm]int revenueId)
        {
            var revenue = _db.Revenues.FirstOrDefault(r => r.RevenueId == revenueId);
            if (revenue == null)
            {
                return Json(new { success = false, message = "Revenue not found." });
            }
            _db.Revenues.Remove(revenue);
            _db.SaveChanges();
            return Json(new { success = true });
        }

        // GET: Revenue/Create
        public IActionResult Create()
        {
            return View();
        }

        // POST: Revenue/Create
        [HttpPost]
        public IActionResult Create(RevenueModel model)
        {
            if (ModelState.IsValid)
            {
                var role = User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
                var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                int.TryParse(uid, out int userId);
                var currentUser = _db.Users.FirstOrDefault(u => u.UserId == userId);
                
                if (role?.ToLower() == "partner")
                    model.ChannelPartnerId = currentUser?.ChannelPartnerId;
                
                _db.Revenues.Add(model);
                _db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(model);
        }

        // POST: Revenue/CreateModal (AJAX)
        [HttpPost]
        public JsonResult CreateModal([FromForm] RevenueModel model)
        {
            if (ModelState.IsValid)
            {
                var role = User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
                var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                int.TryParse(uid, out int userId);
                var currentUser = _db.Users.FirstOrDefault(u => u.UserId == userId);
                
                if (role?.ToLower() == "partner")
                    model.ChannelPartnerId = currentUser?.ChannelPartnerId;
                
                _db.Revenues.Add(model);
                _db.SaveChanges();
                return Json(new { success = true });
            }
            return Json(new { success = false, message = "Invalid data" });
        }

        // GET: Revenue/GetRevenue/{id} (AJAX)
        [HttpGet]
        public JsonResult GetRevenue(int id)
        {
            var revenue = _db.Revenues.FirstOrDefault(r => r.RevenueId == id);
            if (revenue == null)
                return Json(new { success = false, message = "Revenue not found" });
            
            return Json(new { 
                success = true, 
                data = new {
                    revenueId = revenue.RevenueId,
                    type = revenue.Type,
                    description = revenue.Description,
                    amount = revenue.Amount
                }
            });
        }

        // POST: Revenue/EditModal (AJAX)
        [HttpPost]
        public JsonResult EditModal([FromForm] RevenueModel model)
        {
            if (ModelState.IsValid)
            {
                var revenue = _db.Revenues.FirstOrDefault(r => r.RevenueId == model.RevenueId);
                if (revenue == null)
                    return Json(new { success = false, message = "Revenue not found" });
                
                revenue.Type = model.Type;
                revenue.Description = model.Description;
                revenue.Amount = model.Amount;
                
                _db.SaveChanges();
                return Json(new { success = true });
            }
            return Json(new { success = false, message = "Invalid data" });
        }
    }
}

