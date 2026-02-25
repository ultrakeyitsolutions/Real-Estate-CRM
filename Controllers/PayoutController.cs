using CRM.Attributes;
using CRM.Models;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace CRM.Controllers
{
        [RoleAuthorize("Admin")]
    public class PayoutController : Controller
    {
        private readonly AppDbContext _context;
        public PayoutController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult List()
        {
            var agentPayouts = _context.AgentPayouts.ToList();
            var partnerPayouts = _context.PartnerPayouts.ToList();
            ViewBag.AgentPayouts = agentPayouts;
            ViewBag.PartnerPayouts = partnerPayouts;
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> ApproveAgentPayout(int payoutId)
        {
            var payout = _context.AgentPayouts.Find(payoutId);
            if (payout != null)
            {
                payout.Status = "Approved";
                await _context.SaveChangesAsync();
            }
            return RedirectToAction("List");
        }

        [HttpPost]
        public async Task<IActionResult> ApprovePartnerPayout(int payoutId)
        {
            var payout = _context.PartnerPayouts.Find(payoutId);
            if (payout != null)
            {
                payout.Status = "Approved";
                await _context.SaveChangesAsync();
            }
            return RedirectToAction("List");
        }
    }
}
