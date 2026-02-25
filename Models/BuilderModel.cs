using System;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class BuilderModel
    {
        [Key]
        public int BuilderId { get; set; }
        
        [Required]
        public string BuilderName { get; set; } = string.Empty;
        
        public string? ContactPerson { get; set; }
        
        public string? Email { get; set; }
        
        public string? Phone { get; set; }
        
        public string? Address { get; set; }
        
        public string? Website { get; set; }
        
        public byte[]? Logo { get; set; }
        
        public DateTime CreatedOn { get; set; } = DateTime.Now;
        
        public int? CreatedBy { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
}
