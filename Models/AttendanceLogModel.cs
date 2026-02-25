using System;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class AttendanceLogModel
    {
        [Key]
        public int AttendanceLogId { get; set; }
        public int AttendanceId { get; set; }
        public int AgentId { get; set; }
        public DateTime Timestamp { get; set; }
        public string Type { get; set; } // "Login" or "Logout"
        public bool CorrectionRequested { get; set; } = false;
        public string? CorrectionReason { get; set; }
        public string? CorrectionStatus { get; set; } // "Pending", "Approved", "Rejected"
    }
}
