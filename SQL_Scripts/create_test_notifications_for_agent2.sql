-- Create test notifications for Agent UserId = 2 (MahiSales)

INSERT INTO Notifications (Title, Message, Type, UserId, Link, RelatedEntityId, RelatedEntityType, Priority, IsRead, CreatedOn)
VALUES 
('Lead Assignment Test', 'You have been assigned Lead #123 - Test Customer for immediate follow-up', 'LeadAssigned', 2, '/Leads/Details/123', 123, 'Lead', 'High', 0, GETDATE()),
('New Lead Assignment', 'Lead #124 - John Smith has been assigned to you by Admin', 'LeadAssigned', 2, '/Leads/Details/124', 124, 'Lead', 'High', 0, GETDATE()),
('Follow-up Reminder', 'You have 2 follow-ups due today. Please check your tasks.', 'FollowUpDue', 2, '/Tasks/Index', NULL, NULL, 'Medium', 0, GETDATE()),
('Site Visit Scheduled', 'Site visit scheduled for Lead #125 - Jane Doe tomorrow at 10 AM', 'SiteVisit', 2, '/Leads/Details/125', 125, 'Lead', 'Normal', 0, GETDATE()),
('Urgent Follow-up', 'Urgent follow-up required for Lead #126 - Hot prospect', 'FollowUpDue', 2, '/Leads/Details/126', 126, 'Lead', 'High', 0, GETDATE());

-- Check what we inserted
SELECT * FROM Notifications WHERE UserId = 2 ORDER BY CreatedOn DESC;