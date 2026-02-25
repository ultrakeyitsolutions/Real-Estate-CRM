using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    public class PropertyDocumentModel
    {
        [Key]
        public int DocumentId { get; set; }
        
        [Required]
        public int PropertyId { get; set; }
        
        public string? DocumentType { get; set; }
        
        public string? FileName { get; set; }
        
        public byte[]? FileBytes { get; set; }
        
        public string? ContentType { get; set; }
        
        public DateTime UploadedOn { get; set; } = DateTime.Now;
        
        public int? UploadedBy { get; set; }
        
        [ForeignKey("PropertyId")]
        public virtual PropertyModel Property { get; set; }
    }
}
