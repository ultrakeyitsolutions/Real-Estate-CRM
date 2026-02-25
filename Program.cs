using Microsoft.EntityFrameworkCore;
using OfficeOpenXml;
using CRM;
using Microsoft.AspNetCore.Authentication.Cookies;

var builder = WebApplication.CreateBuilder(args);
//ExcelPackage.LicenseContext = OfficeOpenXml.LicenseContext.NonCommercial;

// Add services to the container
builder.Services.AddControllersWithViews(options =>
{
    options.Filters.Add(new Microsoft.AspNetCore.Mvc.IgnoreAntiforgeryTokenAttribute());
});
builder.Services.AddControllers(); // Add support for API controllers
builder.Services.AddHttpContextAccessor();
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
});

// Disable antiforgery globally
builder.Services.Configure<Microsoft.AspNetCore.Mvc.MvcOptions>(options =>
{
    options.Filters.Add(new Microsoft.AspNetCore.Mvc.IgnoreAntiforgeryTokenAttribute());
});

// Add Cookie Authentication
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.LogoutPath = "/Account/Logout";
        options.AccessDeniedPath = "/Account/Login";
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
        options.SlidingExpiration = true;
        options.Cookie.HttpOnly = true;
        options.Cookie.IsEssential = true;
    });

// Add DbContext with SQL Server
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Payout and Payslip Services
builder.Services.AddScoped<CRM.Services.PayoutService>();
builder.Services.AddScoped<CRM.Services.PayslipService>();
builder.Services.AddScoped<CRM.Services.INotificationService, CRM.Services.NotificationService>();
builder.Services.AddHttpClient<CRM.Services.IWhatsAppService, CRM.Services.WhatsAppService>();
builder.Services.AddScoped<CRM.Services.PermissionService>();
builder.Services.AddScoped<CRM.Services.ViewPermissionService>();
builder.Services.AddScoped<CRM.Services.BrandingService>();
builder.Services.AddScoped<CRM.Services.FcmService>();
builder.Services.AddScoped<CRM.Services.SubscriptionService>();
builder.Services.AddScoped<CRM.Services.RazorpayService>();
builder.Services.AddScoped<CRM.Services.SeedDataService>();
builder.Services.AddScoped<CRM.Services.EmailService>();
builder.Services.AddHttpClient(); // For Facebook Marketing API calls

// Add Background Services
builder.Services.AddHostedService<CRM.Services.MonthlyPayoutBackgroundService>();
builder.Services.AddHostedService<CRM.Services.FollowUpReminderService>();
builder.Services.AddHostedService<CRM.BackgroundServices.PaymentStatusSyncService>();
// builder.Services.AddHostedService<CRM.BackgroundServices.FacebookLeadsBackgroundService>(); // Commented out for testing


var app = builder.Build();

// Configure the HTTP request pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();
app.UseSession();   // <-- IMPORTANT

app.UseAuthentication();  // <-- Add this BEFORE Authorization
app.UseAuthorization();

app.MapControllers(); // Map API controller routes
app.MapControllerRoute(
              name: "default",
              pattern: "{controller=Home}/{action=Landing}/{id?}");

app.Run();