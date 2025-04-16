using api.Data;
using api.DTOs.UserSupplement;
using api.Mappers;
using api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UserSupplementsController : ControllerBase
    {
        private readonly ApplicationDBContext _context;

        public UserSupplementsController(ApplicationDBContext context)
        {
            _context = context;
        }

        // GET: api/UserSupplements
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserSupplementDto>>> GetUserSupplements()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var userSupplements = await _context.UserSupplements
                .Include(us => us.Supplement)
                .ThenInclude(s => s.TypeRelations)
                .ThenInclude(tr => tr.Type)
                .Where(us => us.UserID == userId)
                .ToListAsync();

            var result = new List<UserSupplementDto>();
            foreach (var us in userSupplements)
            {
                result.Add(await us.ToUserSupplementDtoAsync(_context));
            }

            return Ok(result);
        }

        // GET: api/UserSupplements/5
        [HttpGet("{id}")]
        public async Task<ActionResult<UserSupplementDto>> GetUserSupplement(Guid id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var userSupplement = await _context.UserSupplements
                .Include(us => us.Supplement)
                .ThenInclude(s => s.TypeRelations)
                .ThenInclude(tr => tr.Type)
                .FirstOrDefaultAsync(us => us.UserSupplementID == id);

            if (userSupplement == null)
            {
                return NotFound();
            }

            // Перевіряємо чи належить запис поточному користувачу
            if (userSupplement.UserID != userId)
            {
                return Forbid();
            }

            return Ok(await userSupplement.ToUserSupplementDtoAsync(_context));
        }

        // POST: api/UserSupplements
        [HttpPost]
        public async Task<ActionResult<UserSupplementDto>> AddUserSupplement(AddUserSupplementDto addDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            // Перевіряємо чи існує добавка
            var supplement = await _context.Supplements
                .Include(s => s.TypeRelations)
                .ThenInclude(tr => tr.Type)
                .FirstOrDefaultAsync(s => s.SupplementID == addDto.SupplementID);

            if (supplement == null)
            {
                return NotFound("Добавка не знайдена");
            }

            // Перевіряємо чи має користувач доступ до цієї добавки
            if (!supplement.IsGlobal && supplement.CreatorId != userId)
            {
                return Forbid();
            }

            // Перевіряємо чи вже існує такий запис
            var existing = await _context.UserSupplements
                .FirstOrDefaultAsync(us => us.UserID == userId && us.SupplementID == addDto.SupplementID);

            if (existing != null)
            {
                return BadRequest("Ця добавка вже додана до вашого списку");
            }

            // Створюємо новий запис
            var userSupplement = addDto.ToUserSupplementFromAddDto(userId);
            _context.UserSupplements.Add(userSupplement);
            await _context.SaveChangesAsync();

            // Завантажуємо пов'язані дані для відповіді
            userSupplement.Supplement = supplement;

            return CreatedAtAction(nameof(GetUserSupplement), new { id = userSupplement.UserSupplementID }, 
                await userSupplement.ToUserSupplementDtoAsync(_context));
        }

        // PUT: api/UserSupplements/5
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUserSupplement(Guid id, AddUserSupplementDto updateDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var userSupplement = await _context.UserSupplements.FindAsync(id);

            if (userSupplement == null)
            {
                return NotFound();
            }

            // Перевіряємо чи належить запис поточному користувачу
            if (userSupplement.UserID != userId)
            {
                return Forbid();
            }

            // Оновлюємо властивості
            userSupplement.DefaultDosage = updateDto.DefaultDosage;
            userSupplement.DefaultUnit = updateDto.DefaultUnit;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/UserSupplements/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUserSupplement(Guid id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var userSupplement = await _context.UserSupplements.FindAsync(id);

            if (userSupplement == null)
            {
                return NotFound();
            }

            // Перевіряємо чи належить запис поточному користувачу
            if (userSupplement.UserID != userId)
            {
                return Forbid();
            }

            _context.UserSupplements.Remove(userSupplement);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
} 