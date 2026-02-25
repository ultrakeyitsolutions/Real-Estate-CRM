using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    public class AgentCommissionLogModel
    {
        [Key]
        public int CommissionLogId { get; set; }
        
        [Required]
        public int AgentId { get; set; }
        
        [Required]
        public int BookingId { get; set; }
        
        [Required]
        public decimal SaleAmount { get; set; }
        
        [Required]
        public decimal CommissionPercentage { get; set; }
        
        [Required]
        public decimal CommissionAmount { get; set; }
        
        [Required]
        public DateTime SaleDate { get; set; }
        
        [Required]
        public string Month { get; set; } // Format: "Nov-2024"
        
        [Required]
        public int Year { get; set; }
        
        public DateTime CreatedOn { get; set; } = DateTime.Now;
        
        // Navigation properties
        [ForeignKey("AgentId")]
        public AgentModel? Agent { get; set; }
        
        [ForeignKey("BookingId")]
        public BookingModel? Booking { get; set; }
    }
}