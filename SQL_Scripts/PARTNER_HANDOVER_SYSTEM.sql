-- Partner Lead Handover System - Complete Implementation
-- This implements the full partner workflow with commission tracking

-- 1. Add handover fields to Leads table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Leads]') AND name = 'HandoverStatus')
BEGIN
    ALTER TABLE [dbo].[Leads] ADD [HandoverStatus] NVARCHAR(50) DEFAULT 'Partner';
    PRINT 'Added HandoverStatus to Leads table';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Leads]') AND name = 'HandoverDate')
BEGIN
    ALTER TABLE [dbo].[Leads] ADD [HandoverDate] DATETIME NULL;
    PRINT 'Added HandoverDate to Leads table';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Leads]') AND name = 'AdminAssignedTo')
BEGIN
    ALTER TABLE [dbo].[Leads] ADD [AdminAssignedTo] INT NULL;
    PRINT 'Added AdminAssignedTo to Leads table';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Leads]') AND name = 'IsReadyToBook')
BEGIN
    ALTER TABLE [dbo].[Leads] ADD [IsReadyToBook] BIT DEFAULT 0;
    PRINT 'Added IsReadyToBook to Leads table';
END

-- 2. Add commission percentage to ChannelPartners table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ChannelPartners]') AND name = 'CommissionPercentage')
BEGIN
    ALTER TABLE [dbo].[ChannelPartners] ADD [CommissionPercentage] DECIMAL(5,2) DEFAULT 5.0;
    PRINT 'Added CommissionPercentage to ChannelPartners table';
END

-- 3. Create Partner Commission Tracking table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PartnerCommissions')
BEGIN
    CREATE TABLE [dbo].[PartnerCommissions] (
        [CommissionId] INT IDENTITY(1,1) PRIMARY KEY,
        [PartnerId] INT NOT NULL,
        [LeadId] INT NOT NULL,
        [BookingId] INT NULL,
        [BookingAmount] DECIMAL(18,2) NOT NULL,
        [CommissionPercentage] DECIMAL(5,2) NOT NULL,
        [CommissionAmount] DECIMAL(18,2) NOT NULL,
        [Status] NVARCHAR(50) DEFAULT 'Pending', -- Pending, Approved, Paid
        [CreatedOn] DATETIME DEFAULT GETDATE(),
        [ApprovedBy] INT NULL,
        [ApprovedOn] DATETIME NULL,
        [PaidOn] DATETIME NULL,
        [PaymentReference] NVARCHAR(100) NULL
    );
    PRINT 'Created PartnerCommissions table';
END

-- 4. Create Lead Handover Audit table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadHandoverAudit')
BEGIN
    CREATE TABLE [dbo].[LeadHandoverAudit] (
        [AuditId] INT IDENTITY(1,1) PRIMARY KEY,
        [LeadId] INT NOT NULL,
        [FromStatus] NVARCHAR(50) NULL,
        [ToStatus] NVARCHAR(50) NOT NULL,
        [HandoverDate] DATETIME DEFAULT GETDATE(),
        [HandedOverBy] INT NOT NULL, -- Partner UserId
        [AssignedTo] INT NULL, -- Admin Agent UserId
        [Notes] NVARCHAR(500) NULL
    );
    PRINT 'Created LeadHandoverAudit table';
END

-- 5. Update existing leads to have default handover status and IsReadyToBook
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Leads]') AND name = 'HandoverStatus')
BEGIN
    EXEC('UPDATE [dbo].[Leads] 
    SET [HandoverStatus] = CASE 
        WHEN [ChannelPartnerId] IS NOT NULL THEN ''Partner''
        ELSE ''Admin''
    END
    WHERE [HandoverStatus] IS NULL');
    PRINT 'Updated existing leads with default handover status';
END

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Leads]') AND name = 'IsReadyToBook')
BEGIN
    EXEC('UPDATE [dbo].[Leads] SET [IsReadyToBook] = 0 WHERE [IsReadyToBook] IS NULL');
    PRINT 'Updated existing leads with default IsReadyToBook value';
END

-- 6. Create indexes for performance
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_HandoverStatus') AND EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Leads]') AND name = 'HandoverStatus')
BEGIN
    EXEC('CREATE INDEX IX_Leads_HandoverStatus ON [dbo].[Leads] ([HandoverStatus], [ChannelPartnerId])');
    PRINT 'Created index on Leads HandoverStatus';
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_ReadyToBook') AND EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Leads]') AND name = 'IsReadyToBook')
BEGIN
    EXEC('CREATE INDEX IX_Leads_ReadyToBook ON [dbo].[Leads] ([IsReadyToBook], [ChannelPartnerId])');
    PRINT 'Created index on Leads IsReadyToBook';
END

-- 7. Set commission percentages for existing partners (default 5%)
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ChannelPartners]') AND name = 'CommissionPercentage')
BEGIN
    EXEC('UPDATE [dbo].[ChannelPartners] 
    SET [CommissionPercentage] = 5.0 
    WHERE [CommissionPercentage] IS NULL OR [CommissionPercentage] = 0');
    PRINT 'Updated existing partners with default commission percentage';
END

PRINT 'Partner Handover System database setup completed successfully!';
GO