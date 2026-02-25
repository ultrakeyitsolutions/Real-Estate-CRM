using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    public class QuotationModel
    {
        [Key]
        public int QuotationId { get; set; }
        
        [Required]
        public string QuotationNumber { get; set; } = string.Empty;
        
        [Required]
        public int LeadId { get; set; }
        
        [Required]
        public int PropertyId { get; set; }
        public int? FloorId { get; set; }

        public int? FlatId { get; set; }
        
        public DateTime QuotationDate { get; set; } = DateTime.Now;
        
        public DateTime? ValidUntil { get; set; }
        
        [Required]
        public decimal BasePrice { get; set; }
        
        [Required]
        public decimal TotalAmount { get; set; }
        
        public decimal DiscountAmount { get; set; } = 0;
        
        public decimal TaxAmount { get; set; } = 0;
        
        [Required]
        public decimal GrandTotal { get; set; }
        
        public string Status { get; set; } = "Draft"; // Draft, Sent, Accepted, Rejected, Expired
        
        public string? Notes { get; set; }
        
        public int? CreatedBy { get; set; }
        
        public DateTime CreatedOn { get; set; } = DateTime.Now;
        
        public DateTime? ModifiedOn { get; set; }
        
        public int? ChannelPartnerId { get; set; } // For tracking quotation ownership
        
        // Navigation properties
        [ForeignKey("LeadId")]
        public LeadModel? Lead { get; set; }
        
        [ForeignKey("PropertyId")]
        public PropertyModel? Property { get; set; }
        
        [ForeignKey("FlatId")]
        public PropertyFlatModel? Flat { get; set; }
        
        public List<QuotationItemModel>? Items { get; set; }
    }
    
    public class QuotationItemModel
    {
    [Key]
    public int ItemId { get; set; }

    [Required]
    [ForeignKey("QuotationId")]
    public int QuotationId { get; set; }

    // Navigation property REMOVED to prevent EF from creating QuotationModelQuotationId

    [Required]
    public string ItemType { get; set; } = string.Empty; // Base, Parking, Club, Legal, Other

    [Required]
    public string Description { get; set; } = string.Empty;

    [Required]
    public decimal Amount { get; set; }

    public int Quantity { get; set; } = 1;

    [Required]
    public decimal Total { get; set; }
    }
}
