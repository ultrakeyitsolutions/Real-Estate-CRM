-- P2 and P3 Features - Manual SQL Script
-- Execute these queries in SQL Server Management Studio
-- Date: January 3, 2026

USE CRM;
GO

PRINT '========================================';
PRINT 'P2 & P3 Features Database Setup';
PRINT '========================================';
PRINT '';

-- ============================================================================
-- P2-PR1: Property Gallery for Multiple Images
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PropertyGallery]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[PropertyGallery](
        [GalleryId] INT IDENTITY(1,1) PRIMARY KEY,
        [PropertyId] INT NOT NULL,
        [ImageTitle] NVARCHAR(200) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        [ImageData] VARBINARY(MAX) NOT NULL,
        [ContentType] NVARCHAR(100) NOT NULL DEFAULT 'image/jpeg',
        [FileSize] BIGINT NOT NULL DEFAULT 0,
        [ImageCategory] NVARCHAR(50) NOT NULL DEFAULT 'General',
        [DisplayOrder] INT NOT NULL DEFAULT 0,
        [IsPrimary] BIT NOT NULL DEFAULT 0,
        [UploadedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [UploadedBy] INT NULL,
        CONSTRAINT FK_PropertyGallery_Property FOREIGN KEY ([PropertyId]) REFERENCES [dbo].[Properties]([PropertyId]) ON DELETE CASCADE
    );
    PRINT 'Created PropertyGallery table';
END
ELSE
    PRINT 'PropertyGallery table already exists';
GO

-- ============================================================================
-- P2-T1: Task Templates
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TaskTemplates]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[TaskTemplates](
        [TemplateId] INT IDENTITY(1,1) PRIMARY KEY,
        [TemplateName] NVARCHAR(200) NOT NULL,
        [TaskTitle] NVARCHAR(500) NOT NULL,
        [Description] NVARCHAR(MAX) NULL,
        [Priority] NVARCHAR(20) NOT NULL DEFAULT 'Medium',
        [Category] NVARCHAR(50) NOT NULL DEFAULT 'General',
        [EstimatedDurationHours] INT NOT NULL DEFAULT 1,
        [DefaultAssigneeRole] NVARCHAR(20) NOT NULL DEFAULT 'Sales',
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedBy] INT NULL
    );
    PRINT 'Created TaskTemplates table';
END
ELSE
    PRINT 'TaskTemplates table already exists';
GO

-- ============================================================================
-- P2-T2: Recurring Tasks
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RecurringTasks]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[RecurringTasks](
        [RecurringTaskId] INT IDENTITY(1,1) PRIMARY KEY,
        [TaskTitle] NVARCHAR(200) NOT NULL,
        [Description] NVARCHAR(MAX) NULL,
        [RecurrencePattern] NVARCHAR(20) NOT NULL DEFAULT 'Daily',
        [RecurrenceInterval] INT NOT NULL DEFAULT 1,
        [StartDate] DATETIME NOT NULL,
        [EndDate] DATETIME NULL,
        [Priority] NVARCHAR(20) NOT NULL DEFAULT 'Medium',
        [AssignedTo] INT NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [LastGeneratedDate] DATETIME NULL,
        [NextGenerationDate] DATETIME NULL,
        [CreatedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedBy] INT NULL
    );
    PRINT 'Created RecurringTasks table';
END
ELSE
    PRINT 'RecurringTasks table already exists';
GO

-- ============================================================================
-- P2-Q2: Quotation Templates
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuotationTemplates]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[QuotationTemplates](
        [TemplateId] INT IDENTITY(1,1) PRIMARY KEY,
        [TemplateName] NVARCHAR(200) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        [ItemsJson] NVARCHAR(MAX) NULL,
        [TermsAndConditions] NVARCHAR(MAX) NULL,
        [DiscountPercentage] DECIMAL(5,2) NOT NULL DEFAULT 0,
        [TaxPercentage] DECIMAL(5,2) NOT NULL DEFAULT 0,
        [ValidityDays] INT NOT NULL DEFAULT 30,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedBy] INT NULL,
        [ModifiedOn] DATETIME NULL
    );
    PRINT 'Created QuotationTemplates table';
