-- Verify payment transaction has RazorpayPaymentId for refund processing
-- Execute this script to check if the payment can be refunded via Razorpay

USE RealEstateCRM;
GO

-- Check Subscription #24 details
SELECT 
    SubscriptionId,
    ChannelPartnerId,
    Status,
    Amount,
    StartDate,
    EndDate,
    CancellationReason
FROM PartnerSubscriptions
WHERE SubscriptionId = 24;
GO

-- Check payment transactions for Subscription #24
SELECT 
    TransactionId,
    SubscriptionId,
    RazorpayPaymentId,
    RazorpayOrderId,
    TransactionReference,
    Amount,
    Status,
    TransactionType,
    TransactionDate,
    CardType,
    CardNetwork,
    CardLast4,
    BankName
FROM PaymentTransactions
WHERE SubscriptionId = 24
AND Status = 'Success'
AND TransactionType != 'Refund'
ORDER BY TransactionDate DESC;
GO

-- Check if RazorpayPaymentId exists for refund
IF EXISTS (
    SELECT 1 
    FROM PaymentTransactions 
    WHERE SubscriptionId = 24 
    AND Status = 'Success'
    AND TransactionType != 'Refund'
    AND RazorpayPaymentId IS NOT NULL
    AND RazorpayPaymentId != ''
)
BEGIN
    PRINT '✓ Payment transaction found with RazorpayPaymentId - Razorpay refund will be processed';
END
ELSE
BEGIN
    PRINT '✗ No RazorpayPaymentId found - Manual refund will be marked (no Razorpay API call)';
END
GO
