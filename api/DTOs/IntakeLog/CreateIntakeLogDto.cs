using System.ComponentModel.DataAnnotations;

namespace api.DTOs.IntakeLog
{
    public class CreateIntakeLogDto
    {
        [Required(ErrorMessage = "ID добавки обов'язковий")]
        public Guid SupplementID { get; set; }
        
        [Required(ErrorMessage = "Кількість обов'язкова")]
        [Range(0.01, double.MaxValue, ErrorMessage = "Кількість має бути більше 0")]
        public double Quantity { get; set; }
        
        [Required(ErrorMessage = "Одиниця виміру обов'язкова")]
        [StringLength(50, ErrorMessage = "Одиниця виміру має бути до {1} символів")]
        public string Unit { get; set; } = string.Empty;
        
        public DateTime? TakenAt { get; set; }
    }
} 