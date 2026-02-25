-- Add missing columns to existing SubscriptionPlans table
-- Step 1: Add all columns first

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [MaxLeadsPerMonth] int NULL;
    PRINT 'Added MaxLeadsPerMonth column';
END TRY
BEGIN CATCH
    PRINT 'MaxLeadsPerMonth column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [MaxStorageGB] int NULL;
    PRINT 'Added MaxStorageGB column';
END TRY
BEGIN CATCH
    PRINT 'MaxStorageGB column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasWhatsAppIntegration] bit NULL;
    PRINT 'Added HasWhatsAppIntegration column';
END TRY
BEGIN CATCH
    PRINT 'HasWhatsAppIntegration column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasFacebookIntegration] bit NULL;
    PRINT 'Added HasFacebookIntegration column';
END TRY
BEGIN CATCH
    PRINT 'HasFacebookIntegration column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasEmailIntegration] bit NULL;
    PRINT 'Added HasEmailIntegration column';
END TRY
BEGIN CATCH
    PRINT 'HasEmailIntegration column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasCustomAPIAccess] bit NULL;
    PRINT 'Added HasCustomAPIAccess column';
END TRY
BEGIN CATCH
    PRINT 'HasCustomAPIAccess column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasAdvancedReports] bit NULL;
    PRINT 'Added HasAdvancedReports column';
END TRY
BEGIN CATCH
    PRINT 'HasAdvancedReports column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasCustomReports] bit NULL;
    PRINT 'Added HasCustomReports column';
END TRY
BEGIN CATCH
    PRINT 'HasCustomReports column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasDataExport] bit NULL;
    PRINT 'Added HasDataExport column';
END TRY
BEGIN CATCH
    PRINT 'HasDataExport column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasPrioritySupport] bit NULL;
    PRINT 'Added HasPrioritySupport column';
END TRY
BEGIN CATCH
    PRINT 'HasPrioritySupport column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasPhoneSupport] bit NULL;
    PRINT 'Added HasPhoneSupport column';
END TRY
BEGIN CATCH
    PRINT 'HasPhoneSupport column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasDedicatedManager] bit NULL;
    PRINT 'Added HasDedicatedManager column';
END TRY
BEGIN CATCH
    PRINT 'HasDedicatedManager column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [SupportLevel] nvarchar(50) NULL;
    PRINT 'Added SupportLevel column';
END TRY
BEGIN CATCH
    PRINT 'SupportLevel column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [SortOrder] int NULL;
    PRINT 'Added SortOrder column';
END TRY
BEGIN CATCH
    PRINT 'SortOrder column already exists';
END CATCH

PRINT 'Column addition phase completed. Run the update script next.';