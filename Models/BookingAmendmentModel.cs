using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    /// <summary>
    /// Booking amendment tracking model (P1-B5)
    /// </summary>
    public class BookingAmendmentModel
    {
        [Key]
        public int AmendmentId { get; set; }
        
        [Required]
        public int BookingId { get; set; }
        
        [Required]
        [StringLength(50)]
        public string AmendmentType { get; set; } = string.Empty; // Unit Change, Amount Adjustment, Payment Terms, Customer Details
        
        public string? PreviousValue { get; set; }
        public string? NewValue { get; set; }
        
        [StringLength(500)]
        public string? Reason { get; set; }
        
        [Required]
        public int AmendedBy { get; set; }
        public DateTime AmendedOn { get; set; } = DateTime.Now;
        
        public int? ApprovedBy { get; set; }
        public DateTime? ApprovedOn { get; set; }
        
        [StringLength(20)]
        public string Status { get; set; } = "Pending"; // Pending, Approved, Rejected
        
        // Navigation properties
        [ForeignKey("BookingId")]
        public virtual BookingModel? Booking { get; set; }
        
        [ForeignKey("AmendedBy")]
        public virtual UserModel? AmendingUser { get; set; }
        
        [ForeignKey("ApprovedBy")]
        public virtual UserModel? ApprovingUser { get; set; }
    }
}
