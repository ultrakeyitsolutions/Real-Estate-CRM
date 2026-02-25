-- Insert test notifications for different roles to verify the notification system

-- First, let's see what users we have
SELECT UserId, Username, Role, ChannelPartnerId FROM Users;

-- Insert test notifications for Admin (assuming UserId = 1)
INSERT INTO Notifications (Title, Message, Type, UserId, Link, RelatedEntityId, RelatedEntityType, Priority, IsRead, CreatedOn)
VALUES 
('Test Admin Notification', 'This is a test notification for Admin user', 'SystemAlert', 1, '/Home/Index', NULL, NULL, 'Normal', 0, GETDATE());

-- Insert test notifications for Agent/Sales (assuming UserId = 2)
INSERT INTO Notifications (Title, Message, Type, UserId, Link, RelatedEntityId, RelatedEntityType, Priority, IsRead, CreatedOn)
VALUES 
('Test Agent Notification', 'This is a test notification for Agent user', 'LeadAssigned', 2, '/Leads/Index', 1, 'Lead', 'High', 0, GETDATE()),
('Lead Assignment Test', 'You have been assigned a new lead for follow-up', 'LeadAssigned', 2, '/Leads/Details/1', 1, 'Lead', 'High', 0, GETDATE());

-- Insert test notifications for Partner (assuming UserId = 3)
INSERT INTO Notifications (Title, Message, Type, UserId, Link, RelatedEntityId, RelatedEntityType, Priority, IsRead, CreatedOn)
VALUES 
('Test Partner Notification', 'This is a test notification for Partner user', 'SystemAlert', 3, '/Home/Index', NULL, NULL, 'Normal', 0, GETDATE());

-- Insert global notifications (UserId = NULL for all admins)
INSERT INTO Notifications (Title, Message, Type, UserId, Link, RelatedEntityId, RelatedEntityType, Priority, IsRead, CreatedOn)
VALUES 
('Global Admin Notification', 'This notification should be visible to all admins', 'SystemAlert', NULL, '/Home/Index', NULL, NULL, 'Normal', 0, GETDATE());

-- Check what we inserted
SELECT * FROM Notifications ORDER BY CreatedOn DESC;