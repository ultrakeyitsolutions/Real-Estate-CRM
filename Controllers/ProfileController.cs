using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CRM.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace CRM.Controllers
{
    [Authorize]
    public class ProfileController : Controller
    {
        private readonly AppDbContext _context;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public ProfileController(AppDbContext context, IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _httpContextAccessor = httpContextAccessor;
        }

        private string GetUsernameFromToken()
        {
            string token = _httpContextAccessor.HttpContext?.Request.Cookies["jwtToken"];
            if (string.IsNullOrEmpty(token)) return null;

            try
            {
                var handler = new JwtSecurityTokenHandler();
                var jwt = handler.ReadJwtToken(token);
                return jwt.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Name || c.Type == "name")?.Value;
            }
            catch
            {
                return null;
            }
        }

        public async Task<IActionResult> Index()
        {
            // Get UserId from claims instead of username
            var userIdClaim = User.FindFirst("UserId")?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return RedirectToAction("Login", "Account");
            }

            var userProfile = await _context.UserProfiles.FirstOrDefaultAsync(u => u.UserId == userId);
            
            if (userProfile == null)
            {
                // Create a new profile if it doesn't exist
                var user = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
                if (user != null)
                {
                    userProfile = new UserProfile
                    {
                        UserId = user.UserId,
                        Username = user.Username,
                        Email = user.Email
                    };
                    _context.UserProfiles.Add(userProfile);
                    await _context.SaveChangesAsync();
                }
            }

            // Get user's ChannelPartnerId and Role for the view
            var currentUser = await _context.Users.FirstOrDefaultAsync(u => u.UserId == userId);
            ViewBag.ChannelPartnerId = currentUser?.ChannelPartnerId;
            ViewBag.UserRole = User.FindFirst(ClaimTypes.Role)?.Value;
            
            // Get AgentId - match by email AND ChannelPartnerId to handle duplicates
            AgentModel agent;
            if (currentUser.ChannelPartnerId == null)
            {
                // Admin agents: match by email + NULL
                agent = await _context.Agents
                    .Where(a => a.Email == currentUser.Email && a.ChannelPartnerId == null)
                    .OrderByDescending(a => a.CreatedOn)
                    .FirstOrDefaultAsync();
            }
            else
            {
                // Partner agents: match by email + ChannelPartnerId
                agent = await _context.Agents
                    .Where(a => a.Email == currentUser.Email && a.ChannelPartnerId == currentUser.ChannelPartnerId)
                    .OrderByDescending(a => a.CreatedOn)
                    .FirstOrDefaultAsync();
            }
            ViewBag.AgentId = agent?.AgentId;

            return View(userProfile);
        }

        [HttpPost]
        public async Task<IActionResult> UpdateProfile(UserProfile model, IFormFile? profileImage)
        {
            // Get UserId from claims instead of username
            var userIdClaim = User.FindFirst("UserId")?.Value;
            if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int userId))
            {
                return RedirectToAction("Login", "Account");
            }

            var userProfile = await _context.UserProfiles.FirstOrDefaultAsync(u => u.UserId == userId);
            
            if (userProfile == null)
            {
                TempData["Error"] = "Profile not found.";
                return RedirectToAction("Index");
            }

            // Update profile fields
            userProfile.FirstName = model.FirstName;
            userProfile.LastName = model.LastName;
            userProfile.Email = model.Email;
            userProfile.PhoneNumber = model.PhoneNumber;
            userProfile.Address = model.Address;
            userProfile.City = model.City;
            userProfile.State = model.State;
            userProfile.Country = model.Country;
            userProfile.PostalCode = model.PostalCode;
            userProfile.Location = model.Location;

            // Handle profile image upload
            if (profileImage != null && profileImage.Length > 0)
            {
                using (var memoryStream = new MemoryStream())
                {
                    await profileImage.CopyToAsync(memoryStream);
                    userProfile.ProfileImage = memoryStream.ToArray();
                }
            }

            try
            {
                _context.UserProfiles.Update(userProfile);
                await _context.SaveChangesAsync();
                TempData["Success"] = "Profile updated successfully!";
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Failed to update profile: " + ex.Message;
            }

            return RedirectToAction("Index");
        }
    }
}
