using CRM.Models;
using Microsoft.EntityFrameworkCore;

namespace CRM
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions options) : base(options)
        {

        }
        public DbSet<UserModel> Users { get; set; }
        public DbSet<UserProfile> UserProfiles { get; set; }
        public DbSet<UserSettings> UserSettings { get; set; }
        public DbSet<RolePermission> RolePermissions { get; set; }
        public DbSet<UserFavorite> UserFavorites { get; set; }
        public DbSet<UserRecentSearch> UserRecentSearches { get; set; }

        public DbSet<LeadModel> Leads { get; set; }
        public DbSet<FollowUpModel> LeadFollowUps { get; set; }
        public DbSet<LeadNoteModel> LeadNotes { get; set; }
        public DbSet<LeadUploadModel> LeadUploads { get; set; }
        public DbSet<LeadHistoryModel> LeadHistory { get; set; }
        public DbSet<LeadLogModel> LeadLogs { get; set; }


        // Property Management
        public DbSet<BuilderModel> Builders { get; set; }
        public DbSet<PropertyModel> Properties { get; set; }
        public DbSet<PropertyUploadModel> PropertyUploads { get; set; }
        public DbSet<PropertyDocumentModel> PropertyDocuments { get; set; }
        public DbSet<PropertyFlatModel> PropertyFlats { get; set; }
        public DbSet<PropertyAgentModel> PropertyAgents { get; set; }
        public DbSet<PropertyHistoryModel> PropertyHistory { get; set; }

        // Settings & Sales Management
        public DbSet<SettingsModel> Settings { get; set; }
        public DbSet<QuotationModel> Quotations { get; set; }
        public DbSet<QuotationItemModel> QuotationItems { get; set; }
        public DbSet<BookingModel> Bookings { get; set; }
        public DbSet<BookingDocumentModel> BookingDocuments { get; set; }
        public DbSet<PaymentPlanModel> PaymentPlans { get; set; }
        public DbSet<PaymentInstallmentModel> PaymentInstallments { get; set; }
        public DbSet<InvoiceModel> Invoices { get; set; }
        public DbSet<InvoiceItemModel> InvoiceItems { get; set; }
        public DbSet<PaymentModel> Payments { get; set; }
        
        // Landing Page & Public Leads
        public DbSet<ProjectInterest> ProjectInterests { get; set; }
        public DbSet<WebhookLeadModel> WebhookLeads { get; set; }
        public DbSet<NotificationModel> Notifications { get; set; }
        public DbSet<WhatsAppLogModel> WhatsAppLogs { get; set; }
        public DbSet<EmailSettingModel> EmailSettings { get; set; }

        // Onboarding & Management
        public DbSet<ChannelPartnerModel> ChannelPartners { get; set; }
        public DbSet<AgentModel> Agents { get; set; }
        public DbSet<AgentDocumentModel> AgentDocuments { get; set; }
        public DbSet<ChannelPartnerDocumentModel> ChannelPartnerDocuments { get; set; }
        public DbSet<AgentAttendanceModel> AgentAttendance { get; set; }
        public DbSet<AttendanceLogModel> AttendanceLog { get; set; }
        public DbSet<PartnerLeadModel> PartnerLeads { get; set; }
        public DbSet<AgentPayoutModel> AgentPayouts { get; set; }
        public DbSet<AgentCommissionLogModel> AgentCommissionLogs { get; set; }
        public DbSet<PartnerPayoutModel> PartnerPayouts { get; set; }
        public DbSet<ChannelPartnerCommissionLogModel> ChannelPartnerCommissionLogs { get; set; }
        public DbSet<ExpenseModel> Expenses { get; set; }
        public DbSet<RevenueModel> Revenues { get; set; }
        
        // Partner Handover System
        public DbSet<PartnerCommissionModel> PartnerCommissions { get; set; }
        public DbSet<LeadHandoverAuditModel> LeadHandoverAudit { get; set; }
        
        // Permission System
        public DbSet<ModuleModel> Modules { get; set; }
        public DbSet<PageModel> Pages { get; set; }
        public DbSet<PermissionModel> Permissions { get; set; }
        public DbSet<RolePagePermissionModel> RolePagePermissions { get; set; }
        
        // Branding System
        public DbSet<BrandingModel> Branding { get; set; }
        
        // Subscription System
        public DbSet<SubscriptionPlanModel> SubscriptionPlans { get; set; }
        public DbSet<PartnerSubscriptionModel> PartnerSubscriptions { get; set; }
        public DbSet<PaymentTransactionModel> PaymentTransactions { get; set; }
        public DbSet<SubscriptionAddonModel> SubscriptionAddons { get; set; }
        public DbSet<PartnerSubscriptionAddonModel> PartnerSubscriptionAddons { get; set; }
        
        // Financial Settings
        public DbSet<PaymentGatewayModel> PaymentGateways { get; set; }
        public DbSet<BankAccountModel> BankAccounts { get; set; }
        
        // New Extended Features (P0/P1/P2 Fixes)
        public DbSet<LeaveRequestModel> LeaveRequests { get; set; }
        public DbSet<BookingAmendmentModel> BookingAmendments { get; set; }
        public DbSet<EmailTemplateModel> EmailTemplates { get; set; }
        public DbSet<NotificationPreferenceModel> NotificationPreferences { get; set; }
        public DbSet<AuditLogModel> AuditLogs { get; set; }
        public DbSet<WebhookRetryQueueModel> WebhookRetryQueue { get; set; }
        public DbSet<DuplicateLeadModel> DuplicateLeads { get; set; }
        
        // P2 Medium Priority Features
        public DbSet<PropertyGalleryModel> PropertyGallery { get; set; }
        public DbSet<TaskTemplateModel> TaskTemplates { get; set; }
        public DbSet<RecurringTaskModel> RecurringTasks { get; set; }
        public DbSet<QuotationTemplateModel> QuotationTemplates { get; set; }
        public DbSet<QuotationVersionModel> QuotationVersions { get; set; }
        public DbSet<RecurringInvoiceModel> RecurringInvoices { get; set; }
        
        // P3 Advanced Features
        public DbSet<TwoFactorAuthModel> TwoFactorAuth { get; set; }
        public DbSet<LeadScoringRuleModel> LeadScoringRules { get; set; }
        public DbSet<PartnerHierarchyModel> PartnerHierarchy { get; set; }
        public DbSet<VirtualTourModel> VirtualTours { get; set; }
        public DbSet<QuotationApprovalModel> QuotationApprovals { get; set; }
        public DbSet<BiometricAttendanceModel> BiometricAttendance { get; set; }
        public DbSet<TaskDependencyModel> TaskDependencies { get; set; }
        public DbSet<CustomReportModel> CustomReports { get; set; }
        public DbSet<ZapierWebhookModel> ZapierWebhooks { get; set; }
        public DbSet<AILeadScoreModel> AILeadScores { get; set; }
        
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configure QuotationModel -> QuotationItemModel relationship
            modelBuilder.Entity<QuotationModel>()
                .HasMany(q => q.Items)
                .WithOne()
                .HasForeignKey(qi => qi.QuotationId)
                .OnDelete(DeleteBehavior.Cascade);

            // Configure BookingModel -> QuotationModel relationship
            modelBuilder.Entity<BookingModel>()
                .HasOne(b => b.Quotation)
                .WithMany()
                .HasForeignKey(b => b.QuotationId)
                .OnDelete(DeleteBehavior.SetNull);

            // Configure PaymentTransactionModel -> PartnerSubscriptionModel relationship
            // This prevents circular reference cascade issues
            modelBuilder.Entity<PaymentTransactionModel>()
                .HasOne(pt => pt.Subscription)
                .WithMany()
                .HasForeignKey(pt => pt.SubscriptionId)
                .OnDelete(DeleteBehavior.Restrict);

            base.OnModelCreating(modelBuilder);
        }
    }
}
