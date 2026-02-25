-- Add ChannelPartnerId column to Settings table
-- This allows each Channel Partner to have their own settings

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Settings]') AND name = 'ChannelPartnerId')
BEGIN
    ALTER TABLE [dbo].[Settings]
    ADD [ChannelPartnerId] INT NULL;
    
    PRINT 'Added ChannelPartnerId column to Settings table';
END
ELSE
BEGIN
    PRINT 'ChannelPartnerId column already exists in Settings table';
END
GO

-- Verify the column was added
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Settings' AND COLUMN_NAME = 'ChannelPartnerId';
GO
