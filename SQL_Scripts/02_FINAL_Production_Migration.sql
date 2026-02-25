-- ================================================================
-- FINAL PRODUCTION-READY MIGRATION SCRIPT
-- Based on your actual database schema verification
-- Date: January 3, 2026
-- ================================================================

USE [YourCRMDatabase]
GO

SET NOCOUNT ON;

PRINT '================================================='
PRINT 'CRM PRODUCTION MIGRATION - STARTING'
PRINT 'Date: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '================================================='
PRINT ''

-- ================================================================
-- PHASE 1: CRITICAL SCHEMA CHANGES (P0)
-- ================================================================

PRINT 'PHASE 1: Critical Schema Changes'
PRINT '---------------------------------'

-- 1. Password Reset Token Expiry
PRINT '1. Adding ResetTokenExpiry to Users...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Users') AND name = 'ResetTokenExpiry')
BEGIN
    ALTER TABLE Users ADD ResetTokenExpiry DATETIME NULL;
    PRINT '   ✓ ResetTokenExpiry added successfully'
END
ELSE
    PRINT '   - ResetTokenExpiry already exists'
GO

-- 2. Optimistic Concurrency Control
PRINT ''
PRINT '2. Adding RowVersion for concurrency control...'

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Leads') AND name = 'RowVersion')
BEGIN
    ALTER TABLE Leads ADD RowVersion ROWVERSION;
    PRINT '   ✓ RowVersion added to Leads'
END
ELSE
    PRINT '   - RowVersion already exists in Leads'

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Bookings') AND name = 'RowVersion')
BEGIN
    ALTER TABLE Bookings ADD RowVersion ROWVERSION;
    PRINT '   ✓ RowVersion added to Bookings'
END
ELSE
    PRINT '   - RowVersion already exists in Bookings'

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Users') AND name = 'RowVersion')
BEGIN
    ALTER TABLE Users ADD RowVersion ROWVERSION;
    PRINT '   ✓ RowVersion added to Users'
END
ELSE
    PRINT '   - RowVersion already exists in Users'

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'PartnerSubscriptions') AND name = 'RowVersion')
BEGIN
    ALTER TABLE PartnerSubscriptions ADD RowVersion ROWVERSION;
    PRINT '   ✓ RowVersion added to PartnerSubscriptions'
END
ELSE
    PRINT '   - RowVersion already exists in PartnerSubscriptions'
GO

-- 3. Payment Installment Status
PRINT ''
PRINT '3. Adding Status to PaymentInstallments...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'PaymentInstallments') AND name = 'Status')
BEGIN
    ALTER TABLE PaymentInstallments ADD Status NVARCHAR(20) NULL;
    PRINT '   ✓ Status column added'
    
    -- Update existing records based on payment status
    UPDATE PaymentInstallments 
    SET Status = CASE 
        WHEN PaidAmount >= Amount THEN 'Paid'
        WHEN PaidAmount > 0 THEN 'Partial'
        WHEN DueDate < GETDATE() THEN 'Overdue'
        ELSE 'Pending'
    END
    WHERE Status IS NULL;
    
    PRINT '   ✓ Updated ' + CAST(@@ROWCOUNT AS VARCHAR) + ' existing installment statuses'
    
    -- Now make it NOT NULL with default
    ALTER TABLE PaymentInstallments ALTER COLUMN Status NVARCHAR(20) NOT NULL;
    ALTER TABLE PaymentInstallments ADD CONSTRAINT DF_PaymentInstallments_Status DEFAULT 'Pending' FOR Status;
    PRINT '   ✓ Status column configured with default value'
END
ELSE
    PRINT '   - Status column already exists'
GO

-- 4. Document Verification Status
PRINT ''
PRINT '4. Adding DocumentStatus columns...'

-- AgentDocuments
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'AgentDocuments') AND name = 'DocumentStatus')
BEGIN
    ALTER TABLE AgentDocuments ADD 
        DocumentStatus NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        VerifiedBy INT NULL,
        VerifiedOn DATETIME NULL;
    
    PRINT '   ✓ DocumentStatus added to AgentDocuments'
