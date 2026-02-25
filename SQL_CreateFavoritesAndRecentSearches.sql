-- Create UserFavorites table
CREATE TABLE [dbo].[UserFavorites] (
    [FavoriteId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [UserId] INT NOT NULL,
    [PageName] NVARCHAR(100) NOT NULL,
    [PageUrl] NVARCHAR(500) NOT NULL,
    [PageIcon] NVARCHAR(50) NOT NULL,
    [PageColor] NVARCHAR(20) NOT NULL,
    CONSTRAINT [FK_UserFavorites_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users]([UserId]) ON DELETE CASCADE
);

-- Create UserRecentSearches table
CREATE TABLE [dbo].[UserRecentSearches] (
    [SearchId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    [UserId] INT NOT NULL,
    [SearchTerm] NVARCHAR(200) NOT NULL,
    [SearchedAt] DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT [FK_UserRecentSearches_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[Users]([UserId]) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX [IX_UserFavorites_UserId] ON [dbo].[UserFavorites]([UserId]);
CREATE INDEX [IX_UserRecentSearches_UserId] ON [dbo].[UserRecentSearches]([UserId]);
CREATE INDEX [IX_UserRecentSearches_SearchedAt] ON [dbo].[UserRecentSearches]([SearchedAt] DESC);
