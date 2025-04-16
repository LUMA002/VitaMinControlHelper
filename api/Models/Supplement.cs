using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace api.Models
{
    public class Supplement
    {
        [Key]
        public Guid SupplementID { get; set; }
        
        [Required]
        [StringLength(255)]
        public string Name { get; set; } = string.Empty;
        
        public string? Description { get; set; }
        
        public string? DeficiencySymptoms { get; set; }
        
        public bool IsGlobal { get; set; } = true;
        
        public string? CreatorId { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Навігаційні властивості
        [ForeignKey("CreatorId")]
        [JsonIgnore]
        public virtual User? Creator { get; set; }
        
        [JsonIgnore]
        public virtual ICollection<SupplementTypeRelation> TypeRelations { get; set; } = new List<SupplementTypeRelation>();
        
        [JsonIgnore]
        public virtual ICollection<UserSupplement> UserSupplements { get; set; } = new List<UserSupplement>();
        
        [JsonIgnore]
        public virtual ICollection<IntakeLog> IntakeLogs { get; set; } = new List<IntakeLog>();
    }
} 