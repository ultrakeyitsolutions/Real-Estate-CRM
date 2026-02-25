-- Stored Procedure: Replace 'Teja Avidi' with 'Mahi Thulluri' and phone number '9154886214' with '9999999999' in all tables/columns
-- Run this in the CRM database

SET NOCOUNT ON;
GO

IF OBJECT_ID('dbo.FIX_Replace_TejaAvidi_and_Phone', 'P') IS NOT NULL
    DROP PROCEDURE dbo.FIX_Replace_TejaAvidi_and_Phone;
GO

CREATE PROCEDURE dbo.FIX_Replace_TejaAvidi_and_Phone
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @table NVARCHAR(256), @column NVARCHAR(256), @sql NVARCHAR(MAX);
    DECLARE @crlf NVARCHAR(2) = CHAR(13) + CHAR(10);

        -- Cursor for all user tables, EXCLUDING identity columns
        DECLARE table_cursor CURSOR FOR
        SELECT t.name AS TableName, c.name AS ColumnName, ty.name AS TypeName
        FROM sys.tables t
        JOIN sys.columns c ON t.object_id = c.object_id
        JOIN sys.types ty ON c.user_type_id = ty.user_type_id
        WHERE t.is_ms_shipped = 0
            AND (ty.name IN ('nvarchar', 'varchar', 'text', 'ntext', 'char', 'nchar'))
            AND c.is_identity = 0;

    OPEN table_cursor;
    FETCH NEXT FROM table_cursor INTO @table, @column, @sql;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        -- Replace 'Teja Avidi' (all case/casing/combos) with 'Mahi Thulluri', and any 'Teja' with 'Mahi'
        SET @sql = N'UPDATE [' + @table + '] SET [' + @column + '] = 
            REPLACE(
                REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                        [' + @column + '],
                        ''TejaAvidi'', ''Mahi Thulluri''),
                        ''tejaavidi'', ''Mahi Thulluri''),
                        ''Teja Avidi'', ''Mahi Thulluri''),
                        ''teja avidi'', ''Mahi Thulluri''),
                        ''TEJA AVIDI'', ''Mahi Thulluri''),
                        ''TEJAAVIDI'', ''Mahi Thulluri''),
                        ''tejaAvidi'', ''Mahi Thulluri''),
                        ''TejaAvidi'', ''Mahi Thulluri''),
                        ''TEJAavidi'', ''Mahi Thulluri''),
                        ''tejaAvidi'', ''Mahi Thulluri''),
                    ''Teja'', ''Mahi''),
                    ''teja'', ''Mahi''),
                    ''TEJA'', ''Mahi''),
                    ''tEjA'', ''Mahi''),
                    ''TEja'', ''Mahi''),
                    ''teJa'', ''Mahi''),
                    ''TeJA'', ''Mahi''),
                    ''tEJA'', ''Mahi''),
                    ''tEja'', ''Mahi''),
                    ''teJA'', ''Mahi''),
                ''TEJA'', ''Mahi'')
            WHERE [' + @column + '] LIKE ''%Teja%'' COLLATE SQL_Latin1_General_CP1_CI_AS 
               OR [' + @column + '] LIKE ''%teja%'' COLLATE SQL_Latin1_General_CP1_CI_AS';
        EXEC sp_executesql @sql;

        -- Replace phone number '9154886214' with '9999999999'
        SET @sql = N'UPDATE [' + @table + '] SET [' + @column + '] =
            REPLACE([' + @column + '], ''9154886214'', ''9999999999'')
            WHERE [' + @column + '] LIKE ''%9154886214%''';
        EXEC sp_executesql @sql;

        FETCH NEXT FROM table_cursor INTO @table, @column, @sql;
    END
    CLOSE table_cursor;
    DEALLOCATE table_cursor;

        -- Repeat for columns that are numeric and could store phone numbers, EXCLUDING identity columns and only those that can store 10 digits
        DECLARE num_cursor CURSOR FOR
        SELECT t.name AS TableName, c.name AS ColumnName, ty.name AS TypeName, c.precision, c.scale
        FROM sys.tables t
        JOIN sys.columns c ON t.object_id = c.object_id
        JOIN sys.types ty ON c.user_type_id = ty.user_type_id
        WHERE t.is_ms_shipped = 0
            AND c.is_identity = 0
            AND (
                        (ty.name = 'bigint')
                 OR (ty.name IN ('numeric', 'decimal') AND c.scale = 0 AND c.precision >= 10)
                 OR (ty.name = 'int' AND 9999999999 BETWEEN -2147483648 AND 2147483647) -- will be false, so int is skipped
                 )
        ;

        OPEN num_cursor;
        FETCH NEXT FROM num_cursor INTO @table, @column, @sql, @crlf, @crlf;

        WHILE @@FETCH_STATUS = 0
        BEGIN
                -- Replace phone number if stored as number
                SET @sql = N'UPDATE [' + @table + '] SET [' + @column + '] = 9999999999 WHERE [' + @column + '] = 9154886214';
                EXEC sp_executesql @sql;
                FETCH NEXT FROM num_cursor INTO @table, @column, @sql, @crlf, @crlf;
        END
        CLOSE num_cursor;
        DEALLOCATE num_cursor;
END
GO

-- To run:
-- EXEC dbo.FIX_Replace_TejaAvidi_and_Phone;
