-- Update pending refund transaction with card details from original payment
-- Execute this script manually in SQL Server Management Studio

USE RealEstateCRM;
GO

-- For each pending refund, find the original payment and copy card details
-- This updates Subscription #24's refund transaction

-- First, find the original payment transaction for Subscription #24
DECLARE @OriginalPaymentId INT;
DECLARE @CardType NVARCHAR(20);
DECLARE @CardNetwork NVARCHAR(50);
DECLARE @CardLast4 NVARCHAR(10);
DECLARE @BankName NVARCHAR(50);

-- Get the original payment details (TransactionId 27)
SELECT TOP 1
    @CardType = CardType,
    @CardNetwork = CardNetwork,
    @CardLast4 = CardLast4,
    @BankName = BankName
FROM PaymentTransactions
WHERE SubscriptionId = 24
AND Status = 'Success'
AND TransactionType IN ('Payment', 'Scheduled Payment')
ORDER BY TransactionDate DESC;

-- Display what we found
SELECT 
    @CardType AS CardType,
    @CardNetwork AS CardNetwork,
    @CardLast4 AS CardLast4,
    @BankName AS BankName;

-- Update the pending refund description to include card details
-- Note: Since the refund transaction doesn't exist yet (it's created when admin clicks "Mark as Processed"),
-- we'll show the card info in the subscription's cancellation reason

UPDATE PartnerSubscriptions
SET CancellationReason = 'Cancelled by user - Refund Pending: ₹299. Refund will be processed to ' 
    + CASE 
        WHEN @CardNetwork IS NOT NULL AND @CardLast4 IS NOT NULL 
        THEN @CardNetwork + ' **** ' + @CardLast4 + ' (' + ISNULL(@CardType, 'card') + ')'
        ELSE 'original payment method'
      END
WHERE SubscriptionId = 24
AND Status = 'Cancelled'
AND CancellationReason LIKE '%Refund Pending%';
GO

-- Verify the update
SELECT 
    SubscriptionId,
    Status,
    Amount,
    CancellationReason,
    CancelledOn
FROM PartnerSubscriptions
WHERE SubscriptionId = 24;
GO

PRINT 'Cancellation reason updated with card details!';
