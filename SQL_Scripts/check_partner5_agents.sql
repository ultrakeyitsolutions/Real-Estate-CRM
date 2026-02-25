-- Check Agent Status for Partner 5
USE RealEstateCRM;
GO

-- Check all agents for partner 5
SELECT 
    AgentId,
    FullName,
    Email,
    Phone,
    Status,
    AgentType,
    Salary,
    ChannelPartnerId,
    CreatedOn,
    ApprovedBy,
    ApprovedOn
FROM Agents
WHERE ChannelPartnerId = 5;

-- Count agents by status
SELECT 
    Status,
    COUNT(*) AS Count
FROM Agents
WHERE ChannelPartnerId = 5
GROUP BY Status;

-- Check if there are any null or empty statuses
SELECT 
    CASE 
        WHEN Status IS NULL THEN 'NULL'
        WHEN Status = '' THEN 'EMPTY STRING'
        ELSE Status
    END AS StatusValue,
    COUNT(*) AS Count
FROM Agents
WHERE ChannelPartnerId = 5
GROUP BY Status;
