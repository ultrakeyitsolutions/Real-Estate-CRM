-- Create the missing notification for Lead 54 assigned to Agent UserId = 4 (Sales Head)
INSERT INTO Notifications (Title, Message, Type, UserId, Link, RelatedEntityId, RelatedEntityType, Priority, IsRead, CreatedOn)
VALUES 
('Lead Assigned to You', 'Lead ''joy joy'' has been assigned to you by Admin', 'LeadAssigned', 4, '/Leads/Details/54', 54, 'Lead', 'High', 0, GETDATE());

-- Check if the lead was actually assigned to agent 4
SELECT LeadId, Name, ExecutiveId FROM Leads WHERE LeadId = 54;

-- Check all notifications for agent 4
SELECT * FROM Notifications WHERE UserId = 4 ORDER BY CreatedOn DESC;