using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace api.Models
{
    public class SupplementTypeRelation
    {
        [Key]
        public Guid RelationID { get; set; }
        
        public Guid SupplementID { get; set; }
        
        public Guid TypeID { get; set; }
        
        // Навігаційні властивості
        [ForeignKey("SupplementID")]
        public virtual Supplement Supplement { get; set; } = null!;
        
        [ForeignKey("TypeID")]
        public virtual SupplementType Type { get; set; } = null!;
    }
} 