-- Check for NULL values in CreatedOn column
SELECT COUNT(*) as TotalLeads, 
       COUNT(CreatedOn) as LeadsWithCreatedOn,
       COUNT(*) - COUNT(CreatedOn) as LeadsWithNullCreatedOn
FROM Leads;

-- Show any leads with NULL CreatedOn
SELECT TOP 5 LeadId, Name, CreatedOn 
FROM Leads 
WHERE CreatedOn IS NULL;

-- Update NULL CreatedOn values to current date
UPDATE Leads 
SET CreatedOn = GETDATE() 
WHERE CreatedOn IS NULL;

-- Show count after update
SELECT COUNT(*) as TotalLeads, 
       COUNT(CreatedOn) as LeadsWithCreatedOn,
       COUNT(*) - COUNT(CreatedOn) as LeadsWithNullCreatedOn
FROM Leads;