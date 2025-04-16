namespace api.DTOs.Auth
{
    public class UserDto
    {
        public string Id { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Username { get; set; } = string.Empty;
        public DateTime? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public float? Height { get; set; }
        public float? Weight { get; set; }
        public DateTime CreatedAt { get; set; }
    }
} 