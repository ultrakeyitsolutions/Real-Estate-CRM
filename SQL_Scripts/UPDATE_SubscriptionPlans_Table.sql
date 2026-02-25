-- =============================================
-- Update SubscriptionPlans Table with Missing Columns
-- =============================================

-- Check if SubscriptionPlans table exists and add missing columns
IF EXISTS (SELECT * FROM sysobjects WHERE name='SubscriptionPlans' AND xtype='U')
BEGIN
    PRINT 'SubscriptionPlans table exists, checking for missing columns...';
    
    -- Add AnnualPrice column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'AnnualPrice')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [AnnualPrice] decimal(18,2) NOT NULL DEFAULT 0;
        PRINT 'Added AnnualPrice column';
    END
    
    -- Add MaxLeadsPerMonth column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'MaxLeadsPerMonth')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [MaxLeadsPerMonth] int NOT NULL DEFAULT 500;
        PRINT 'Added MaxLeadsPerMonth column';
    END
    
    -- Add MaxStorageGB column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'MaxStorageGB')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [MaxStorageGB] int NOT NULL DEFAULT 1;
        PRINT 'Added MaxStorageGB column';
    END
    
    -- Add HasWhatsAppIntegration column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'HasWhatsAppIntegration')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasWhatsAppIntegration] bit NOT NULL DEFAULT 1;
        PRINT 'Added HasWhatsAppIntegration column';
    END
    
    -- Add HasFacebookIntegration column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'HasFacebookIntegration')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasFacebookIntegration] bit NOT NULL DEFAULT 0;
        PRINT 'Added HasFacebookIntegration column';
    END
    
    -- Add HasEmailIntegration column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'HasEmailIntegration')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasEmailIntegration] bit NOT NULL DEFAULT 0;
        PRINT 'Added HasEmailIntegration column';
    END
    
    -- Add HasCustomAPIAccess column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'HasCustomAPIAccess')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasCustomAPIAccess] bit NOT NULL DEFAULT 0;
        PRINT 'Added HasCustomAPIAccess column';
    END
    
    -- Add HasAdvancedReports column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'HasAdvancedReports')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasAdvancedReports] bit NOT NULL DEFAULT 0;
        PRINT 'Added HasAdvancedReports column';
    END
    
    -- Add HasCustomReports column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'HasCustomReports')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasCustomReports] bit NOT NULL DEFAULT 0;
        PRINT 'Added HasCustomReports column';
    END
    
    -- Add HasDataExport column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'HasDataExport')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasDataExport] bit NOT NULL DEFAULT 0;
        PRINT 'Added HasDataExport column';
    END
    
    -- Add HasPrioritySupport column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'HasPrioritySupport')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasPrioritySupport] bit NOT NULL DEFAULT 0;
        PRINT 'Added HasPrioritySupport column';
    END
    
    -- Add HasPhoneSupport column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'HasPhoneSupport')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasPhoneSupport] bit NOT NULL DEFAULT 0;
        PRINT 'Added HasPhoneSupport column';
    END
    
    -- Add HasDedicatedManager column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'HasDedicatedManager')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [HasDedicatedManager] bit NOT NULL DEFAULT 0;
        PRINT 'Added HasDedicatedManager column';
    END
    
    -- Add SupportLevel column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'SupportLevel')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [SupportLevel] nvarchar(50) NOT NULL DEFAULT 'Email';
        PRINT 'Added SupportLevel column';
    END
    
    -- Add SortOrder column if it doesn't exist
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'SortOrder')
    BEGIN
        ALTER TABLE [dbo].[SubscriptionPlans] ADD [SortOrder] int NOT NULL DEFAULT 0;
        PRINT 'Added SortOrder column';
    END
    
    -- Update AnnualPrice for existing plans if they are 0 (only if column exists)
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('SubscriptionPlans') AND name = 'AnnualPrice')
    BEGIN
        UPDATE [dbo].[SubscriptionPlans] 
        SET [AnnualPrice] = [MonthlyPrice] * 10
        WHERE [AnnualPrice] = 0;
        PRINT 'Updated AnnualPrice for existing plans';
    END
    
    PRINT 'SubscriptionPlans table updated successfully with all required columns';
END
ELSE
BEGIN
    PRINT 'SubscriptionPlans table does not exist. Please run the CREATE_Subscription_System.sql script first.';
END

PRINT '==============================================';
PRINT 'SubscriptionPlans Table Update Completed!';
PRINT '==============================================';