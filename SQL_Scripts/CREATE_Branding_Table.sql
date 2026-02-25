-- Create Branding Table for Landing Page Customization
-- This table stores all branding elements that Admin can customize

CREATE TABLE Branding (
    BrandingId INT IDENTITY(1,1) PRIMARY KEY,
    
    -- Header/Navbar
    CompanyLogo NVARCHAR(MAX) NULL, -- Base64 image data
    
    -- Social Media Links
    TwitterUrl NVARCHAR(500) NULL,
    WhatsAppNumber NVARCHAR(20) NULL,
    FacebookUrl NVARCHAR(500) NULL,
    InstagramUrl NVARCHAR(500) NULL,
    LinkedInUrl NVARCHAR(500) NULL,
    
    -- About Us Section
    AboutUsText NVARCHAR(MAX) NULL,
    AboutUsImage NVARCHAR(MAX) NULL, -- Base64 image data
    
    -- Footer
    FooterLogo NVARCHAR(MAX) NULL, -- Base64 image data (smaller version)
    CompanyInfo NVARCHAR(MAX) NULL,
    TermsAndConditions NVARCHAR(MAX) NULL,
    PrivacyPolicy NVARCHAR(MAX) NULL,
    
    -- Metadata
    CreatedOn DATETIME DEFAULT GETDATE(),
    ModifiedOn DATETIME NULL,
    ModifiedBy INT NULL,
    IsActive BIT DEFAULT 1
);

-- Insert default record
INSERT INTO Branding (
    CompanyInfo,
    AboutUsText,
    IsActive
) VALUES (
    'Your Company Name<br/>Gachhibowli, Hyderabad<br/>Old Mumbai Highway 500032<br/>+91-9876543210<br/>info@company.com',
    'We are a leading real estate company committed to providing exceptional service and helping you find your dream property.',
    1
);

-- Add Branding page to Settings module
DECLARE @SettingsModuleId INT = (SELECT ModuleId FROM Modules WHERE ModuleName = 'Settings');

IF @SettingsModuleId IS NOT NULL
BEGIN
    INSERT INTO Pages (ModuleId, PageName, DisplayName, Controller, Action, SortOrder, IsActive) VALUES
    (@SettingsModuleId, 'Branding', 'Landing Page Branding', 'Settings', 'Branding', 3, 1);
    
    -- Get the new page ID
    DECLARE @BrandingPageId INT = (SELECT PageId FROM Pages WHERE Controller = 'Settings' AND Action = 'Branding');
    
    -- Grant Admin permissions for Branding page
    INSERT INTO RolePagePermissions (RoleName, PageId, PermissionId, IsGranted, CreatedBy, ChannelPartnerId) VALUES
    ('Admin', @BrandingPageId, 1, 1, 'System', NULL), -- View Access
    ('Admin', @BrandingPageId, 2, 1, 'System', NULL), -- Create Access
    ('Admin', @BrandingPageId, 3, 1, 'System', NULL), -- Edit Access
    ('Admin', @BrandingPageId, 4, 1, 'System', NULL), -- Delete Access
    ('Admin', @BrandingPageId, 5, 1, 'System', NULL), -- Export Access
    ('Admin', @BrandingPageId, 6, 1, 'System', NULL); -- Bulk Upload Access
    
    PRINT 'Branding page added to Settings module with Admin permissions';
END

-- Verification
SELECT 
    'Branding Table Created' as Status,
    COUNT(*) as RecordCount
FROM Branding;

SELECT 
    'Branding Page Added' as Status,
    p.DisplayName,
    p.Controller + '/' + p.Action as Route
FROM Pages p
JOIN Modules m ON p.ModuleId = m.ModuleId
WHERE m.ModuleName = 'Settings' AND p.Action = 'Branding';