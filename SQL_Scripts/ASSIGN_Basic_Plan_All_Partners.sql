-- Assign all partners to Basic plan for testing
-- This will create active subscriptions for all partners

-- First, deactivate any existing subscriptions
UPDATE PartnerSubscriptions SET Status = 'Cancelled' WHERE Status = 'Active';

-- Create Basic plan subscriptions for all partners
INSERT INTO PartnerSubscriptions (
    ChannelPartnerId, 
    PlanId, 
    BillingCycle, 
    Amount, 
    StartDate, 
    EndDate, 
    Status,
    PaymentMethod,
    CreatedOn
)
SELECT 
    cp.PartnerId,
    1, -- Basic Plan ID
    'Monthly',
    99.00, -- Basic plan price
    GETDATE(),
    DATEADD(MONTH, 1, GETDATE()), -- 1 month from now
    'Active',
    'Testing',
    GETDATE()
FROM ChannelPartners cp
WHERE cp.PartnerId NOT IN (
    SELECT ChannelPartnerId 
    FROM PartnerSubscriptions 
    WHERE Status = 'Active' AND PlanId = 1
);

-- Verify all partners have Basic plan
SELECT 
    cp.CompanyName,
    sp.PlanName,
    ps.Amount,
    ps.StartDate,
    ps.EndDate,
    ps.Status
FROM PartnerSubscriptions ps
JOIN ChannelPartners cp ON ps.ChannelPartnerId = cp.PartnerId
JOIN SubscriptionPlans sp ON ps.PlanId = sp.PlanId
WHERE ps.Status = 'Active'
ORDER BY cp.CompanyName;