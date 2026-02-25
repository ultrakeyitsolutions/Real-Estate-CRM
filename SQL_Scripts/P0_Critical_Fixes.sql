-- P0 Critical Fixes - Manual SQL Script
-- Execute these queries in SQL Server Management Studio
-- Date: January 3, 2026

USE CRM;
GO

-- ============================================================================
-- P0-D2: Add Concurrency Control to Bookings
-- ============================================================================
-- Add RowVersion column to BookingModel for optimistic concurrency
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Bookings]') AND name = 'RowVersion')
BEGIN
    ALTER TABLE [dbo].[Bookings]
    ADD [RowVersion] ROWVERSION;
    
    PRINT 'Added RowVersion to Bookings table';
END
ELSE
BEGIN
    PRINT 'RowVersion already exists in Bookings table';
END
GO

-- ============================================================================
-- P0-D3: Add Document Verification Fields to AgentDocuments
-- ============================================================================
-- Add verification fields to AgentDocumentModel
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AgentDocuments]') AND name = 'VerificationStatus')
BEGIN
    ALTER TABLE [dbo].[AgentDocuments]
    ADD [VerificationStatus] NVARCHAR(20) NOT NULL DEFAULT 'Pending';
    
    PRINT 'Added VerificationStatus to AgentDocuments table';
END
ELSE
BEGIN
    PRINT 'VerificationStatus already exists in AgentDocuments table';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AgentDocuments]') AND name = 'VerifiedBy')
BEGIN
    ALTER TABLE [dbo].[AgentDocuments]
    ADD [VerifiedBy] INT NULL;
    
    PRINT 'Added VerifiedBy to AgentDocuments table';
END
ELSE
BEGIN
    PRINT 'VerifiedBy already exists in AgentDocuments table';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AgentDocuments]') AND name = 'VerifiedOn')
BEGIN
    ALTER TABLE [dbo].[AgentDocuments]
    ADD [VerifiedOn] DATETIME NULL;
    
    PRINT 'Added VerifiedOn to AgentDocuments table';
END
ELSE
BEGIN
    PRINT 'VerifiedOn already exists in AgentDocuments table';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AgentDocuments]') AND name = 'RejectionReason')
BEGIN
    ALTER TABLE [dbo].[AgentDocuments]
    ADD [RejectionReason] NVARCHAR(500) NULL;
    
    PRINT 'Added RejectionReason to AgentDocuments table';
END
ELSE
BEGIN
    PRINT 'RejectionReason already exists in AgentDocuments table';
END
GO

-- ============================================================================
-- P0-D3: Add Document Verification Fields to ChannelPartnerDocuments
-- ============================================================================
-- Add verification fields to ChannelPartnerDocumentModel
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ChannelPartnerDocuments]') AND name = 'VerificationStatus')
BEGIN
    ALTER TABLE [dbo].[ChannelPartnerDocuments]
    ADD [VerificationStatus] NVARCHAR(20) NOT NULL DEFAULT 'Pending';
    
    PRINT 'Added VerificationStatus to ChannelPartnerDocuments table';
END
ELSE
BEGIN
    PRINT 'VerificationStatus already exists in ChannelPartnerDocuments table';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ChannelPartnerDocuments]') AND name = 'VerifiedBy')
BEGIN
    ALTER TABLE [dbo].[ChannelPartnerDocuments]
    ADD [VerifiedBy] INT NULL;
    
    PRINT 'Added VerifiedBy to ChannelPartnerDocuments table';
END
ELSE
BEGIN
    PRINT 'VerifiedBy already exists in ChannelPartnerDocuments table';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ChannelPartnerDocuments]') AND name = 'VerifiedOn')
BEGIN
    ALTER TABLE [dbo].[ChannelPartnerDocuments]
    ADD [VerifiedOn] DATETIME NULL;
    
    PRINT 'Added VerifiedOn to ChannelPartnerDocuments table';
END
ELSE
BEGIN
    PRINT 'VerifiedOn already exists in ChannelPartnerDocuments table';
END
GO

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ChannelPartnerDocuments]') AND name = 'RejectionReason')
BEGIN
    ALTER TABLE [dbo].[ChannelPartnerDocuments]
    ADD [RejectionReason] NVARCHAR(500) NULL;
    
    PRINT 'Added RejectionReason to ChannelPartnerDocuments table';
END
ELSE
BEGIN
    PRINT 'RejectionReason already exists in ChannelPartnerDocuments table';
END
GO

-- ============================================================================
-- Verification: Check all changes
-- ============================================================================
PRINT '';
PRINT '========================================';
PRINT 'Verification of P0 Critical Fixes';
PRINT '========================================';

-- Check Bookings table
SELECT 
    'Bookings' AS TableName,
    (SELECT COUNT(*) FROM [dbo].[Bookings]) AS [RowCount],
    CASE WHEN EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Bookings]') AND name = 'RowVersion') 
         THEN 'YES' ELSE 'NO' END AS HasRowVersion;

-- Check AgentDocuments table
SELECT 
    'AgentDocuments' AS TableName,
    (SELECT COUNT(*) FROM [dbo].[AgentDocuments]) AS [RowCount],
    CASE WHEN EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AgentDocuments]') AND name = 'VerificationStatus') 
         THEN 'YES' ELSE 'NO' END AS HasVerificationStatus,
    CASE WHEN EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AgentDocuments]') AND name = 'VerifiedBy') 
         THEN 'YES' ELSE 'NO' END AS HasVerifiedBy,
    CASE WHEN EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AgentDocuments]') AND name = 'VerifiedOn') 
         THEN 'YES' ELSE 'NO' END AS HasVerifiedOn,
    CASE WHEN EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[AgentDocuments]') AND name = 'RejectionReason') 
         THEN 'YES' ELSE 'NO' END AS HasRejectionReason;

-- Check ChannelPartnerDocuments table
SELECT 
    'ChannelPartnerDocuments' AS TableName,
    (SELECT COUNT(*) FROM [dbo].[ChannelPartnerDocuments]) AS [RowCount],
    CASE WHEN EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ChannelPartnerDocuments]') AND name = 'VerificationStatus') 
         THEN 'YES' ELSE 'NO' END AS HasVerificationStatus,
    CASE WHEN EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ChannelPartnerDocuments]') AND name = 'VerifiedBy') 
         THEN 'YES' ELSE 'NO' END AS HasVerifiedBy,
    CASE WHEN EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ChannelPartnerDocuments]') AND name = 'VerifiedOn') 
         THEN 'YES' ELSE 'NO' END AS HasVerifiedOn,
    CASE WHEN EXISTS(SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ChannelPartnerDocuments]') AND name = 'RejectionReason') 
         THEN 'YES' ELSE 'NO' END AS HasRejectionReason;

PRINT '';
PRINT '========================================';
PRINT 'P0 Critical Fixes Applied Successfully!';
PRINT '========================================';
GO
