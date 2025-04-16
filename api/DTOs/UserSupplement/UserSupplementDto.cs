using api.DTOs.Supplement;

namespace api.DTOs.UserSupplement
{
    public class UserSupplementDto
    {
        public Guid UserSupplementID { get; set; }
        public string UserID { get; set; } = string.Empty;
        public SupplementDto Supplement { get; set; } = null!;
        public double? DefaultDosage { get; set; }
        public string? DefaultUnit { get; set; }
    }
} 