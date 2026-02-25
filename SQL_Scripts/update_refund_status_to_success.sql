-- Update refund transaction status from "Processed" to "Success"
-- This makes it clearer for partners that the refund was successful

USE RealEstateCRM;
GO

-- Update all refund transactions from "Processed" to "Success"
UPDATE PaymentTransactions
SET Status = 'Success'
WHERE TransactionType = 'Refund'
AND Status = 'Processed';
GO

-- Verify the updates
SELECT 
    TransactionId,
    TransactionReference,
    SubscriptionId,
    Amount,
    Status,
    TransactionType,
    CardNetwork,
    CardLast4,
    Description,
    TransactionDate,
    CompletedDate
FROM PaymentTransactions
WHERE TransactionType = 'Refund'
ORDER BY TransactionDate DESC;
GO

PRINT 'Refund statuses updated to Success!';