END
ELSE
    PRINT '   - DocumentStatus already exists in AgentDocuments'

-- ChannelPartnerDocuments
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'ChannelPartnerDocuments') AND name = 'DocumentStatus')
BEGIN
    ALTER TABLE ChannelPartnerDocuments ADD 
        DocumentStatus NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        VerifiedBy INT NULL,
        VerifiedOn DATETIME NULL;
    
    PRINT '   ✓ DocumentStatus added to ChannelPartnerDocuments'
END
ELSE
    PRINT '   - DocumentStatus already exists in ChannelPartnerDocuments'

-- PropertyDocuments
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'PropertyDocuments') AND name = 'DocumentStatus')
BEGIN
    ALTER TABLE PropertyDocuments ADD 
        DocumentStatus NVARCHAR(20) NOT NULL DEFAULT 'Approved',
        VerifiedBy INT NULL,
        VerifiedOn DATETIME NULL;
    
    PRINT '   ✓ DocumentStatus added to PropertyDocuments'
END
ELSE
    PRINT '   - DocumentStatus already exists in PropertyDocuments'
GO

-- ================================================================
-- PHASE 2: HIGH PRIORITY FEATURES (P1)
-- ================================================================

PRINT ''
PRINT 'PHASE 2: High Priority Features'
PRINT '--------------------------------'

-- 5. UTM Campaign Tracking for Leads
PRINT ''
PRINT '5. Adding UTM tracking to Leads...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Leads') AND name = 'UtmSource')
BEGIN
    ALTER TABLE Leads ADD 
        UtmSource NVARCHAR(100) NULL,
        UtmMedium NVARCHAR(100) NULL,
        UtmCampaign NVARCHAR(100) NULL,
        UtmTerm NVARCHAR(100) NULL,
        UtmContent NVARCHAR(100) NULL;
    PRINT '   ✓ UTM tracking fields added to Leads'
END
ELSE
    PRINT '   - UTM tracking already exists in Leads'
GO

-- 6. Follow-Up Completion Tracking (only if FollowUps table exists)
PRINT ''
PRINT '6. Adding completion tracking to FollowUps...'
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'FollowUps')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'FollowUps') AND name = 'CompletedOn')
    BEGIN
        ALTER TABLE FollowUps ADD 
            CompletedOn DATETIME NULL,
            CompletedBy INT NULL,
            CompletionNotes NVARCHAR(MAX) NULL;
        PRINT '   ✓ Completion tracking added to FollowUps'
    END
    ELSE
        PRINT '   - Completion tracking already exists in FollowUps'
END
ELSE
    PRINT '   - FollowUps table not found, skipping'
GO

-- 7. Attendance Time Tracking
PRINT ''
PRINT '7. Adding time tracking to AgentAttendance...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'AgentAttendance') AND name = 'CheckInTime')
BEGIN
    ALTER TABLE AgentAttendance ADD 
        CheckInTime TIME NULL,
        CheckOutTime TIME NULL,
        WorkingHours DECIMAL(5,2) NULL,
        IsLate BIT NULL,
        LateBy INT NULL;
    
    -- Set defaults for existing records
    UPDATE AgentAttendance SET IsLate = 0, LateBy = 0 WHERE IsLate IS NULL;
    
    -- Make NOT NULL with defaults
    ALTER TABLE AgentAttendance ALTER COLUMN IsLate BIT NOT NULL;
    ALTER TABLE AgentAttendance ADD CONSTRAINT DF_AgentAttendance_IsLate DEFAULT 0 FOR IsLate;
    ALTER TABLE AgentAttendance ALTER COLUMN LateBy INT NOT NULL;
    ALTER TABLE AgentAttendance ADD CONSTRAINT DF_AgentAttendance_LateBy DEFAULT 0 FOR LateBy;
    
    PRINT '   ✓ Time tracking added to AgentAttendance'
END
ELSE
    PRINT '   - Time tracking already exists in AgentAttendance'
GO

