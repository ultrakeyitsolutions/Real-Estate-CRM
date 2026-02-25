        
using CRM.Models;
using Microsoft.AspNetCore.Mvc;
using CRM.Attributes;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using iText.Kernel.Pdf;
using iText.Layout;
using iText.Layout.Element;
using iText.Layout.Properties;
using iText.Kernel.Font;
using iText.IO.Font.Constants;

namespace CRM.Controllers
{
    public class InvoicesController : Controller
    {
        private readonly AppDbContext _db;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public InvoicesController(AppDbContext db, IHttpContextAccessor httpContextAccessor)
        {
            _db = db;
            _httpContextAccessor = httpContextAccessor;
        }

        // GET: Invoices/Index
        [PermissionAuthorize("View")]
        public IActionResult Index(string search = "", string status = "")
        {
            var role = User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid, out int userId);

            var invoicesQuery = _db.Invoices.AsQueryable();
            
            var currentUser = _db.Users.FirstOrDefault(u => u.UserId == userId);
            var channelPartnerId = currentUser?.ChannelPartnerId;

            if (role?.ToLower() == "partner")
            {
                // Partners see invoices for their leads only
                var partnerLeadIds = _db.Leads.Where(l => l.ChannelPartnerId == channelPartnerId).Select(l => l.LeadId).ToList();
                var partnerBookingIds = _db.Bookings.Where(b => partnerLeadIds.Contains(b.LeadId)).Select(b => b.BookingId).ToList();
                invoicesQuery = invoicesQuery.Where(i => partnerBookingIds.Contains(i.BookingId));
            }
            else if (role?.ToLower() == "admin")
            {
                // Admin sees their own invoices + partner invoices for handed over leads
                var adminLeadIds = _db.Leads.Where(l => l.ChannelPartnerId == null || l.HandoverStatus == "ReadyToBook" || l.HandoverStatus == "HandedOver").Select(l => l.LeadId).ToList();
                var adminBookingIds = _db.Bookings.Where(b => b.ChannelPartnerId == null || adminLeadIds.Contains(b.LeadId)).Select(b => b.BookingId).ToList();
                invoicesQuery = invoicesQuery.Where(i => adminBookingIds.Contains(i.BookingId));
            }
            else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
            {
                var myLeadIds = _db.Leads.Where(l => l.ExecutiveId == userId).Select(l => l.LeadId).ToList();
                var myBookingIds = _db.Bookings.Where(b => myLeadIds.Contains(b.LeadId)).Select(b => b.BookingId).ToList();
                invoicesQuery = invoicesQuery.Where(i => myBookingIds.Contains(i.BookingId));
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(search))
            {
                invoicesQuery = invoicesQuery.Where(i =>
                    i.InvoiceNumber.Contains(search) ||
                    i.Notes.Contains(search));
            }

            // Apply status filter
            if (!string.IsNullOrEmpty(status))
            {
                invoicesQuery = invoicesQuery.Where(i => i.Status == status);
            }

            var invoices = invoicesQuery
                .OrderByDescending(i => i.InvoiceDate)
                .ToList();

            // Defensive: Always set ViewBag.Bookings and ViewBag.Installments
            var bookings = _db.Bookings.Include(b => b.Lead).Include(b => b.Property).ToList();
            var installments = _db.PaymentInstallments.ToList();
            ViewBag.Bookings = bookings ?? new List<CRM.Models.BookingModel>();
            ViewBag.Installments = installments ?? new List<CRM.Models.PaymentInstallmentModel>();
            ViewBag.SearchTerm = search;
            ViewBag.StatusFilter = status;
            
            // Add user info for view-level access control
            ViewBag.IsPartnerTeam = currentUser?.ChannelPartnerId != null;

            return View(invoices);
        }

