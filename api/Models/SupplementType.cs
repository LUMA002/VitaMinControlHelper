using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace api.Models
{
    public class SupplementType
    {
        [Key]
        public Guid TypeID { get; set; }
        
        [Required]
        [StringLength(50)]
        public string Name { get; set; } = string.Empty;
        
        // Навігаційні властивості
        [JsonIgnore]
        public virtual ICollection<SupplementTypeRelation> SupplementRelations { get; set; } = new List<SupplementTypeRelation>();
    }
} 