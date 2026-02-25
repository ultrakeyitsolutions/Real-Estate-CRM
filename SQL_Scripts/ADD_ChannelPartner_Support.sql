-- =====================================================
-- ADD CHANNEL PARTNER SUPPORT TO EXISTING TABLES
-- All columns are NULLABLE to support existing data
-- =====================================================

-- 1. Add ChannelPartnerId to Users table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Users') AND name = 'ChannelPartnerId')
BEGIN
    ALTER TABLE Users ADD ChannelPartnerId INT NULL;
    PRINT 'Added ChannelPartnerId to Users table';
END
GO

-- 2. Add ChannelPartnerId to Leads table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Leads') AND name = 'ChannelPartnerId')
BEGIN
    ALTER TABLE Leads ADD ChannelPartnerId INT NULL;
    PRINT 'Added ChannelPartnerId to Leads table';
END
GO

-- 3. Add ChannelPartnerId to Agents table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Agents') AND name = 'ChannelPartnerId')
BEGIN
    ALTER TABLE Agents ADD ChannelPartnerId INT NULL;
    PRINT 'Added ChannelPartnerId to Agents table';
END
GO

-- 4. Add ChannelPartnerId to Bookings table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Bookings') AND name = 'ChannelPartnerId')
BEGIN
    ALTER TABLE Bookings ADD ChannelPartnerId INT NULL;
    PRINT 'Added ChannelPartnerId to Bookings table';
END
GO

-- 5. Add ChannelPartnerId to Quotations table
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Quotations') AND name = 'ChannelPartnerId')
BEGIN
    ALTER TABLE Quotations ADD ChannelPartnerId INT NULL;
    PRINT 'Added ChannelPartnerId to Quotations table';
END
GO

-- 6. Add UserId to ChannelPartners table (to link with Users table)
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'ChannelPartners') AND name = 'UserId')
BEGIN
    ALTER TABLE ChannelPartners ADD UserId INT NULL;
    PRINT 'Added UserId to ChannelPartners table';
END
GO

-- 7. Add Partner role to RolePermissions if not exists
IF NOT EXISTS (SELECT * FROM RolePermissions WHERE RoleName = 'Partner')
BEGIN
    INSERT INTO RolePermissions (RoleName, CanCreate, CanEdit, CanDelete, CanView, CreatedAt)
    VALUES ('Partner', 1, 1, 1, 1, GETDATE());
    PRINT 'Added Partner role to RolePermissions';
END
GO

PRINT 'All database changes completed successfully!';
