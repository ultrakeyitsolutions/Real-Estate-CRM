-- Check current users and their roles
SELECT UserId, Username, Role, ChannelPartnerId 
FROM Users 
ORDER BY Role, UserId;

-- Check current notifications
SELECT 
    NotificationId,
    Title,
    Message,
    Type,
    UserId,
    Priority,
    IsRead,
    CreatedOn,
    RelatedEntityType,
    RelatedEntityId
FROM Notifications 
ORDER BY CreatedOn DESC;

-- Check unread notifications count by user
SELECT 
    u.UserId,
    u.Username,
    u.Role,
    COUNT(n.NotificationId) as UnreadCount
FROM Users u
LEFT JOIN Notifications n ON (n.UserId = u.UserId OR (n.UserId IS NULL AND u.Role = 'Admin'))
    AND n.IsRead = 0
GROUP BY u.UserId, u.Username, u.Role
ORDER BY u.Role, u.UserId;

-- Check if there are any leads assigned to agents
SELECT 
    l.LeadId,
    l.Name as LeadName,
    l.ExecutiveId,
    u.Username as AssignedTo,
    u.Role as AssignedToRole,
    l.CreatedOn
FROM Leads l
LEFT JOIN Users u ON l.ExecutiveId = u.UserId
WHERE l.ExecutiveId IS NOT NULL
ORDER BY l.CreatedOn DESC;