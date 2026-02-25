-- Simple cleanup for tejaavidi4@gmail.com duplicate
-- This will keep the FIRST partner and delete the duplicate

USE RealEstateCRM;
GO

-- Step 1: Show what we have
PRINT '=== BEFORE CLEANUP ===';
SELECT 
    PartnerId,
    CompanyName,
    ContactPerson,
    Email,
    UserId,
    ApprovedOn
FROM ChannelPartners
WHERE Email = 'tejaavidi4@gmail.com'
ORDER BY PartnerId;
GO

-- Step 2: Identify which to keep and which to delete
DECLARE @KeepPartnerId INT;
DECLARE @DeletePartnerId INT;

SELECT TOP 1 @KeepPartnerId = PartnerId
FROM ChannelPartners
WHERE Email = 'tejaavidi4@gmail.com'
ORDER BY PartnerId ASC; -- Keep the FIRST one

SELECT TOP 1 @DeletePartnerId = PartnerId
FROM ChannelPartners
WHERE Email = 'tejaavidi4@gmail.com'
ORDER BY PartnerId DESC; -- Delete the LAST one

-- Step 3: Only proceed if there are duplicates
IF @KeepPartnerId != @DeletePartnerId
BEGIN
    PRINT '';
    PRINT 'Found duplicate!';
    PRINT 'Keeping PartnerId: ' + CAST(@KeepPartnerId AS VARCHAR);
    PRINT 'Deleting PartnerId: ' + CAST(@DeletePartnerId AS VARCHAR);
    
    -- Delete the duplicate partner's subscription
    DELETE FROM PartnerSubscriptions 
    WHERE ChannelPartnerId = @DeletePartnerId;
    PRINT 'Deleted subscription for duplicate partner';
    
    -- Make sure user links to the partner we're keeping
    UPDATE Users 
    SET ChannelPartnerId = @KeepPartnerId 
    WHERE Email = 'tejaavidi4@gmail.com';
    PRINT 'Updated user link to correct partner';
    
    -- Delete the duplicate partner record
    DELETE FROM ChannelPartners 
    WHERE PartnerId = @DeletePartnerId;
    PRINT 'Deleted duplicate partner record';
    
    PRINT '';
    PRINT '✅ CLEANUP COMPLETE!';
END
ELSE
BEGIN
    PRINT '';
    PRINT 'No duplicates found - only one partner exists!';
END

-- Step 4: Verify cleanup
PRINT '';
PRINT '=== AFTER CLEANUP ===';
SELECT 
    PartnerId,
    CompanyName,
    ContactPerson,
    Email,
    UserId,
    ApprovedOn
FROM ChannelPartners
WHERE Email = 'tejaavidi4@gmail.com'
ORDER BY PartnerId;

PRINT '';
PRINT '=== USER ACCOUNT ===';
SELECT 
    UserId,
    Username,
    Email,
    Role,
    ChannelPartnerId,
    CreatedDate
FROM Users
WHERE Email = 'tejaavidi4@gmail.com';

GO