-- 8. Attendance Geolocation
PRINT ''
PRINT '8. Adding geolocation to AgentAttendance...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'AgentAttendance') AND name = 'CheckInLatitude')
BEGIN
    ALTER TABLE AgentAttendance ADD 
        CheckInLatitude DECIMAL(10,8) NULL,
        CheckInLongitude DECIMAL(11,8) NULL,
        CheckOutLatitude DECIMAL(10,8) NULL,
        CheckOutLongitude DECIMAL(11,8) NULL,
        LocationVerified BIT NULL;
    
    -- Set default for LocationVerified
    UPDATE AgentAttendance SET LocationVerified = 0 WHERE LocationVerified IS NULL;
    ALTER TABLE AgentAttendance ALTER COLUMN LocationVerified BIT NOT NULL;
    ALTER TABLE AgentAttendance ADD CONSTRAINT DF_AgentAttendance_LocationVerified DEFAULT 0 FOR LocationVerified;
    
    PRINT '   ✓ Geolocation fields added to AgentAttendance'
END
ELSE
    PRINT '   - Geolocation already exists in AgentAttendance'
GO

-- 9. Quotation Expiry
PRINT ''
PRINT '9. Adding ValidUntil to Quotations...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Quotations') AND name = 'ValidUntil')
BEGIN
    ALTER TABLE Quotations ADD ValidUntil DATE NULL;
    
    -- Set 30 days validity for existing quotations
    UPDATE Quotations 
    SET ValidUntil = DATEADD(DAY, 30, CreatedOn) 
    WHERE ValidUntil IS NULL AND CreatedOn IS NOT NULL;
    
    PRINT '   ✓ ValidUntil added to Quotations (30-day default for existing)'
END
ELSE
    PRINT '   - ValidUntil already exists in Quotations'
GO

-- ================================================================
-- PHASE 3: NEW TABLES
-- ================================================================

PRINT ''
PRINT 'PHASE 3: Creating New Tables'
PRINT '-----------------------------'

-- 10. Leave Requests
PRINT ''
PRINT '10. Creating LeaveRequests table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeaveRequests')
BEGIN
    CREATE TABLE LeaveRequests (
        LeaveRequestId INT PRIMARY KEY IDENTITY(1,1),
        AgentId INT NOT NULL,
        LeaveType NVARCHAR(50) NOT NULL,
        FromDate DATE NOT NULL,
        ToDate DATE NOT NULL,
        Reason NVARCHAR(500) NOT NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        RequestedOn DATETIME NOT NULL DEFAULT GETDATE(),
        ApprovedBy INT NULL,
        ApprovedOn DATETIME NULL,
        RejectionReason NVARCHAR(500) NULL,
        CONSTRAINT FK_LeaveRequests_Agent FOREIGN KEY (AgentId) REFERENCES Users(UserId),
        CONSTRAINT FK_LeaveRequests_Approver FOREIGN KEY (ApprovedBy) REFERENCES Users(UserId)
    );
    CREATE INDEX IX_LeaveRequests_AgentId_Status ON LeaveRequests(AgentId, Status);
    PRINT '   ✓ LeaveRequests table created'
END
ELSE
    PRINT '   - LeaveRequests table already exists'
GO

-- 11. Booking Amendments
PRINT ''
PRINT '11. Creating BookingAmendments table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BookingAmendments')
BEGIN
    CREATE TABLE BookingAmendments (
        AmendmentId INT PRIMARY KEY IDENTITY(1,1),
        BookingId INT NOT NULL,
        AmendmentType NVARCHAR(50) NOT NULL,
        PreviousValue NVARCHAR(MAX) NULL,
        NewValue NVARCHAR(MAX) NULL,
        Reason NVARCHAR(500) NULL,
        AmendedBy INT NOT NULL,
        AmendedOn DATETIME NOT NULL DEFAULT GETDATE(),
        ApprovedBy INT NULL,
        ApprovedOn DATETIME NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        CONSTRAINT FK_BookingAmendments_Booking FOREIGN KEY (BookingId) REFERENCES Bookings(BookingId) ON DELETE CASCADE,
        CONSTRAINT FK_BookingAmendments_AmendedBy FOREIGN KEY (AmendedBy) REFERENCES Users(UserId),
        CONSTRAINT FK_BookingAmendments_ApprovedBy FOREIGN KEY (ApprovedBy) REFERENCES Users(UserId)
    );
    CREATE INDEX IX_BookingAmendments_BookingId ON BookingAmendments(BookingId);
    PRINT '   ✓ BookingAmendments table created'
