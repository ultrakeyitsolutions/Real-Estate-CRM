-- Update existing transaction with dummy card details for testing
-- Execute this script manually in SQL Server Management Studio

USE RealEstateCRM;
GO

-- Update TransactionId 27 with dummy card details
UPDATE PaymentTransactions
SET CardType = 'credit',
    CardNetwork = 'Visa',
    CardLast4 = '1111',
    BankName = 'HDFC Bank'
WHERE TransactionId = 27;
GO

-- Update any other recent successful transactions with dummy data
UPDATE PaymentTransactions
SET CardType = 'debit',
    CardNetwork = 'Mastercard',
    CardLast4 = '5555',
    BankName = 'ICICI Bank'
WHERE TransactionId = 26
AND Status = 'Success'
AND CardType IS NULL;
GO

-- Verify the updates
SELECT 
    TransactionId,
    RazorpayPaymentId,
    Amount,
    Status,
    CardType,
    CardNetwork,
    CardLast4,
    BankName,
    TransactionDate
FROM PaymentTransactions
WHERE TransactionId IN (26, 27)
ORDER BY TransactionId DESC;
GO

PRINT 'Dummy card details updated successfully!';
