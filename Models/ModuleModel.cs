using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class ModuleModel
    {
        [Key]
        public int ModuleId { get; set; }
        public string ModuleName { get; set; } // Leads, Revenue, Expenses, etc.
        public string DisplayName { get; set; }
        public string Icon { get; set; }
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
        
        public virtual ICollection<PageModel> Pages { get; set; } = new List<PageModel>();
    }
}