using System.ComponentModel.DataAnnotations;

namespace api.DTOs.SupplementType
{
    public class CreateSupplementTypeDto
    {
        [Required(ErrorMessage = "Назва типу обов'язкова")]
        [StringLength(50, ErrorMessage = "Назва має бути до {1} символів")]
        public string Name { get; set; } = string.Empty;
    }
} 