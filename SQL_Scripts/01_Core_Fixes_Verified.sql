-- ================================================================
-- VERIFIED MIGRATION SCRIPT - CORE FIXES ONLY
-- Based on successful execution results
-- Date: January 2, 2026
-- ================================================================

USE [YourCRMDatabase]
GO

PRINT '================================================='
PRINT 'RUNNING CORE CRM FIXES'
PRINT '================================================='
PRINT ''

-- ================================================================
-- P0 CRITICAL FIXES THAT SUCCEEDED
-- ================================================================

-- P0-D2: Optimistic Concurrency Control
PRINT '1. Adding RowVersion for concurrency control...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Leads') AND name = 'RowVersion')
BEGIN
    ALTER TABLE Leads ADD RowVersion ROWVERSION;
    PRINT '   ✓ Added RowVersion to Leads'
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Bookings') AND name = 'RowVersion')
BEGIN
    ALTER TABLE Bookings ADD RowVersion ROWVERSION;
    PRINT '   ✓ Added RowVersion to Bookings'
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Users') AND name = 'RowVersion')
BEGIN
    ALTER TABLE Users ADD RowVersion ROWVERSION;
    PRINT '   ✓ Added RowVersion to Users'
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'PartnerSubscriptions') AND name = 'RowVersion')
BEGIN
    ALTER TABLE PartnerSubscriptions ADD RowVersion ROWVERSION;
    PRINT '   ✓ Added RowVersion to PartnerSubscriptions'
END
GO

-- P0-D3: Cascade Delete Configuration (if tables exist)
PRINT ''
PRINT '2. Configuring cascade deletes...'

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FollowUps_Leads_LeadId')
BEGIN
    ALTER TABLE FollowUps DROP CONSTRAINT FK_FollowUps_Leads_LeadId;
    ALTER TABLE FollowUps ADD CONSTRAINT FK_FollowUps_Leads_LeadId 
        FOREIGN KEY (LeadId) REFERENCES Leads(LeadId) ON DELETE CASCADE;
    PRINT '   ✓ Updated FK_FollowUps_Leads_LeadId for cascade delete'
END
ELSE
    PRINT '   - FK_FollowUps_Leads_LeadId not found, skipping'

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_LeadNotes_Leads_LeadId')
BEGIN
    ALTER TABLE LeadNotes DROP CONSTRAINT FK_LeadNotes_Leads_LeadId;
    ALTER TABLE LeadNotes ADD CONSTRAINT FK_LeadNotes_Leads_LeadId 
        FOREIGN KEY (LeadId) REFERENCES Leads(LeadId) ON DELETE CASCADE;
    PRINT '   ✓ Updated FK_LeadNotes_Leads_LeadId for cascade delete'
END

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PaymentPlans_Bookings_BookingId')
BEGIN
    ALTER TABLE PaymentPlans DROP CONSTRAINT FK_PaymentPlans_Bookings_BookingId;
    ALTER TABLE PaymentPlans ADD CONSTRAINT FK_PaymentPlans_Bookings_BookingId 
        FOREIGN KEY (BookingId) REFERENCES Bookings(BookingId) ON DELETE CASCADE;
    PRINT '   ✓ Updated FK_PaymentPlans_Bookings_BookingId for cascade delete'
END

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Invoices_Bookings_BookingId')
BEGIN
    ALTER TABLE Invoices DROP CONSTRAINT FK_Invoices_Bookings_BookingId;
    ALTER TABLE Invoices ADD CONSTRAINT FK_Invoices_Bookings_BookingId 
        FOREIGN KEY (BookingId) REFERENCES Bookings(BookingId) ON DELETE CASCADE;
    PRINT '   ✓ Updated FK_Invoices_Bookings_BookingId for cascade delete'
END
GO

-- P0-B1: Payment Installment Status
PRINT ''
PRINT '3. Adding Status to PaymentInstallments...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'PaymentInstallments') AND name = 'Status')
BEGIN
    ALTER TABLE PaymentInstallments ADD Status NVARCHAR(20) DEFAULT 'Pending';
    PRINT '   ✓ Added Status column'
    
    -- Update existing records
    UPDATE PaymentInstallments SET Status = 
        CASE 
            WHEN PaidAmount >= Amount THEN 'Paid'
            WHEN PaidAmount > 0 THEN 'Partial'
            WHEN DueDate < GETDATE() THEN 'Overdue'
            ELSE 'Pending'
        END;
    PRINT '   ✓ Updated existing installment statuses'
END
GO

-- ================================================================
-- P1 HIGH PRIORITY FIXES THAT SUCCEEDED
-- ================================================================

-- P1-L4: Lead UTM Tracking
PRINT ''
PRINT '4. Adding UTM tracking fields to Leads...'
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Leads') AND name = 'UtmSource')
BEGIN
    ALTER TABLE Leads ADD UtmSource NVARCHAR(100) NULL;
    ALTER TABLE Leads ADD UtmMedium NVARCHAR(100) NULL;
    ALTER TABLE Leads ADD UtmCampaign NVARCHAR(100) NULL;
    ALTER TABLE Leads ADD UtmTerm NVARCHAR(100) NULL;
    ALTER TABLE Leads ADD UtmContent NVARCHAR(100) NULL;
    PRINT '   ✓ Added UTM tracking fields'