END
ELSE
    PRINT '   - BookingAmendments table already exists'
GO

-- 12. Email Templates
PRINT ''
PRINT '12. Creating EmailTemplates table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmailTemplates')
BEGIN
    CREATE TABLE EmailTemplates (
        TemplateId INT PRIMARY KEY IDENTITY(1,1),
        TemplateName NVARCHAR(100) NOT NULL UNIQUE,
        Subject NVARCHAR(200) NOT NULL,
        BodyHtml NVARCHAR(MAX) NOT NULL,
        Variables NVARCHAR(500) NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
        UpdatedOn DATETIME NOT NULL DEFAULT GETDATE()
    );
    
    -- Insert default templates
    INSERT INTO EmailTemplates (TemplateName, Subject, BodyHtml, Variables)
    VALUES 
    ('PasswordReset', 'Reset Your Password', 
     '<h2>Password Reset Request</h2><p>Click the link to reset: <a href="{ResetLink}">Reset Password</a></p><p>This link expires in 1 hour.</p>', 
     '{ResetLink}'),
    ('WelcomeEmail', 'Welcome to CRM', 
     '<h2>Welcome {Name}!</h2><p>Your account has been created successfully.</p><p>Login at <a href="{LoginUrl}">CRM Portal</a></p><p>Username: {Username}</p><p>Temporary Password: {Password}</p>', 
     '{Name},{LoginUrl},{Username},{Password}'),
    ('BookingConfirmation', 'Booking Confirmed - {BookingNumber}', 
     '<h2>Booking Confirmed</h2><p>Dear {CustomerName},</p><p>Your booking <strong>{BookingNumber}</strong> for <strong>{PropertyName}</strong> has been confirmed.</p><p>Booking Amount: ₹{Amount}</p><p>Thank you for your business!</p>', 
     '{CustomerName},{BookingNumber},{PropertyName},{Amount}');
    
    PRINT '   ✓ EmailTemplates table created with 3 default templates'
END
ELSE
    PRINT '   - EmailTemplates table already exists'
GO

-- 13. Notification Preferences
PRINT ''
PRINT '13. Creating NotificationPreferences table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'NotificationPreferences')
BEGIN
    CREATE TABLE NotificationPreferences (
        PreferenceId INT PRIMARY KEY IDENTITY(1,1),
        UserId INT NOT NULL UNIQUE,
        EmailNotifications BIT NOT NULL DEFAULT 1,
        PushNotifications BIT NOT NULL DEFAULT 1,
        WhatsAppNotifications BIT NOT NULL DEFAULT 0,
        SMSNotifications BIT NOT NULL DEFAULT 0,
        LeadAssignmentNotif BIT NOT NULL DEFAULT 1,
        BookingNotif BIT NOT NULL DEFAULT 1,
        PaymentNotif BIT NOT NULL DEFAULT 1,
        TaskNotif BIT NOT NULL DEFAULT 1,
        CONSTRAINT FK_NotificationPreferences_User FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
    );
    PRINT '   ✓ NotificationPreferences table created'
END
ELSE
    PRINT '   - NotificationPreferences table already exists'
GO

-- 14. Audit Logs
PRINT ''
PRINT '14. Creating AuditLogs table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditLogs')
BEGIN
    CREATE TABLE AuditLogs (
        AuditId BIGINT PRIMARY KEY IDENTITY(1,1),
        UserId INT NULL,
        Action NVARCHAR(100) NOT NULL,
        EntityType NVARCHAR(50) NULL,
        EntityId INT NULL,
        OldValues NVARCHAR(MAX) NULL,
        NewValues NVARCHAR(MAX) NULL,
        IpAddress NVARCHAR(45) NULL,
        UserAgent NVARCHAR(500) NULL,
        Timestamp DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_AuditLogs_User FOREIGN KEY (UserId) REFERENCES Users(UserId)
    );
    
    CREATE INDEX IX_AuditLogs_UserId_Timestamp ON AuditLogs(UserId, Timestamp DESC);
    CREATE INDEX IX_AuditLogs_EntityType_EntityId ON AuditLogs(EntityType, EntityId);
    CREATE INDEX IX_AuditLogs_Timestamp ON AuditLogs(Timestamp DESC);
    
    PRINT '   ✓ AuditLogs table created with indexes'
