using api.DTOs.Auth;
using api.Models;

namespace api.Mappers
{
    public static class UserMappers
    {
        public static UserDto ToUserDto(this User user)
        {
            return new UserDto
            {
                Id = user.Id,
                Email = user.Email ?? string.Empty,
                Username = user.UserName ?? string.Empty,
                DateOfBirth = user.DateOfBirth,
                Gender = user.Gender,
                Height = user.Height,
                Weight = user.Weight,
                CreatedAt = user.CreatedAt
            };
        }
        
        public static User ToUserFromRegisterDto(this RegisterDto registerDto)
        {
            return new User
            {
                UserName = registerDto.Username,
                Email = registerDto.Email,
                DateOfBirth = registerDto.DateOfBirth,
                Gender = registerDto.Gender,
                Height = registerDto.Height,
                Weight = registerDto.Weight,
                CreatedAt = DateTime.UtcNow
            };
        }
    }
} 