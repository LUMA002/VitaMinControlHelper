/*using System.ComponentModel.DataAnnotations;

namespace api.DTOs.UserSupplement
{
    public class AddUserSupplementDto
    {
        [Required(ErrorMessage = "ID добавки обов'язковий")]
        public Guid SupplementID { get; set; }
        
        public double? DefaultDosage { get; set; }
        
        [StringLength(50)]
        public string? DefaultUnit { get; set; }
    }
} */