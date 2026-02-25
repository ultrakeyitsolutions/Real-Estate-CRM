-- Check the specific lead that was assigned
SELECT LeadId, Name, ExecutiveId, CreatedBy, ModifiedOn 
FROM Leads 
WHERE LeadId = 53;

-- Check if there are any notifications for lead assignment
SELECT * FROM Notifications 
WHERE RelatedEntityId = 53 AND Type = 'LeadAssigned';

-- Check all notifications for agent UserId = 2
SELECT * FROM Notifications 
WHERE UserId = 2 
ORDER BY CreatedOn DESC;