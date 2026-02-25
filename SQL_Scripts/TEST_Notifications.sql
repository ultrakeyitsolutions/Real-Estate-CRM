-- Check if notifications are being created
SELECT TOP 10 
    NotificationId,
    Title,
    Message,
    Type,
    UserId,
    IsRead,
    CreatedOn,
    Priority
FROM Notifications 
ORDER BY CreatedOn DESC;

-- Check notification count by type
SELECT 
    Type,
    COUNT(*) as Count,
    COUNT(CASE WHEN IsRead = 0 THEN 1 END) as UnreadCount
FROM Notifications 
GROUP BY Type
ORDER BY Count DESC;

-- Check recent lead activities
SELECT TOP 5
    LeadId,
    Name,
    ExecutiveId,
    CreatedOn,
    ModifiedOn,
    Source
FROM Leads 
ORDER BY CreatedOn DESC;