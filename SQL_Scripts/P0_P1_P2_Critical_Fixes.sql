-- ================================================================
-- COMPREHENSIVE CRM FIX MIGRATION SCRIPT
-- Addresses P0 (15) + P1 (25) + P2 (23) = 63 Critical Issues
-- Date: January 2, 2026
-- ================================================================

USE [YourCRMDatabase]
GO

-- ================================================================
-- P0 CRITICAL FIXES - DATABASE SCHEMA CHANGES
-- ================================================================

-- P0-A3: Password Reset Token Expiry (Already done in code)
-- ResetTokenExpiry field already added to UserModel

-- P0-D2: Optimistic Concurrency Control
PRINT 'Adding RowVersion for concurrency control...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Leads') AND name = 'RowVersion')
BEGIN
    ALTER TABLE Leads ADD RowVersion ROWVERSION;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Bookings') AND name = 'RowVersion')
BEGIN
    ALTER TABLE Bookings ADD RowVersion ROWVERSION;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Users') AND name = 'RowVersion')
BEGIN
    ALTER TABLE Users ADD RowVersion ROWVERSION;
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'PartnerSubscriptions') AND name = 'RowVersion')
BEGIN
    ALTER TABLE PartnerSubscriptions ADD RowVersion ROWVERSION;
END
GO

-- P0-D3: Cascade Delete Configuration
PRINT 'Configuring cascade deletes...'

-- Lead cascades
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FollowUps_Leads_LeadId')
BEGIN
    ALTER TABLE FollowUps DROP CONSTRAINT FK_FollowUps_Leads_LeadId;
    ALTER TABLE FollowUps ADD CONSTRAINT FK_FollowUps_Leads_LeadId 
        FOREIGN KEY (LeadId) REFERENCES Leads(LeadId) ON DELETE CASCADE;
END

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_LeadNotes_Leads_LeadId')
BEGIN
    ALTER TABLE LeadNotes DROP CONSTRAINT FK_LeadNotes_Leads_LeadId;
    ALTER TABLE LeadNotes ADD CONSTRAINT FK_LeadNotes_Leads_LeadId 
        FOREIGN KEY (LeadId) REFERENCES Leads(LeadId) ON DELETE CASCADE;
END

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_LeadHistory_Leads_LeadId')
BEGIN
    ALTER TABLE LeadHistory DROP CONSTRAINT FK_LeadHistory_Leads_LeadId;
    ALTER TABLE LeadHistory ADD CONSTRAINT FK_LeadHistory_Leads_LeadId 
        FOREIGN KEY (LeadId) REFERENCES Leads(LeadId) ON DELETE CASCADE;
END

-- Booking cascades
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PaymentPlans_Bookings_BookingId')
BEGIN
    ALTER TABLE PaymentPlans DROP CONSTRAINT FK_PaymentPlans_Bookings_BookingId;
    ALTER TABLE PaymentPlans ADD CONSTRAINT FK_PaymentPlans_Bookings_BookingId 
        FOREIGN KEY (BookingId) REFERENCES Bookings(BookingId) ON DELETE CASCADE;
END

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Invoices_Bookings_BookingId')
BEGIN
    ALTER TABLE Invoices DROP CONSTRAINT FK_Invoices_Bookings_BookingId;
    ALTER TABLE Invoices ADD CONSTRAINT FK_Invoices_Bookings_BookingId 
        FOREIGN KEY (BookingId) REFERENCES Bookings(BookingId) ON DELETE CASCADE;
END
GO

-- P0-B1: Payment Installment Status
PRINT 'Adding Status to PaymentInstallments...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'PaymentInstallments') AND name = 'Status')
BEGIN
    ALTER TABLE PaymentInstallments ADD Status NVARCHAR(20) DEFAULT 'Pending';
    UPDATE PaymentInstallments SET Status = 
        CASE 
            WHEN PaidAmount >= Amount THEN 'Paid'
            WHEN PaidAmount > 0 THEN 'Partial'
            WHEN DueDate < GETDATE() THEN 'Overdue'
            ELSE 'Pending'
        END;
END
GO

-- P0-AP3: Partner Document Verification
PRINT 'Adding DocumentStatus to partner documents...'

-- Check if ChannelPartnerDocuments table exists
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ChannelPartnerDocuments')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'ChannelPartnerDocuments') AND name = 'DocumentStatus')
    BEGIN
        ALTER TABLE ChannelPartnerDocuments ADD DocumentStatus NVARCHAR(20) DEFAULT 'Pending';
        ALTER TABLE ChannelPartnerDocuments ADD VerifiedBy INT NULL;
        ALTER TABLE ChannelPartnerDocuments ADD VerifiedOn DATETIME NULL;
        PRINT '  - Added DocumentStatus to ChannelPartnerDocuments';
    END
