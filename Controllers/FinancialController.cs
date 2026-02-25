using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CRM.Attributes;
using CRM.Models;

namespace CRM.Controllers
{
    [RoleAuthorize("Admin")]
    public class FinancialController : Controller
    {
        private readonly AppDbContext _context;

        public FinancialController(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IActionResult> PaymentGateways()
        {
            var gateways = await _context.PaymentGateways.ToListAsync();
            return View(gateways);
        }

        [HttpPost]
        public async Task<IActionResult> SavePaymentGateway(PaymentGatewayModel model)
        {
            try
            {
                var existing = await _context.PaymentGateways
                    .FirstOrDefaultAsync(g => g.GatewayName == model.GatewayName);

                if (existing != null)
                {
                    existing.KeyId = model.KeyId;
                    existing.KeySecret = model.KeySecret;
                    existing.WebhookSecret = model.WebhookSecret;
                    existing.IsActive = model.IsActive;
                    existing.UpdatedOn = DateTime.Now;
                }
                else
                {
                    _context.PaymentGateways.Add(model);
                }

                await _context.SaveChangesAsync();
                return Json(new { success = true, message = "Payment gateway saved successfully!" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        public async Task<IActionResult> BankAccounts()
        {
            var accounts = await _context.BankAccounts.OrderByDescending(b => b.IsActive).ToListAsync();
            return View(accounts);
        }

        [HttpPost]
        public async Task<IActionResult> SaveBankAccount(BankAccountModel model)
        {
            try
            {
                if (model.IsActive)
                {
                    // Deactivate all other accounts
                    var activeAccounts = await _context.BankAccounts.Where(b => b.IsActive).ToListAsync();
                    foreach (var account in activeAccounts)
                    {
                        account.IsActive = false;
                        account.UpdatedOn = DateTime.Now;
                    }
                }

                if (model.Id == 0)
                {
                    _context.BankAccounts.Add(model);
                }
                else
                {
                    var existing = await _context.BankAccounts.FindAsync(model.Id);
                    if (existing != null)
                    {
                        existing.AccountHolderName = model.AccountHolderName;
                        existing.AccountNumber = model.AccountNumber;
                        existing.BankName = model.BankName;
                        existing.IFSCCode = model.IFSCCode;
                        existing.BranchName = model.BranchName;
                        existing.AccountType = model.AccountType;
                        existing.IsActive = model.IsActive;
                        existing.UpdatedOn = DateTime.Now;
                    }
                }

                await _context.SaveChangesAsync();
                return Json(new { success = true, message = "Bank account saved successfully!" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<IActionResult> DeleteBankAccount(int id)
        {
            try
            {
                var account = await _context.BankAccounts.FindAsync(id);
                if (account != null)
                {
                    _context.BankAccounts.Remove(account);
                    await _context.SaveChangesAsync();
                }
                return Json(new { success = true, message = "Bank account deleted successfully!" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = ex.Message });
            }
        }
    }
}