END
ELSE
    PRINT '   - AuditLogs table already exists'
GO

-- 15. Webhook Retry Queue
PRINT ''
PRINT '15. Creating WebhookRetryQueue table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'WebhookRetryQueue')
BEGIN
    CREATE TABLE WebhookRetryQueue (
        QueueId INT PRIMARY KEY IDENTITY(1,1),
        WebhookEventId NVARCHAR(200) NOT NULL,
        PayloadJson NVARCHAR(MAX) NOT NULL,
        Endpoint NVARCHAR(500) NOT NULL,
        RetryCount INT NOT NULL DEFAULT 0,
        MaxRetries INT NOT NULL DEFAULT 3,
        NextRetryAt DATETIME NULL,
        LastError NVARCHAR(MAX) NULL,
        Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
        CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
        ProcessedOn DATETIME NULL
    );
    
    CREATE INDEX IX_WebhookRetryQueue_Status_NextRetryAt ON WebhookRetryQueue(Status, NextRetryAt);
    
    PRINT '   ✓ WebhookRetryQueue table created'
END
ELSE
    PRINT '   - WebhookRetryQueue table already exists'
GO

-- 16. Duplicate Leads Tracking
PRINT ''
PRINT '16. Creating DuplicateLeads table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'DuplicateLeads')
BEGIN
    CREATE TABLE DuplicateLeads (
        DuplicateId INT PRIMARY KEY IDENTITY(1,1),
        LeadId1 INT NOT NULL,
        LeadId2 INT NOT NULL,
        MatchType NVARCHAR(50) NOT NULL,
        ReviewedBy INT NULL,
        ReviewedOn DATETIME NULL,
        Action NVARCHAR(20) NULL,
        CONSTRAINT FK_DuplicateLeads_Lead1 FOREIGN KEY (LeadId1) REFERENCES Leads(LeadId),
        CONSTRAINT FK_DuplicateLeads_Lead2 FOREIGN KEY (LeadId2) REFERENCES Leads(LeadId),
        CONSTRAINT FK_DuplicateLeads_Reviewer FOREIGN KEY (ReviewedBy) REFERENCES Users(UserId)
    );
    
    CREATE INDEX IX_DuplicateLeads_LeadId1 ON DuplicateLeads(LeadId1);
    CREATE INDEX IX_DuplicateLeads_LeadId2 ON DuplicateLeads(LeadId2);
    
    PRINT '   ✓ DuplicateLeads table created'
END
ELSE
    PRINT '   - DuplicateLeads table already exists'
GO

-- 17. Notification Read Status
PRINT ''
PRINT '17. Adding IsRead to Notifications...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Notifications') AND name = 'IsRead')
BEGIN
    ALTER TABLE Notifications ADD 
        IsRead BIT NULL,
        ReadOn DATETIME NULL;
    
    -- Set default for existing records
    UPDATE Notifications SET IsRead = 0 WHERE IsRead IS NULL;
    ALTER TABLE Notifications ALTER COLUMN IsRead BIT NOT NULL;
    ALTER TABLE Notifications ADD CONSTRAINT DF_Notifications_IsRead DEFAULT 0 FOR IsRead;
    
    PRINT '   ✓ IsRead added to Notifications'
END
ELSE
    PRINT '   - IsRead already exists in Notifications'
GO