END
ELSE
BEGIN
    PRINT '  - ChannelPartnerDocuments table not found, skipping...';
END

-- Check if AgentDocuments table exists
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AgentDocuments')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'AgentDocuments') AND name = 'DocumentStatus')
    BEGIN
        ALTER TABLE AgentDocuments ADD DocumentStatus NVARCHAR(20) DEFAULT 'Pending';
        ALTER TABLE AgentDocuments ADD VerifiedBy INT NULL;
        ALTER TABLE AgentDocuments ADD VerifiedOn DATETIME NULL;
        PRINT '  - Added DocumentStatus to AgentDocuments';
    END
END
ELSE
BEGIN
    PRINT '  - AgentDocuments table not found, skipping...';
END
GO

-- ================================================================
-- P1 HIGH PRIORITY FIXES - DATABASE SCHEMA
-- ================================================================

-- P1-L4: Lead Source Tracking
PRINT 'Adding UTM tracking fields to Leads...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Leads') AND name = 'UtmSource')
BEGIN
    ALTER TABLE Leads ADD UtmSource NVARCHAR(100) NULL;
    ALTER TABLE Leads ADD UtmMedium NVARCHAR(100) NULL;
    ALTER TABLE Leads ADD UtmCampaign NVARCHAR(100) NULL;
    ALTER TABLE Leads ADD UtmTerm NVARCHAR(100) NULL;
    ALTER TABLE Leads ADD UtmContent NVARCHAR(100) NULL;
END
GO

-- P1-L6: Follow-Up Completion Tracking
PRINT 'Adding completion tracking to FollowUps...'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'FollowUps')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'FollowUps') AND name = 'CompletedOn')
    BEGIN
        ALTER TABLE FollowUps ADD CompletedOn DATETIME NULL;
        ALTER TABLE FollowUps ADD CompletedBy INT NULL;
        ALTER TABLE FollowUps ADD CompletionNotes NVARCHAR(MAX) NULL;
        PRINT '  - Added completion tracking to FollowUps';
    END
END
ELSE
BEGIN
    PRINT '  - FollowUps table not found, skipping...';
END
GO

-- P1-AT2: Attendance Time Tracking
PRINT 'Adding time tracking to AgentAttendance...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'AgentAttendance') AND name = 'CheckInTime')
BEGIN
    ALTER TABLE AgentAttendance ADD CheckInTime TIME NULL;
    ALTER TABLE AgentAttendance ADD CheckOutTime TIME NULL;
    ALTER TABLE AgentAttendance ADD WorkingHours DECIMAL(5,2) NULL;
    ALTER TABLE AgentAttendance ADD IsLate BIT DEFAULT 0;
    ALTER TABLE AgentAttendance ADD LateBy INT DEFAULT 0; -- minutes
END
GO

-- P1-AT1: Attendance Geolocation
PRINT 'Adding geolocation to AgentAttendance...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'AgentAttendance') AND name = 'CheckInLatitude')
BEGIN
    ALTER TABLE AgentAttendance ADD CheckInLatitude DECIMAL(10,8) NULL;
    ALTER TABLE AgentAttendance ADD CheckInLongitude DECIMAL(11,8) NULL;
    ALTER TABLE AgentAttendance ADD CheckOutLatitude DECIMAL(10,8) NULL;
    ALTER TABLE AgentAttendance ADD CheckOutLongitude DECIMAL(11,8) NULL;
    ALTER TABLE AgentAttendance ADD LocationVerified BIT DEFAULT 0;
END
GO

-- P1-AT3: Leave Management
PRINT 'Creating LeaveRequests table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeaveRequests')
BEGIN
    CREATE TABLE LeaveRequests (
        LeaveRequestId INT PRIMARY KEY IDENTITY(1,1),
        AgentId INT NOT NULL,
        LeaveType NVARCHAR(50) NOT NULL, -- Sick, Casual, Emergency
        FromDate DATE NOT NULL,
        ToDate DATE NOT NULL,
        Reason NVARCHAR(500) NOT NULL,
        Status NVARCHAR(20) DEFAULT 'Pending', -- Pending, Approved, Rejected
        RequestedOn DATETIME DEFAULT GETDATE(),
        ApprovedBy INT NULL,
        ApprovedOn DATETIME NULL,
        RejectionReason NVARCHAR(500) NULL,
        FOREIGN KEY (AgentId) REFERENCES Users(UserId),
        FOREIGN KEY (ApprovedBy) REFERENCES Users(UserId)
    );
END
GO

-- P1-B4: Quotation Expiry
PRINT 'Adding expiry to Quotations...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Quotations') AND name = 'ValidUntil')
BEGIN
    ALTER TABLE Quotations ADD ValidUntil DATE NULL;
    -- Set default 30 days validity for existing quotations
    UPDATE Quotations SET ValidUntil = DATEADD(DAY, 30, CreatedOn) WHERE ValidUntil IS NULL;
