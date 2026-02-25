-- Create PartnerSubscriptionAddons table
-- This script creates the PartnerSubscriptionAddons table for addon subscriptions

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='PartnerSubscriptionAddons' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[PartnerSubscriptionAddons] (
        [PartnerAddonId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [SubscriptionId] int NOT NULL,
        [AddonId] int NOT NULL,
        [Amount] decimal(18,2) NOT NULL,
        [StartDate] datetime2(7) NOT NULL,
        [EndDate] datetime2(7) NOT NULL,
        [Status] nvarchar(20) NOT NULL DEFAULT 'Active',
        [CreatedOn] datetime2(7) NOT NULL DEFAULT GETDATE(),
        [UpdatedOn] datetime2(7) NULL,
        FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[PartnerSubscriptions]([SubscriptionId]),
        FOREIGN KEY ([AddonId]) REFERENCES [dbo].[SubscriptionAddons]([AddonId])
    );
    PRINT 'PartnerSubscriptionAddons table created successfully';
END
ELSE
BEGIN
    PRINT 'PartnerSubscriptionAddons table already exists';
END

PRINT 'PartnerSubscriptionAddons table setup completed!';