END
GO

-- P1-AT2: Attendance Time Tracking
PRINT ''
PRINT '5. Adding time tracking to AgentAttendance...'
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AgentAttendance')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'AgentAttendance') AND name = 'CheckInTime')
    BEGIN
        ALTER TABLE AgentAttendance ADD CheckInTime TIME NULL;
        ALTER TABLE AgentAttendance ADD CheckOutTime TIME NULL;
        ALTER TABLE AgentAttendance ADD WorkingHours DECIMAL(5,2) NULL;
        ALTER TABLE AgentAttendance ADD IsLate BIT DEFAULT 0;
        ALTER TABLE AgentAttendance ADD LateBy INT DEFAULT 0;
        PRINT '   ✓ Added time tracking fields'
    END
END
ELSE
    PRINT '   - AgentAttendance table not found'
GO

-- P1-AT1: Attendance Geolocation
PRINT ''
PRINT '6. Adding geolocation to AgentAttendance...'
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AgentAttendance')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'AgentAttendance') AND name = 'CheckInLatitude')
    BEGIN
        ALTER TABLE AgentAttendance ADD CheckInLatitude DECIMAL(10,8) NULL;
        ALTER TABLE AgentAttendance ADD CheckInLongitude DECIMAL(11,8) NULL;
        ALTER TABLE AgentAttendance ADD CheckOutLatitude DECIMAL(10,8) NULL;
        ALTER TABLE AgentAttendance ADD CheckOutLongitude DECIMAL(11,8) NULL;
        ALTER TABLE AgentAttendance ADD LocationVerified BIT DEFAULT 0;
        PRINT '   ✓ Added geolocation fields'
    END
END
GO

-- P1-AT3: Leave Management
PRINT ''
PRINT '7. Creating LeaveRequests table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeaveRequests')
BEGIN
    CREATE TABLE LeaveRequests (
        LeaveRequestId INT PRIMARY KEY IDENTITY(1,1),
        AgentId INT NOT NULL,
        LeaveType NVARCHAR(50) NOT NULL,
        FromDate DATE NOT NULL,
        ToDate DATE NOT NULL,
        Reason NVARCHAR(500) NOT NULL,
        Status NVARCHAR(20) DEFAULT 'Pending',
        RequestedOn DATETIME DEFAULT GETDATE(),
        ApprovedBy INT NULL,
        ApprovedOn DATETIME NULL,
        RejectionReason NVARCHAR(500) NULL,
        FOREIGN KEY (AgentId) REFERENCES Users(UserId),
        FOREIGN KEY (ApprovedBy) REFERENCES Users(UserId)
    );
    PRINT '   ✓ Created LeaveRequests table'
END
GO

-- P1-B4: Quotation Expiry
PRINT ''
PRINT '8. Adding expiry to Quotations...'
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Quotations')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Quotations') AND name = 'ValidUntil')
    BEGIN
        ALTER TABLE Quotations ADD ValidUntil DATE NULL;
        UPDATE Quotations SET ValidUntil = DATEADD(DAY, 30, CreatedOn) WHERE ValidUntil IS NULL;
        PRINT '   ✓ Added ValidUntil to Quotations'
    END
END
GO

-- P1-B5: Booking Amendment
PRINT ''
PRINT '9. Creating BookingAmendments table...'
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
        AmendedOn DATETIME DEFAULT GETDATE(),
        ApprovedBy INT NULL,
        ApprovedOn DATETIME NULL,
        Status NVARCHAR(20) DEFAULT 'Pending',
        FOREIGN KEY (BookingId) REFERENCES Bookings(BookingId) ON DELETE CASCADE,
        FOREIGN KEY (AmendedBy) REFERENCES Users(UserId),
        FOREIGN KEY (ApprovedBy) REFERENCES Users(UserId)
    );
    PRINT '   ✓ Created BookingAmendments table'
END
GO

-- ================================================================
-- P2 MEDIUM PRIORITY FIXES THAT SUCCEEDED
-- ================================================================

-- P2-N1: Notification Read Status
PRINT ''
PRINT '10. Adding IsRead to Notifications...'
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Notifications')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Notifications') AND name = 'IsRead')
    BEGIN
        ALTER TABLE Notifications ADD IsRead BIT DEFAULT 0;
        ALTER TABLE Notifications ADD ReadOn DATETIME NULL;
        UPDATE Notifications SET IsRead = 0 WHERE IsRead IS NULL;
        PRINT '   ✓ Added IsRead to Notifications'
    END
END
GO

