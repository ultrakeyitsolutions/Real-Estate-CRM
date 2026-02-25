-- =============================================
-- Subscription System Database Setup
-- =============================================

-- Create SubscriptionPlans table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='SubscriptionPlans' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[SubscriptionPlans] (
        [PlanId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [PlanName] nvarchar(100) NOT NULL,
        [Description] nvarchar(500) NULL,
        [MonthlyPrice] decimal(18,2) NOT NULL,
        [AnnualPrice] decimal(18,2) NOT NULL,
        [MaxAgents] int NOT NULL DEFAULT 2,
        [MaxLeadsPerMonth] int NOT NULL DEFAULT 500,
        [MaxStorageGB] int NOT NULL DEFAULT 1,
        [HasWhatsAppIntegration] bit NOT NULL DEFAULT 1,
        [HasFacebookIntegration] bit NOT NULL DEFAULT 0,
        [HasEmailIntegration] bit NOT NULL DEFAULT 0,
        [HasCustomAPIAccess] bit NOT NULL DEFAULT 0,
        [HasAdvancedReports] bit NOT NULL DEFAULT 0,
        [HasCustomReports] bit NOT NULL DEFAULT 0,
        [HasDataExport] bit NOT NULL DEFAULT 0,
        [HasPrioritySupport] bit NOT NULL DEFAULT 0,
        [HasPhoneSupport] bit NOT NULL DEFAULT 0,
        [HasDedicatedManager] bit NOT NULL DEFAULT 0,
        [SupportLevel] nvarchar(50) NOT NULL DEFAULT 'Email',
        [IsActive] bit NOT NULL DEFAULT 1,
        [CreatedOn] datetime2(7) NOT NULL DEFAULT GETDATE(),
        [UpdatedOn] datetime2(7) NULL,
        [PlanType] nvarchar(20) NOT NULL DEFAULT 'Basic',
        [SortOrder] int NOT NULL DEFAULT 0
    );
    PRINT 'SubscriptionPlans table created successfully';
END
ELSE
BEGIN
    PRINT 'SubscriptionPlans table already exists';
END

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
        FOREIGN KEY ([ChannelPartnerId]) REFERENCES [dbo].[ChannelPartners]([PartnerId]),
        FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[PartnerSubscriptions]([SubscriptionId])
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
        [AnnualPrice] decimal(18,2) NOT NULL,
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

-- Insert default subscription plans
IF NOT EXISTS (SELECT * FROM [dbo].[SubscriptionPlans])
BEGIN
    INSERT INTO [dbo].[SubscriptionPlans] (
        [PlanName], [Description], [MonthlyPrice], [AnnualPrice], [MaxAgents], [MaxLeadsPerMonth], [MaxStorageGB],
        [HasWhatsAppIntegration], [HasFacebookIntegration], [HasEmailIntegration], [HasCustomAPIAccess],
        [HasAdvancedReports], [HasCustomReports], [HasDataExport], [HasPrioritySupport], [HasPhoneSupport], [HasDedicatedManager],
        [SupportLevel], [PlanType], [SortOrder]
    ) VALUES 
    -- Basic Plan
    (
        'Basic Plan', 
        'Perfect for small teams getting started with CRM', 
        999.00, 9999.00, 2, 500, 1,
        1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        'Email', 'Basic', 1
    ),
    -- Standard Plan
    (
        'Standard Plan', 
        'Ideal for growing businesses with advanced features', 
        2999.00, 29999.00, 10, 2000, 10,
        1, 1, 1, 0, 1, 0, 1, 1, 0, 0,
        'Chat', 'Standard', 2
    ),
    -- Enterprise Plan
    (
        'Enterprise Plan', 
        'Complete solution for large organizations', 
        9999.00, 99999.00, -1, -1, 100,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        'Dedicated', 'Enterprise', 3
    );
    
    PRINT 'Default subscription plans inserted successfully';
END
ELSE
BEGIN
    PRINT 'Subscription plans already exist';
END

-- Insert default subscription addons
IF NOT EXISTS (SELECT * FROM [dbo].[SubscriptionAddons])
BEGIN
    INSERT INTO [dbo].[SubscriptionAddons] (
        [AddonName], [Description], [MonthlyPrice], [AnnualPrice], [AddonType], 
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

-- Add indexes for better performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PartnerSubscriptions_ChannelPartnerId_Status')
BEGIN
    CREATE INDEX IX_PartnerSubscriptions_ChannelPartnerId_Status ON [dbo].[PartnerSubscriptions] ([ChannelPartnerId], [Status]);
    PRINT 'Index IX_PartnerSubscriptions_ChannelPartnerId_Status created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PaymentTransactions_ChannelPartnerId_Status')
BEGIN
    CREATE INDEX IX_PaymentTransactions_ChannelPartnerId_Status ON [dbo].[PaymentTransactions] ([ChannelPartnerId], [Status]);
    PRINT 'Index IX_PaymentTransactions_ChannelPartnerId_Status created';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PaymentTransactions_TransactionDate')
BEGIN
    CREATE INDEX IX_PaymentTransactions_TransactionDate ON [dbo].[PaymentTransactions] ([TransactionDate] DESC);
    PRINT 'Index IX_PaymentTransactions_TransactionDate created';
END

PRINT '==============================================';
PRINT 'Subscription System Setup Completed Successfully!';
PRINT '==============================================';
PRINT 'Tables Created:';
PRINT '- SubscriptionPlans (3 default plans)';
PRINT '- PartnerSubscriptions';
PRINT '- PaymentTransactions';
PRINT '- SubscriptionAddons (5 default addons)';
PRINT '- PartnerSubscriptionAddons';
PRINT '';
PRINT 'Default Plans:';
PRINT '- Basic Plan: ₹999/month, 2 agents, 500 leads/month';
PRINT '- Standard Plan: ₹2999/month, 10 agents, 2000 leads/month';
PRINT '- Enterprise Plan: ₹9999/month, unlimited agents & leads';
PRINT '==============================================';