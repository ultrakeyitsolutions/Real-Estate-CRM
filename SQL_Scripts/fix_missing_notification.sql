-- Create the missing notification for Lead 53 assigned to Agent UserId = 2
INSERT INTO Notifications (Title, Message, Type, UserId, Link, RelatedEntityId, RelatedEntityType, Priority, IsRead, CreatedOn)
VALUES 
('Lead Assigned to You', 'Lead ''Mahi joy'' has been assigned to you by Admin', 'LeadAssigned', 2, '/Leads/Details/53', 53, 'Lead', 'High', 0, GETDATE());

-- Verify the notification was created
SELECT * FROM Notifications WHERE UserId = 2 AND RelatedEntityId = 53 AND Type = 'LeadAssigned';