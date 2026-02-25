-- Clear all existing notifications
DELETE FROM [Notifications];

-- Reset identity seed to start from 1
DBCC CHECKIDENT ('Notifications', RESEED, 0);

PRINT 'All notifications cleared successfully';