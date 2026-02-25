-- Test basic operations on Leads table
-- 1. Check if we can select from Leads table
SELECT TOP 1 * FROM Leads;

-- 2. Test inserting a simple record
INSERT INTO Leads (Name, Contact, Email, Source, Status, Stage, CreatedOn, Comments)
VALUES ('Test Lead', '1234567890', 'test@example.com', 'Facebook API', 'New', 'Lead', GETDATE(), 'Test Facebook Lead');

-- 3. Check if the insert worked
SELECT TOP 1 * FROM Leads WHERE Name = 'Test Lead';

-- 4. Clean up the test record
DELETE FROM Leads WHERE Name = 'Test Lead';