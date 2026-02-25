using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    public class PartnerLeadModel
    {
        [Key]
        public int LeadId { get; set; }
        public int PartnerId { get; set; }
        public string? LeadName { get; set; }
        public string? Contact { get; set; }
        public string? Email { get; set; }
        public string? Location { get; set; }
        public string? Stage { get; set; }
        public string Status { get; set; } = "New";
        public string? Source { get; set; }
        public string? Type { get; set; }
        public string? PropertyInterest { get; set; }
        public DateTime CreatedOn { get; set; } = DateTime.Now;
        public bool ConvertedToSale { get; set; } = false;
        public decimal? CommissionAmount { get; set; }
        
        // Navigation properties
        [ForeignKey("LeadId")]
        public LeadModel? Lead { get; set; }
        
        [ForeignKey("PartnerId")]
        public ChannelPartnerModel? Partner { get; set; }
    }
}