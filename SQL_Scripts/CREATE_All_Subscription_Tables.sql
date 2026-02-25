-- Complete Subscription System Tables Creation
-- This script creates all missing subscription tables

-- Create PartnerSubscriptions table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='PartnerSubscriptions' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[PartnerSubscriptions] (
        [SubscriptionId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ChannelPartnerId] int NOT NULL,
        [PlanId] int NOT NULL,
        [BillingCycle] nvarchar(20) NOT NULL DEFAULT 'Monthly',
        [Amount] decimal(18,2) NOT NULL,
        [StartDate] datetime2(7) NOT NULL,
        [EndDate] datetime2(7) NOT NULL,
        [Status] nvarchar(20) NOT NULL DEFAULT 'Active',
        [CancelledOn] datetime2(7) NULL,
        [CancellationReason] nvarchar(max) NULL,
        [AutoRenew] bit NOT NULL DEFAULT 1,
        [PaymentTransactionId] nvarchar(100) NULL,
        [PaymentMethod] nvarchar(50) NULL DEFAULT 'Razorpay',
        [LastPaymentDate] datetime2(7) NULL,
        [NextPaymentDate] datetime2(7) NULL,
        [CurrentAgentCount] int NOT NULL DEFAULT 0,
        [CurrentMonthLeads] int NOT NULL DEFAULT 0,
        [CurrentStorageUsedGB] decimal(18,2) NOT NULL DEFAULT 0,
        [CreatedOn] datetime2(7) NOT NULL DEFAULT GETDATE(),
        [UpdatedOn] datetime2(7) NULL,
        [CreatedBy] int NULL,
        [UpdatedBy] int NULL,
        FOREIGN KEY ([ChannelPartnerId]) REFERENCES [dbo].[ChannelPartners]([PartnerId]),
        FOREIGN KEY ([PlanId]) REFERENCES [dbo].[SubscriptionPlans]([PlanId])
    );
    PRINT 'PartnerSubscriptions table created successfully';
END
ELSE
BEGIN
    PRINT 'PartnerSubscriptions table already exists';
END

-- Create PaymentTransactions table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='PaymentTransactions' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[PaymentTransactions] (
        [TransactionId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [ChannelPartnerId] int NOT NULL,
        [SubscriptionId] int NULL,
        [TransactionReference] nvarchar(100) NOT NULL,
        [RazorpayPaymentId] nvarchar(100) NULL,
        [RazorpayOrderId] nvarchar(100) NULL,
        [RazorpaySignature] nvarchar(100) NULL,
        [Amount] decimal(18,2) NOT NULL,
        [Currency] nvarchar(10) NOT NULL DEFAULT 'INR',
        [TransactionType] nvarchar(20) NOT NULL DEFAULT 'Payment',
        [Status] nvarchar(20) NOT NULL DEFAULT 'Pending',
        [PaymentMethod] nvarchar(50) NOT NULL DEFAULT 'Razorpay',
        [TransactionDate] datetime2(7) NOT NULL DEFAULT GETDATE(),
        [CompletedDate] datetime2(7) NULL,
        [Description] nvarchar(500) NULL,
        [FailureReason] nvarchar(1000) NULL,
        [PlanName] nvarchar(100) NULL,
        [BillingCycle] nvarchar(20) NULL,
        [InvoiceNumber] nvarchar(50) NULL,
        [InvoiceDate] datetime2(7) NULL,
        [TaxAmount] decimal(18,2) NULL DEFAULT 0,
        [DiscountAmount] decimal(18,2) NULL DEFAULT 0,
        [NetAmount] decimal(18,2) NOT NULL,
        [CreatedOn] datetime2(7) NOT NULL DEFAULT GETDATE(),
        [UpdatedOn] datetime2(7) NULL,
        FOREIGN KEY ([ChannelPartnerId]) REFERENCES [dbo].[ChannelPartners]([PartnerId])
    );
    PRINT 'PaymentTransactions table created successfully';
END
ELSE
BEGIN
    PRINT 'PaymentTransactions table already exists';
END

-- Create SubscriptionAddons table
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

-- Create PartnerSubscriptionAddons table
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

-- Add foreign key constraint to PaymentTransactions after PartnerSubscriptions is created
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PaymentTransactions_PartnerSubscriptions')
BEGIN
    ALTER TABLE [dbo].[PaymentTransactions]
    ADD CONSTRAINT FK_PaymentTransactions_PartnerSubscriptions
    FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[PartnerSubscriptions]([SubscriptionId]);
    PRINT 'Foreign key constraint added to PaymentTransactions';
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

PRINT 'All subscription system tables created successfully!';