        // GET: Invoices/Create
        public IActionResult Create(int? bookingId, int? installmentId)
        {
            var role = User?.FindFirst(System.Security.Claims.ClaimTypes.Role)?.Value;
            var uid = User?.FindFirst("UserId")?.Value ?? User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
            int.TryParse(uid, out int userId);
            var currentUser = _db.Users.FirstOrDefault(u => u.UserId == userId);
            
            // Partners and their team members cannot create invoices
            if (role?.ToLower() == "partner" || currentUser?.ChannelPartnerId != null)
            {
                return RedirectToAction("Index");
            }
            
            var model = new InvoiceModel();

            if (bookingId.HasValue)
            {
                var booking = _db.Bookings
                    .Include(b => b.Lead)
                    .Include(b => b.Property)
                    .Include(b => b.Flat)
                    .FirstOrDefault(b => b.BookingId == bookingId.Value);

                if (booking != null)
                {
                    model.BookingId = booking.BookingId;
                    ViewBag.Booking = booking;

                    // Get payment plan and installments
                    var paymentPlan = _db.PaymentPlans.FirstOrDefault(p => p.BookingId == bookingId.Value);
                    if (paymentPlan != null)
                    {
                        var installments = _db.PaymentInstallments
                            .Where(i => i.PlanId == paymentPlan.PlanId)
                            .OrderBy(i => i.InstallmentNumber)
                            .ToList();
                        ViewBag.Installments = installments;
                    }

                    // If installmentId is provided, auto-fill from installment
                    if (installmentId.HasValue)
                    {
                        var installment = _db.PaymentInstallments.Find(installmentId.Value);
                        if (installment != null)
                        {
                            model.InstallmentId = installment.InstallmentId;
                            model.Amount = installment.Amount;
                            model.DueDate = installment.DueDate;
                            ViewBag.SelectedInstallment = installment;
                        }
                    }
                }
            }
            else
            {
                // Load all bookings for selection
                var allBookings = _db.Bookings
                    .Include(b => b.Lead)
                    .Include(b => b.Property)
                    .Where(b => b.Status == "Confirmed" || b.Status == "Completed");

                // Role-based filtering
                var channelPartnerId = currentUser?.ChannelPartnerId;
                
                if (role?.ToLower() == "partner")
                {
                    // Partners see only bookings for their leads
                    var partnerLeadIds = _db.Leads.Where(l => l.ChannelPartnerId == channelPartnerId).Select(l => l.LeadId).ToList();
                    allBookings = allBookings.Where(b => partnerLeadIds.Contains(b.LeadId));
                }
                else if (role?.ToLower() == "sales" || role?.ToLower() == "agent")
                {
                    var myLeadIds = _db.Leads.Where(l => l.ExecutiveId == userId).Select(l => l.LeadId).ToList();
                    allBookings = allBookings.Where(b => myLeadIds.Contains(b.LeadId));
                }

                ViewBag.AllBookings = allBookings.ToList();
            }

            // Get GST rate from settings
            var gstRate = SettingsController.GetSettingValueDecimal(_db, "GSTRate", 5);
            ViewBag.GSTRate = gstRate;

            // Generate next invoice number with prefix
            var prefix = SettingsController.GetSettingValue(_db, "InvoicePrefix", "INV");
            var year = DateTime.Now.Year;
            var lastInvoice = _db.Invoices
                .Where(i => i.InvoiceNumber.StartsWith($"{prefix}-{year}"))
                .OrderByDescending(i => i.InvoiceId)
                .FirstOrDefault();

            int nextNumber = 1;
            if (lastInvoice != null)
            {
                var lastNumberStr = lastInvoice.InvoiceNumber.Split('-').Last();
                if (int.TryParse(lastNumberStr, out int lastNum))
                    nextNumber = lastNum + 1;
            }

            ViewBag.InvoicePrefix = $"{prefix}-{year}-";
            model.InvoiceNumber = $"{nextNumber:D4}";
            return View(model);
        }

