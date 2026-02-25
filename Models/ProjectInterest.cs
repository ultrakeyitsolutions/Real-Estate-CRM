using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class ProjectInterest
    {
        public int Id { get; set; }
        
        [Required]
        [StringLength(100)]
        public string FullName { get; set; } = string.Empty;
        
        [Required]
        [EmailAddress]
        [StringLength(100)]
        public string Email { get; set; } = string.Empty;
        
        [Required]
        [StringLength(20)]
        public string Phone { get; set; } = string.Empty;
        
        [StringLength(100)]
        public string? Company { get; set; }
        
        [Required]
        [StringLength(100)]
        public string ProjectName { get; set; } = string.Empty;
        
        [StringLength(500)]
        public string? Message { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        
        public bool IsContacted { get; set; } = false;
    }
}