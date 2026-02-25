-- Simple step-by-step column addition for SubscriptionPlans table
-- Run each ALTER TABLE statement individually

-- Step 1: Add AnnualPrice
ALTER TABLE [dbo].[SubscriptionPlans] ADD [AnnualPrice] decimal(18,2) NULL;

-- Step 2: Add MaxLeadsPerMonth  
ALTER TABLE [dbo].[SubscriptionPlans] ADD [MaxLeadsPerMonth] int NULL;

-- Step 3: Add MaxStorageGB
ALTER TABLE [dbo].[SubscriptionPlans] ADD [MaxStorageGB] int NULL;

-- Step 4: Add integration flags
ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasWhatsAppIntegration] bit NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasFacebookIntegration] bit NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasEmailIntegration] bit NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasCustomAPIAccess] bit NULL;

-- Step 5: Add report flags
ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasAdvancedReports] bit NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasCustomReports] bit NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasDataExport] bit NULL;

-- Step 6: Add support flags
ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasPrioritySupport] bit NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasPhoneSupport] bit NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasDedicatedManager] bit NULL;

-- Step 7: Add support level and sort order
ALTER TABLE [dbo].[SubscriptionPlans] ADD [SupportLevel] nvarchar(50) NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ADD [SortOrder] int NULL;

-- Step 8: Update default values
UPDATE [dbo].[SubscriptionPlans] SET [AnnualPrice] = [MonthlyPrice] * 10 WHERE [AnnualPrice] IS NULL;
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

-- Step 9: Make columns NOT NULL after setting defaults
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [AnnualPrice] decimal(18,2) NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [MaxLeadsPerMonth] int NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [MaxStorageGB] int NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [HasWhatsAppIntegration] bit NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [HasFacebookIntegration] bit NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [HasEmailIntegration] bit NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [HasCustomAPIAccess] bit NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [HasAdvancedReports] bit NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [HasCustomReports] bit NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [HasDataExport] bit NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [HasPrioritySupport] bit NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [HasPhoneSupport] bit NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [HasDedicatedManager] bit NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [SupportLevel] nvarchar(50) NOT NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ALTER COLUMN [SortOrder] int NOT NULL;

PRINT 'All columns added successfully to SubscriptionPlans table!';