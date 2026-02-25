using System;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class LeadLogModel
    {
        [Key]
        public int LogId { get; set; }
        public int LeadId { get; set; }
        public string LogText { get; set; }
        public DateTime LogDate { get; set; } = DateTime.Now;
        public int? ExecutiveId { get; set; }
    }
}
