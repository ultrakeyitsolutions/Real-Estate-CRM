using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    public class PaymentModel
    {
        [Key]
        public int PaymentId { get; set; }
        
        [Required]
        public string ReceiptNumber { get; set; } = string.Empty;
        
        [Required]
        public int InvoiceId { get; set; }
        
        [Required]
        public int BookingId { get; set; }
        
        public int? InstallmentId { get; set; }
        
        public DateTime PaymentDate { get; set; } = DateTime.Now;
        
        [Required]
        public decimal Amount { get; set; }
        
        [Required]
        public string PaymentMethod { get; set; } = string.Empty; // Cash, Cheque, UPI, NEFT, RTGS, Card
        
        public string? TransactionReference { get; set; }
        
        public string? BankName { get; set; }
        
        public string? ChequeNumber { get; set; }
        
        public DateTime? ChequeDate { get; set; }
        
        public string? Notes { get; set; }
        
        public int? ReceivedBy { get; set; }
        
        public DateTime CreatedOn { get; set; } = DateTime.Now;
        
        // Navigation properties
        [ForeignKey("InvoiceId")]
        public InvoiceModel? Invoice { get; set; }
        
        [ForeignKey("BookingId")]
        public BookingModel? Booking { get; set; }
        
        [ForeignKey("InstallmentId")]
        public PaymentInstallmentModel? Installment { get; set; }
    }
}
