-- Add SubscriptionPlan column to existing ChannelPartners table if it doesn't exist
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ChannelPartners' AND COLUMN_NAME = 'SubscriptionPlan')
BEGIN
    ALTER TABLE ChannelPartners ADD SubscriptionPlan NVARCHAR(50) DEFAULT 'Basic';
END