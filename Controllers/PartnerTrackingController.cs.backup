using CRM.Attributes;
using CRM.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CRM.Controllers
{
    [RoleAuthorize("Partner")]
    public class PartnerTrackingController : Controller
    {
        private readonly AppDbContext _context;

        public PartnerTrackingController(AppDbContext context)
        {
            _context = context;
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirst("UserId")?.Value;
            return int.TryParse(userIdClaim, out int userId) ? userId : 0;
        }

        private int? GetCurrentChannelPartnerId()
        {
            var userId = GetCurrentUserId();
            var user = _context.Users.FirstOrDefault(u => u.UserId == userId);
            return user?.ChannelPartnerId;
        }

        // GET: PartnerTracking/Index - Partner's tracking dashboard
        public IActionResult Index()
        {
            var channelPartnerId = GetCurrentChannelPartnerId();
            if (!channelPartnerId.HasValue)
            {
                return Unauthorized("Partner not found");
            }

            // Get partner's handed over leads with tracking info
            var leads = _context.Leads
                .Where(l => l.ChannelPartnerId == channelPartnerId && l.IsReadyToBook == true)
                .OrderByDescending(l => l.HandoverDate)
                .ToList();

            var handedOverLeads = leads.Select(l => new
            {
                l.LeadId,
                l.Name,
                l.Contact,
                l.HandoverDate,
                l.HandoverStatus,
                AdminAgent = _context.Users.FirstOrDefault(u => u.UserId == l.AdminAssignedTo)?.Username,
                BookingStatus = _context.Bookings.Where(b => b.LeadId == l.LeadId).Select(b => b.Status).FirstOrDefault(),
                BookingAmount = _context.Bookings.Where(b => b.LeadId == l.LeadId).Select(b => b.BookingAmount).FirstOrDefault(),
                CommissionStatus = GetCommissionStatus(l.LeadId, channelPartnerId.Value),
                CommissionAmount = GetCommissionAmount(l.LeadId, channelPartnerId.Value),
                CommissionCalculation = GetCommissionCalculation(l.LeadId, channelPartnerId.Value)
            }).ToList();

            return View(handedOverLeads);
        }

        // GET: Real-time lead tracking details
        [HttpGet]
        public IActionResult GetLeadTracking(int leadId)
        {
            var channelPartnerId = GetCurrentChannelPartnerId();
            if (!channelPartnerId.HasValue)
            {
                return Json(new { success = false, message = "Unauthorized" });
            }

            var lead = _context.Leads.FirstOrDefault(l => l.LeadId == leadId && l.ChannelPartnerId == channelPartnerId);
            if (lead == null)
            {
                return Json(new { success = false, message = "Lead not found" });
            }

            // Get booking details
            var booking = _context.Bookings.FirstOrDefault(b => b.LeadId == leadId);
            
            // Get payment details
            var payments = new List<object>();
            if (booking != null)
            {
                payments = _context.Payments
                    .Where(p => p.BookingId == booking.BookingId)
                    .Select(p => new
                    {
                        p.PaymentId,
                        p.Amount,
                        p.PaymentDate,
                        p.PaymentMethod,
                        p.ReceiptNumber
                    })
                    .OrderByDescending(p => p.PaymentDate)
                    .ToList<object>();
            }

            // Get commission details from booking and payout
            var commissionLog = booking != null ? _context.ChannelPartnerCommissionLogs
                .FirstOrDefault(c => c.BookingId == booking.BookingId && c.PartnerId == channelPartnerId.Value) : null;
            
            var payout = commissionLog != null ? _context.PartnerPayouts
                .FirstOrDefault(p => p.PartnerId == channelPartnerId.Value && 
                                   p.Month == commissionLog.Month && 
                                   p.Year == commissionLog.Year) : null;

            // Get handover audit trail
            var auditTrail = _context.LeadHandoverAudit
                .Where(a => a.LeadId == leadId)
                .OrderByDescending(a => a.HandoverDate)
                .Select(a => new
                {
                    a.FromStatus,
                    a.ToStatus,
                    a.HandoverDate,
                    HandedOverBy = _context.Users.FirstOrDefault(u => u.UserId == a.HandedOverBy).Username,
                    AssignedTo = a.AssignedTo.HasValue ? _context.Users.FirstOrDefault(u => u.UserId == a.AssignedTo).Username : null,
                    a.Notes
                })
                .ToList();

            var trackingData = new
            {
                Lead = new
                {
                    lead.LeadId,
                    lead.Name,
                    lead.Contact,
                    lead.HandoverStatus,
                    lead.HandoverDate,
                    AdminAgent = lead.AdminAssignedTo.HasValue ? _context.Users.FirstOrDefault(u => u.UserId == lead.AdminAssignedTo).Username : null
                },
                Booking = booking != null ? new
                {
                    booking.BookingId,
                    booking.Status,
                    booking.BookingAmount,
                    booking.CreatedOn
                } : null,
                Payments = payments,
                Commission = commissionLog != null ? new
                {
                    CommissionId = commissionLog.CommissionLogId,
                    Status = payout?.Status ?? "Pending",
                    CommissionAmount = commissionLog.FixedCommissionAmount,
                    CommissionPercentage = _context.ChannelPartners.FirstOrDefault(cp => cp.PartnerId == channelPartnerId.Value)?.CommissionPercentage ?? 0,
                    ApprovedOn = (DateTime?)null,
                    PaidOn = (DateTime?)null,
                    PaymentReference = (string)null
                } : null,
                AuditTrail = auditTrail
            };

            return Json(new { success = true, data = trackingData });
        }

        // GET: Partner commission summary
        [HttpGet]
        public IActionResult GetCommissionSummary()
        {
            var channelPartnerId = GetCurrentChannelPartnerId();
            if (!channelPartnerId.HasValue)
            {
                return Json(new { success = false, message = "Unauthorized" });
            }

            var partner = _context.ChannelPartners.FirstOrDefault(cp => cp.PartnerId == channelPartnerId.Value);
            if (partner == null)
            {
                return Json(new { success = false, message = "Partner not found" });
            }

            var payouts = _context.PartnerPayouts
                .Where(p => p.PartnerId == channelPartnerId.Value)
                .ToList();

            var summary = new
            {
                TotalCommissions = payouts.Sum(p => p.TotalSales),
                PendingCommissions = payouts.Where(p => p.Status == "Pending").Sum(p => p.TotalSales),
                ApprovedCommissions = payouts.Where(p => p.Status == "Approved").Sum(p => p.TotalSales),
                PaidCommissions = payouts.Where(p => p.Status == "Paid").Sum(p => p.TotalSales),
                TotalCommissionAmount = payouts.Sum(p => p.TotalCommission),
                PendingAmount = payouts.Where(p => p.Status == "Pending").Sum(p => p.TotalCommission),
                ApprovedAmount = payouts.Where(p => p.Status == "Approved").Sum(p => p.TotalCommission),
                PaidAmount = payouts.Where(p => p.Status == "Paid").Sum(p => p.TotalCommission),
                CommissionPercentage = partner.CommissionPercentage
            };

            return Json(new { success = true, data = summary });
        }

        // GET: Partner's leads pipeline (read-only view)
        [HttpGet]
        public IActionResult GetLeadsPipeline()
        {
            var channelPartnerId = GetCurrentChannelPartnerId();
            if (!channelPartnerId.HasValue)
            {
                return Json(new { success = false, message = "Unauthorized" });
            }

            var leads = _context.Leads
                .Where(l => l.ChannelPartnerId == channelPartnerId)
                .Select(l => new
                {
                    l.LeadId,
                    l.Name,
                    l.Contact,
                    l.Stage,
                    l.Status,
                    l.HandoverStatus,
                    l.IsReadyToBook,
                    l.CreatedOn,
                    l.HandoverDate,
                    CanEdit = l.HandoverStatus == "Partner" // Only editable if not handed over
                })
                .OrderByDescending(l => l.CreatedOn)
                .ToList();

            var pipeline = new
            {
                TotalLeads = leads.Count,
                ActiveLeads = leads.Count(l => l.HandoverStatus == "Partner"),
                HandedOverLeads = leads.Count(l => l.IsReadyToBook),
                Leads = leads
            };

            return Json(new { success = true, data = pipeline });
        }

        private string GetCommissionStatus(int leadId, int partnerId)
        {
            var booking = _context.Bookings.FirstOrDefault(b => b.LeadId == leadId);
            if (booking == null) return "No Booking";

            var commissionLog = _context.ChannelPartnerCommissionLogs
                .FirstOrDefault(c => c.BookingId == booking.BookingId && c.PartnerId == partnerId);
            if (commissionLog == null) return "Pending";

            var payout = _context.PartnerPayouts
                .FirstOrDefault(p => p.PartnerId == partnerId && 
                               p.Month == commissionLog.Month && 
                               p.Year == commissionLog.Year);

            return payout?.Status ?? "Pending";
        }

        private decimal GetCommissionAmount(int leadId, int partnerId)
        {
            var booking = _context.Bookings.FirstOrDefault(b => b.LeadId == leadId);
            if (booking == null) return 0;

            var commissionLog = _context.ChannelPartnerCommissionLogs
                .FirstOrDefault(c => c.BookingId == booking.BookingId && c.PartnerId == partnerId);

            return commissionLog?.FixedCommissionAmount ?? 0;
        }

        private string GetCommissionCalculation(int leadId, int partnerId)
        {
            var booking = _context.Bookings.FirstOrDefault(b => b.LeadId == leadId);
            if (booking == null) return "No booking";

            var partner = _context.ChannelPartners.FirstOrDefault(cp => cp.PartnerId == partnerId);
            if (partner == null) return "Partner not found";

            var commissionLog = _context.ChannelPartnerCommissionLogs
                .FirstOrDefault(c => c.BookingId == booking.BookingId && c.PartnerId == partnerId);

            if (commissionLog == null) return "No commission calculated";

            return $"₹{booking.TotalAmount:N0} × {partner.CommissionPercentage}% = ₹{commissionLog.FixedCommissionAmount:N2}";
        }
    }
}