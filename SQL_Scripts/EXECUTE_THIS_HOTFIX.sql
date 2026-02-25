-- ============================================================================
-- COMPREHENSIVE HOTFIX: Add All Missing Columns
-- Date: January 3, 2026
-- Purpose: Fix all "Invalid column name" SQL exceptions
-- ============================================================================

USE [RealEstateCRM]
GO

PRINT '========================================';
PRINT 'Starting Comprehensive Hotfix';
PRINT '========================================';
GO

-- ============================================================================
-- 1. PaymentTransactions: Add WebhookEventId
-- ============================================================================
PRINT 'Checking PaymentTransactions.WebhookEventId...';

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('PaymentTransactions') 
    AND name = 'WebhookEventId'
)
BEGIN
    ALTER TABLE PaymentTransactions
    ADD WebhookEventId NVARCHAR(200) NULL;
    
    PRINT '✓ Added WebhookEventId to PaymentTransactions';
END
ELSE
BEGIN
    PRINT '✓ WebhookEventId already exists';
END
GO

-- Create index for webhook event lookups
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_PaymentTransactions_WebhookEventId' 
    AND object_id = OBJECT_ID('PaymentTransactions')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_PaymentTransactions_WebhookEventId
    ON PaymentTransactions(WebhookEventId)
    WHERE WebhookEventId IS NOT NULL;
    
    PRINT '✓ Created index IX_PaymentTransactions_WebhookEventId';
END
GO

-- ============================================================================
-- 2. Bookings: Add RowVersion for Concurrency Control
-- ============================================================================
PRINT 'Checking Bookings.RowVersion...';

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('Bookings') 
    AND name = 'RowVersion'
)
BEGIN
    ALTER TABLE Bookings
    ADD RowVersion ROWVERSION;
    
    PRINT '✓ Added RowVersion to Bookings';
END
ELSE
BEGIN
    PRINT '✓ RowVersion already exists';
END
GO

-- ============================================================================
-- 3. AgentDocuments: Add Verification Fields
-- ============================================================================
PRINT 'Checking AgentDocuments verification fields...';

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('AgentDocuments') 
    AND name = 'VerificationStatus'
)
BEGIN
    ALTER TABLE AgentDocuments
    ADD VerificationStatus NVARCHAR(20) NOT NULL DEFAULT 'Pending';
    
    PRINT '✓ Added VerificationStatus to AgentDocuments';
END
ELSE
BEGIN
    PRINT '✓ VerificationStatus already exists';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('AgentDocuments') 
    AND name = 'VerifiedBy'
)
BEGIN
    ALTER TABLE AgentDocuments
    ADD VerifiedBy INT NULL;
    
    PRINT '✓ Added VerifiedBy to AgentDocuments';
END
ELSE
BEGIN
    PRINT '✓ VerifiedBy already exists';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('AgentDocuments') 
    AND name = 'VerifiedOn'
)
BEGIN
    ALTER TABLE AgentDocuments
    ADD VerifiedOn DATETIME NULL;
    
    PRINT '✓ Added VerifiedOn to AgentDocuments';
END
ELSE
BEGIN
    PRINT '✓ VerifiedOn already exists';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('AgentDocuments') 
    AND name = 'RejectionReason'
)
BEGIN
    ALTER TABLE AgentDocuments
    ADD RejectionReason NVARCHAR(500) NULL;
    
    PRINT '✓ Added RejectionReason to AgentDocuments';
END
ELSE
BEGIN
    PRINT '✓ RejectionReason already exists';
END
GO

-- ============================================================================
-- 4. ChannelPartnerDocuments: Add Verification Fields
-- ============================================================================
PRINT 'Checking ChannelPartnerDocuments verification fields...';

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('ChannelPartnerDocuments') 
    AND name = 'VerificationStatus'
)
BEGIN
    ALTER TABLE ChannelPartnerDocuments
    ADD VerificationStatus NVARCHAR(20) NOT NULL DEFAULT 'Pending';
    
    PRINT '✓ Added VerificationStatus to ChannelPartnerDocuments';
