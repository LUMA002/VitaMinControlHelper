using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace api.DTOs.Supplement
{
    public class UpdateSupplementDto
    {
        [Required]
        public Guid SupplementID { get; set; }
        
        [Required]
        public string Name { get; set; }
        
        public string? Description { get; set; }
        
        public string? DeficiencySymptoms { get; set; }
        
        public IEnumerable<Guid>? TypeIds { get; set; }
        
        public bool IsGlobal { get; set; }
    }
} 