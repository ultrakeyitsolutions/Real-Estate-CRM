using CRM.Models;
using Microsoft.EntityFrameworkCore;

namespace CRM.Services
{
    public class FollowUpReminderService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<FollowUpReminderService> _logger;

        public FollowUpReminderService(IServiceProvider serviceProvider, ILogger<FollowUpReminderService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    await CheckFollowUpReminders();
                    await Task.Delay(TimeSpan.FromHours(2), stoppingToken); // Check every 2 hours
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error in FollowUpReminderService");
                    await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken); // Wait 5 minutes on error
                }
            }
        }

        private async Task CheckFollowUpReminders()
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var notificationService = scope.ServiceProvider.GetRequiredService<INotificationService>();

            var today = DateTime.Today;
            
            // Get leads with follow-ups due today that don't have notifications yet
            var leadsWithFollowUps = await context.Leads
                .Where(l => l.FollowUpDate.HasValue && 
                           l.FollowUpDate.Value.Date == today &&
                           l.ExecutiveId.HasValue &&
                           l.Status != "Completed" && 
                           l.Stage != "Booked")
                .ToListAsync();

            foreach (var lead in leadsWithFollowUps)
            {
                // Check if notification already exists for today (unread only)
                var existingNotification = await context.Notifications
                    .AnyAsync(n => n.UserId == lead.ExecutiveId &&
                                  n.Type == "FollowUpDue" &&
                                  n.RelatedEntityId == lead.LeadId &&
                                  n.CreatedOn.Date == today &&
                                  !n.IsRead);

                if (!existingNotification)
                {
                    await notificationService.NotifyFollowUpDueAsync(
                        0, // followUpId not needed
                        lead.LeadId,
                        lead.Name ?? "Unknown Lead",
                        lead.FollowUpDate.Value,
                        lead.ExecutiveId.Value
                    );
                    
                    _logger.LogInformation($"Created follow-up reminder for lead {lead.LeadId} assigned to user {lead.ExecutiveId}");
                }
            }
        }
    }
}