-- Add missing CreatedOn and UpdatedOn columns to SubscriptionPlans table

ALTER TABLE [dbo].[SubscriptionPlans] ADD [CreatedOn] datetime2 NULL;
ALTER TABLE [dbo].[SubscriptionPlans] ADD [UpdatedOn] datetime2 NULL;

PRINT 'DateTime columns added successfully!';