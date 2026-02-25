-- Add CreatedOn column to Leads table if it doesn't exist
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Leads' AND COLUMN_NAME = 'CreatedOn')
BEGIN
    ALTER TABLE Leads ADD CreatedOn DATETIME2 NOT NULL DEFAULT GETDATE();
    PRINT 'CreatedOn column added to Leads table';
END
ELSE
BEGIN
    PRINT 'CreatedOn column already exists in Leads table';
END