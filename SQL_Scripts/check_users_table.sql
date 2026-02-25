-- Check Users table structure
SELECT TOP 5 UserId, Username, Role, ExecutiveId FROM Users;

-- Check if ExecutiveId exists and has values
SELECT UserId, Username, Role, ExecutiveId FROM Users WHERE ExecutiveId IS NOT NULL;