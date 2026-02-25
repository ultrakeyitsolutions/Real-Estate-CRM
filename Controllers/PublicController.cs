using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CRM.Models;

namespace CRM.Controllers
{
    public class PublicController : Controller
    {
        private readonly AppDbContext _db;

        public PublicController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public IActionResult CreateAccount()
        {
            var branding = _db.Branding.AsNoTracking().FirstOrDefault();
            ViewBag.CompanyLogo = branding?.CompanyLogo;
            
            return View();
        }

        [HttpPost]
        public IActionResult CreateAccount(RegisterModel model)
        {
            var exists = _db.Users.Any(u => u.Username == model.Username);
            if (exists)
            {
                ViewBag.Message = "Username already exists!";
                return View();
            }

            var newUser = new UserModel
            {
                Username = model.Username,
                Email = model.Email,
                Password = model.Password,
                Role = "Agent", // Default role for public registration
                IsActive = true,
                CreatedDate = DateTime.Now
            };

            _db.Users.Add(newUser);
            _db.SaveChanges();

            TempData["Success"] = "Account created successfully! Please login.";
            return RedirectToAction("Login", "Account");
        }
    }
}