        // GET: Invoices/GetBookingDetails (AJAX)
        [HttpGet]
        public IActionResult GetBookingDetails(int bookingId)
        {
            try
            {
                var booking = _db.Bookings
                    .Include(b => b.Lead)
                    .Include(b => b.Property)
                    .Include(b => b.Flat)
                    .FirstOrDefault(b => b.BookingId == bookingId);

                if (booking == null)
                {
                    return Json(new { success = false, message = "Booking not found" });
                }

                // Get payment plan and pending installments
                var paymentPlan = _db.PaymentPlans.FirstOrDefault(p => p.BookingId == bookingId);
                var milestones = new List<object>();

                if (paymentPlan != null)
                {
                    var pendingInstallments = _db.PaymentInstallments
                        .Where(i => i.PlanId == paymentPlan.PlanId && i.Status == "Pending")
                        .OrderBy(i => i.InstallmentNumber)
                        .ToList();

                    milestones = pendingInstallments.Select(i => new {
                        installmentId = i.InstallmentId,
                        milestoneName = i.MilestoneName,
                        amount = i.Amount,
                        dueDate = i.DueDate.ToString("yyyy-MM-dd"),
                        status = i.Status
                    }).ToList<object>();
                }

                return Json(new {
                    success = true,
                    leadName = booking.Lead?.Name ?? "",
                    propertyName = booking.Property?.PropertyName ?? "",
                    flatName = booking.Flat?.FlatName ?? "",
                    paymentType = booking.PaymentType ?? "",
                    milestones = milestones
                });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        // POST: Invoices/Create
        [HttpPost]
        public IActionResult Create(InvoiceModel model, List<InvoiceItemModel> items)
        {
            // Validate model
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage).ToList();
                return Json(new { success = false, message = "Validation failed", errors });
            }
            // Validate DueDate is in valid SQL Server range
            if (model.DueDate < new DateTime(1753, 1, 1) || model.DueDate > new DateTime(9999, 12, 31))
            {
                return Json(new { success = false, message = "DueDate is out of valid SQL Server range (1753-01-01 to 9999-12-31). Please select a valid due date." });
            }
            try
            {
                // Generate invoice number from settings prefix
                var prefix = SettingsController.GetSettingValue(_db, "InvoicePrefix", "INV");
                var year = DateTime.Now.Year;
                var lastInvoice = _db.Invoices
                    .Where(i => i.InvoiceNumber.StartsWith($"{prefix}-{year}"))
                    .OrderByDescending(i => i.InvoiceId)
                    .FirstOrDefault();

                int nextNumber = 1;
                if (lastInvoice != null)
                {
                    var lastNumberStr = lastInvoice.InvoiceNumber.Split('-').Last();
                    if (int.TryParse(lastNumberStr, out int lastNum))
                        nextNumber = lastNum + 1;
                }

                model.InvoiceNumber = $"{prefix}-{year}-{nextNumber:D4}";
                model.InvoiceDate = DateTime.Now;
                model.Status = "Generated";
                model.CreatedOn = DateTime.Now;

                // No tax calculation - milestone amounts already include tax
                model.TaxAmount = 0;
                model.TotalAmount = model.Amount;
                model.PaidAmount = 0;

                // Save invoice
                _db.Invoices.Add(model);
                _db.SaveChanges();

                // Save invoice items
                foreach (var item in items)
                {
                    if (!string.IsNullOrEmpty(item.Description) && item.Amount > 0)
                    {
                        item.InvoiceId = model.InvoiceId;
                        _db.InvoiceItems.Add(item);
                    }
                }
                _db.SaveChanges();

                return Json(new
                {
                    success = true,
                    message = "Invoice generated successfully!",
                    invoiceId = model.InvoiceId,
                    invoiceNumber = model.InvoiceNumber
                });
            }
            catch (Exception ex)
            {
                // Show inner exception if available
                var errorMsg = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
                return Json(new { success = false, message = $"Error: {errorMsg}" });
            }
        }