-- P2-N2: Email Templates
PRINT ''
PRINT '11. Creating EmailTemplates table...'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EmailTemplates')
BEGIN
    CREATE TABLE EmailTemplates (
        TemplateId INT PRIMARY KEY IDENTITY(1,1),
        TemplateName NVARCHAR(100) NOT NULL UNIQUE,
        Subject NVARCHAR(200) NOT NULL,
        BodyHtml NVARCHAR(MAX) NOT NULL,
        Variables NVARCHAR(500) NULL,
        IsActive BIT DEFAULT 1,
        CreatedOn DATETIME DEFAULT GETDATE(),
        UpdatedOn DATETIME DEFAULT GETDATE()
    );
    
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
     
    PRINT '   ✓ Created EmailTemplates with 3 default templates'
END
GO

-- P2-N5: Notification Preferences
PRINT ''
PRINT '12. Creating NotificationPreferences table...'
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
    PRINT '   ✓ Created NotificationPreferences table'
END
GO

-- P2-U2: Password Strength
PRINT ''
PRINT '13. Adding password policy tracking...'
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserSettings')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'UserSettings') AND name = 'PasswordStrength')
    BEGIN
        ALTER TABLE UserSettings ADD PasswordStrength NVARCHAR(20) NULL;
        ALTER TABLE UserSettings ADD MustChangePassword BIT DEFAULT 0;
        ALTER TABLE UserSettings ADD PasswordExpiryDays INT DEFAULT 90;
        PRINT '   ✓ Added password policy fields'
    END
END
GO

-- P2-U4: Audit Logs
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
        Timestamp DATETIME DEFAULT GETDATE(),
        FOREIGN KEY (UserId) REFERENCES Users(UserId)
    );
    
    CREATE INDEX IX_AuditLogs_UserId_Timestamp ON AuditLogs(UserId, Timestamp DESC);
    CREATE INDEX IX_AuditLogs_EntityType_EntityId ON AuditLogs(EntityType, EntityId);
    PRINT '   ✓ Created AuditLogs table with indexes'
END
GO

-- P2-I2: Webhook Retry
PRINT ''
PRINT '15. Creating WebhookRetryQueue table...'
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
        Status NVARCHAR(20) DEFAULT 'Pending',
        CreatedOn DATETIME DEFAULT GETDATE(),
        ProcessedOn DATETIME NULL
    );
    PRINT '   ✓ Created WebhookRetryQueue table'
END
GO

-- P2-DQ: Duplicate Leads
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
        FOREIGN KEY (LeadId1) REFERENCES Leads(LeadId),
        FOREIGN KEY (LeadId2) REFERENCES Leads(LeadId),
        FOREIGN KEY (ReviewedBy) REFERENCES Users(UserId)
    );
    PRINT '   ✓ Created DuplicateLeads table'
END
GO

-- ================================================================
-- PERFORMANCE INDEXES
-- ================================================================

PRINT ''
PRINT '17. Creating performance indexes...'

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_Contact')
BEGIN
    CREATE INDEX IX_Leads_Contact ON Leads(Contact);
    PRINT '   ✓ Created IX_Leads_Contact'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_Email')
BEGIN
    CREATE INDEX IX_Leads_Email ON Leads(Email);
    PRINT '   ✓ Created IX_Leads_Email'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Leads_Status_Stage')
BEGIN
    CREATE INDEX IX_Leads_Status_Stage ON Leads(Status, Stage);
    PRINT '   ✓ Created IX_Leads_Status_Stage'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Bookings_Status_BookingDate')
BEGIN
    CREATE INDEX IX_Bookings_Status_BookingDate ON Bookings(Status, BookingDate DESC);
    PRINT '   ✓ Created IX_Bookings_Status_BookingDate'
END

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PartnerSubscriptions_Status_EndDate')
BEGIN
    CREATE INDEX IX_PartnerSubscriptions_Status_EndDate ON PartnerSubscriptions(Status, EndDate);
    PRINT '   ✓ Created IX_PartnerSubscriptions_Status_EndDate'
END

GO

PRINT ''
PRINT '================================================='
PRINT '✓ CORE MIGRATION COMPLETED SUCCESSFULLY!'
PRINT '================================================='
PRINT ''
PRINT 'Summary:'
PRINT '--------'
PRINT '✓ Optimistic Concurrency (RowVersion)'
PRINT '✓ Cascade Delete Configuration'
PRINT '✓ Payment Installment Status'
PRINT '✓ UTM Campaign Tracking'
PRINT '✓ Attendance Time & Geolocation'
PRINT '✓ Leave Management System'
PRINT '✓ Quotation Expiry'
PRINT '✓ Booking Amendments'
PRINT '✓ Notification Read Status'
PRINT '✓ Email Templates'
PRINT '✓ Notification Preferences'
PRINT '✓ Password Policy'
PRINT '✓ Audit Logging'
PRINT '✓ Webhook Retry Queue'
PRINT '✓ Duplicate Lead Detection'
PRINT '✓ Performance Indexes'
PRINT ''
PRINT 'Next Steps:'
PRINT '1. Update AppDbContext.cs with new DbSet properties'
PRINT '2. Add EF Core model configurations if needed'
PRINT '3. Test application with new schema'
PRINT '4. Implement business logic for new features'
PRINT ''
