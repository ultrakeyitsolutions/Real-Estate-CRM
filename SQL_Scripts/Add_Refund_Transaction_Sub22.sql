-- Add Refund Transaction for Subscription #22
-- This creates the missing refund transaction record
-- Date: January 3, 2026

USE [RealEstateCRM]
GO

-- Create refund transaction for Subscription #22
INSERT INTO PaymentTransactions (
    ChannelPartnerId,
    SubscriptionId,
    TransactionReference,
    Amount,
    Currency,
    TransactionType,
    Status,
    PaymentMethod,
    TransactionDate,
    CompletedDate,
    Description,
    TaxAmount,
    DiscountAmount,
    NetAmount
)
SELECT 
    s.ChannelPartnerId,
    s.SubscriptionId,
    'rfnd_manual_sub22_' + FORMAT(GETDATE(), 'yyyyMMddHHmmss') AS TransactionReference,
    s.Amount,
    'INR' AS Currency,
    'Refund' AS TransactionType,
    'Processed' AS Status,
    'Razorpay' AS PaymentMethod,
    ISNULL(s.CancelledOn, GETDATE()) AS TransactionDate,
    GETDATE() AS CompletedDate,
    'Refund for Subscription #' + CAST(s.SubscriptionId AS NVARCHAR(10)) + 
    ' - ' + ISNULL(sp.PlanName, 'Professional Plan') + 
    ' - Processed by admin' AS Description,
    0 AS TaxAmount,
    0 AS DiscountAmount,
    s.Amount AS NetAmount
FROM PartnerSubscriptions s
LEFT JOIN SubscriptionPlans sp ON s.PlanId = sp.PlanId
WHERE s.SubscriptionId = 22
  AND s.Status = 'Cancelled'
  AND s.CancellationReason LIKE '%Refund Processed%'
  AND NOT EXISTS (
    SELECT 1 FROM PaymentTransactions 
    WHERE SubscriptionId = 22 AND TransactionType = 'Refund'
  );

-- Verify the transaction was created
IF @@ROWCOUNT > 0
BEGIN
    PRINT '✓ Refund transaction created successfully for Subscription #22';
    
    -- Show the created transaction
    SELECT 
        TransactionId,
        ChannelPartnerId,
        SubscriptionId,
        TransactionReference,
        Amount,
        Currency,
        TransactionType,
        Status,
        PaymentMethod,
        TransactionDate,
        CompletedDate,
        Description
    FROM PaymentTransactions
    WHERE SubscriptionId = 22 AND TransactionType = 'Refund';
END
ELSE
BEGIN
    PRINT '⚠ No transaction created. Either:';
    PRINT '  - Subscription #22 not found';
    PRINT '  - Subscription not marked as "Refund Processed"';
    PRINT '  - Refund transaction already exists';
    
    -- Check subscription status
    SELECT 
        SubscriptionId,
        Status,
        CancellationReason,
        Amount,
        CancelledOn
    FROM PartnerSubscriptions
    WHERE SubscriptionId = 22;
END
GO

-- Final verification: Show all refund transactions
PRINT '';
PRINT '========================================';
PRINT 'All Refund Transactions:';
PRINT '========================================';

SELECT 
    t.TransactionId,
    t.SubscriptionId,
    t.TransactionReference,
    t.Amount,
    t.TransactionType,
    t.Status,
    t.TransactionDate,
    cp.CompanyName AS PartnerName
FROM PaymentTransactions t
LEFT JOIN ChannelPartners cp ON t.ChannelPartnerId = cp.PartnerId
WHERE t.TransactionType = 'Refund'
ORDER BY t.TransactionDate DESC;

GO
