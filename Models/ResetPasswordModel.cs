namespace CRM.Models
{
    public class ResetPasswordModel
    {
        public string Username { get; set; }
        public string oldPassword { get; set; }

        public string NewPassword { get; set; }
        public string ConfirmPassword { get; set; }
    }
}