END
ELSE
BEGIN
    PRINT '✓ VerificationStatus already exists';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('ChannelPartnerDocuments') 
    AND name = 'VerifiedBy'
)
BEGIN
    ALTER TABLE ChannelPartnerDocuments
    ADD VerifiedBy INT NULL;
    
    PRINT '✓ Added VerifiedBy to ChannelPartnerDocuments';
END
ELSE
BEGIN
    PRINT '✓ VerifiedBy already exists';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('ChannelPartnerDocuments') 
    AND name = 'VerifiedOn'
)
BEGIN
    ALTER TABLE ChannelPartnerDocuments
    ADD VerifiedOn DATETIME NULL;
    
    PRINT '✓ Added VerifiedOn to ChannelPartnerDocuments';
END
ELSE
BEGIN
    PRINT '✓ VerifiedOn already exists';
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('ChannelPartnerDocuments') 
    AND name = 'RejectionReason'
)
BEGIN
    ALTER TABLE ChannelPartnerDocuments
    ADD RejectionReason NVARCHAR(500) NULL;
    
    PRINT '✓ Added RejectionReason to ChannelPartnerDocuments';
END
ELSE
BEGIN
    PRINT '✓ RejectionReason already exists';
END
GO

-- ============================================================================
-- 5. Create WebhookRetryQueue Table (if not exists)
-- ============================================================================
PRINT 'Checking WebhookRetryQueue table...';

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WebhookRetryQueue')
BEGIN
    CREATE TABLE WebhookRetryQueue (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        WebhookEventId NVARCHAR(200) NOT NULL,
        WebhookUrl NVARCHAR(500) NOT NULL,
        PayloadJson NVARCHAR(MAX) NOT NULL,
        RetryCount INT NOT NULL DEFAULT 0,
        MaxRetries INT NOT NULL DEFAULT 5,
        NextRetryAt DATETIME NOT NULL,
        LastAttemptAt DATETIME NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        ErrorMessage NVARCHAR(MAX) NULL,
        CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
        CompletedAt DATETIME NULL
    );
    
    CREATE NONCLUSTERED INDEX IX_WebhookRetryQueue_Status_NextRetryAt
    ON WebhookRetryQueue(Status, NextRetryAt);
    
    CREATE NONCLUSTERED INDEX IX_WebhookRetryQueue_WebhookEventId
    ON WebhookRetryQueue(WebhookEventId);
    
    PRINT '✓ Created WebhookRetryQueue table';
END
ELSE
BEGIN
    PRINT '✓ WebhookRetryQueue table already exists';
END
GO

-- ============================================================================
-- VERIFICATION: List all changes
-- ============================================================================
PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION RESULTS';
PRINT '========================================';

-- PaymentTransactions
SELECT 'PaymentTransactions' AS TableName, 
       COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PaymentTransactions' 
AND COLUMN_NAME = 'WebhookEventId';

-- Bookings
SELECT 'Bookings' AS TableName,
       COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Bookings' 
AND COLUMN_NAME = 'RowVersion';

-- AgentDocuments
SELECT 'AgentDocuments' AS TableName,
       COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AgentDocuments' 
AND COLUMN_NAME IN ('VerificationStatus', 'VerifiedBy', 'VerifiedOn', 'RejectionReason');

-- ChannelPartnerDocuments
SELECT 'ChannelPartnerDocuments' AS TableName,
       COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ChannelPartnerDocuments' 
AND COLUMN_NAME IN ('VerificationStatus', 'VerifiedBy', 'VerifiedOn', 'RejectionReason');

-- WebhookRetryQueue
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'WebhookRetryQueue')
BEGIN
    SELECT 'WebhookRetryQueue' AS TableName, COUNT(*) AS RecordCount FROM WebhookRetryQueue;
END
GO

PRINT '';
PRINT '========================================';
PRINT '✓ HOTFIX COMPLETED SUCCESSFULLY';
PRINT '========================================';
GO
