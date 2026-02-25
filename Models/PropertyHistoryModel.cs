using System;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class PropertyHistoryModel
    {
        [Key]
        public int HistoryId { get; set; }
        
        [Required]
        public int PropertyId { get; set; }
        
        public string? Activity { get; set; }
        
        public DateTime ActivityDate { get; set; } = DateTime.Now;
        
        public int? ExecutiveId { get; set; }
    }
}
