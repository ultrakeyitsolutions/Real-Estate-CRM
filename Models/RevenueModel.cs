using System;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class RevenueModel
    {
        [Key]
        public int RevenueId { get; set; }
        public string Type { get; set; } // e.g. Sale, Booking, Rental, Service
        public string Description { get; set; }
        public decimal Amount { get; set; }
        public DateTime Date { get; set; } = DateTime.Now;
        public int? ChannelPartnerId { get; set; }
    }
}
