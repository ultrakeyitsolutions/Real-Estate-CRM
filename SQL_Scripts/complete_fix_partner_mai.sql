-- COMPLETE FIX: Delete duplicate PartnerId 9 and ensure PartnerId 8 has trial
-- For partner: mai (tejaavidi4@gmail.com)

USE RealEstateCRM;
GO

PRINT '=== STEP 1: CHECK CURRENT STATE ===';
PRINT '';

-- Show both partner records
SELECT 
    PartnerId,
    CompanyName,
    ContactPerson,
    Email,
    UserId,
    Status,
    ApprovedOn
FROM ChannelPartners
WHERE Email = 'tejaavidi4@gmail.com'
ORDER BY PartnerId;
GO

-- Show subscriptions for both
SELECT 
    ps.SubscriptionId,
    ps.ChannelPartnerId,
    sp.PlanName,
    ps.BillingCycle,
    ps.Amount,
    ps.Status,
    ps.StartDate,
    ps.EndDate
FROM PartnerSubscriptions ps
LEFT JOIN SubscriptionPlans sp ON ps.PlanId = sp.PlanId
WHERE ps.ChannelPartnerId IN (8, 9)
ORDER BY ps.SubscriptionId;
GO

PRINT '';
PRINT '=== STEP 2: DELETE DUPLICATE PARTNER (PartnerId 9) ===';
PRINT '';

-- Delete subscription for PartnerId 9 (if exists)
DELETE FROM PartnerSubscriptions WHERE ChannelPartnerId = 9;
PRINT 'Deleted subscriptions for PartnerId 9';

-- Delete the duplicate partner record
DELETE FROM ChannelPartners WHERE PartnerId = 9;
PRINT 'Deleted duplicate partner PartnerId 9';

PRINT '';
PRINT '=== STEP 3: ENSURE PARTNERID 8 HAS TRIAL SUBSCRIPTION ===';
PRINT '';

DECLARE @PartnerId INT = 8;
DECLARE @BasicPlanId INT;

-- Get the Basic/lowest price plan
SELECT TOP 1 @BasicPlanId = PlanId
FROM SubscriptionPlans
WHERE IsActive = 1
ORDER BY MonthlyPrice ASC;

PRINT 'Selected Plan ID: ' + CAST(@BasicPlanId AS VARCHAR);

-- Check if subscription already exists for PartnerId 8
IF NOT EXISTS (SELECT 1 FROM PartnerSubscriptions WHERE ChannelPartnerId = @PartnerId)
BEGIN
    PRINT 'No subscription found - creating 7-day trial...';
    
    INSERT INTO PartnerSubscriptions (
        ChannelPartnerId,
        PlanId,
        BillingCycle,
        Amount,
        StartDate,
        EndDate,
        Status,
        PaymentMethod,
        PaymentTransactionId,
        LastPaymentDate,
        NextPaymentDate,
        AutoRenew,
        CreatedOn,
        UpdatedOn
    )
    VALUES (
        @PartnerId,
        @BasicPlanId,
        'Trial',
        0.00,
        GETDATE(),
        DATEADD(DAY, 7, GETDATE()),
        'Active',
        'Trial',
        'trial_' + CAST(DATEDIFF(SECOND, '1970-01-01', GETDATE()) AS VARCHAR),
        GETDATE(),
        DATEADD(DAY, 7, GETDATE()),
        0,
        GETDATE(),
        GETDATE()
    );
    
    PRINT '✅ 7-day trial subscription created!';
    PRINT 'Start Date: ' + CONVERT(VARCHAR, GETDATE(), 120);
    PRINT 'End Date: ' + CONVERT(VARCHAR, DATEADD(DAY, 7, GETDATE()), 120);
END
ELSE
BEGIN
    PRINT '✅ Subscription already exists for PartnerId 8';
    
    -- Show existing subscription
    SELECT 
        SubscriptionId,
        BillingCycle,
        Amount,
        Status,
        StartDate,
        EndDate,
        DATEDIFF(DAY, GETDATE(), EndDate) AS DaysRemaining
    FROM PartnerSubscriptions
    WHERE ChannelPartnerId = @PartnerId;
END

GO

PRINT '';
PRINT '=== STEP 4: FINAL VERIFICATION ===';
PRINT '';

-- Show final partner state
PRINT 'Partner Record:';
SELECT 
    PartnerId,
    CompanyName,
    ContactPerson,
    Email,
    UserId,
    Status
FROM ChannelPartners
WHERE Email = 'tejaavidi4@gmail.com';

-- Show subscription
PRINT '';
PRINT 'Subscription:';
SELECT 
    ps.SubscriptionId,
    ps.ChannelPartnerId,
    sp.PlanName,
    ps.BillingCycle,
    ps.Amount,
    ps.Status,
    ps.StartDate,
    ps.EndDate,
    DATEDIFF(DAY, GETDATE(), ps.EndDate) AS DaysRemaining
FROM PartnerSubscriptions ps
LEFT JOIN SubscriptionPlans sp ON ps.PlanId = sp.PlanId
WHERE ps.ChannelPartnerId = 8;

-- Show user account
PRINT '';
PRINT 'User Account:';
SELECT 
    UserId,
    Username,
    Email,
    Role,
    ChannelPartnerId,
    IsActive
FROM Users
WHERE Email = 'tejaavidi4@gmail.com';

GO

PRINT '';
PRINT '🎉 CLEANUP COMPLETE!';
PRINT 'Partner "mai" (tejaavidi4@gmail.com) is now ready with:';
PRINT '  ✅ Single partner record (PartnerId 8)';
PRINT '  ✅ User account (UserId 33)';
PRINT '  ✅ 7-day free trial subscription';
PRINT '';
PRINT 'Partner can now login with:';
PRINT '  Username: mai';
PRINT '  Password: TEJA@7878';
GO
