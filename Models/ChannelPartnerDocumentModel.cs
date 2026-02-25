using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class ChannelPartnerDocumentModel
    {
        [Key]
        public int DocumentId { get; set; }
        public int ChannelPartnerId { get; set; }
        public string FileName { get; set; }
        public string DocumentName { get; set; }
        public string DocumentType { get; set; }
        public int DocumentTypeId { get; set; } = 1;
        public string FilePath { get; set; } = "";
        public byte[] FileContent { get; set; }
        public long FileSize { get; set; }
        public string ContentType { get; set; }
        public DateTime UploadedOn { get; set; }
        
        // P0-D3: Document verification
        public string VerificationStatus { get; set; } = "Pending"; // Pending, Approved, Rejected
        public int? VerifiedBy { get; set; }
        public DateTime? VerifiedOn { get; set; }
        public string? RejectionReason { get; set; }
    }
}