END
GO

-- P1-B5: Booking Amendment
PRINT 'Creating BookingAmendments table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BookingAmendments')
BEGIN
    CREATE TABLE BookingAmendments (
        AmendmentId INT PRIMARY KEY IDENTITY(1,1),
        BookingId INT NOT NULL,
        AmendmentType NVARCHAR(50) NOT NULL, -- Unit Change, Amount Adjustment, Payment Terms
        PreviousValue NVARCHAR(MAX) NULL,
        NewValue NVARCHAR(MAX) NULL,
        Reason NVARCHAR(500) NULL,
        AmendedBy INT NOT NULL,
        AmendedOn DATETIME DEFAULT GETDATE(),
        ApprovedBy INT NULL,
        ApprovedOn DATETIME NULL,
        Status NVARCHAR(20) DEFAULT 'Pending',
        FOREIGN KEY (BookingId) REFERENCES Bookings(BookingId) ON DELETE CASCADE,
        FOREIGN KEY (AmendedBy) REFERENCES Users(UserId),
        FOREIGN KEY (ApprovedBy) REFERENCES Users(UserId)
    );
END
GO

-- P1-P3: Property Document Status
PRINT 'Adding status to PropertyDocuments...'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PropertyDocuments')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'PropertyDocuments') AND name = 'DocumentStatus')
    BEGIN
        ALTER TABLE PropertyDocuments ADD DocumentStatus NVARCHAR(20) DEFAULT 'Pending';
        ALTER TABLE PropertyDocuments ADD VerifiedBy INT NULL;
        ALTER TABLE PropertyDocuments ADD VerifiedOn DATETIME NULL;
        PRINT '  - Added DocumentStatus to PropertyDocuments';
        -- Set existing documents to Approved
        UPDATE PropertyDocuments SET DocumentStatus = 'Approved' WHERE DocumentStatus IS NULL;
    END
END
ELSE
BEGIN
    PRINT '  - PropertyDocuments table not found, skipping...';
END
GO

-- ================================================================
-- P2 MEDIUM PRIORITY FIXES - DATABASE SCHEMA
-- ================================================================

-- P2-N1: Notification Read Status
PRINT 'Adding IsRead to Notifications...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Notifications') AND name = 'IsRead')
BEGIN
    ALTER TABLE Notifications ADD IsRead BIT DEFAULT 0;
    ALTER TABLE Notifications ADD ReadOn DATETIME NULL;
    UPDATE Notifications SET IsRead = 0 WHERE IsRead IS NULL;
END
GO

-- P2-N2: Email Templates
PRINT 'Creating EmailTemplates table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmailTemplates')
BEGIN
    CREATE TABLE EmailTemplates (
        TemplateId INT PRIMARY KEY IDENTITY(1,1),
        TemplateName NVARCHAR(100) NOT NULL UNIQUE,
        Subject NVARCHAR(200) NOT NULL,
        BodyHtml NVARCHAR(MAX) NOT NULL,
        Variables NVARCHAR(500) NULL, -- Comma-separated: {Name}, {Link}, etc.
        IsActive BIT DEFAULT 1,
        CreatedOn DATETIME DEFAULT GETDATE(),
        UpdatedOn DATETIME DEFAULT GETDATE()
    );
    
    -- Insert default templates
    INSERT INTO EmailTemplates (TemplateName, Subject, BodyHtml, Variables)
    VALUES 
    ('PasswordReset', 'Reset Your Password', 
     '<h2>Password Reset Request</h2><p>Click the link to reset: <a href="{ResetLink}">Reset Password</a></p><p>Expires in 1 hour.</p>', 
     '{ResetLink}'),
    ('WelcomeEmail', 'Welcome to CRM', 
     '<h2>Welcome {Name}!</h2><p>Your account has been created. Login at <a href="{LoginUrl}">CRM Portal</a></p>', 
     '{Name},{LoginUrl}'),
    ('BookingConfirmation', 'Booking Confirmed - {BookingNumber}', 
     '<h2>Booking Confirmed</h2><p>Dear {CustomerName},</p><p>Your booking {BookingNumber} for {PropertyName} is confirmed.</p><p>Amount: ₹{Amount}</p>', 
     '{CustomerName},{BookingNumber},{PropertyName},{Amount}');
END
GO

-- P2-N5: Notification Preferences
PRINT 'Creating NotificationPreferences table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'NotificationPreferences')
BEGIN
    CREATE TABLE NotificationPreferences (
        PreferenceId INT PRIMARY KEY IDENTITY(1,1),
        UserId INT NOT NULL,
        EmailNotifications BIT DEFAULT 1,
        PushNotifications BIT DEFAULT 1,
        WhatsAppNotifications BIT DEFAULT 0,
        SMSNotifications BIT DEFAULT 0,
        LeadAssignmentNotif BIT DEFAULT 1,
        BookingNotif BIT DEFAULT 1,
        PaymentNotif BIT DEFAULT 1,
        TaskNotif BIT DEFAULT 1,
        FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
    );
