using System;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class PropertyAgentModel
    {
        [Key]
        public int PropertyAgentId { get; set; }
        
        [Required]
        public int PropertyId { get; set; }
        
        [Required]
        public int AgentUserId { get; set; }
        
        public DateTime AssignedOn { get; set; } = DateTime.Now;
        
        public int? AssignedBy { get; set; }
        
        public bool IsActive { get; set; } = true;
    }
}
