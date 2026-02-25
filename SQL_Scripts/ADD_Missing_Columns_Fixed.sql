-- Add missing columns to existing SubscriptionPlans table
-- Current columns: PlanId, PlanName, Description, PlanType, MaxAgents, MonthlyPrice, YearlyPrice, Features, IsActive, CreatedDate

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [MaxLeadsPerMonth] int NULL;
    PRINT 'Added MaxLeadsPerMonth column';
END TRY
BEGIN CATCH
    PRINT 'MaxLeadsPerMonth column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [MaxStorageGB] int NULL;
    PRINT 'Added MaxStorageGB column';
END TRY
BEGIN CATCH
    PRINT 'MaxStorageGB column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasWhatsAppIntegration] bit NULL;
    PRINT 'Added HasWhatsAppIntegration column';
END TRY
BEGIN CATCH
    PRINT 'HasWhatsAppIntegration column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasFacebookIntegration] bit NULL;
    PRINT 'Added HasFacebookIntegration column';
END TRY
BEGIN CATCH
    PRINT 'HasFacebookIntegration column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasEmailIntegration] bit NULL;
    PRINT 'Added HasEmailIntegration column';
END TRY
BEGIN CATCH
    PRINT 'HasEmailIntegration column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasCustomAPIAccess] bit NULL;
    PRINT 'Added HasCustomAPIAccess column';
END TRY
BEGIN CATCH
    PRINT 'HasCustomAPIAccess column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasAdvancedReports] bit NULL;
    PRINT 'Added HasAdvancedReports column';
END TRY
BEGIN CATCH
    PRINT 'HasAdvancedReports column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasCustomReports] bit NULL;
    PRINT 'Added HasCustomReports column';
END TRY
BEGIN CATCH
    PRINT 'HasCustomReports column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasDataExport] bit NULL;
    PRINT 'Added HasDataExport column';
END TRY
BEGIN CATCH
    PRINT 'HasDataExport column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasPrioritySupport] bit NULL;
    PRINT 'Added HasPrioritySupport column';
END TRY
BEGIN CATCH
    PRINT 'HasPrioritySupport column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasPhoneSupport] bit NULL;
    PRINT 'Added HasPhoneSupport column';
END TRY
BEGIN CATCH
    PRINT 'HasPhoneSupport column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasDedicatedManager] bit NULL;
    PRINT 'Added HasDedicatedManager column';
END TRY
BEGIN CATCH
    PRINT 'HasDedicatedManager column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [SupportLevel] nvarchar(50) NULL;
    PRINT 'Added SupportLevel column';
END TRY
BEGIN CATCH
    PRINT 'SupportLevel column already exists or error occurred';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [SortOrder] int NULL;
    PRINT 'Added SortOrder column';
END TRY
BEGIN CATCH
    PRINT 'SortOrder column already exists or error occurred';
END CATCH

-- Update default values for new columns
UPDATE [dbo].[SubscriptionPlans] SET [MaxLeadsPerMonth] = 500 WHERE [MaxLeadsPerMonth] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [MaxStorageGB] = 1 WHERE [MaxStorageGB] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [HasWhatsAppIntegration] = 1 WHERE [HasWhatsAppIntegration] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [HasFacebookIntegration] = 0 WHERE [HasFacebookIntegration] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [HasEmailIntegration] = 0 WHERE [HasEmailIntegration] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [HasCustomAPIAccess] = 0 WHERE [HasCustomAPIAccess] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [HasAdvancedReports] = 0 WHERE [HasAdvancedReports] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [HasCustomReports] = 0 WHERE [HasCustomReports] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [HasDataExport] = 0 WHERE [HasDataExport] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [HasPrioritySupport] = 0 WHERE [HasPrioritySupport] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [HasPhoneSupport] = 0 WHERE [HasPhoneSupport] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [HasDedicatedManager] = 0 WHERE [HasDedicatedManager] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [SupportLevel] = 'Email' WHERE [SupportLevel] IS NULL;
UPDATE [dbo].[SubscriptionPlans] SET [SortOrder] = 0 WHERE [SortOrder] IS NULL;

PRINT 'All missing columns added and updated successfully!';