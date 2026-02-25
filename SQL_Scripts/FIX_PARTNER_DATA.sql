-- =====================================================
-- FIX PARTNER USER DATA AND VERIFY SETUP
-- =====================================================

-- 1. Verify Partner user setup
SELECT UserId, Username, Email, Role, ChannelPartnerId 
FROM Users 
WHERE UserId = 24;

-- Expected: UserId=24, Role='Partner', ChannelPartnerId=3

-- 2. Verify ChannelPartner record
SELECT PartnerId, CompanyName, ContactPerson, Email, Status, UserId
FROM ChannelPartners
WHERE PartnerId = 3;

-- Expected: PartnerId=3, Status='Approved', UserId=24

-- 3. If ChannelPartner.UserId is NULL, update it
UPDATE ChannelPartners 
SET UserId = 24 
WHERE PartnerId = 3 AND UserId IS NULL;

-- 4. Verify the link is correct
SELECT 
    u.UserId,
    u.Username,
    u.Role,
    u.ChannelPartnerId,
    cp.PartnerId,
    cp.CompanyName,
    cp.UserId as CP_UserId
FROM Users u
LEFT JOIN ChannelPartners cp ON u.ChannelPartnerId = cp.PartnerId
WHERE u.UserId = 24;

-- 5. Check if Partner has any leads (should be empty initially)
SELECT COUNT(*) as PartnerLeadsCount
FROM Leads
WHERE ChannelPartnerId = 3;

-- 6. Check if Partner has any agents (should be empty initially)
SELECT COUNT(*) as PartnerAgentsCount
FROM Agents
WHERE ChannelPartnerId = 3;

-- 7. Check if Partner has any bookings (should be empty initially)
SELECT COUNT(*) as PartnerBookingsCount
FROM Bookings
WHERE ChannelPartnerId = 3;

-- 8. Check if Partner has any quotations (should be empty initially)
SELECT COUNT(*) as PartnerQuotationsCount
FROM Quotations
WHERE ChannelPartnerId = 3;

PRINT 'Partner data verification complete!';
