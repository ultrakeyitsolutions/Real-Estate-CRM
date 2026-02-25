-- Check and clean up subscription plans
-- First, let's see what plans exist

SELECT PlanId, PlanName, Description, MonthlyPrice, YearlyPrice, PlanType, IsActive, SortOrder
FROM SubscriptionPlans
ORDER BY SortOrder, PlanId;

-- Remove duplicate or incorrect plans
-- Keep only one Basic plan and update pricing

-- Delete the duplicate "Paid" plan (assuming it's the second one)
DELETE FROM SubscriptionPlans 
WHERE PlanName = 'Paid' OR (PlanName = 'Basic Plan' AND MonthlyPrice = 0);

-- Update the remaining Basic plan with proper pricing
UPDATE SubscriptionPlans 
SET MonthlyPrice = 999.00, 
    YearlyPrice = 9999.00,
    MaxAgents = 2,
    PlanName = 'Basic Plan',
    Description = 'Perfect for small teams getting started with CRM'
WHERE PlanType = 'Basic' AND IsActive = 1;

-- Verify the cleanup
SELECT PlanId, PlanName, Description, MonthlyPrice, YearlyPrice, MaxAgents, PlanType, IsActive
FROM SubscriptionPlans
WHERE IsActive = 1
ORDER BY SortOrder, MonthlyPrice;