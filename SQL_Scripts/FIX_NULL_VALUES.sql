-- Fix NULL values in IsReadyToBook column
UPDATE [dbo].[Leads] SET [IsReadyToBook] = 0 WHERE [IsReadyToBook] IS NULL;

-- Ensure all existing leads have proper HandoverStatus
UPDATE [dbo].[Leads] 
SET [HandoverStatus] = CASE 
    WHEN [ChannelPartnerId] IS NOT NULL THEN 'Partner'
    ELSE 'Admin'
END
WHERE [HandoverStatus] IS NULL;

PRINT 'Fixed NULL values in Leads table';