END
ELSE
    PRINT 'QuotationTemplates table already exists';
GO

-- ============================================================================
-- P2-Q3: Quotation Version History
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuotationVersions]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[QuotationVersions](
        [VersionId] INT IDENTITY(1,1) PRIMARY KEY,
        [QuotationId] INT NOT NULL,
        [VersionNumber] INT NOT NULL,
        [TotalAmount] DECIMAL(18,2) NOT NULL,
        [ItemsJson] NVARCHAR(MAX) NULL,
        [NotesJson] NVARCHAR(MAX) NULL,
        [ChangeReason] NVARCHAR(200) NULL,
        [CreatedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedBy] INT NULL,
        CONSTRAINT FK_QuotationVersions_Quotation FOREIGN KEY ([QuotationId]) REFERENCES [dbo].[Quotations]([QuotationId]) ON DELETE CASCADE
    );
    PRINT 'Created QuotationVersions table';
END
ELSE
    PRINT 'QuotationVersions table already exists';
GO

-- ============================================================================
-- P2-I4: Recurring Invoices
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[RecurringInvoices]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[RecurringInvoices](
        [RecurringInvoiceId] INT IDENTITY(1,1) PRIMARY KEY,
        [CustomerId] INT NULL,
        [InvoiceDescription] NVARCHAR(200) NOT NULL,
        [Amount] DECIMAL(18,2) NOT NULL,
        [Frequency] NVARCHAR(20) NOT NULL DEFAULT 'Monthly',
        [StartDate] DATETIME NOT NULL,
        [EndDate] DATETIME NULL,
        [LastGeneratedDate] DATETIME NULL,
        [NextGenerationDate] DATETIME NULL,
        [GeneratedInvoiceCount] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [AutoSendEmail] BIT NOT NULL DEFAULT 0,
        [CreatedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedBy] INT NULL
    );
    PRINT 'Created RecurringInvoices table';
END
ELSE
    PRINT 'RecurringInvoices table already exists';
GO

-- ============================================================================
-- P3-A7: Two-Factor Authentication
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TwoFactorAuth]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[TwoFactorAuth](
        [TwoFactorId] INT IDENTITY(1,1) PRIMARY KEY,
        [UserId] INT NOT NULL,
        [IsEnabled] BIT NOT NULL DEFAULT 0,
        [Method] NVARCHAR(20) NOT NULL DEFAULT 'SMS',
        [SecretKey] NVARCHAR(500) NULL,
        [BackupCodes] NVARCHAR(500) NULL,
        [EnabledOn] DATETIME NULL,
        [LastUsedOn] DATETIME NULL,
        CONSTRAINT FK_TwoFactorAuth_User FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users]([UserId]) ON DELETE CASCADE
    );
    PRINT 'Created TwoFactorAuth table';
END
ELSE
    PRINT 'TwoFactorAuth table already exists';
GO

-- ============================================================================
-- P3-L8: Lead Scoring Rules
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LeadScoringRules]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[LeadScoringRules](
        [RuleId] INT IDENTITY(1,1) PRIMARY KEY,
        [RuleName] NVARCHAR(200) NOT NULL,
        [Criteria] NVARCHAR(50) NOT NULL,
        [Operator] NVARCHAR(20) NOT NULL DEFAULT 'Equals',
        [Value] NVARCHAR(200) NOT NULL,
        [ScorePoints] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedOn] DATETIME NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Created LeadScoringRules table';
END
ELSE
    PRINT 'LeadScoringRules table already exists';
GO

