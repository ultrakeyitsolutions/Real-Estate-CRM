using System;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class ExpenseModel
    {
        [Key]
        public int ExpenseId { get; set; }
        public string Type { get; set; } // e.g. Land, Construction, Legal, Marketing, Agent, Tax, Maintenance
        public string Description { get; set; }
        public decimal Amount { get; set; }
        public DateTime Date { get; set; } = DateTime.Now;
        public int? ChannelPartnerId { get; set; }
    }
}
