-- Update default values for newly added columns
-- Run this AFTER ADD_Columns_Only.sql

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

PRINT 'Default values updated successfully!';