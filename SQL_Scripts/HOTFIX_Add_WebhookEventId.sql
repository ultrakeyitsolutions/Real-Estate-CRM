-- HOTFIX: Add WebhookEventId column to PaymentTransactions table
-- Date: January 3, 2026
-- Purpose: Fix SqlException - Invalid column name 'WebhookEventId'

USE [RealEstateCRM]
GO

-- Check if column already exists before adding
IF NOT EXISTS (
    SELECT 1 
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('PaymentTransactions') 
    AND name = 'WebhookEventId'
)
BEGIN
    ALTER TABLE PaymentTransactions
    ADD WebhookEventId NVARCHAR(200) NULL;
    
    PRINT 'WebhookEventId column added to PaymentTransactions table';
END
ELSE
BEGIN
    PRINT 'WebhookEventId column already exists in PaymentTransactions table';
END
GO

-- Create index for faster webhook event lookups (prevent duplicates)
IF NOT EXISTS (
    SELECT 1 
    FROM sys.indexes 
    WHERE name = 'IX_PaymentTransactions_WebhookEventId' 
    AND object_id = OBJECT_ID('PaymentTransactions')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_PaymentTransactions_WebhookEventId
    ON PaymentTransactions(WebhookEventId)
    WHERE WebhookEventId IS NOT NULL;
    
    PRINT 'Index IX_PaymentTransactions_WebhookEventId created';
END
GO

-- Verify the column was added
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PaymentTransactions' 
AND COLUMN_NAME = 'WebhookEventId';
GO

PRINT 'HOTFIX completed successfully!';
GO
