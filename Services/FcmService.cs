using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.EntityFrameworkCore;

namespace CRM.Services
{
    public class FcmService
    {
        private readonly AppDbContext _context;
        private static bool _firebaseInitialized = false;
        private static readonly object _lock = new object();

        public FcmService(AppDbContext context)
        {
            _context = context;
            EnsureFirebaseInitialized();
        }

        private void EnsureFirebaseInitialized()
        {
            if (!_firebaseInitialized)
            {
                lock (_lock)
                {
                    if (!_firebaseInitialized)
                    {
                        FirebaseApp.Create(new AppOptions()
                        {
                            Credential = GoogleCredential.FromFile("C:/Users/aviditej/source/repos/CRM/CRM_beforeauth/CRM/CRM/CRM/realestatecrm-b1b4f-firebase-adminsdk-fbsvc-d2181a60b4.json")
                        });
                        _firebaseInitialized = true;
                    }
                }
            }
        }

        public async Task<bool> SendNotificationToUser(int userId, string title, string body)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user?.DeviceToken == null) return false;

            return await SendNotification(user.DeviceToken, title, body);
        }

        public async Task<bool> SendNotification(string deviceToken, string title, string body)
        {
            try
            {
                var message = new Message()
                {
                    Token = deviceToken,
                    Notification = new Notification
                    {
                        Title = title,
                        Body = body
                    },
                    Webpush = new WebpushConfig()
                    {
                        Notification = new WebpushNotification()
                        {
                            Icon = "/img/icons/icon-48x48.png",
                            Badge = "/img/icons/icon-48x48.png",
                            RequireInteraction = true
                        }
                    }
                };

                await FirebaseMessaging.DefaultInstance.SendAsync(message);
                return true;
            }
            catch (FirebaseMessagingException ex)
            {
                if (ex.MessagingErrorCode == MessagingErrorCode.Unregistered)
                {
                    await RemoveInvalidToken(deviceToken);
                }
                return false;
            }
        }

        public async Task SaveDeviceToken(int userId, string deviceToken)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            if (user != null)
            {
                user.DeviceToken = deviceToken;
                await _context.SaveChangesAsync();
            }
        }

        private async Task RemoveInvalidToken(string deviceToken)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.DeviceToken == deviceToken);
            if (user != null)
            {
                user.DeviceToken = null;
                await _context.SaveChangesAsync();
            }
        }
    }
}