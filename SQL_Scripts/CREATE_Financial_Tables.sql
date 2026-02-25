-- ================================================================
-- FINANCIAL SETTINGS TABLES CREATION SCRIPT
-- Creates PaymentGateways and BankAccounts tables
-- Date: January 2025
-- ================================================================

USE [YourCRMDatabase]
GO

PRINT 'Creating Financial Settings Tables...'
PRINT '======================================'

-- Create PaymentGateways table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PaymentGateways')
BEGIN
    CREATE TABLE [dbo].[PaymentGateways] (
        [GatewayId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [GatewayName] nvarchar(50) NOT NULL,
        [KeyId] nvarchar(200) NOT NULL,
        [KeySecret] nvarchar(500) NOT NULL,
        [WebhookSecret] nvarchar(500) NULL,
        [IsActive] bit NOT NULL DEFAULT 1,
        [CreatedOn] datetime2(7) NOT NULL DEFAULT GETDATE(),
        [UpdatedOn] datetime2(7) NULL,
        [CreatedBy] int NULL,
        [UpdatedBy] int NULL,
        CONSTRAINT FK_PaymentGateways_CreatedBy FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users]([UserId]),
        CONSTRAINT FK_PaymentGateways_UpdatedBy FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[Users]([UserId])
    );
    
    CREATE INDEX IX_PaymentGateways_GatewayName ON [dbo].[PaymentGateways]([GatewayName]);
    CREATE INDEX IX_PaymentGateways_IsActive ON [dbo].[PaymentGateways]([IsActive]);
    
    PRINT '✓ PaymentGateways table created successfully';
END
ELSE
BEGIN
    PRINT '- PaymentGateways table already exists';
END

-- Create BankAccounts table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BankAccounts')
BEGIN
    CREATE TABLE [dbo].[BankAccounts] (
        [AccountId] int IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [BankName] nvarchar(100) NOT NULL,
        [AccountNumber] nvarchar(50) NOT NULL,
        [AccountHolderName] nvarchar(100) NOT NULL,
        [IFSCCode] nvarchar(20) NOT NULL,
        [BranchName] nvarchar(100) NULL,
        [AccountType] nvarchar(20) NOT NULL DEFAULT 'Current',
        [IsActive] bit NOT NULL DEFAULT 1,
        [CreatedOn] datetime2(7) NOT NULL DEFAULT GETDATE(),
        [UpdatedOn] datetime2(7) NULL,
        [CreatedBy] int NULL,
        [UpdatedBy] int NULL,
        CONSTRAINT FK_BankAccounts_CreatedBy FOREIGN KEY ([CreatedBy]) REFERENCES [dbo].[Users]([UserId]),
        CONSTRAINT FK_BankAccounts_UpdatedBy FOREIGN KEY ([UpdatedBy]) REFERENCES [dbo].[Users]([UserId])
    );
    
    CREATE INDEX IX_BankAccounts_IsActive ON [dbo].[BankAccounts]([IsActive]);
    CREATE INDEX IX_BankAccounts_AccountNumber ON [dbo].[BankAccounts]([AccountNumber]);
    
    PRINT '✓ BankAccounts table created successfully';
END
ELSE
BEGIN
    PRINT '- BankAccounts table already exists';
END

PRINT ''
PRINT '======================================'
PRINT '✓ Financial Settings Tables Created!'
PRINT '======================================'
PRINT ''
PRINT 'Next Steps:'
PRINT '1. Update your connection string if needed'
PRINT '2. Test the Financial Settings functionality'
PRINT '3. Configure payment gateway credentials'
PRINT ''