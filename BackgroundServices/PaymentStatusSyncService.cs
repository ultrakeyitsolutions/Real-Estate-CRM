using CRM.Models;
using CRM.Services;
using Microsoft.EntityFrameworkCore;

namespace CRM.BackgroundServices
{
    public class PaymentStatusSyncService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<PaymentStatusSyncService> _logger;
        private readonly TimeSpan _syncInterval = TimeSpan.FromMinutes(5); // Sync every 5 minutes

        public PaymentStatusSyncService(IServiceProvider serviceProvider, ILogger<PaymentStatusSyncService> logger)
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
                    await SyncPaymentStatuses();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error during payment status sync");
                }

                await Task.Delay(_syncInterval, stoppingToken);
            }
        }

        private async Task SyncPaymentStatuses()
        {
            using var scope = _serviceProvider.CreateScope();
            var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var razorpayService = scope.ServiceProvider.GetRequiredService<RazorpayService>();

            try
            {
                // Get transactions that might need status updates (created in last 24 hours and not Success/Failed)
                var pendingTransactions = await context.PaymentTransactions
                    .Include(t => t.Subscription)
                    .Where(t => !string.IsNullOrEmpty(t.RazorpayPaymentId) && 
                               (t.Status == "Pending" || t.Status == "Authorized") &&
                               t.CreatedOn >= DateTime.Now.AddHours(-24))
                    .ToListAsync();

                if (!pendingTransactions.Any())
                {
                    _logger.LogInformation("No pending transactions to sync");
                    return;
                }

                int updated = 0;
                foreach (var transaction in pendingTransactions)
                {
                    try
                    {
                        var paymentDetails = await razorpayService.GetPaymentDetailsAsync(transaction.RazorpayPaymentId!);
                        var razorpayStatus = paymentDetails.status?.ToString();
                        
                        if (!string.IsNullOrEmpty(razorpayStatus))
                        {
                            var oldStatus = transaction.Status;
                            var newStatus = razorpayStatus switch
                            {
                                "captured" => "Success",
                                "failed" => "Failed",
                                "created" => "Pending",
                                "authorized" => "Authorized",
                                "refunded" => "Refunded",
                                _ => transaction.Status
                            };
                            
                            if (newStatus != transaction.Status)
                            {
                                transaction.Status = newStatus;
                                transaction.UpdatedOn = DateTime.Now;
                                
                                // Activate subscription only when payment is captured
                                if (razorpayStatus == "captured" && oldStatus != "Success" && transaction.Subscription != null)
                                {
                                    await ActivateSubscriptionOnCapture(transaction.Subscription);
                                }
                                
                                updated++;
                                _logger.LogInformation($"Updated transaction {transaction.TransactionId} status from {oldStatus} to {newStatus}");
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, $"Failed to sync status for payment {transaction.RazorpayPaymentId}");
                    }
                }

                if (updated > 0)
                {
                    await context.SaveChangesAsync();
                    _logger.LogInformation($"Payment status sync completed. Updated {updated} transactions.");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during payment status sync operation");
            }
        }

        private async Task ActivateSubscriptionOnCapture(PartnerSubscriptionModel subscription)
        {
            try
            {
                // Only activate if subscription is not already active
                if (subscription.Status != "Active")
                {
                    subscription.Status = "Active";
                    subscription.StartDate = DateTime.Now;
                    subscription.UpdatedOn = DateTime.Now;
                    
                    _logger.LogInformation($"Activated subscription {subscription.SubscriptionId} on payment capture via background sync");
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error activating subscription {subscription.SubscriptionId}");
            }
        }
    }
}