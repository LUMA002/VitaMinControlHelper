using api.DTOs.Supplement;

namespace api.DTOs.IntakeLog
{
    public class IntakeLogDto
    {
        public Guid LogID { get; set; }
        public string UserID { get; set; } = string.Empty;
        public SupplementDto Supplement { get; set; } = null!;
        public double Quantity { get; set; }
        public string Unit { get; set; } = string.Empty;
        public DateTime TakenAt { get; set; }
    }
} 