        // GET: Invoices/Details/5
        public IActionResult Details(int id)
        {
            var invoice = _db.Invoices
                .Include(i => i.Booking)
                    .ThenInclude(b => b.Lead)
                .Include(i => i.Booking)
                    .ThenInclude(b => b.Property)
                .Include(i => i.Booking)
                    .ThenInclude(b => b.Flat)
                .Include(i => i.Installment)
                .FirstOrDefault(i => i.InvoiceId == id);

            if (invoice == null)
            {
                return NotFound();
            }

            // Get invoice items
            var items = _db.InvoiceItems.Where(i => i.InvoiceId == id).ToList();
            ViewBag.Items = items;

            // Get payments for this invoice
            var payments = _db.Payments.Where(p => p.InvoiceId == id).ToList();
            ViewBag.Payments = payments;

            // Get company settings for header
            ViewBag.CompanyName = SettingsController.GetSettingValue(_db, "CompanyName");
            ViewBag.CompanyAddress = SettingsController.GetSettingValue(_db, "CompanyAddress");
            ViewBag.CompanyPhone = SettingsController.GetSettingValue(_db, "CompanyPhone");
            ViewBag.CompanyEmail = SettingsController.GetSettingValue(_db, "CompanyEmail");
            ViewBag.CompanyGST = SettingsController.GetSettingValue(_db, "CompanyGST");
            ViewBag.GSTRate = SettingsController.GetSettingValueDecimal(_db, "GSTRate", 5);

            return View(invoice);
        }

