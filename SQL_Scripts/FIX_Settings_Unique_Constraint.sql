-- Fix Settings table UNIQUE constraint to allow same SettingKey for different ChannelPartnerIds
-- This allows Admin and Partners to have separate logos and settings

-- Drop old unique constraint on SettingKey only
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ__Settings__01E719AD677D1BDD' AND object_id = OBJECT_ID('dbo.Settings'))
BEGIN
    ALTER TABLE [dbo].[Settings] DROP CONSTRAINT [UQ__Settings__01E719AD677D1BDD];
    PRINT 'Dropped old unique constraint on SettingKey';
END
GO

-- Create new unique constraint on (SettingKey, ChannelPartnerId) combination
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'UQ_Settings_Key_Partner' AND object_id = OBJECT_ID('dbo.Settings'))
BEGIN
    ALTER TABLE [dbo].[Settings] 
    ADD CONSTRAINT [UQ_Settings_Key_Partner] UNIQUE (SettingKey, ChannelPartnerId);
    PRINT 'Created new unique constraint on (SettingKey, ChannelPartnerId)';
END
GO

-- Verify the constraint
SELECT 
    i.name AS ConstraintName,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE i.object_id = OBJECT_ID('dbo.Settings') AND i.is_unique = 1
ORDER BY ic.key_ordinal;
GO
