using CRM.Attributes;
using CRM.Models;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace CRM.Controllers
{
    // [RoleAuthorize("Admin")] // Allow all authenticated users
    public class AttendanceController : Controller
    {
        private readonly AppDbContext _context;
        public AttendanceController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult AgentList()
        {
            var role = User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid, out int userId);
            var currentUser = _context.Users.FirstOrDefault(u => u.UserId == userId);
            var channelPartnerId = currentUser?.ChannelPartnerId;

            var agentsQuery = _context.Users.Where(u => u.Role == "Sales" || u.Role == "Agent");
            if (role?.ToLower() == "partner")
                agentsQuery = agentsQuery.Where(u => u.ChannelPartnerId == channelPartnerId);
            else if (role?.ToLower() == "admin")
                agentsQuery = agentsQuery.Where(u => u.ChannelPartnerId == null);

            var agents = agentsQuery.OrderBy(u => u.Username).ToList();

            // Calculate attendance stats for each agent for current month
            var currentMonth = DateTime.Now;
            var firstDay = new DateTime(currentMonth.Year, currentMonth.Month, 1);
            var lastDay = firstDay.AddMonths(1).AddDays(-1);
            var daysInMonth = DateTime.DaysInMonth(currentMonth.Year, currentMonth.Month);
            var workingDaysCount = Enumerable.Range(1, daysInMonth)
                .Select(day => new DateTime(currentMonth.Year, currentMonth.Month, day))
                .Count(date => date.DayOfWeek != DayOfWeek.Sunday && date <= DateTime.Today);

            var agentStats = new List<dynamic>();
            
            foreach (var agent in agents)
            {
                var attendanceRecords = _context.AgentAttendance
                    .Where(a => a.AgentId == agent.UserId && 
                               a.Date >= firstDay && 
                               a.Date <= lastDay &&
                               a.Date <= DateTime.Today)
                    .ToList();

                var presentDays = attendanceRecords.Count(a => a.Status == "Present");
                var absentDays = workingDaysCount - presentDays;
                var attendancePercentage = workingDaysCount > 0 ? (double)presentDays / workingDaysCount * 100 : 0;

                // Get user profile for image
                var userProfile = _context.UserProfiles.FirstOrDefault(p => p.Username == agent.Username);
                string profileImageSrc = null;
                if (userProfile?.ProfileImage != null)
                {
                    profileImageSrc = $"data:image/png;base64,{Convert.ToBase64String(userProfile.ProfileImage)}";
                }

                agentStats.Add(new
                {
                    Agent = agent,
                    PresentDays = presentDays,
                    AbsentDays = absentDays,
                    WorkingDays = workingDaysCount,
                    AttendancePercentage = attendancePercentage,
                    ProfileImage = profileImageSrc
                });
            }

            ViewBag.AgentStats = agentStats;
            ViewBag.CurrentMonth = currentMonth;
            ViewBag.WorkingDays = workingDaysCount;
            
            return View();
        }

        [HttpGet]
        public IActionResult Calendar(int? agentId = null, int? year = null, int? month = null)
        {
            var role = User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid, out int userId);
            var currentUser = _context.Users.FirstOrDefault(u => u.UserId == userId);
            var channelPartnerId = currentUser?.ChannelPartnerId;

            var now = DateTime.Now;
            int y = year ?? now.Year;
            int m = month ?? now.Month;
            
            var allUsersQuery = _context.Users.Where(u => u.Role == "Sales" || u.Role == "Agent");
            if (role?.ToLower() == "partner")
                allUsersQuery = allUsersQuery.Where(u => u.ChannelPartnerId == channelPartnerId);
            else if (role?.ToLower() == "admin")
                allUsersQuery = allUsersQuery.Where(u => u.ChannelPartnerId == null);
            
            var allUsers = allUsersQuery.ToList();

            // If agentId is null or 0, try to get from various sources
            if (!agentId.HasValue || agentId == 0)
            {
                // Try to get from cookies (common in this application)
                var userIdCookie = Request.Cookies["UserId"];
                if (!string.IsNullOrEmpty(userIdCookie) && int.TryParse(userIdCookie, out int cookieUserId))
                {
                    agentId = cookieUserId;
                }
                else
                {
                    // Try JWT claims
                    var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == "sub" || c.Type == "userid" || c.Type == "UserId");
                    if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int claimId))
                    {
                        agentId = claimId;
                    }
                    else if (User.Identity != null && !string.IsNullOrEmpty(User.Identity.Name) && int.TryParse(User.Identity.Name, out int nameId))
                    {
                        agentId = nameId;
                    }
                }
                
                // If still null/0 and admin, default to first available user
                if ((!agentId.HasValue || agentId == 0) && User.IsInRole("Admin"))
                {
                    var firstUser = allUsers.FirstOrDefault();
                    if (firstUser != null)
                    {
                        agentId = firstUser.UserId;
                    }
                }
            }
            
            // If no year/month specified and we have an agentId, try to find the latest month with data
            if (!year.HasValue && !month.HasValue && agentId.HasValue && agentId > 0)
            {
                var latestRecord = _context.AgentAttendance
                    .Where(a => a.AgentId == agentId.Value)
                    .OrderByDescending(a => a.Date)
                    .FirstOrDefault();
                if (latestRecord != null)
                {
                    y = latestRecord.Date.Year;
                    m = latestRecord.Date.Month;
                }
            }
            var daysInMonth = DateTime.DaysInMonth(y, m);

            // Use agentId directly as UserId (no mapping needed)
            var attendance = new List<AgentAttendanceModel>();
            int actualUserId = agentId ?? 0;
            
            // Debug: Log the process
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"\n=== Attendance Lookup ===\n");
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"UserId: {actualUserId}\n");
            
            // Debug: Show ALL AgentAttendance records to understand the data
            var allAttendanceRecords = _context.AgentAttendance.ToList();
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"\n=== ALL AgentAttendance Records ===\n");
            foreach (var rec in allAttendanceRecords)
            {
                System.IO.File.AppendAllText("AttendanceDebug.txt", $"  AttendanceId: {rec.AttendanceId}, AgentId: {rec.AgentId}, Date: {rec.Date:yyyy-MM-dd}, Status: {rec.Status}\n");
            }
            
            // Debug: Show ALL Users
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"\n=== ALL Users ===\n");
            foreach (var user in allUsers)
            {
                System.IO.File.AppendAllText("AttendanceDebug.txt", $"  UserId: {user.UserId}, Username: {user.Username}, Email: {user.Email}, Role: {user.Role}\n");
            }
            
            // Get attendance records using the correct UserId
            attendance = _context.AgentAttendance
                .Where(a => a.AgentId == actualUserId && a.Date.Year == y && a.Date.Month == m)
                .ToList();
                
            // IMMEDIATE DEBUG: Show what we're looking for vs what exists
            var debugQuery = $"Looking for: AgentId={actualUserId}, Year={y}, Month={m}";
            var allRecordsForUser = _context.AgentAttendance.Where(a => a.AgentId == actualUserId).ToList();
            System.IO.File.WriteAllText("QuickDebug.txt", $"{debugQuery}\nFound {attendance.Count} records for this month\nAll records for user {actualUserId}:\n");
            foreach(var r in allRecordsForUser) {
                System.IO.File.AppendAllText("QuickDebug.txt", $"  Date: {r.Date:yyyy-MM-dd}, Status: {r.Status}\n");
            }
            
            // Debug: Log the query parameters and all available records
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"\n=== Calendar Debug ===\n");
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"URL AgentId: {agentId}\n");
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"Mapped UserId: {actualUserId}\n");
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"Querying: Year={y}, Month={m}\n");
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"Found {attendance.Count} records\n");
            
            // Debug: Show all AgentAttendance records for this agent
            var allRecords = _context.AgentAttendance.Where(a => a.AgentId == actualUserId).ToList();
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"All records for AgentId {actualUserId}: {allRecords.Count}\n");
            foreach (var rec in allRecords)
            {
                System.IO.File.AppendAllText("AttendanceDebug.txt", $"  Record: Date={rec.Date:yyyy-MM-dd}, Status={rec.Status}\n");
            }
            
            // Calculate hours for each attendance record based on AttendanceLog
            foreach (var att in attendance)
            {
                var logs = _context.AttendanceLog
                    .Where(l => l.AgentId == actualUserId && l.Timestamp.Date == att.Date.Date)
                    .OrderBy(l => l.Timestamp)
                    .ToList();
                
                var intervals = new List<(DateTime login, DateTime? logout)>();
                DateTime? currentLogin = null;
                
                foreach (var log in logs)
                {
                    if (log.Type == "Login")
                    {
                        currentLogin = log.Timestamp;
                    }
                    else if (log.Type == "Logout" && currentLogin != null)
                    {
                        intervals.Add((currentLogin.Value, log.Timestamp));
                        currentLogin = null;
                    }
                }
                
                // Calculate total hours from completed intervals
                double totalHours = intervals.Sum(i => (i.logout.Value - i.login).TotalHours);
                
                // Set LoginTime and LogoutTime for display and update database
                if (intervals.Any())
                {
                    att.LoginTime = intervals.First().login;
                    att.LogoutTime = intervals.Last().logout;
                    
                    // Update the database record
                    var dbRecord = _context.AgentAttendance.Find(att.AttendanceId);
                    if (dbRecord != null)
                    {
                        dbRecord.LoginTime = att.LoginTime;
                        dbRecord.LogoutTime = att.LogoutTime;
                        dbRecord.Status = "Present";
                        _context.SaveChanges();
                    }
                }
                
                // Update status based on hours worked
                if (totalHours > 0)
                {
                    att.Status = "Present";
                }
            }
            
            // Debug: Log what we found
            System.IO.File.AppendAllText("AttendanceDebug.txt", $"AgentId from URL: {agentId}, Mapped UserId: {actualUserId}, Year: {y}, Month: {m}, Records found: {attendance.Count}\n");
            foreach (var rec in attendance)
            {
                System.IO.File.AppendAllText("AttendanceDebug.txt", $"  Date: {rec.Date:yyyy-MM-dd}, Status: {rec.Status}\n");
            }

            // Create a dictionary of existing attendance records
            var attendanceDict = attendance
                .GroupBy(a => a.Date.Date)
                .ToDictionary(g => g.Key, g => g.First());
            
            // Create a complete list for the month
            var completeAttendance = new List<AgentAttendanceModel>();
            
            for (int day = 1; day <= daysInMonth; day++)
            {
                var date = new DateTime(y, m, day);
                
                if (attendanceDict.ContainsKey(date.Date))
                {
                    // Use existing record
                    completeAttendance.Add(attendanceDict[date.Date]);
                }
                else if (date <= DateTime.Today)
                {
                    // Add absent record for missing days (only past dates)
                    completeAttendance.Add(new AgentAttendanceModel
                    {
                        AgentId = actualUserId, // Use the mapped UserId
                        Date = date,
                        Status = "Absent",
                        CorrectionRequested = false,
                        CorrectionStatus = string.Empty
                    });
                }
            }
            
            attendance = completeAttendance;
            // Sort by date
            attendance = attendance.OrderBy(a => a.Date).ToList();

            // Get today's login/logout intervals from AttendanceLog
            var today = DateTime.Today;
            var todayLogs = _context.AttendanceLog
                .Where(l => l.AgentId == actualUserId && l.Timestamp.Date == today)
                .OrderBy(l => l.Timestamp)
                .ToList();

            var todayIntervals = new List<(DateTime login, DateTime? logout)>();
            DateTime? lastLogin = null;
            foreach (var log in todayLogs)
            {
                if (log.Type == "Login")
                {
                    lastLogin = log.Timestamp;
                }
                else if (log.Type == "Logout" && lastLogin != null)
                {
                    todayIntervals.Add((lastLogin.Value, log.Timestamp));
                    lastLogin = null;
                }
            }
            if (lastLogin != null)
            {
                todayIntervals.Add((lastLogin.Value, null));
            }
            ViewBag.TodayLogIntervals = todayIntervals;
            ViewBag.TodayLogs = todayLogs;

            // Check last activity from AttendanceLog for today (only if viewing current month)
            var isViewingCurrentMonth = (y == DateTime.Now.Year && m == DateTime.Now.Month);
            if (isViewingCurrentMonth)
            {
                var lastActivityToday = _context.AttendanceLog
                    .Where(log => log.AgentId == actualUserId && log.Timestamp.Date == today)
                    .OrderByDescending(log => log.Timestamp)
                    .FirstOrDefault();
                
                ViewBag.LastActivityIsLogin = lastActivityToday?.Type == "Login";
            }
            else
            {
                ViewBag.LastActivityIsLogin = false;
            }

            ViewBag.AgentId = agentId ?? actualUserId;
            ViewBag.Year = y;
            ViewBag.Month = m;
            ViewBag.DaysInMonth = daysInMonth;
            ViewBag.Attendance = attendance;
            ViewBag.AllUsers = allUsers;
            return View();
        }
            

        [HttpPost]
        public async Task<IActionResult> Login(int attendanceId, int? agentId = null, DateTime? date = null)
        {
            AgentAttendanceModel? record = null;
            int resolvedAgentId = agentId ?? 0;
            if (resolvedAgentId == 0)
            {
                // Try to get user id from JWT token/claims
                var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == "sub" || c.Type == "userid" || c.Type == "UserId");
                if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int claimId))
                {
                    resolvedAgentId = claimId;
                }
                else if (User.Identity != null && !string.IsNullOrEmpty(User.Identity.Name) && int.TryParse(User.Identity.Name, out int nameId))
                {
                    resolvedAgentId = nameId;
                }
            }
            if (attendanceId > 0)
            {
                record = _context.AgentAttendance.Find(attendanceId);
            }
            else if (resolvedAgentId > 0)
            {
                var currentDate = DateTime.Today;
                record = _context.AgentAttendance.FirstOrDefault(a => a.AgentId == resolvedAgentId && a.Date.Date == currentDate);
                if (record == null)
                {
                    record = new AgentAttendanceModel
                    {
                        AgentId = resolvedAgentId,
                        Date = currentDate,
                        Status = "Absent"
                    };
                    _context.AgentAttendance.Add(record);
                    await _context.SaveChangesAsync(); // Ensure AttendanceId is set
                }
            }
            if (record != null)
            {
                record.Status = "Present";
                try
                {
                    // Ensure AttendanceId exists in AgentAttendance
                    var attendanceExists = _context.AgentAttendance.Any(a => a.AttendanceId == record.AttendanceId);
                    if (!attendanceExists)
                    {
                        System.IO.File.AppendAllText("AttendanceLogError.txt", $"Login Error: AttendanceId {record.AttendanceId} does not exist in AgentAttendance.\n");
                        return RedirectToAction("Calendar", new { agentId = record.AgentId });
                    }
                    // Insert new AttendanceLog for login
                    var log = new AttendanceLogModel
                    {
                        AttendanceId = record.AttendanceId,
                        AgentId = record.AgentId,
                        Timestamp = DateTime.Now,
                        Type = "Login"
                    };
                    _context.AttendanceLog.Add(log);
                    await _context.SaveChangesAsync();
                }
                catch (Exception ex)
                {
                    var inner = ex.InnerException != null ? ex.InnerException.Message : "";
                    System.IO.File.AppendAllText("AttendanceLogError.txt", $"Login Error: {ex.Message} Inner: {inner} {ex.StackTrace}\n");
                }
            }
            return RedirectToAction("Calendar", new { agentId = record?.AgentId ?? agentId });
        }

        [HttpPost]
        public async Task<IActionResult> Logout(int attendanceId)
        {
            var record = _context.AgentAttendance.Find(attendanceId);
            if (record != null)
            {
                record.Status = "Present";
                try
                {
                    // Ensure AttendanceId exists in AgentAttendance
                    var attendanceExists = _context.AgentAttendance.Any(a => a.AttendanceId == record.AttendanceId);
                    if (!attendanceExists)
                    {
                        System.IO.File.AppendAllText("AttendanceLogError.txt", $"Logout Error: AttendanceId {record.AttendanceId} does not exist in AgentAttendance.\n");
                        return RedirectToAction("Calendar", new { agentId = record.AgentId });
                    }
                    // Insert new AttendanceLog for logout
                    var log = new AttendanceLogModel
                    {
                        AttendanceId = record.AttendanceId,
                        AgentId = record.AgentId,
                        Timestamp = DateTime.Now,
                        Type = "Logout"
                    };
                    _context.AttendanceLog.Add(log);
                    await _context.SaveChangesAsync();
                }
                catch (Exception ex)
                {
                    var inner = ex.InnerException != null ? ex.InnerException.Message : "";
                    System.IO.File.AppendAllText("AttendanceLogError.txt", $"Logout Error: {ex.Message} Inner: {inner} {ex.StackTrace}\n");
                }
            }
            return RedirectToAction("Calendar", new { agentId = record?.AgentId });
        }

        [HttpPost]
        public async Task<IActionResult> RequestCorrection(int attendanceId, string reason, int? agentId = null, DateTime? date = null)
        {
            var record = _context.AgentAttendance.Find(attendanceId);
            if (record != null)
            {
                record.CorrectionRequested = true;
                record.CorrectionReason = reason;
                record.CorrectionStatus = "Pending";
                await _context.SaveChangesAsync();
                return Ok();
            }
            // If no record, try to create one if agentId and date are provided
            if (agentId.HasValue && date.HasValue)
            {
                var newRecord = new AgentAttendanceModel
                {
                    AgentId = agentId.Value,
                    Date = date.Value,
                    Status = "Absent",
                    CorrectionRequested = true,
                    CorrectionReason = reason,
                    CorrectionStatus = "Pending"
                };
                _context.AgentAttendance.Add(newRecord);
                await _context.SaveChangesAsync();
                return Ok();
            }
            return BadRequest("Attendance record not found and insufficient data to create.");
        }

        [HttpPost]
        public async Task<IActionResult> ApproveCorrection(int attendanceId)
        {
            var record = _context.AgentAttendance.Find(attendanceId);
            if (record != null && record.CorrectionRequested && record.CorrectionStatus == "Pending")
            {
                record.CorrectionStatus = "Approved";
                record.Status = "Present";
                // If login/logout missing, set login to 09:00 and logout to 18:00
                if (record.LoginTime == null || record.LogoutTime == null)
                {
                    var date = record.Date;
                    record.LoginTime = new DateTime(date.Year, date.Month, date.Day, 9, 0, 0);
                    record.LogoutTime = new DateTime(date.Year, date.Month, date.Day, 18, 0, 0);
                }
                await _context.SaveChangesAsync();
            }
            return Ok();
        }

        [HttpPost]
        public async Task<IActionResult> RejectCorrection(int attendanceId)
        {
            var record = _context.AgentAttendance.Find(attendanceId);
            if (record != null && record.CorrectionRequested && record.CorrectionStatus == "Pending")
            {
                record.CorrectionStatus = "Rejected";
                await _context.SaveChangesAsync();
            }
            return Ok();
        }

        [HttpPost]
        public async Task<IActionResult> RequestLogCorrection(int attendanceLogId, string reason)
        {
            var log = _context.AttendanceLog.Find(attendanceLogId);
            if (log != null)
            {
                log.CorrectionRequested = true;
                log.CorrectionReason = reason;
                log.CorrectionStatus = "Pending";
                await _context.SaveChangesAsync();
                return Ok();
            }
            return BadRequest("Attendance log not found.");
        }

        [HttpPost]
        public async Task<IActionResult> ApproveLogCorrection(int attendanceLogId)
        {
            var log = _context.AttendanceLog.Find(attendanceLogId);
            if (log != null && log.CorrectionRequested && log.CorrectionStatus == "Pending")
            {
                log.CorrectionStatus = "Approved";
                await _context.SaveChangesAsync();
            }
            return Ok();
        }

        [HttpPost]
        public async Task<IActionResult> RejectLogCorrection(int attendanceLogId)
        {
            var log = _context.AttendanceLog.Find(attendanceLogId);
            if (log != null && log.CorrectionRequested && log.CorrectionStatus == "Pending")
            {
                log.CorrectionStatus = "Rejected";
                await _context.SaveChangesAsync();
            }
            return Ok();
        }

        [HttpGet]
        public IActionResult GetDateIntervals(int agentId, DateTime date)
        {
            var logs = _context.AttendanceLog
                .Where(l => l.AgentId == agentId && l.Timestamp.Date == date.Date)
                .OrderBy(l => l.Timestamp)
                .ToList();

            var intervals = new List<object>();
            DateTime? currentLogin = null;
            bool hasActiveSession = false;

            foreach (var log in logs)
            {
                if (log.Type == "Login")
                {
                    currentLogin = log.Timestamp;
                }
                else if (log.Type == "Logout" && currentLogin != null)
                {
                    var duration = (log.Timestamp - currentLogin.Value).TotalMinutes;
                    intervals.Add(new
                    {
                        login = currentLogin.Value.ToString("HH:mm:ss"),
                        logout = log.Timestamp.ToString("HH:mm:ss"),
                        duration = duration.ToString("0") + "m"
                    });
                    currentLogin = null;
                }
            }

            // If there's an active session (login without logout)
            if (currentLogin != null)
            {
                intervals.Add(new
                {
                    login = currentLogin.Value.ToString("HH:mm:ss"),
                    logout = (string)null,
                    duration = "Active"
                });
                hasActiveSession = true;
            }

            // Get attendance record ID for the date
            var attendance = _context.AgentAttendance
                .FirstOrDefault(a => a.AgentId == agentId && a.Date.Date == date.Date);

            return Json(new { 
                intervals, 
                hasActiveSession, 
                attendanceId = attendance?.AttendanceId ?? 0 
            });
        }
    }
}
