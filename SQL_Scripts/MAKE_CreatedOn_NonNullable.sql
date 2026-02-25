-- Make CreatedOn column non-nullable to match Entity Framework model
-- First, ensure all existing records have a CreatedOn value
UPDATE Leads 
SET CreatedOn = GETDATE() 
WHERE CreatedOn IS NULL;

-- Now alter the column to be non-nullable with a default value
ALTER TABLE Leads 
ALTER COLUMN CreatedOn DATETIME2 NOT NULL;

-- Add a default constraint for future inserts
IF NOT EXISTS (SELECT * FROM sys.default_constraints 
               WHERE parent_object_id = OBJECT_ID('Leads') 
               AND parent_column_id = (SELECT column_id FROM sys.columns 
                                      WHERE object_id = OBJECT_ID('Leads') 
                                      AND name = 'CreatedOn'))
BEGIN
    ALTER TABLE Leads 
    ADD CONSTRAINT DF_Leads_CreatedOn DEFAULT GETDATE() FOR CreatedOn;
END

PRINT 'CreatedOn column updated to be non-nullable with default value';