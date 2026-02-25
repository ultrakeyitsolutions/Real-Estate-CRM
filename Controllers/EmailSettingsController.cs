using CRM.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace CRM.Controllers
{
    [Authorize(Roles = "Admin,Partner")]
    public class EmailSettingsController : Controller
    {
        private readonly AppDbContext _context;

        public EmailSettingsController(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> Index()
        {
            var userIdClaim = User.FindFirst("UserId")?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                return RedirectToAction("Login", "Account");
            
            var role = User.FindFirst(ClaimTypes.Role)?.Value;

            var emailSetting = await _context.EmailSettings.FirstOrDefaultAsync(e => e.UserId == userId);
            ViewBag.Role = role;
            return View(emailSetting);
        }

        [HttpPost]
        public async Task<IActionResult> SaveSmtp(string smtpFrom, string smtpPassword)
        {
            var userIdClaim = User.FindFirst("UserId")?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
                return Json(new { success = false, message = "User not authenticated" });
            var emailSetting = await _context.EmailSettings.FirstOrDefaultAsync(e => e.UserId == userId);

            if (emailSetting == null)
            {
                emailSetting = new EmailSettingModel
                {
                    UserId = userId,
                    SmtpFrom = smtpFrom,
                    SmtpPassword = smtpPassword
                };
                _context.EmailSettings.Add(emailSetting);
            }
            else
            {
                emailSetting.SmtpFrom = smtpFrom;
                emailSetting.SmtpPassword = smtpPassword;
                emailSetting.UpdatedOn = DateTime.Now;
            }

            await _context.SaveChangesAsync();
            return Json(new { success = true, message = "SMTP settings saved successfully" });
        }

        public async Task<string> GetUserEmail(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return null;

            var role = user.Role;
            var emailSetting = await _context.EmailSettings.FirstOrDefaultAsync(e => e.UserId == userId);

            if (emailSetting != null)
                return emailSetting.SmtpFrom;

            if (role == "Agent" && user.ChannelPartnerId.HasValue)
            {
                var partnerSetting = await _context.EmailSettings.FirstOrDefaultAsync(e => e.UserId == user.ChannelPartnerId.Value);
                if (partnerSetting != null)
                    return partnerSetting.SmtpFrom;
            }

            return null;
        }

        public async Task<(string from, string password)> GetEmailCredentials(int userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return (null, null);

            var emailSetting = await _context.EmailSettings.FirstOrDefaultAsync(e => e.UserId == userId);
            if (emailSetting != null)
                return (emailSetting.SmtpFrom, emailSetting.SmtpPassword);

            if (user.Role == "Agent" && user.ChannelPartnerId.HasValue)
            {
                var partnerSetting = await _context.EmailSettings.FirstOrDefaultAsync(e => e.UserId == user.ChannelPartnerId.Value);
                if (partnerSetting != null)
                    return (partnerSetting.SmtpFrom, partnerSetting.SmtpPassword);
            }

            return (null, null);
        }
    }
}
