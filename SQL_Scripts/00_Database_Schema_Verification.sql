-- ================================================================
-- DATABASE SCHEMA VERIFICATION SCRIPT
-- Run this BEFORE the migration to identify existing tables
-- Date: January 2, 2026
-- ================================================================

PRINT '================================================='
PRINT 'CRM DATABASE SCHEMA VERIFICATION'
PRINT '================================================='
PRINT ''

-- Check critical tables
PRINT 'Checking Core Tables:'
PRINT '---------------------'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
    PRINT '✓ Users table exists'
ELSE
    PRINT '✗ Users table MISSING'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Leads')
    PRINT '✓ Leads table exists'
ELSE
    PRINT '✗ Leads table MISSING'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Bookings')
    PRINT '✓ Bookings table exists'
ELSE
    PRINT '✗ Bookings table MISSING'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Payments')
    PRINT '✓ Payments table exists'
ELSE
    PRINT '✗ Payments table MISSING'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PaymentInstallments')
    PRINT '✓ PaymentInstallments table exists'
ELSE
    PRINT '✗ PaymentInstallments table MISSING'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PartnerSubscriptions')
    PRINT '✓ PartnerSubscriptions table exists'
ELSE
    PRINT '✗ PartnerSubscriptions table MISSING'

PRINT ''
PRINT 'Checking Relationship Tables:'
PRINT '-----------------------------'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'FollowUps')
    PRINT '✓ FollowUps table exists'
ELSE
    PRINT '✗ FollowUps table MISSING - Will skip follow-up modifications'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadNotes')
    PRINT '✓ LeadNotes table exists'
ELSE
    PRINT '✗ LeadNotes table MISSING'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LeadHistory')
    PRINT '✓ LeadHistory table exists'
ELSE
    PRINT '✗ LeadHistory table MISSING'

PRINT ''
PRINT 'Checking Document Tables:'
PRINT '-------------------------'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AgentDocuments')
    PRINT '✓ AgentDocuments table exists'
ELSE
    PRINT '✗ AgentDocuments table MISSING - Will skip agent document modifications'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ChannelPartnerDocuments')
    PRINT '✓ ChannelPartnerDocuments table exists'
ELSE
    PRINT '✗ ChannelPartnerDocuments table MISSING - Will skip partner document modifications'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PropertyDocuments')
    PRINT '✓ PropertyDocuments table exists'
ELSE
    PRINT '✗ PropertyDocuments table MISSING - Will skip property document modifications'

PRINT ''
PRINT 'Checking Attendance Tables:'
PRINT '---------------------------'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'AgentAttendance')
    PRINT '✓ AgentAttendance table exists'
ELSE
    PRINT '✗ AgentAttendance table MISSING - Will skip attendance modifications'

PRINT ''
PRINT 'Checking Other Tables:'
PRINT '----------------------'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Quotations')
    PRINT '✓ Quotations table exists'
ELSE
    PRINT '✗ Quotations table MISSING'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Invoices')
    PRINT '✓ Invoices table exists'
ELSE
    PRINT '✗ Invoices table MISSING'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PaymentPlans')
    PRINT '✓ PaymentPlans table exists'
ELSE
    PRINT '✗ PaymentPlans table MISSING'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Notifications')
    PRINT '✓ Notifications table exists'
ELSE
    PRINT '✗ Notifications table MISSING'

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserSettings')
    PRINT '✓ UserSettings table exists'
ELSE
    PRINT '✗ UserSettings table MISSING'

PRINT ''
PRINT '================================================='
PRINT 'COLUMN VERIFICATION'
PRINT '================================================='
PRINT ''

-- Check if critical columns exist
PRINT 'Checking Users table columns:'
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Users') AND name = 'ResetToken')
    PRINT '  ✓ ResetToken exists'
ELSE
    PRINT '  ✗ ResetToken MISSING'

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Users') AND name = 'ResetTokenExpiry')
    PRINT '  ✓ ResetTokenExpiry exists'
ELSE
    PRINT '  ✗ ResetTokenExpiry MISSING - Will be added'

PRINT ''
PRINT 'Checking Leads table columns:'
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Leads') AND name = 'UtmSource')
    PRINT '  ✓ UTM tracking already exists'
ELSE
    PRINT '  ✗ UTM tracking MISSING - Will be added'

IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'Leads') AND name = 'RowVersion')
    PRINT '  ✓ RowVersion already exists'
ELSE
    PRINT '  ✗ RowVersion MISSING - Will be added'

PRINT ''
PRINT 'Checking PaymentInstallments columns:'
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'PaymentInstallments')
BEGIN
    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'PaymentInstallments') AND name = 'Status')
        PRINT '  ✓ Status column already exists'
    ELSE
        PRINT '  ✗ Status column MISSING - Will be added'
END

PRINT ''
PRINT '================================================='
PRINT 'FOREIGN KEY VERIFICATION'
PRINT '================================================='
PRINT ''

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FollowUps_Leads_LeadId')
    PRINT '✓ FK_FollowUps_Leads_LeadId exists'
ELSE
    PRINT '✗ FK_FollowUps_Leads_LeadId not found'

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_LeadNotes_Leads_LeadId')
    PRINT '✓ FK_LeadNotes_Leads_LeadId exists'
ELSE
    PRINT '✗ FK_LeadNotes_Leads_LeadId not found'

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PaymentPlans_Bookings_BookingId')
    PRINT '✓ FK_PaymentPlans_Bookings_BookingId exists'
ELSE
    PRINT '✗ FK_PaymentPlans_Bookings_BookingId not found'

PRINT ''
PRINT '================================================='
PRINT 'VERIFICATION COMPLETE'
PRINT '================================================='
PRINT ''
PRINT 'Next Steps:'
PRINT '1. Review the output above'
PRINT '2. Note which tables/columns are missing'
PRINT '3. Run P0_P1_P2_Critical_Fixes.sql'
PRINT '4. The migration will skip modifications for missing tables'
PRINT ''
