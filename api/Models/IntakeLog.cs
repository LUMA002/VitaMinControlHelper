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
        
        public double Quantity { get; set; }
        
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