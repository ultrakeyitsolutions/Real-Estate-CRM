using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    public class InvoiceModel
    {
        [Key]
        public int InvoiceId { get; set; }
        
        [Required]
        public string InvoiceNumber { get; set; } = string.Empty;
        
        [Required]
        public int BookingId { get; set; }
        
        public int? InstallmentId { get; set; }
        
        public DateTime InvoiceDate { get; set; } = DateTime.Now;
        
        [Required]
        public DateTime DueDate { get; set; }
        
        [Required]
        public decimal Amount { get; set; }
        
        public decimal TaxAmount { get; set; } = 0;
        
        [Required]
        public decimal TotalAmount { get; set; }
        
        public decimal PaidAmount { get; set; } = 0;
        
        public string Status { get; set; } = "Generated"; // Generated, Sent, Paid, Partial, Overdue, Cancelled
        
        public string? Notes { get; set; }
        
        public DateTime CreatedOn { get; set; } = DateTime.Now;
        
        public DateTime? ModifiedOn { get; set; }
        
        // Navigation properties
        [ForeignKey("BookingId")]
        public BookingModel? Booking { get; set; }
        
        [ForeignKey("InstallmentId")]
        public PaymentInstallmentModel? Installment { get; set; }
        
        public List<InvoiceItemModel>? Items { get; set; }
    }

    public class InvoiceItemModel
    {
        [Key]
        public int ItemId { get; set; }

        [Required]
        public int InvoiceId { get; set; }

        [ForeignKey("InvoiceId")]
        public InvoiceModel Invoice { get; set; }

        [Required]
        public string Description { get; set; } = string.Empty;

        public int Quantity { get; set; } = 1;

        [Required]
        public decimal Rate { get; set; }

        [Required]
        public decimal Amount { get; set; }
    }
}
