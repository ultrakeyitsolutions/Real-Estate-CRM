-- Check and add missing columns to ChannelPartnerDocuments table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ChannelPartnerDocuments' AND COLUMN_NAME = 'PartnerId')
    ALTER TABLE [dbo].[ChannelPartnerDocuments] ADD [PartnerId] int NOT NULL DEFAULT 0;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ChannelPartnerDocuments' AND COLUMN_NAME = 'DocumentName')
    ALTER TABLE [dbo].[ChannelPartnerDocuments] ADD [DocumentName] nvarchar(max) NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ChannelPartnerDocuments' AND COLUMN_NAME = 'DocumentType')
    ALTER TABLE [dbo].[ChannelPartnerDocuments] ADD [DocumentType] nvarchar(max) NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ChannelPartnerDocuments' AND COLUMN_NAME = 'FileContent')
    ALTER TABLE [dbo].[ChannelPartnerDocuments] ADD [FileContent] varbinary(max) NULL;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ChannelPartnerDocuments' AND COLUMN_NAME = 'UploadedOn')
    ALTER TABLE [dbo].[ChannelPartnerDocuments] ADD [UploadedOn] datetime2 NOT NULL DEFAULT GETDATE();