using api.DTOs.Auth;
using api.Helpers;
using api.Mappers;
using api.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<User> _userManager;
        private readonly SignInManager<User> _signInManager;
        private readonly JwtService _jwtService;

        public AuthController(
            UserManager<User> userManager,
            SignInManager<User> signInManager,
            JwtService jwtService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _jwtService = jwtService;
        }

        // POST: api/Auth/Register
        [HttpPost("Register")]
        public async Task<ActionResult<AuthResponseDto>> Register(RegisterDto registerDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Перевіряємо чи існує користувач з таким email
            var userExists = await _userManager.FindByEmailAsync(registerDto.Email);
            if (userExists != null)
            {
                return BadRequest(new AuthResponseDto
                {
                    Success = false,
                    Message = "Користувач з таким email вже існує"
                });
            }

            // Створюємо нового користувача
            var user = registerDto.ToUserFromRegisterDto();
            var result = await _userManager.CreateAsync(user, registerDto.Password);

            if (!result.Succeeded)
            {
                return BadRequest(new AuthResponseDto
                {
                    Success = false,
                    Message = string.Join(", ", result.Errors.Select(e => e.Description))
                });
            }

            // Генеруємо JWT токен
            var token = _jwtService.GenerateJwtToken(user);

            return Ok(new AuthResponseDto
            {
                Success = true,
                Message = "Реєстрація успішна",
                Token = token,
                Expiration = DateTime.UtcNow.AddHours(6),
                User = user.ToUserDto()
            });
        }

        // POST: api/Auth/Login
        [HttpPost("Login")]
        public async Task<ActionResult<AuthResponseDto>> Login(LoginDto loginDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Знаходимо користувача за email
            var user = await _userManager.FindByEmailAsync(loginDto.Email);
            if (user == null)
            {
                return Unauthorized(new AuthResponseDto
                {
                    Success = false,
                    Message = "Невірний email або пароль"
                });
            }

            // Перевіряємо пароль
            var result = await _signInManager.CheckPasswordSignInAsync(user, loginDto.Password, false);
            if (!result.Succeeded)
            {
                return Unauthorized(new AuthResponseDto
                {
                    Success = false,
                    Message = "Невірний email або пароль"
                });
            }

            // Генеруємо JWT токен
            var token = _jwtService.GenerateJwtToken(user);

            return Ok(new AuthResponseDto
            {
                Success = true,
                Message = "Авторизація успішна",
                Token = token,
                Expiration = DateTime.UtcNow.AddHours(6),
                User = user.ToUserDto()
            });
        }
    }
} 