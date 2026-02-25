-- Check trial subscription for partner 'mai' (tejaavidi4@gmail.com)
-- PartnerId: 8, UserId: 33

USE RealEstateCRM;
GO

-- Check partner details
SELECT 
    PartnerId,
    CompanyName,
    ContactPerson,
    Email,
    UserId,
    Status,
    ApprovedOn
FROM ChannelPartners
WHERE PartnerId = 8;
GO

-- Check if trial subscription exists for this partner
SELECT 
    ps.SubscriptionId,
    ps.ChannelPartnerId,
    ps.PlanId,
    sp.PlanName,
    ps.BillingCycle,
    ps.Amount,
    ps.Status,
    ps.StartDate,
    ps.EndDate,
    DATEDIFF(DAY, GETDATE(), ps.EndDate) AS DaysRemaining,
    ps.PaymentMethod,
    ps.PaymentTransactionId,
    ps.CreatedOn
FROM PartnerSubscriptions ps
LEFT JOIN SubscriptionPlans sp ON ps.PlanId = sp.PlanId
WHERE ps.ChannelPartnerId = 8
ORDER BY ps.SubscriptionId DESC;
GO

-- If NO trial exists, create one
-- UNCOMMENT BELOW TO CREATE TRIAL SUBSCRIPTION

/*
DECLARE @PartnerId INT = 8;
DECLARE @BasicPlanId INT;

-- Get the Basic/lowest price plan
SELECT TOP 1 @BasicPlanId = PlanId
FROM SubscriptionPlans
WHERE IsActive = 1
ORDER BY MonthlyPrice ASC;

-- Check if subscription already exists
IF NOT EXISTS (SELECT 1 FROM PartnerSubscriptions WHERE ChannelPartnerId = @PartnerId)
BEGIN
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
        'trial_' + CAST(DATEPART(MILLISECOND, GETDATE()) AS VARCHAR),
        GETDATE(),
        DATEADD(DAY, 7, GETDATE()),
        0,
        GETDATE(),
        GETDATE()
    );
    
    PRINT '✅ 7-day trial subscription created successfully!';
    PRINT 'Plan ID: ' + CAST(@BasicPlanId AS VARCHAR);
    PRINT 'Start Date: ' + CAST(GETDATE() AS VARCHAR);
    PRINT 'End Date: ' + CAST(DATEADD(DAY, 7, GETDATE()) AS VARCHAR);
END
ELSE
BEGIN
    PRINT '⚠️ Subscription already exists for this partner';
END
*/

GO

-- Check available subscription plans
SELECT 
    PlanId,
    PlanName,
    MonthlyPrice,
    YearlyPrice,
    IsActive,
    Features
FROM SubscriptionPlans
WHERE IsActive = 1
ORDER BY MonthlyPrice ASC;
GO
