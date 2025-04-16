using api.DTOs.SupplementType;

namespace api.DTOs.Supplement
{
    public class SupplementDto
    {
        public Guid SupplementID { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? DeficiencySymptoms { get; set; }
        public bool IsGlobal { get; set; }
        public string? CreatorId { get; set; }
        public DateTime CreatedAt { get; set; }
        public List<SupplementTypeDto> Types { get; set; } = new List<SupplementTypeDto>();
    }
} 