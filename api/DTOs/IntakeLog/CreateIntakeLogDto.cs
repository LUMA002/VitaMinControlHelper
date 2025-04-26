using System.ComponentModel.DataAnnotations;

namespace api.DTOs.IntakeLog
{
    public class CreateIntakeLogDto
    {
        [Required(ErrorMessage = "ID добавки обов'язковий")]
        public Guid SupplementID { get; set; }

        [Required(ErrorMessage = "Кількість порцій обов'язкова")]
        [Range(1, 100, ErrorMessage = "Кількість порцій має бути не менше 1")]
        public int Quantity { get; set; } = 1; // Змінено тип на int з значенням за замовчуванням
        
        [Required(ErrorMessage = "Дозування обов'язкове")]
        [Range(0.01, 100000000, ErrorMessage = "Дозування має бути більше 0")]
        public double Dosage { get; set; } // Додано поле для дозування активної речовини
        
        [Required(ErrorMessage = "Одиниця виміру обов'язкова")]
        [StringLength(50, ErrorMessage = "Одиниця виміру має бути до {1} символів")]
        public string Unit { get; set; } = string.Empty;
        
        public DateTime? TakenAt { get; set; }
    }
}