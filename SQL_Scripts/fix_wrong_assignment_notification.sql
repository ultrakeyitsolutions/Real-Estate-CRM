-- Fix the wrong assignment notification (ID 69) - it went to Admin instead of Agent
-- Delete the wrong notification
DELETE FROM Notifications WHERE NotificationId = 69;

-- Create the correct notification for Agent UserId = 2
INSERT INTO Notifications (Title, Message, Type, UserId, Link, RelatedEntityId, RelatedEntityType, Priority, IsRead, CreatedOn)
VALUES 
('Lead Assigned to You', 'Lead ''Mahi joy'' has been assigned to you by Admin', 'LeadAssigned', 2, '/Leads/Details/53', 53, 'Lead', 'High', 0, GETDATE());

-- Check the result
SELECT * FROM Notifications WHERE RelatedEntityId = 53 AND Type = 'LeadAssigned';