-- Reset ChannelPartner ID 5 to Basic Plan (Version 2 - Fixed Column Names)
-- Remove all existing subscription data and create fresh Basic plan subscription

USE RealEstateCRM;
GO

-- Step 1: Check current data
PRINT '=== STEP 1: Checking Current Data ===';
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
PRINT '=== STEP 2: Deleting Subscription Addons ===';
IF OBJECT_ID('PartnerSubscriptionAddons', 'U') IS NOT NULL
BEGIN
    DELETE psa FROM PartnerSubscriptionAddons psa
    INNER JOIN PartnerSubscriptions ps ON psa.SubscriptionId = ps.SubscriptionId
    WHERE ps.ChannelPartnerId = 5;
    PRINT 'Deleted subscription addons for Partner 5';
END
ELSE
BEGIN
    PRINT 'PartnerSubscriptionAddons table does not exist, skipping...';
END

-- Step 3: Delete all payment transactions for partner 5
PRINT '=== STEP 3: Deleting Payment Transactions ===';
DELETE FROM PaymentTransactions WHERE ChannelPartnerId = 5;
PRINT 'Deleted payment transactions for Partner 5';

-- Step 4: Delete all subscriptions for partner 5
PRINT '=== STEP 4: Deleting Subscriptions ===';
DELETE FROM PartnerSubscriptions WHERE ChannelPartnerId = 5;
PRINT 'Deleted all subscriptions for Partner 5';

-- Step 5: Get Basic Plan details
PRINT '=== STEP 5: Getting Basic Plan Details ===';
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
PRINT 'Monthly Price: ₹' + CAST(@MonthlyPrice AS VARCHAR);

-- Step 6: Create new Basic Plan subscription (Monthly)
PRINT '=== STEP 6: Creating New Basic Subscription ===';
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

-- Step 7: Verify the changes
PRINT '=== STEP 7: Verifying Changes ===';
SELECT 'New Subscription:' AS Info;
SELECT 
    ps.SubscriptionId,
    ps.ChannelPartnerId,
    ps.PlanId,
    sp.PlanName,
    ps.BillingCycle,
    ps.Amount,
    sp.MonthlyPrice,
    sp.YearlyPrice,
    ps.Status,
    ps.StartDate,
    ps.EndDate,
    ps.AutoRenew,
    ps.CreatedOn
FROM PartnerSubscriptions ps
INNER JOIN SubscriptionPlans sp ON ps.PlanId = sp.PlanId
WHERE ps.ChannelPartnerId = 5;

SELECT 'Payment Transactions (should be empty):' AS Info;
SELECT COUNT(*) AS TransactionCount FROM PaymentTransactions WHERE ChannelPartnerId = 5;
SELECT * FROM PaymentTransactions WHERE ChannelPartnerId = 5;

SELECT 'Subscription Addons (should be empty):' AS Info;
IF OBJECT_ID('PartnerSubscriptionAddons', 'U') IS NOT NULL
BEGIN
    SELECT COUNT(*) AS AddonCount FROM PartnerSubscriptionAddons psa
    INNER JOIN PartnerSubscriptions ps ON psa.SubscriptionId = ps.SubscriptionId
    WHERE ps.ChannelPartnerId = 5;
    
    SELECT psa.* FROM PartnerSubscriptionAddons psa
    INNER JOIN PartnerSubscriptions ps ON psa.SubscriptionId = ps.SubscriptionId
    WHERE ps.ChannelPartnerId = 5;
END

PRINT '';
PRINT '==============================================';
PRINT 'SUCCESS: Partner 5 reset to Basic Plan!';
PRINT '==============================================';
