-- Clean up duplicate subscription plans
-- Remove the duplicate and incorrectly priced plans

-- Delete the duplicate Basic plans (keep PlanId = 1, remove PlanId = 4)
DELETE FROM SubscriptionPlans WHERE PlanId = 4;

-- Delete the incorrect "Basic" and "Paid" plans with ₹0 pricing
DELETE FROM SubscriptionPlans WHERE PlanId IN (4, 5);

-- Update the remaining plans with proper MaxAgents values
UPDATE SubscriptionPlans SET MaxAgents = 2 WHERE PlanId = 1;
UPDATE SubscriptionPlans SET MaxAgents = 10 WHERE PlanId = 2;
UPDATE SubscriptionPlans SET MaxAgents = -1 WHERE PlanId = 3; -- Unlimited for Enterprise

-- Verify final plans
SELECT PlanId, PlanName, Description, MonthlyPrice, YearlyPrice, MaxAgents, PlanType, IsActive
FROM SubscriptionPlans
WHERE IsActive = 1
ORDER BY MonthlyPrice;