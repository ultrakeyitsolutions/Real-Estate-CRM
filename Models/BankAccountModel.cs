using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CRM.Models
{
    public class BankAccountModel
    {
        [Key]
        [Column("AccountId")]
        public int Id { get; set; }
        
        [Required]
        public string AccountHolderName { get; set; } = string.Empty;
        
        [Required]
        public string AccountNumber { get; set; } = string.Empty;
        
        [Required]
        public string BankName { get; set; } = string.Empty;
        
        [Required]
        public string IFSCCode { get; set; } = string.Empty;
        
        public string? BranchName { get; set; }
        
        public string? AccountType { get; set; } // Savings, Current, etc.
        
        public bool IsActive { get; set; } = false;
        
        public DateTime CreatedOn { get; set; } = DateTime.Now;
        
        public DateTime? UpdatedOn { get; set; }
    }
}