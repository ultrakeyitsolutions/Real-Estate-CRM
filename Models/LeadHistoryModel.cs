using System;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class LeadHistoryModel
    {
        [Key]
        public int HistoryId { get; set; }
        public int LeadId { get; set; }
        public string Activity { get; set; }
        public DateTime ActivityDate { get; set; } = DateTime.Now;
        public int? ExecutiveId { get; set; }
    }
}
