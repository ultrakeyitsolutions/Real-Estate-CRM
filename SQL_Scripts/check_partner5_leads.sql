-- Check Leads count for Partner 5
USE RealEstateCRM;
GO

-- Total leads for partner 5
SELECT 'Total Leads for Partner 5:' AS Info;
SELECT COUNT(*) AS TotalLeads
FROM Leads
WHERE ChannelPartnerId = 5;

-- Leads created in January 2026
SELECT 'Leads Created in January 2026:' AS Info;
SELECT COUNT(*) AS JanuaryLeads
FROM Leads
WHERE ChannelPartnerId = 5
  AND CreatedOn >= '2026-01-01';

-- All leads for partner 5 with details
SELECT 'All Leads Details:' AS Info;
SELECT 
    LeadId,
    Name,
    Contact,
    Email,
    Status,
    Stage,
    Source,
    ChannelPartnerId,
    CreatedOn,
    YEAR(CreatedOn) AS Year,
    MONTH(CreatedOn) AS Month
FROM Leads
WHERE ChannelPartnerId = 5
ORDER BY CreatedOn DESC;

-- Leads grouped by month
SELECT 'Leads by Month:' AS Info;
SELECT 
    YEAR(CreatedOn) AS Year,
    MONTH(CreatedOn) AS Month,
    COUNT(*) AS LeadCount
FROM Leads
WHERE ChannelPartnerId = 5
GROUP BY YEAR(CreatedOn), MONTH(CreatedOn)
ORDER BY YEAR(CreatedOn) DESC, MONTH(CreatedOn) DESC;
