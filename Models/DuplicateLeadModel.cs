using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    /// <summary>
    /// Duplicate leads tracking for data quality (P0-L1)
    /// </summary>
    public class DuplicateLeadModel
    {
        [Key]
        public int DuplicateId { get; set; }
        
        [Required]
        public int LeadId1 { get; set; }
        
        [Required]
        public int LeadId2 { get; set; }
        
        [Required]
        [StringLength(50)]
        public string MatchType { get; set; } = string.Empty; // Phone, Email, Both
        
        public int? ReviewedBy { get; set; }
        public DateTime? ReviewedOn { get; set; }
        
        [StringLength(20)]
        public string? Action { get; set; } // Merge, Keep Both, Delete
        
        // Navigation properties
        [ForeignKey("LeadId1")]
        public virtual LeadModel? Lead1 { get; set; }
        
        [ForeignKey("LeadId2")]
        public virtual LeadModel? Lead2 { get; set; }
        
        [ForeignKey("ReviewedBy")]
        public virtual UserModel? Reviewer { get; set; }
    }
}
