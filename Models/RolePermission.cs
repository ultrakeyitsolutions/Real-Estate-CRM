using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
namespace CRM.Models
{
    public class RolePermission
    {
        [Key]
        public int Id { get; set; }
        public string RoleName { get; set; }

        // ✅ Add these new permission fields
        public bool CanCreate { get; set; }
        public bool CanEdit { get; set; }
        public bool CanDelete { get; set; }
        public bool CanView { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