-- ============================================================================
-- P3-CP4: Partner Hierarchy
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PartnerHierarchy]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[PartnerHierarchy](
        [HierarchyId] INT IDENTITY(1,1) PRIMARY KEY,
        [PartnerId] INT NOT NULL,
        [ParentPartnerId] INT NULL,
        [HierarchyLevel] INT NOT NULL DEFAULT 1,
        [CommissionPercentage] DECIMAL(5,2) NOT NULL DEFAULT 0,
        [JoinedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_PartnerHierarchy_Partner FOREIGN KEY ([PartnerId]) REFERENCES [dbo].[ChannelPartners]([PartnerId]),
        CONSTRAINT FK_PartnerHierarchy_Parent FOREIGN KEY ([ParentPartnerId]) REFERENCES [dbo].[ChannelPartners]([PartnerId])
    );
    PRINT 'Created PartnerHierarchy table';
END
ELSE
    PRINT 'PartnerHierarchy table already exists';
GO

-- ============================================================================
-- P3-PR4: Virtual Tours 360°
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[VirtualTours]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[VirtualTours](
        [TourId] INT IDENTITY(1,1) PRIMARY KEY,
        [PropertyId] INT NOT NULL,
        [TourTitle] NVARCHAR(200) NOT NULL,
        [TourUrl] NVARCHAR(1000) NOT NULL,
        [TourType] NVARCHAR(50) NOT NULL DEFAULT '360Video',
        [ViewCount] INT NOT NULL DEFAULT 0,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [CreatedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedBy] INT NULL,
        CONSTRAINT FK_VirtualTours_Property FOREIGN KEY ([PropertyId]) REFERENCES [dbo].[Properties]([PropertyId]) ON DELETE CASCADE
    );
    PRINT 'Created VirtualTours table';
END
ELSE
    PRINT 'VirtualTours table already exists';
GO

-- ============================================================================
-- P3-Q5: Quotation Approval Workflow
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[QuotationApprovals]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[QuotationApprovals](
        [ApprovalId] INT IDENTITY(1,1) PRIMARY KEY,
        [QuotationId] INT NOT NULL,
        [ClientEmail] NVARCHAR(100) NOT NULL,
        [ApprovalToken] NVARCHAR(500) NOT NULL UNIQUE,
        [Status] NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        [ApprovedOn] DATETIME NULL,
        [ClientComments] NVARCHAR(MAX) NULL,
        [ClientIPAddress] NVARCHAR(200) NULL,
        [ClientSignature] NVARCHAR(500) NULL,
        [ExpiresOn] DATETIME NOT NULL,
        [SentOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [SentBy] INT NULL,
        CONSTRAINT FK_QuotationApprovals_Quotation FOREIGN KEY ([QuotationId]) REFERENCES [dbo].[Quotations]([QuotationId]) ON DELETE CASCADE
    );
    PRINT 'Created QuotationApprovals table';
END
ELSE
    PRINT 'QuotationApprovals table already exists';
GO

-- ============================================================================
-- P3-AT1: Biometric Attendance
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[BiometricAttendance]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[BiometricAttendance](
        [BiometricId] INT IDENTITY(1,1) PRIMARY KEY,
        [AgentId] INT NOT NULL,
        [DeviceId] NVARCHAR(100) NOT NULL,
        [BiometricDeviceRecordId] NVARCHAR(100) NOT NULL,
        [PunchTime] DATETIME NOT NULL,
        [PunchType] NVARCHAR(20) NOT NULL DEFAULT 'In',
        [LocationGPS] NVARCHAR(200) NULL,
        [IsVerified] BIT NOT NULL DEFAULT 1,
        [SyncedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_BiometricAttendance_Agent FOREIGN KEY ([AgentId]) REFERENCES [dbo].[Agents]([AgentId]) ON DELETE CASCADE
    );
    PRINT 'Created BiometricAttendance table';
END
ELSE
    PRINT 'BiometricAttendance table already exists';
GO

-- ============================================================================
-- P3-T4: Task Dependencies
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TaskDependencies]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[TaskDependencies](
        [DependencyId] INT IDENTITY(1,1) PRIMARY KEY,
        [TaskId] INT NOT NULL,
        [DependsOnTaskId] INT NOT NULL,
        [DependencyType] NVARCHAR(20) NOT NULL DEFAULT 'FinishToStart',
        [LagDays] INT NOT NULL DEFAULT 0,
        [CreatedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_TaskDependencies_Task FOREIGN KEY ([TaskId]) REFERENCES [dbo].[RecurringTasks]([RecurringTaskId]),
        CONSTRAINT FK_TaskDependencies_DependsOn FOREIGN KEY ([DependsOnTaskId]) REFERENCES [dbo].[RecurringTasks]([RecurringTaskId])
    );
    PRINT 'Created TaskDependencies table';
END
ELSE
    PRINT 'TaskDependencies table already exists';
GO

-- ============================================================================
-- P3-R3: Custom Report Builder
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CustomReports]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[CustomReports](
        [ReportId] INT IDENTITY(1,1) PRIMARY KEY,
        [ReportName] NVARCHAR(200) NOT NULL,
        [Description] NVARCHAR(500) NULL,
        [DataSource] NVARCHAR(50) NOT NULL,
        [ColumnsJson] NVARCHAR(MAX) NULL,
        [FiltersJson] NVARCHAR(MAX) NULL,
        [SortingJson] NVARCHAR(MAX) NULL,
        [GroupingJson] NVARCHAR(MAX) NULL,
        [ChartType] NVARCHAR(50) NOT NULL DEFAULT 'Table',
        [IsPublic] BIT NOT NULL DEFAULT 0,
        [CreatedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedBy] INT NULL,
        [ModifiedOn] DATETIME NULL
    );
    PRINT 'Created CustomReports table';
END
ELSE
    PRINT 'CustomReports table already exists';
GO

-- ============================================================================
-- P3-W3: Zapier Integration Webhooks
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZapierWebhooks]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ZapierWebhooks](
        [ZapWebhookId] INT IDENTITY(1,1) PRIMARY KEY,
        [WebhookUrl] NVARCHAR(500) NOT NULL,
        [TriggerEvent] NVARCHAR(50) NOT NULL,
        [IsActive] BIT NOT NULL DEFAULT 1,
        [LastTriggeredOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [TriggerCount] INT NOT NULL DEFAULT 0,
        [CreatedOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [CreatedBy] INT NULL
    );
    PRINT 'Created ZapierWebhooks table';
END
ELSE
    PRINT 'ZapierWebhooks table already exists';
GO

-- ============================================================================
-- P3-W4: AI Lead Scoring
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AILeadScores]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[AILeadScores](
        [ScoreId] INT IDENTITY(1,1) PRIMARY KEY,
        [LeadId] INT NOT NULL,
        [AIScore] INT NOT NULL DEFAULT 0,
        [ScoreCategory] NVARCHAR(20) NOT NULL DEFAULT 'Cold',
        [AIReasoningJson] NVARCHAR(MAX) NULL,
        [ConversionProbability] DECIMAL(5,4) NOT NULL DEFAULT 0,
        [RecommendedActions] NVARCHAR(MAX) NULL,
        [ScoredOn] DATETIME NOT NULL DEFAULT GETDATE(),
        [AIModel] NVARCHAR(50) NOT NULL DEFAULT 'v1.0',
        CONSTRAINT FK_AILeadScores_Lead FOREIGN KEY ([LeadId]) REFERENCES [dbo].[Leads]([LeadId]) ON DELETE CASCADE
    );
    PRINT 'Created AILeadScores table';
END
ELSE
    PRINT 'AILeadScores table already exists';
GO

PRINT '';
PRINT '========================================';
PRINT 'P2 & P3 Tables Created Successfully!';
PRINT '========================================';
PRINT '';
PRINT 'Summary:';
PRINT '- P2 Features: 6 tables (PropertyGallery, TaskTemplates, RecurringTasks, QuotationTemplates, QuotationVersions, RecurringInvoices)';
PRINT '- P3 Features: 11 tables (TwoFactorAuth, LeadScoringRules, PartnerHierarchy, VirtualTours, QuotationApprovals, BiometricAttendance, TaskDependencies, CustomReports, ZapierWebhooks, AILeadScores)';
PRINT '';
GO
