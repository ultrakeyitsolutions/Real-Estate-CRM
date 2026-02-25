-- Remove ALL follow-up notifications and let background service recreate them properly
DELETE FROM Notifications WHERE Type = 'FollowUpDue';

PRINT 'All follow-up notifications cleared - background service will recreate them properly';