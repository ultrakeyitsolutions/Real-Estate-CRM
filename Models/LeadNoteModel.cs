using System;
using System.ComponentModel.DataAnnotations;

namespace CRM.Models
{
    public class LeadNoteModel
    {
        [Key]

        public int NoteId { get; set; }
        public int LeadId { get; set; }
        public string NoteText { get; set; }
        public int? ExecutiveId { get; set; }
        public DateTime CreatedOn { get; set; } = DateTime.Now;
    }
}
