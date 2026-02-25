-- Create SubscriptionAddons table to fix the SqlException
-- This script creates only the missing SubscriptionAddons table

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='SubscriptionAddons' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[SubscriptionAddons] (
        [AddonId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [AddonName] nvarchar(100) NOT NULL,
        [Description] nvarchar(500) NULL,
        [MonthlyPrice] decimal(18,2) NOT NULL,
        [YearlyPrice] decimal(18,2) NOT NULL,
        [AddonType] nvarchar(50) NOT NULL DEFAULT 'Feature',
        [AdditionalAgents] int NULL,
        [AdditionalStorageGB] int NULL,
        [AdditionalAPICallsPerMonth] int NULL,
        [AdditionalLeadsPerMonth] int NULL,
        [FeatureName] nvarchar(100) NULL,
        [IsActive] bit NOT NULL DEFAULT 1,
        [CreatedOn] datetime2(7) NOT NULL DEFAULT GETDATE(),
        [UpdatedOn] datetime2(7) NULL,
        [SortOrder] int NOT NULL DEFAULT 0
    );
    PRINT 'SubscriptionAddons table created successfully';
END
ELSE
BEGIN
    PRINT 'SubscriptionAddons table already exists';
END

-- Insert default subscription addons
IF NOT EXISTS (SELECT * FROM [dbo].[SubscriptionAddons])
BEGIN
    INSERT INTO [dbo].[SubscriptionAddons] (
        [AddonName], [Description], [MonthlyPrice], [YearlyPrice], [AddonType], 
        [AdditionalAgents], [AdditionalStorageGB], [AdditionalAPICallsPerMonth], [AdditionalLeadsPerMonth], 
        [FeatureName], [SortOrder]
    ) VALUES 
    ('Extra Agents Pack', 'Add 5 more agents to your plan', 499.00, 4999.00, 'Agents', 5, NULL, NULL, NULL, NULL, 1),
    ('Storage Boost', 'Additional 50GB storage space', 299.00, 2999.00, 'Storage', NULL, 50, NULL, NULL, NULL, 2),
    ('API Access', 'Custom API integration access', 999.00, 9999.00, 'Feature', NULL, NULL, 10000, NULL, 'Custom API Access', 3),
    ('Lead Boost', 'Additional 1000 leads per month', 799.00, 7999.00, 'Leads', NULL, NULL, NULL, 1000, NULL, 4),
    ('Premium Support', 'Priority phone and chat support', 1499.00, 14999.00, 'Feature', NULL, NULL, NULL, NULL, 'Premium Support', 5);
    
    PRINT 'Default subscription addons inserted successfully';
END
ELSE
BEGIN
    PRINT 'Subscription addons already exist';
END

PRINT 'SubscriptionAddons table setup completed!';