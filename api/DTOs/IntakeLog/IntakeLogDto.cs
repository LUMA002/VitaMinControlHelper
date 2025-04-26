using api.DTOs.Supplement;

namespace api.DTOs.IntakeLog
{
    public class IntakeLogDto
    {
        public Guid LogID { get; set; }
        public string UserID { get; set; } = string.Empty;
        public SupplementDto Supplement { get; set; } = null!;
        public int Quantity { get; set; } // Змінено тип на int
        public double Dosage { get; set; } // Додано поле для дозування
        public string Unit { get; set; } = string.Empty;
        public DateTime TakenAt { get; set; }
    }
}