-- Create EmailSettings Table
CREATE TABLE EmailSettings (
    EmailSettingId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    SmtpFrom NVARCHAR(255) NOT NULL,
    SmtpPassword NVARCHAR(255) NOT NULL,
    SmtpHost NVARCHAR(255) NOT NULL DEFAULT 'smtp.gmail.com',
    SmtpPort INT NOT NULL DEFAULT 587,
    EnableSsl BIT NOT NULL DEFAULT 1,
    CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedOn DATETIME NULL,
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

-- Create index for faster lookups
CREATE INDEX IX_EmailSettings_UserId ON EmailSettings(UserId);
