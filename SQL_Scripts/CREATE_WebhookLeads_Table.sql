-- Create WebhookLeads Table for Public Lead Capture
-- This stores leads from public-facing pages (Landing, Project Details)
-- Separate from main Leads table to allow review before assigning

USE CRM;
GO

-- Check if table exists
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'WebhookLeads')
BEGIN
    CREATE TABLE WebhookLeads (
        WebhookLeadId INT PRIMARY KEY IDENTITY(1,1),
        Name NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) NOT NULL,
        Contact NVARCHAR(20) NOT NULL,
        CompanyName NVARCHAR(100) NULL,
        Requirements NVARCHAR(MAX) NULL,
        LeadType NVARCHAR(50) NOT NULL DEFAULT 'Express Interest', -- 'Express Interest' or 'Site Visit'
        ProjectName NVARCHAR(100) NULL,
        PropertyId INT NULL,
        Status NVARCHAR(50) NOT NULL DEFAULT 'Pending', -- Pending, Assigned, Converted, Rejected
        AssignedToUserId INT NULL,
        CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
        AssignedOn DATETIME NULL,
        Notes NVARCHAR(500) NULL,
        Source NVARCHAR(100) NULL DEFAULT 'Website',
        ConvertedToLeadId INT NULL,

        -- Foreign Keys
        CONSTRAINT FK_WebhookLeads_Property FOREIGN KEY (PropertyId) REFERENCES Properties(PropertyId),
        CONSTRAINT FK_WebhookLeads_AssignedUser FOREIGN KEY (AssignedToUserId) REFERENCES Users(UserId),
        CONSTRAINT FK_WebhookLeads_ConvertedLead FOREIGN KEY (ConvertedToLeadId) REFERENCES Leads(LeadId)
    );

    -- Create Indexes for better performance
    CREATE INDEX IX_WebhookLeads_Status ON WebhookLeads(Status);
    CREATE INDEX IX_WebhookLeads_CreatedOn ON WebhookLeads(CreatedOn DESC);
    CREATE INDEX IX_WebhookLeads_PropertyId ON WebhookLeads(PropertyId);
    CREATE INDEX IX_WebhookLeads_AssignedToUserId ON WebhookLeads(AssignedToUserId);
    CREATE INDEX IX_WebhookLeads_Email ON WebhookLeads(Email);

    PRINT 'WebhookLeads table created successfully';
END
ELSE
BEGIN
    PRINT 'WebhookLeads table already exists';
END
GO
