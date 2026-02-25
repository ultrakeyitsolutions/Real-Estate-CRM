-- Check for duplicate partners with email 'tejaavidi4@gmail.com'

USE RealEstateCRM;
GO

-- Check ChannelPartners table
SELECT 
    PartnerId,
    CompanyName,
    ContactPerson,
    Email,
    Phone,
    Status,
    ApprovedBy,
    ApprovedOn,
    UserId,
    CreatedOn
FROM ChannelPartners
WHERE Email = 'tejaavidi4@gmail.com'
ORDER BY PartnerId;
GO

-- Check related subscriptions
SELECT 
    ps.SubscriptionId,
    ps.ChannelPartnerId,
    ps.BillingCycle,
    ps.Amount,
    ps.Status,
    ps.StartDate,
    ps.EndDate,
    sp.PlanName,
    cp.CompanyName,
    cp.Email
FROM PartnerSubscriptions ps
INNER JOIN ChannelPartners cp ON ps.ChannelPartnerId = cp.PartnerId
LEFT JOIN SubscriptionPlans sp ON ps.PlanId = sp.PlanId
WHERE cp.Email = 'tejaavidi4@gmail.com'
ORDER BY ps.SubscriptionId;
GO

-- If duplicates exist, delete the newest one
-- NOW EXECUTING THE CLEANUP

-- Find the duplicate PartnerId (the NEWEST one to delete)
DECLARE @OldestPartnerId INT;
DECLARE @NewestPartnerId INT;

SELECT TOP 1 @OldestPartnerId = PartnerId
FROM ChannelPartners
WHERE Email = 'tejaavidi4@gmail.com'
ORDER BY PartnerId ASC;

SELECT TOP 1 @NewestPartnerId = PartnerId
FROM ChannelPartners
WHERE Email = 'tejaavidi4@gmail.com'
ORDER BY PartnerId DESC;

PRINT 'Oldest Partner ID (KEEPING): ' + CAST(@OldestPartnerId AS VARCHAR);
PRINT 'Newest Partner ID (DELETING): ' + CAST(@NewestPartnerId AS VARCHAR);

-- Delete the newest duplicate
IF @OldestPartnerId != @NewestPartnerId
BEGIN
    -- Delete subscription of duplicate
    DELETE FROM PartnerSubscriptions WHERE ChannelPartnerId = @NewestPartnerId;
    PRINT 'Deleted subscription for PartnerId: ' + CAST(@NewestPartnerId AS VARCHAR);
    
    -- Update user to link to oldest partner (if any orphaned users exist)
    UPDATE Users 
    SET ChannelPartnerId = @OldestPartnerId 
    WHERE ChannelPartnerId = @NewestPartnerId;
    PRINT 'Updated user to link to PartnerId: ' + CAST(@OldestPartnerId AS VARCHAR);
    
    -- Delete duplicate partner
    DELETE FROM ChannelPartners WHERE PartnerId = @NewestPartnerId;
    PRINT 'Deleted duplicate partner: ' + CAST(@NewestPartnerId AS VARCHAR);
    
    PRINT 'Cleanup complete!';
END
ELSE
BEGIN
    PRINT 'No duplicates found - only one partner exists!';
END

GO
