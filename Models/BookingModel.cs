using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    public class BookingModel
    {
        [Key]
        public int BookingId { get; set; }
        
        [Required]
        public string BookingNumber { get; set; } = string.Empty;
        
        [Required]
        public int LeadId { get; set; }
        
        [Required]
        public int PropertyId { get; set; }
        
        [Required]
        public int FlatId { get; set; }
        
        public int? QuotationId { get; set; }
        
        public DateTime BookingDate { get; set; } = DateTime.Now;
        
        [Required]
        public decimal BookingAmount { get; set; }
        
        [Required]
        public decimal TotalAmount { get; set; }
        
        [Required]
        public string PaymentType { get; set; } = string.Empty; // FullPayment, EMI
        
        public string Status { get; set; } = "Pending"; // Pending, Confirmed, Cancelled, Completed
        
        public DateTime? AgreementDate { get; set; }
        
        public string? AgreementPath { get; set; }
        
        public DateTime? PossessionDate { get; set; }
        
        public string? Notes { get; set; }
        
        public int? CreatedBy { get; set; }
        
        public DateTime CreatedOn { get; set; } = DateTime.Now;
        
        public DateTime? ModifiedOn { get; set; }
        
        public int? ChannelPartnerId { get; set; } // For tracking booking ownership
        
        // P0-D2: Concurrency control to prevent double bookings
        [Timestamp]
        public byte[]? RowVersion { get; set; }
        
        // Navigation properties
        [ForeignKey("LeadId")]
        public LeadModel? Lead { get; set; }
        
        [ForeignKey("PropertyId")]
        public PropertyModel? Property { get; set; }
        
        [ForeignKey("FlatId")]
        public PropertyFlatModel? Flat { get; set; }
        
        [ForeignKey("QuotationId")]
        public QuotationModel? Quotation { get; set; }
    }
    
    public class BookingDocumentModel
    {
        [Key]
        public int DocumentId { get; set; }
        
        [Required]
        public int BookingId { get; set; }
        
        [Required]
        public string DocumentType { get; set; } = string.Empty;
        
        [Required]
        public string DocumentName { get; set; } = string.Empty;
        
        [Required]
        public string FilePath { get; set; } = string.Empty;
        
        public DateTime UploadedOn { get; set; } = DateTime.Now;
        
        public int? UploadedBy { get; set; }
    }
}
