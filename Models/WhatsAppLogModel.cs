using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    [Table("WhatsAppLogs")]
    public class WhatsAppLogModel
    {
        [Key]
        public int LogId { get; set; }

        [Required]
        [StringLength(50)]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required]
        public string Message { get; set; } = string.Empty;

        [StringLength(50)]
        public string MessageType { get; set; } = "text"; // text, template, document, image

        [StringLength(20)]
        public string Status { get; set; } = "Pending"; // Pending, Sent, Delivered, Read, Failed

        public string? ErrorMessage { get; set; }

        public DateTime SentOn { get; set; } = DateTime.Now;

        public int? LeadId { get; set; }

        [ForeignKey("LeadId")]
        public virtual LeadModel? Lead { get; set; }

        public int? UserId { get; set; }

        [ForeignKey("UserId")]
        public virtual UserModel? User { get; set; }
    }
}
