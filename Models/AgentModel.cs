using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class AgentModel
    {
        [Key]
        public int AgentId { get; set; }
        public string? FullName { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string? Address { get; set; }
        public string? AgentType { get; set; } // Salary, Hybrid, Commission
        public decimal? Salary { get; set; }
        public string? CommissionRules { get; set; }
        public string? Documents { get; set; }
        public string? Status { get; set; } = "Pending";
        public DateTime CreatedOn { get; set; } = DateTime.Now;
        public int? ApprovedBy { get; set; }
        public DateTime? ApprovedOn { get; set; }
        public int? ChannelPartnerId { get; set; } // For linking agents to channel partners
        
        // Navigation property for documents
        public virtual ICollection<AgentDocumentModel>? AgentDocuments { get; set; }
    }
}