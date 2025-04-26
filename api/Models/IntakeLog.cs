using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api.Models
{
    public class IntakeLog
    {
        [Key]
        public Guid LogID { get; set; }
        
        public string UserID { get; set; } = null!;
        
        public Guid SupplementID { get; set; }
        
        public int Quantity { get; set; } = 1; // Змінено тип на int і додано значення за замовчуванням
        
        public double Dosage { get; set; } = 0; // Додане нове поле для дозування активної речовини
        
        [StringLength(50)]
        public string Unit { get; set; } = string.Empty;
        
        public DateTime TakenAt { get; set; } = DateTime.UtcNow;
        
        // Навігаційні властивості
        [ForeignKey("UserID")]
        public virtual User User { get; set; } = null!;
        
        [ForeignKey("SupplementID")]
        public virtual Supplement Supplement { get; set; } = null!;
    }
}