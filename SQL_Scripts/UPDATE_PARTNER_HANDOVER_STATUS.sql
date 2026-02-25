-- Update existing partner leads to have correct HandoverStatus
-- This script sets HandoverStatus = 'Partner' for all leads created by partners

UPDATE Leads 
SET HandoverStatus = 'Partner',
    IsReadyToBook = 0
WHERE ChannelPartnerId IS NOT NULL 
  AND (HandoverStatus IS NULL OR HandoverStatus = '');

-- Update admin leads to have correct HandoverStatus
UPDATE Leads 
SET HandoverStatus = 'Admin'
WHERE ChannelPartnerId IS NULL 
  AND (HandoverStatus IS NULL OR HandoverStatus = '');

-- Verify the updates
SELECT 
    COUNT(*) as TotalLeads,
    HandoverStatus,
    CASE 
        WHEN ChannelPartnerId IS NOT NULL THEN 'Partner Lead'
        ELSE 'Admin Lead'
    END as LeadType
FROM Leads 
GROUP BY HandoverStatus, 
         CASE 
             WHEN ChannelPartnerId IS NOT NULL THEN 'Partner Lead'
             ELSE 'Admin Lead'
         END
ORDER BY LeadType, HandoverStatus;