        // POST: Invoices/UpdateStatus
        [HttpPost]
        public IActionResult UpdateStatus(int invoiceId, string status)
        {
            try
            {
                var invoice = _db.Invoices.Find(invoiceId);
                if (invoice == null)
                {
                    return Json(new { success = false, message = "Invoice not found" });
                }

                invoice.Status = status;
                invoice.ModifiedOn = DateTime.Now;
                _db.SaveChanges();

                return Json(new { success = true, message = "Status updated successfully" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        // POST: Invoices/Delete
        [HttpPost]
        public IActionResult Delete(int id)
        {
            try
            {
                var invoice = _db.Invoices.Find(id);
                if (invoice == null)
                {
                    return Json(new { success = false, message = "Invoice not found" });
                }

                // Check if there are any payments
                var hasPayments = _db.Payments.Any(p => p.InvoiceId == id);
                if (hasPayments)
                {
                    return Json(new { success = false, message = "Cannot delete invoice with existing payments" });
                }

                _db.Invoices.Remove(invoice);
                _db.SaveChanges();

                return Json(new { success = true, message = "Invoice deleted successfully" });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }



        // GET: Invoices/GenerateForInstallment
        [HttpPost]
        public IActionResult GenerateForInstallment(int installmentId)
        {
            try
            {
                var installment = _db.PaymentInstallments
                    .Include(i => i.PaymentPlan)
                        .ThenInclude(p => p.Booking)
                    .FirstOrDefault(i => i.InstallmentId == installmentId);

                if (installment == null)
                {
                    return Json(new { success = false, message = "Installment not found" });
                }

                // Check if invoice already exists for this installment
                var existingInvoice = _db.Invoices.FirstOrDefault(i => i.InstallmentId == installmentId);
                if (existingInvoice != null)
                {
                    return Json(new
                    {
                        success = false,
                        message = "Invoice already exists for this installment",
                        invoiceId = existingInvoice.InvoiceId
                    });
                }

                // Generate invoice number from settings prefix
                var prefix = SettingsController.GetSettingValue(_db, "InvoicePrefix", "INV");
                var year = DateTime.Now.Year;
                var lastInvoice = _db.Invoices
                    .Where(i => i.InvoiceNumber.StartsWith($"{prefix}-{year}"))
                    .OrderByDescending(i => i.InvoiceId)
                    .FirstOrDefault();

                int nextNumber = 1;
                if (lastInvoice != null)
                {
                    var lastNumberStr = lastInvoice.InvoiceNumber.Split('-').Last();
                    if (int.TryParse(lastNumberStr, out int lastNum))
                        nextNumber = lastNum + 1;
                }

                var invoiceNumber = $"{prefix}-{year}-{nextNumber:D4}";

                // No tax calculation - installment amounts already include tax
                var taxAmount = 0;
                var totalAmount = installment.Amount;

                // Create invoice
                var invoice = new InvoiceModel
                {
                    InvoiceNumber = invoiceNumber,
                    BookingId = installment.PaymentPlan.BookingId,
                    InstallmentId = installmentId,
                    InvoiceDate = DateTime.Now,
                    DueDate = installment.DueDate,
                    Amount = installment.Amount,
                    TaxAmount = taxAmount,
                    TotalAmount = totalAmount,
                    PaidAmount = 0,
                    Status = "Generated",
                    Notes = $"Invoice for {installment.MilestoneName} installment",
                    CreatedOn = DateTime.Now
                };

                _db.Invoices.Add(invoice);
                _db.SaveChanges();

                // Create invoice item
                var invoiceItem = new InvoiceItemModel
                {
                    InvoiceId = invoice.InvoiceId,
                    Description = $"{installment.MilestoneName} Payment - Installment {installment.InstallmentNumber}",
                    Quantity = 1,
                    Rate = installment.Amount,
                    Amount = installment.Amount
                };

                _db.InvoiceItems.Add(invoiceItem);
                _db.SaveChanges();

                return Json(new
                {
                    success = true,
                    message = "Invoice generated successfully!",
                    invoiceId = invoice.InvoiceId,
                    invoiceNumber = invoice.InvoiceNumber
                });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        // Helper: Get current user ID
        private int _getCurrentUserId()
        {
            var userIdClaim = _httpContextAccessor.HttpContext?.Request.Cookies["UserId"];
            if (int.TryParse(userIdClaim, out int userId))
            {
                return userId;
            }
            return 0;
        }

        // GET: Invoices/DownloadPdf/{id}
        public IActionResult DownloadPdf(int id)
        {
            var invoice = _db.Invoices
                .Include(i => i.Booking)
                    .ThenInclude(b => b.Lead)
                .Include(i => i.Booking)
                    .ThenInclude(b => b.Property)
                .Include(i => i.Booking)
                    .ThenInclude(b => b.Flat)
                .Include(i => i.Installment)
                .FirstOrDefault(i => i.InvoiceId == id);

            if (invoice == null)
                return NotFound();

            var items = _db.InvoiceItems.Where(i => i.InvoiceId == id).ToList();
            var payments = _db.Payments.Where(p => p.InvoiceId == id).ToList();

            var companyName = SettingsController.GetSettingValue(_db, "CompanyName");
            var companyAddress = SettingsController.GetSettingValue(_db, "CompanyAddress");
            var companyPhone = SettingsController.GetSettingValue(_db, "CompanyPhone");
            var companyEmail = SettingsController.GetSettingValue(_db, "CompanyEmail");
            var companyGst = SettingsController.GetSettingValue(_db, "CompanyGST");
            var gstRate = SettingsController.GetSettingValueDecimal(_db, "GSTRate", 5);

            using (var ms = new System.IO.MemoryStream())
            {
                PdfWriter writer = new PdfWriter(ms);
                PdfDocument pdf = new PdfDocument(writer);
                Document document = new Document(pdf, PageSize.A4);
                document.SetMargins(36, 36, 36, 36);

                PdfFont titleFont = PdfFontFactory.CreateFont(StandardFonts.HELVETICA_BOLD);
                PdfFont labelFont = PdfFontFactory.CreateFont(StandardFonts.HELVETICA_BOLD);
                PdfFont valueFont = PdfFontFactory.CreateFont(StandardFonts.HELVETICA);

                // Company Header
                document.Add(new Paragraph(companyName).SetFont(titleFont).SetFontSize(18));
                document.Add(new Paragraph(companyAddress).SetFont(valueFont).SetFontSize(12));
                document.Add(new Paragraph($"Phone: {companyPhone} | Email: {companyEmail}").SetFont(valueFont).SetFontSize(12));
                document.Add(new Paragraph($"GST: {companyGst}").SetFont(valueFont).SetFontSize(12));
                document.Add(new Paragraph(" "));

                // Invoice Info
                document.Add(new Paragraph($"INVOICE: {invoice.InvoiceNumber}").SetFont(labelFont).SetFontSize(12));
                document.Add(new Paragraph($"Date: {invoice.InvoiceDate:dd-MMM-yyyy}").SetFont(valueFont).SetFontSize(12));
                document.Add(new Paragraph($"Due Date: {invoice.DueDate:dd-MMM-yyyy}").SetFont(valueFont).SetFontSize(12));
                document.Add(new Paragraph($"Status: {invoice.Status}").SetFont(valueFont).SetFontSize(12));
                document.Add(new Paragraph(" "));

                // Lead/Property/Flat
                document.Add(new Paragraph($"Lead: {invoice.Booking?.Lead?.Name}").SetFont(valueFont).SetFontSize(12));
                document.Add(new Paragraph($"Property: {invoice.Booking?.Property?.PropertyName}").SetFont(valueFont).SetFontSize(12));
                document.Add(new Paragraph($"Flat: {invoice.Booking?.Flat?.FlatName}").SetFont(valueFont).SetFontSize(12));
                document.Add(new Paragraph(" "));

                // Installment
                if (invoice.Installment != null)
                {
                    document.Add(new Paragraph($"Installment: {invoice.Installment.MilestoneName}").SetFont(valueFont).SetFontSize(12));
                }

                // Notes
                if (!string.IsNullOrEmpty(invoice.Notes))
                {
                    document.Add(new Paragraph($"Notes: {invoice.Notes}").SetFont(valueFont).SetFontSize(12));
                }
                document.Add(new Paragraph(" "));

                // Items Table
                if (items.Any())
                {
                    Table table = new Table(UnitValue.CreatePercentArray(new float[] { 3, 1, 1, 1 })).UseAllAvailableWidth();
                    table.AddHeaderCell("Description");
                    table.AddHeaderCell("Qty");
                    table.AddHeaderCell("Rate");
                    table.AddHeaderCell("Amount");
                    foreach (var item in items)
                    {
                        table.AddCell(item.Description);
                        table.AddCell(item.Quantity.ToString());
                        table.AddCell(item.Rate.ToString("N2"));
                        table.AddCell(item.Amount.ToString("N2"));
                    }
                    document.Add(table);
                }

                document.Add(new Paragraph(" "));

                // Amounts
                document.Add(new Paragraph($"Base Amount: â‚¹{invoice.Amount:N2}").SetFont(labelFont).SetFontSize(12));
                document.Add(new Paragraph($"GST ({gstRate}%): â‚¹{invoice.TaxAmount:N2}").SetFont(labelFont).SetFontSize(12));
                document.Add(new Paragraph($"Total Amount: â‚¹{invoice.TotalAmount:N2}").SetFont(labelFont).SetFontSize(12));
                document.Add(new Paragraph($"Paid Amount: â‚¹{invoice.PaidAmount:N2}").SetFont(labelFont).SetFontSize(12));
                document.Add(new Paragraph($"Outstanding: â‚¹{(invoice.TotalAmount - invoice.PaidAmount):N2}").SetFont(labelFont).SetFontSize(12));

                document.Close();
                var pdfBytes = ms.ToArray();
                return File(pdfBytes, "application/pdf", $"Invoice_{invoice.InvoiceNumber}.pdf");
            }
        }
    }
}

