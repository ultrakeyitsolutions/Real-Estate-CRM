-- Check table structures to understand column names
SELECT 'ChannelPartners Table Structure' as Info;
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'ChannelPartners';

SELECT 'Users Table Structure' as Info;
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Users';

SELECT 'Sample ChannelPartners Data' as Info;
SELECT TOP 5 * FROM ChannelPartners;

SELECT 'Sample Users with ChannelPartnerId' as Info;
SELECT TOP 5 UserId, Username, Role, ChannelPartnerId FROM Users WHERE ChannelPartnerId IS NOT NULL;