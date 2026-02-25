using System;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class UserRecentSearch
    {
        [Key]
        public int SearchId { get; set; }
        public int UserId { get; set; }
        public string SearchTerm { get; set; }
        public DateTime SearchedAt { get; set; }
    }
}