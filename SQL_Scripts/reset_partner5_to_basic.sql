-- Reset ChannelPartner ID 5 to Basic Plan
-- Remove all existing subscription data and create fresh Basic plan subscription

USE RealEstateCRM;
GO

-- Step 1: Check current data
SELECT 'Current Subscriptions:' AS Info;
SELECT * FROM PartnerSubscriptions WHERE ChannelPartnerId = 5;

SELECT 'Current Payment Transactions:' AS Info;
SELECT * FROM PaymentTransactions WHERE ChannelPartnerId = 5;

SELECT 'Current Subscription Addons:' AS Info;
IF OBJECT_ID('PartnerSubscriptionAddons', 'U') IS NOT NULL
    SELECT psa.* FROM PartnerSubscriptionAddons psa
    INNER JOIN PartnerSubscriptions ps ON psa.SubscriptionId = ps.SubscriptionId
    WHERE ps.ChannelPartnerId = 5;

-- Step 2: Delete subscription addons (if table exists)
IF OBJECT_ID('PartnerSubscriptionAddons', 'U') IS NOT NULL
BEGIN
    DELETE psa FROM PartnerSubscriptionAddons psa
    INNER JOIN PartnerSubscriptions ps ON psa.SubscriptionId = ps.SubscriptionId
    WHERE ps.ChannelPartnerId = 5;
    PRINT 'Deleted subscription addons for Partner 5';
END

-- Step 3: Delete all payment transactions for partner 5
DELETE FROM PaymentTransactions WHERE ChannelPartnerId = 5;
PRINT 'Deleted payment transactions for Partner 5';

-- Step 4: Delete all subscriptions for partner 5
DELETE FROM PartnerSubscriptions WHERE ChannelPartnerId = 5;
PRINT 'Deleted all subscriptions for Partner 5';

-- Step 4: Get Basic Plan details
DECLARE @BasicPlanId INT;
DECLARE @BasicPlanName NVARCHAR(100);
DECLARE @MonthlyPrice DECIMAL(10,2);
DECLARE @YearlyPrice DECIMAL(10,2);

SELECT TOP 1 
    @BasicPlanId = PlanId,
    @BasicPlanName = PlanName,
    @MonthlyPrice = MonthlyPrice,
    @YearlyPrice = YearlyPrice
FROM SubscriptionPlans 
WHERE PlanName = 'Basic' OR PlanName = 'Basic Plan';

IF @BasicPlanId IS NULL
BEGIN
    PRINT 'ERROR: Basic Plan not found!';
    RETURN;
END

PRINT 'Basic Plan ID: ' + CAST(@BasicPlanId AS VARCHAR);
PRINT 'Basic Plan Name: ' + @BasicPlanName;

-- Step 5: Create new Basic Plan subscription (Monthly)
INSERT INTO PartnerSubscriptions 
(
    ChannelPartnerId,
    PlanId,
    BillingCycle,
    Amount,
    Status,
    StartDate,
    EndDate,
    AutoRenew,
    CreatedOn
)
VALUES 
(
    5,
    @BasicPlanId,
    'Monthly',
    @MonthlyPrice,
    'Active',
    GETDATE(),
    DATEADD(MONTH, 1, GETDATE()),
    1,
    GETDATE()
);

PRINT 'Created new Basic Monthly subscription for Partner 5';

-- Step 6: Verify the changes
SELECT 'New Subscription:' AS Info;
SELECT 
    ps.*,
    sp.PlanName,
    sp.MonthlyPrice,
    sp.YearlyPrice
FROM PartnerSubscriptions ps
INNER JOIN SubscriptionPlans sp ON ps.PlanId = sp.PlanId
WHERE ps.ChannelPartnerId = 5;

SELECT 'Payment Transactions (should be empty):' AS Info;
SELECT * FROM PaymentTransactions WHERE ChannelPartnerId = 5;

SELECT 'Subscription Addons (should be empty):' AS Info;
IF OBJECT_ID('PartnerSubscriptionAddons', 'U') IS NOT NULL
    SELECT psa.* FROM PartnerSubscriptionAddons psa
    INNER JOIN PartnerSubscriptions ps ON psa.SubscriptionId = ps.SubscriptionId
    WHERE ps.ChannelPartnerId = 5;

PRINT 'Partner 5 reset to Basic Plan successfully!';
