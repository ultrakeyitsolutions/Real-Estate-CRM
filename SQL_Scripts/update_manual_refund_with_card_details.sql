-- Update existing manual refund transaction with card details from original payment
-- This will make the refund display card information like regular transactions

USE RealEstateCRM;
GO

-- Find the manual refund transaction (rfnd_manual_sub22_20260103085303)
SELECT 
    TransactionId,
    TransactionReference,
    SubscriptionId,
    Amount,
    Status,
    TransactionType,
    CardType,
    CardNetwork,
    CardLast4,
    BankName,
    Description
FROM PaymentTransactions
WHERE TransactionReference LIKE 'rfnd_manual_sub22%';
GO

-- Update the manual refund with card details from the original payment (Subscription #22)
UPDATE refund
SET 
    refund.SubscriptionId = 22,
    refund.CardType = orig.CardType,
    refund.CardNetwork = orig.CardNetwork,
    refund.CardLast4 = orig.CardLast4,
    refund.BankName = orig.BankName,
    refund.PlanName = orig.PlanName,
    refund.BillingCycle = orig.BillingCycle,
    refund.Currency = orig.Currency,
    refund.NetAmount = refund.Amount,
    refund.Description = 'Refund for Subscription #22 - ' + ISNULL(orig.PlanName, 'Professional Plan') + ' - Processed by admin'
FROM PaymentTransactions refund
CROSS APPLY (
    SELECT TOP 1 
        CardType, 
        CardNetwork, 
        CardLast4, 
        BankName,
        PlanName,
        BillingCycle,
        Currency
    FROM PaymentTransactions
    WHERE SubscriptionId = 22
    AND Status = 'Success'
    AND TransactionType IN ('Payment', 'Scheduled Payment')
    ORDER BY TransactionDate DESC
) orig
WHERE refund.TransactionReference LIKE 'rfnd_manual_sub22%';
GO

-- Verify the update
SELECT 
    TransactionId,
    SubscriptionId,
    TransactionReference,
    Amount,
    Status,
    TransactionType,
    CardType,
    CardNetwork,
    CardLast4,
    BankName,
    PlanName,
    BillingCycle,
    Description,
    TransactionDate,
    CompletedDate
FROM PaymentTransactions
WHERE TransactionReference LIKE 'rfnd_manual_sub22%';
GO

PRINT 'Manual refund transaction updated with card details!';
