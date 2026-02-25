-- Add card detail columns to PaymentTransactions table
-- Execute this script manually in SQL Server Management Studio

USE RealEstateCRM;
GO

-- Add card information columns
ALTER TABLE PaymentTransactions
ADD CardType NVARCHAR(20) NULL,
    CardNetwork NVARCHAR(50) NULL,
    CardLast4 NVARCHAR(10) NULL,
    BankName NVARCHAR(50) NULL;
GO

-- Verify the columns were added
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PaymentTransactions'
AND COLUMN_NAME IN ('CardType', 'CardNetwork', 'CardLast4', 'BankName');
GO

PRINT 'Card detail columns added successfully!';
