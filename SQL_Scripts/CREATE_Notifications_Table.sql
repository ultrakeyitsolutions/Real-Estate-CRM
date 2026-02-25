-- Create Notifications table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Notifications' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[Notifications] (
        [NotificationId] INT IDENTITY(1,1) PRIMARY KEY,
        [Title] NVARCHAR(200) NOT NULL,
        [Message] NVARCHAR(MAX) NOT NULL,
        [Type] NVARCHAR(50) NOT NULL,
        [IsRead] BIT NOT NULL DEFAULT 0,
        [CreatedOn] DATETIME2 NOT NULL DEFAULT GETDATE(),
        [UserId] INT NULL,
        [Link] NVARCHAR(500) NULL,
        [RelatedEntityId] INT NULL,
        [RelatedEntityType] NVARCHAR(50) NULL,
        [Priority] NVARCHAR(20) NOT NULL DEFAULT 'Normal',
        [ExpiresOn] DATETIME2 NULL,
        [ReadOn] DATETIME2 NULL,
        
        CONSTRAINT FK_Notifications_Users FOREIGN KEY ([UserId]) REFERENCES [Users]([UserId]) ON DELETE CASCADE
    );
    
    -- Create indexes for better performance
    CREATE INDEX IX_Notifications_UserId ON [Notifications]([UserId]);
    CREATE INDEX IX_Notifications_IsRead ON [Notifications]([IsRead]);
    CREATE INDEX IX_Notifications_CreatedOn ON [Notifications]([CreatedOn]);
    CREATE INDEX IX_Notifications_Type ON [Notifications]([Type]);
    
    PRINT 'Notifications table created successfully';
END
ELSE
BEGIN
    PRINT 'Notifications table already exists';
END

-- Insert sample notifications for testing (optional)
IF NOT EXISTS (SELECT * FROM [Notifications])
BEGIN
    INSERT INTO [Notifications] ([Title], [Message], [Type], [UserId], [Link], [Priority])
    VALUES 
    ('Welcome to CRM', 'Welcome to the CRM system! You can now manage leads, follow-ups, and notifications.', 'SystemAlert', NULL, '/Home/Index', 'Normal'),
    ('System Maintenance', 'System maintenance is scheduled for this weekend. Please save your work.', 'SystemAlert', NULL, NULL, 'High');
    
    PRINT 'Sample notifications inserted';
END