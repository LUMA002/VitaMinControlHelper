using System.ComponentModel.DataAnnotations;

namespace api.DTOs.Auth
{
    public class RegisterDto
    {
        [Required(ErrorMessage = "Email обов'язковий")]
        [EmailAddress(ErrorMessage = "Невірний формат email")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "Ім'я користувача обов'язкове")]
        [StringLength(100, ErrorMessage = "Ім'я користувача має бути від {2} до {1} символів", MinimumLength = 3)]
        public string Username { get; set; } = string.Empty;

        [Required(ErrorMessage = "Пароль обов'язковий")]
        [StringLength(100, ErrorMessage = "Пароль має бути від {2} до {1} символів", MinimumLength = 6)]
        public string Password { get; set; } = string.Empty;

        [Required(ErrorMessage = "Підтвердження паролю обов'язкове")]
        [Compare("Password", ErrorMessage = "Паролі не співпадають")]
        public string ConfirmPassword { get; set; } = string.Empty;

        public DateTime? DateOfBirth { get; set; }
        
        [StringLength(25)]
        public string? Gender { get; set; }
        
        public float? Height { get; set; }
        
        public float? Weight { get; set; }
    }
} 