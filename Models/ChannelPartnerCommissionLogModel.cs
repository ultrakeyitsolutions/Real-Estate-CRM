using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    public class ChannelPartnerCommissionLogModel
    {
        [Key]
        public int CommissionLogId { get; set; }
        
        [Required]
        public int PartnerId { get; set; }
        
        [Required]
        public int BookingId { get; set; }
        
        [Required]
        public decimal FixedCommissionAmount { get; set; }
        
        [Required]
        public DateTime SaleDate { get; set; }
        
        [Required]
        public string Month { get; set; } // Format: "Nov-2024"
        
        [Required]
        public int Year { get; set; }
        
        public DateTime CreatedOn { get; set; } = DateTime.Now;
        
        // Navigation properties
        [ForeignKey("PartnerId")]
        public ChannelPartnerModel? Partner { get; set; }
        
        [ForeignKey("BookingId")]
        public BookingModel? Booking { get; set; }
    }
}