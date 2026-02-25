-- Test Partner Upload Issue
-- Check if there are any specific issues with Partner bulk upload

-- 1. Verify Partner user exists and has correct role
SELECT 'Partner Users' as Test, UserId, Username, Role, ChannelPartnerId 
FROM Users 
WHERE Role = 'Partner';

-- 2. Check if Partner has all required permissions for Leads/Index
SELECT 
    'Partner Leads Permissions' as Test,
    perm.PermissionName,
    rpp.IsGranted,
    CASE WHEN rpp.ChannelPartnerId IS NULL THEN 'Global' ELSE CAST(rpp.ChannelPartnerId AS VARCHAR) END as Scope
FROM RolePagePermissions rpp
JOIN Pages p ON rpp.PageId = p.PageId
JOIN Permissions perm ON rpp.PermissionId = perm.PermissionId
WHERE rpp.RoleName = 'Partner' 
AND p.Controller = 'Leads'
AND p.Action = 'Index'
AND rpp.IsGranted = 1
ORDER BY perm.PermissionName;

-- 3. Check if there are any error logs or constraints that might block Partner uploads
-- (This would depend on your logging setup)

-- 4. Verify the UploadLeadFile method signature matches what's expected
-- Check if there are any recent leads created by Partner users
SELECT 
    'Recent Partner Leads' as Test,
    l.LeadId, 
    l.Name, 
    l.CreatedBy, 
    u.Username as CreatedByUser,
    u.Role as CreatedByRole,
    l.CreatedOn,
    l.ChannelPartnerId
FROM Leads l
LEFT JOIN Users u ON l.CreatedBy = u.UserId
WHERE u.Role = 'Partner' 
OR l.ChannelPartnerId IS NOT NULL
ORDER BY l.CreatedOn DESC;