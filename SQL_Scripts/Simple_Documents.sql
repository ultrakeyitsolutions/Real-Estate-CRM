-- Simple document management for Channel Partner onboarding
-- Only add what's needed without breaking existing functionality

-- 1. Document Types Table
CREATE TABLE DocumentTypes (
    DocumentTypeId INT IDENTITY(1,1) PRIMARY KEY,
    DocumentName NVARCHAR(100) NOT NULL,
    IsRequired BIT DEFAULT 1,
    IsActive BIT DEFAULT 1
);

-- 2. Channel Partner Documents Table  
CREATE TABLE ChannelPartnerDocuments (
    DocumentId INT IDENTITY(1,1) PRIMARY KEY,
    PartnerId INT NOT NULL, -- Links to existing ChannelPartners.PartnerId
    DocumentTypeId INT NOT NULL,
    FileName NVARCHAR(255) NOT NULL,
    FilePath NVARCHAR(500) NOT NULL,
    UploadedDate DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (DocumentTypeId) REFERENCES DocumentTypes(DocumentTypeId)
);

-- Insert basic document types
INSERT INTO DocumentTypes (DocumentName, IsRequired) VALUES
('Business Registration', 1),
('Tax Certificate', 1),
('Bank Details', 1),
('Identity Proof', 1),
('Address Proof', 0);

-- Add SubscriptionPlan column to existing ChannelPartners table
ALTER TABLE ChannelPartners ADD SubscriptionPlan NVARCHAR(50) DEFAULT 'Basic';