-- Add ChannelPartnerId column to Revenues table

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Revenues]') AND name = 'ChannelPartnerId')
BEGIN
    ALTER TABLE [dbo].[Revenues]
    ADD [ChannelPartnerId] INT NULL;
    
    PRINT 'Added ChannelPartnerId column to Revenues table';
END
ELSE
BEGIN
    PRINT 'ChannelPartnerId column already exists in Revenues table';
END
GO
