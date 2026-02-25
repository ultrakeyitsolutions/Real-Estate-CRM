-- Fix subscription plan pricing to show proper tier progression
-- Basic should be cheapest, Professional middle, Enterprise highest

-- Update pricing to proper tier structure
UPDATE SubscriptionPlans SET 
    MonthlyPrice = 99.00, 
    YearlyPrice = 999.00,
    MaxAgents = 2,
    MaxLeadsPerMonth = 500,
    MaxStorageGB = 1,
    SortOrder = 1
WHERE PlanId = 1; -- Basic Plan

UPDATE SubscriptionPlans SET 
    MonthlyPrice = 299.00, 
    YearlyPrice = 2999.00,
    MaxAgents = 10,
    MaxLeadsPerMonth = 2000,
    MaxStorageGB = 10,
    SortOrder = 2
WHERE PlanId = 2; -- Professional Plan

UPDATE SubscriptionPlans SET 
    MonthlyPrice = 599.00, 
    YearlyPrice = 5999.00,
    MaxAgents = -1,
    MaxLeadsPerMonth = -1,
    MaxStorageGB = 100,
    SortOrder = 3
WHERE PlanId = 3; -- Enterprise Plan

-- Verify the corrected pricing
SELECT PlanId, PlanName, MonthlyPrice, YearlyPrice, MaxAgents, MaxLeadsPerMonth, MaxStorageGB, SortOrder
FROM SubscriptionPlans
WHERE IsActive = 1
ORDER BY SortOrder;