-- Create assignment notification for the lead "iiiiiiiiii joy" assigned to MahiSales
INSERT INTO Notifications (Title, Message, Type, UserId, Link, RelatedEntityId, RelatedEntityType, Priority, IsRead, CreatedOn)
VALUES 
('Lead Assigned to You', 'Lead ''iiiiiiiiii joy'' has been assigned to you by Admin', 'LeadAssigned', 2, '/Leads/Details/56', 56, 'Lead', 'High', 0, GETDATE());

-- Verify it was created
SELECT * FROM Notifications WHERE UserId = 2 AND Type = 'LeadAssigned' ORDER BY CreatedOn DESC;