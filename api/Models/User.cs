using Microsoft.AspNetCore.Identity;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace api.Models
{
    public class User : IdentityUser
    {
        public DateTime? DateOfBirth { get; set; }
        
        [StringLength(25)]
        public string? Gender { get; set; }
        
        public float? Height { get; set; }
        
        public float? Weight { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Навігаційні властивості
        [JsonIgnore]
        public virtual ICollection<Supplement> CreatedSupplements { get; set; } = new List<Supplement>();
        
    /*    [JsonIgnore]
        public virtual ICollection<UserSupplement> UserSupplements { get; set; } = new List<UserSupplement>();
        */
        [JsonIgnore]
        public virtual ICollection<IntakeLog> IntakeLogs { get; set; } = new List<IntakeLog>();
    }
} 