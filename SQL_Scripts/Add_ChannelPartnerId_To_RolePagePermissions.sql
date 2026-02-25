-- Add ChannelPartnerId column to RolePagePermissions table
-- This allows separate permissions for Admin agents vs Partner agents

-- Add the new column
ALTER TABLE RolePagePermissions 
ADD ChannelPartnerId INT NULL;

-- Add foreign key constraint (optional, if you want referential integrity)
-- ALTER TABLE RolePagePermissions 
-- ADD CONSTRAINT FK_RolePagePermissions_ChannelPartner 
-- FOREIGN KEY (ChannelPartnerId) REFERENCES ChannelPartners(Id);

-- Update existing records to have NULL ChannelPartnerId (Admin permissions)
-- No update needed as new column defaults to NULL

PRINT 'ChannelPartnerId column added to RolePagePermissions table successfully';