using System.ComponentModel.DataAnnotations;

namespace api.DTOs.Supplement
{
    public class CreateSupplementDto
    {
        [Required(ErrorMessage = "Назва добавки обов'язкова")]
        [StringLength(255, ErrorMessage = "Назва має бути до {1} символів")]
        public string Name { get; set; } = string.Empty;
        
        public string? Description { get; set; }
        
        public string? DeficiencySymptoms { get; set; }
        
        public List<Guid> TypeIds { get; set; } = new List<Guid>();
    }
} 