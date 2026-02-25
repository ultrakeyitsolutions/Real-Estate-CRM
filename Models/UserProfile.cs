using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class UserProfile
    {
        [Key]
        public int Id { get; set; }
        public int UserId { get; set; }

        [Required]
        public string Username { get; set; }

        [Required, EmailAddress]
        public string Email { get; set; }

        public string? Location { get; set; }
        public string? Address { get; set; }

        public byte[]? ProfileImage { get; set; }


        ///////////////adding
        ///
        public string? FirstName { get; set; }
        public string? LastName { get; set; }

        public string? PhoneNumber { get; set; }
        public string? Country { get; set; }
        public string? State { get; set; }
        public string? City { get; set; }
        public string? PostalCode { get; set; }
    }
}
