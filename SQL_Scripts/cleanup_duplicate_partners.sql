-- Cleanup Duplicate Partners Created by Double-Click
-- This script identifies and removes duplicate partner records

USE RealEstateCRM;
GO

-- Step 1: Identify duplicate partners by email
PRINT '=== DUPLICATE PARTNERS FOUND ===';
SELECT 
    Email,
    COUNT(*) AS DuplicateCount,
    STRING_AGG(CAST(PartnerId AS VARCHAR), ', ') AS PartnerIds,
    STRING_AGG(CompanyName, ', ') AS CompanyNames
FROM ChannelPartners
GROUP BY Email
HAVING COUNT(*) > 1;
GO

-- Step 2: Show details of duplicates (for review)
PRINT '';
PRINT '=== DUPLICATE PARTNER DETAILS ===';
SELECT 
    cp.PartnerId,
    cp.CompanyName,
    cp.ContactPerson,
    cp.Email,
    cp.Phone,
    cp.Status,
    cp.ApprovedOn,
    cp.UserId,
    u.Username,
    ps.SubscriptionId,
    ps.Status AS SubscriptionStatus,
    ps.BillingCycle
FROM ChannelPartners cp
LEFT JOIN Users u ON cp.UserId = u.UserId
LEFT JOIN PartnerSubscriptions ps ON cp.PartnerId = ps.ChannelPartnerId
WHERE cp.Email IN (
    SELECT Email
    FROM ChannelPartners
    GROUP BY Email
    HAVING COUNT(*) > 1
)
ORDER BY cp.Email, cp.PartnerId;
GO

-- Step 3: Delete duplicate partners (keeps the FIRST one created)
-- UNCOMMENT THE FOLLOWING LINES AFTER REVIEWING THE DUPLICATES ABOVE

/*
PRINT '';
PRINT '=== DELETING DUPLICATE PARTNERS (KEEPING OLDEST) ===';

-- Delete related subscriptions first
DELETE ps
FROM PartnerSubscriptions ps
INNER JOIN (
    SELECT 
        cp.PartnerId,
        ROW_NUMBER() OVER (PARTITION BY cp.Email ORDER BY cp.PartnerId ASC) AS RowNum
    FROM ChannelPartners cp
) AS Duplicates ON ps.ChannelPartnerId = Duplicates.PartnerId
WHERE Duplicates.RowNum > 1;

PRINT 'Deleted duplicate subscriptions';

-- Delete related user accounts
DELETE u
FROM Users u
INNER JOIN (
    SELECT 
        cp.UserId,
        ROW_NUMBER() OVER (PARTITION BY cp.Email ORDER BY cp.PartnerId ASC) AS RowNum
    FROM ChannelPartners cp
    WHERE cp.UserId IS NOT NULL
) AS Duplicates ON u.UserId = Duplicates.UserId
WHERE Duplicates.RowNum > 1;

PRINT 'Deleted duplicate user accounts';

-- Delete duplicate partner records (keeps oldest)
DELETE cp
FROM ChannelPartners cp
INNER JOIN (
    SELECT 
        PartnerId,
        ROW_NUMBER() OVER (PARTITION BY Email ORDER BY PartnerId ASC) AS RowNum
    FROM ChannelPartners
) AS Duplicates ON cp.PartnerId = Duplicates.PartnerId
WHERE Duplicates.RowNum > 1;

PRINT 'Deleted duplicate partner records';
*/

-- Step 4: MANUAL CLEANUP (if you want to choose which to keep)
-- Find the specific duplicate you want to keep and delete the other manually
/*
EXAMPLE: For email 'tejaavidi4@gmail.com'

-- First, check which PartnerId you want to KEEP
SELECT PartnerId, CompanyName, ContactPerson, Email, ApprovedOn
FROM ChannelPartners
WHERE Email = 'tejaavidi4@gmail.com'
ORDER BY PartnerId;

-- Then delete the duplicate (REPLACE 123 with the PartnerId you want to DELETE)
DECLARE @PartnerIdToDelete INT = 123; -- CHANGE THIS!

-- Delete subscription
DELETE FROM PartnerSubscriptions WHERE ChannelPartnerId = @PartnerIdToDelete;

-- Delete user account
DELETE FROM Users WHERE UserId = (SELECT UserId FROM ChannelPartners WHERE PartnerId = @PartnerIdToDelete);

-- Delete partner record
DELETE FROM ChannelPartners WHERE PartnerId = @PartnerIdToDelete;

PRINT 'Deleted partner #' + CAST(@PartnerIdToDelete AS VARCHAR);
*/

-- Step 5: Verify cleanup
PRINT '';
PRINT '=== VERIFICATION: Check for remaining duplicates ===';
SELECT 
    Email,
    COUNT(*) AS Count
FROM ChannelPartners
GROUP BY Email
HAVING COUNT(*) > 1;

PRINT '';
PRINT 'If no results above, all duplicates have been cleaned up!';
GO
