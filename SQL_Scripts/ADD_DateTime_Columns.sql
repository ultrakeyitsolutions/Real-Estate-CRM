-- Add missing CreatedOn and UpdatedOn columns to SubscriptionPlans table

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [CreatedOn] datetime2 NULL;
    PRINT 'Added CreatedOn column';
END TRY
BEGIN CATCH
    PRINT 'CreatedOn column already exists';
END CATCH

BEGIN TRY
    ALTER TABLE [dbo].[SubscriptionPlans] ADD [UpdatedOn] datetime2 NULL;
    PRINT 'Added UpdatedOn column';
END TRY
BEGIN CATCH
    PRINT 'UpdatedOn column already exists';
END CATCH

-- Set default values for existing records
IF COL_LENGTH('dbo.SubscriptionPlans', 'CreatedOn') IS NOT NULL
    UPDATE [dbo].[SubscriptionPlans] SET [CreatedOn] = GETDATE() WHERE [CreatedOn] IS NULL;

PRINT 'DateTime columns added successfully!';