-- 18. Password Policy Tracking
PRINT ''
PRINT '18. Adding password policy fields to UserSettings...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'UserSettings') AND name = 'PasswordStrength')
BEGIN
    ALTER TABLE UserSettings ADD 
        PasswordStrength NVARCHAR(20) NULL,
        MustChangePassword BIT NULL,
        PasswordExpiryDays INT NULL;
    
    -- Set defaults
    UPDATE UserSettings SET MustChangePassword = 0, PasswordExpiryDays = 90 
    WHERE MustChangePassword IS NULL;
    
    ALTER TABLE UserSettings ALTER COLUMN MustChangePassword BIT NOT NULL;
    ALTER TABLE UserSettings ADD CONSTRAINT DF_UserSettings_MustChangePassword DEFAULT 0 FOR MustChangePassword;
    ALTER TABLE UserSettings ALTER COLUMN PasswordExpiryDays INT NOT NULL;
    ALTER TABLE UserSettings ADD CONSTRAINT DF_UserSettings_PasswordExpiryDays DEFAULT 90 FOR PasswordExpiryDays;
    
    PRINT '   ✓ Password policy fields added to UserSettings'
END
ELSE
    PRINT '   - Password policy fields already exist in UserSettings'
GO

-- ================================================================
-- PHASE 4: PERFORMANCE INDEXES
-- ================================================================

PRINT ''
PRINT 'PHASE 4: Performance Indexes'
PRINT '----------------------------'

PRINT ''
PRINT '19. Creating performance indexes...'

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_Contact' AND object_id = OBJECT_ID(N'Leads'))
BEGIN
    CREATE INDEX IX_Leads_Contact ON Leads(Contact);
    PRINT '   ✓ IX_Leads_Contact created'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_Email' AND object_id = OBJECT_ID(N'Leads'))
BEGIN
    CREATE INDEX IX_Leads_Email ON Leads(Email);
    PRINT '   ✓ IX_Leads_Email created'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_Status_Stage' AND object_id = OBJECT_ID(N'Leads'))
BEGIN
    CREATE INDEX IX_Leads_Status_Stage ON Leads(Status, Stage);
    PRINT '   ✓ IX_Leads_Status_Stage created'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Bookings_Status_BookingDate' AND object_id = OBJECT_ID(N'Bookings'))
BEGIN
    CREATE INDEX IX_Bookings_Status_BookingDate ON Bookings(Status, BookingDate DESC);
    PRINT '   ✓ IX_Bookings_Status_BookingDate created'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PartnerSubscriptions_Status_EndDate' AND object_id = OBJECT_ID(N'PartnerSubscriptions'))
BEGIN
    CREATE INDEX IX_PartnerSubscriptions_Status_EndDate ON PartnerSubscriptions(Status, EndDate);
    PRINT '   ✓ IX_PartnerSubscriptions_Status_EndDate created'
END

GO

-- ================================================================
-- COMPLETION SUMMARY
-- ================================================================

PRINT ''
PRINT '================================================='
PRINT '✓✓✓ MIGRATION COMPLETED SUCCESSFULLY! ✓✓✓'
PRINT '================================================='
PRINT ''
PRINT 'Summary of Changes:'
PRINT '-------------------'
PRINT '✓ Password reset token expiry'
PRINT '✓ Optimistic concurrency control (RowVersion)'
PRINT '✓ Payment installment status tracking'
PRINT '✓ Document verification workflow'
PRINT '✓ UTM campaign tracking'
PRINT '✓ Follow-up completion tracking'
PRINT '✓ Attendance time & geolocation'
PRINT '✓ Quotation expiry dates'
PRINT '✓ 7 new tables created:'
PRINT '  - LeaveRequests'
PRINT '  - BookingAmendments'
PRINT '  - EmailTemplates (with 3 templates)'
PRINT '  - NotificationPreferences'
PRINT '  - AuditLogs'
PRINT '  - WebhookRetryQueue'
PRINT '  - DuplicateLeads'
PRINT '✓ Notification read status'
PRINT '✓ Password policy tracking'
PRINT '✓ Performance indexes'
PRINT ''
PRINT 'Database is now production-ready!'
PRINT ''
PRINT 'Next Steps:'
PRINT '1. Update AppDbContext.cs with new DbSet properties'
PRINT '2. Test application functionality'
PRINT '3. Implement business logic for new features'
PRINT '4. Review COMPREHENSIVE_FIX_IMPLEMENTATION_GUIDE.md'
PRINT ''
PRINT 'Completion Time: ' + CONVERT(VARCHAR, GETDATE(), 120)
PRINT '================================================='
