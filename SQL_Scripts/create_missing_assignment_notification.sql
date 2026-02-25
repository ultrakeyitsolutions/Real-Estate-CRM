-- Create notification for the latest lead assigned to MahiSales (UserId = 2)
-- Find the latest lead assigned to ExecutiveId = 2
SELECT TOP 1 LeadId, Name FROM Leads WHERE ExecutiveId = 2 ORDER BY ModifiedOn DESC;

-- Create notification for that lead (replace LeadId and Name with actual values)
INSERT INTO Notifications (Title, Message, Type, UserId, Link, RelatedEntityId, RelatedEntityType, Priority, IsRead, CreatedOn)
VALUES 
('Lead Assigned to You', 'Lead ''iiiiiiiiii joy'' has been assigned to you by Admin', 'LeadAssigned', 2, '/Leads/Details/56', 56, 'Lead', 'High', 0, GETDATE());

-- Check all notifications for agent 2
SELECT * FROM Notifications WHERE UserId = 2 ORDER BY CreatedOn DESC;