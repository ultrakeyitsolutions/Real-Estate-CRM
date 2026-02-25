-- Create ChannelPartnerDocuments table
CREATE TABLE [dbo].[ChannelPartnerDocuments] (
    [DocumentId] int IDENTITY(1,1) NOT NULL,
    [PartnerId] int NOT NULL,
    [FileName] nvarchar(max) NULL,
    [DocumentName] nvarchar(max) NULL,
    [DocumentType] nvarchar(max) NULL,
    [FileContent] varbinary(max) NULL,
    [FileSize] bigint NOT NULL,
    [ContentType] nvarchar(max) NULL,
    [UploadedOn] datetime2 NOT NULL,
    CONSTRAINT [PK_ChannelPartnerDocuments] PRIMARY KEY ([DocumentId])
);

-- Add foreign key constraint to ChannelPartners table
ALTER TABLE [dbo].[ChannelPartnerDocuments]
ADD CONSTRAINT [FK_ChannelPartnerDocuments_ChannelPartners_PartnerId] 
FOREIGN KEY ([PartnerId]) REFERENCES [dbo].[ChannelPartners] ([PartnerId]) ON DELETE CASCADE;

-- Create index on PartnerId for better query performance
CREATE INDEX [IX_ChannelPartnerDocuments_PartnerId] ON [dbo].[ChannelPartnerDocuments] ([PartnerId]);