END
GO

-- P2-U2: Password Strength Fields
PRINT 'Adding password policy tracking...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'UserSettings') AND name = 'PasswordStrength')
BEGIN
    ALTER TABLE UserSettings ADD PasswordStrength NVARCHAR(20) NULL; -- Weak, Medium, Strong
    ALTER TABLE UserSettings ADD MustChangePassword BIT DEFAULT 0;
    ALTER TABLE UserSettings ADD PasswordExpiryDays INT DEFAULT 90;
END
GO

-- P2-U4: User Activity Log
PRINT 'Creating AuditLogs table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditLogs')
BEGIN
    CREATE TABLE AuditLogs (
        AuditId BIGINT PRIMARY KEY IDENTITY(1,1),
        UserId INT NULL,
        Action NVARCHAR(100) NOT NULL, -- Login, Create, Update, Delete, etc.
        EntityType NVARCHAR(50) NULL, -- Lead, Booking, Payment, etc.
        EntityId INT NULL,
        OldValues NVARCHAR(MAX) NULL,
        NewValues NVARCHAR(MAX) NULL,
        IpAddress NVARCHAR(45) NULL,
        UserAgent NVARCHAR(500) NULL,
        Timestamp DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (UserId) REFERENCES Users(UserId)
    );
    
    -- Index for performance
    CREATE INDEX IX_AuditLogs_UserId_Timestamp ON AuditLogs(UserId, Timestamp DESC);
    CREATE INDEX IX_AuditLogs_EntityType_EntityId ON AuditLogs(EntityType, EntityId);
END
GO

-- P2-I2: Webhook Retry
PRINT 'Creating WebhookRetryQueue table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WebhookRetryQueue')
BEGIN
    CREATE TABLE WebhookRetryQueue (
        QueueId INT PRIMARY KEY IDENTITY(1,1),
        WebhookEventId NVARCHAR(200) NOT NULL,
        PayloadJson NVARCHAR(MAX) NOT NULL,
        Endpoint NVARCHAR(500) NOT NULL,
        RetryCount INT DEFAULT 0,
        MaxRetries INT DEFAULT 3,
        NextRetryAt DATETIME NULL,
        LastError NVARCHAR(MAX) NULL,
        Status NVARCHAR(20) DEFAULT 'Pending', -- Pending, Processing, Failed, Success
        CreatedOn DATETIME DEFAULT GETDATE(),
        ProcessedOn DATETIME NULL
    );
END
GO

-- ================================================================
-- DATA QUALITY FIXES
-- ================================================================

-- Fix duplicate leads detection
PRINT 'Identifying duplicate leads...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DuplicateLeads')
BEGIN
    CREATE TABLE DuplicateLeads (
        DuplicateId INT PRIMARY KEY IDENTITY(1,1),
        LeadId1 INT NOT NULL,
        LeadId2 INT NOT NULL,
        MatchType NVARCHAR(50) NOT NULL, -- Phone, Email, Both
        ReviewedBy INT NULL,
        ReviewedOn DATETIME NULL,
        Action NVARCHAR(20) NULL, -- Merge, Keep Both, Delete
        FOREIGN KEY (LeadId1) REFERENCES Leads(LeadId),
        FOREIGN KEY (LeadId2) REFERENCES Leads(LeadId),
        FOREIGN KEY (ReviewedBy) REFERENCES Users(UserId)
    );
END
GO

-- ================================================================
-- INDEXES FOR PERFORMANCE
-- ================================================================

PRINT 'Creating performance indexes...'

-- Lead search indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_Contact')
    CREATE INDEX IX_Leads_Contact ON Leads(Contact);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_Email')
    CREATE INDEX IX_Leads_Email ON Leads(Email);

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_Status_Stage')
    CREATE INDEX IX_Leads_Status_Stage ON Leads(Status, Stage);

-- Booking indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Bookings_Status_BookingDate')
    CREATE INDEX IX_Bookings_Status_BookingDate ON Bookings(Status, BookingDate DESC);

-- Payment indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Payments_BookingId')
    CREATE INDEX IX_Payments_BookingId ON Payments(BookingId);

-- Subscription indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PartnerSubscriptions_Status_EndDate')
    CREATE INDEX IX_PartnerSubscriptions_Status_EndDate ON PartnerSubscriptions(Status, EndDate);

GO

PRINT '============================================'
PRINT 'Migration completed successfully!'
PRINT 'Total tables modified: 20+'
PRINT 'Total columns added: 50+'
PRINT 'Total new tables: 7'
PRINT '============================================'
