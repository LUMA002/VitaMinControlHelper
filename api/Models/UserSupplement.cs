/*using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api.Models
{
    public class UserSupplement
    {
        [Key]
        public Guid UserSupplementID { get; set; }
        
        public string UserID { get; set; } = null!;
        
        public Guid SupplementID { get; set; }
        
        public double? DefaultDosage { get; set; }
        
        [StringLength(50)]
        public string? DefaultUnit { get; set; }
        
        // Навігаційні властивості
        [ForeignKey("UserID")]
        public virtual User User { get; set; } = null!;
        
        [ForeignKey("SupplementID")]
        public virtual Supplement Supplement { get; set; } = null!;
    }
} */