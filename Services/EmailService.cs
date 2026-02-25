using System.Net;
using System.Net.Mail;
using CRM.Models;
using Microsoft.EntityFrameworkCore;

namespace CRM.Services
{
    public class EmailService
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _config;

        public EmailService(AppDbContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
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

            return (_config["EmailSettings:From"], _config["EmailSettings:Password"]);
        }

        public async Task SendEmailAsync(int userId, string toEmail, string subject, string body)
        {
            var (from, password) = await GetEmailCredentials(userId);
            if (string.IsNullOrEmpty(from) || string.IsNullOrEmpty(password))
                throw new Exception("Email credentials not configured");

            using var smtp = new SmtpClient("smtp.gmail.com", 587)
            {
                Credentials = new NetworkCredential(from, password),
                EnableSsl = true
            };

            var mail = new MailMessage(from, toEmail, subject, body) { IsBodyHtml = true };
            await smtp.SendMailAsync(mail);
        }
    }
}
