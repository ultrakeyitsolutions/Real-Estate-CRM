using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class RegisterModel
    {
        public string Username { get; set; }

        [Required(ErrorMessage = "Email is required.")]
        [EmailAddress(ErrorMessage = "Please enter a valid email address with '@' symbol.")]
        public string Email { get; set; }

        [Required(ErrorMessage = "Password is required.")]
        [RegularExpression(@"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$",
            ErrorMessage = "Password must contain uppercase, lowercase, number, and special character (min 6 chars).")]
        public string Password { get; set; }
        public string Role { get; set; }
    }
}
