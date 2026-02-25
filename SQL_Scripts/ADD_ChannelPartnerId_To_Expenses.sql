-- Add ChannelPartnerId column to Expenses table
-- This allows Partner filtering for expenses

-- Add ChannelPartnerId column (nullable for backward compatibility)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Expenses]') AND name = 'ChannelPartnerId')
BEGIN
    ALTER TABLE [dbo].[Expenses]
    ADD [ChannelPartnerId] INT NULL;
    
    PRINT 'Added ChannelPartnerId column to Expenses table';
END
ELSE
BEGIN
    PRINT 'ChannelPartnerId column already exists in Expenses table';
END
GO

-- Verify the column was added
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Expenses' AND COLUMN_NAME = 'ChannelPartnerId';
GO
