using api.Data;
using api.DTOs.Supplement;
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
    public class SupplementsController : ControllerBase
    {
        private readonly ApplicationDBContext _context;

        public SupplementsController(ApplicationDBContext context)
        {
            _context = context;
        }

        // GET: api/Supplements
        [HttpGet]
        public async Task<ActionResult<IEnumerable<SupplementDto>>> GetSupplements([FromQuery] bool? global = null)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            
            IQueryable<Supplement> query = _context.Supplements
                .Include(s => s.TypeRelations)
                .ThenInclude(tr => tr.Type);

            // Фільтрація за global параметром
            if (global.HasValue)
            {
                if (global.Value)
                {
                    // Тільки глобальні добавки
                    query = query.Where(s => s.IsGlobal);
                }
                else if (userId != null)
                {
                    // Тільки користувацькі добавки поточного користувача
                    query = query.Where(s => !s.IsGlobal && s.CreatorId == userId);
                }
                else
                {
                    return Unauthorized("Ви повинні бути авторизовані для отримання користувацьких добавок");
                }
            }
            else if (userId != null)
            {
                // За замовчуванням: глобальні + користувацькі поточного користувача
                query = query.Where(s => s.IsGlobal || s.CreatorId == userId);
            }
            else
            {
                // Тільки глобальні для неавторизованих користувачів
                query = query.Where(s => s.IsGlobal);
            }

            var supplements = await query.ToListAsync();
            return Ok(supplements.Select(s => s.ToSupplementDto()));
        }

        // GET: api/Supplements/5
        [HttpGet("{id}")]
        public async Task<ActionResult<SupplementDto>> GetSupplement(Guid id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var supplement = await _context.Supplements
                .Include(s => s.TypeRelations)
                .ThenInclude(tr => tr.Type)
                .FirstOrDefaultAsync(s => s.SupplementID == id);

            if (supplement == null)
            {
                return NotFound();
            }

            // Перевіряємо доступ до користувацьких добавок
            if (!supplement.IsGlobal && supplement.CreatorId != userId)
            {
                return Forbid();
            }

            return Ok(supplement.ToSupplementDto());
        }

        // POST: api/Supplements
        [HttpPost]
        [Authorize]
        public async Task<ActionResult<SupplementDto>> CreateSupplement(CreateSupplementDto createDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            
            // Створюємо добавку
            var supplement = createDto.ToSupplementFromCreateDto(userId);
            
            // Додаємо зв'язки з типами якщо вони вказані
            if (createDto.TypeIds.Any())
            {
                foreach (var typeId in createDto.TypeIds)
                {
                    var type = await _context.SupplementTypes.FindAsync(typeId);
                    if (type != null)
                    {
                        supplement.TypeRelations.Add(new SupplementTypeRelation
                        {
                            RelationID = Guid.NewGuid(),
                            SupplementID = supplement.SupplementID,
                            TypeID = type.TypeID,
                            Supplement = supplement,
                            Type = type
                        });
                    }
                }
            }

            _context.Supplements.Add(supplement);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetSupplement), new { id = supplement.SupplementID }, supplement.ToSupplementDto());
        }

        // PUT: api/Supplements/5
        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> UpdateSupplement(Guid id, CreateSupplementDto updateDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var supplement = await _context.Supplements
                .Include(s => s.TypeRelations)
                .FirstOrDefaultAsync(s => s.SupplementID == id);

            if (supplement == null)
            {
                return NotFound();
            }

            // Перевіряємо права на редагування
            if (!supplement.IsGlobal && supplement.CreatorId != userId)
            {
                return Forbid();
            }

            // Оновлюємо базові властивості
            supplement.Name = updateDto.Name;
            supplement.Description = updateDto.Description;
            supplement.DeficiencySymptoms = updateDto.DeficiencySymptoms;

            // Оновлюємо зв'язки з типами
            _context.SupplementTypeRelations.RemoveRange(supplement.TypeRelations);
            
            foreach (var typeId in updateDto.TypeIds)
            {
                var type = await _context.SupplementTypes.FindAsync(typeId);
                if (type != null)
                {
                    supplement.TypeRelations.Add(new SupplementTypeRelation
                    {
                        RelationID = Guid.NewGuid(),
                        SupplementID = supplement.SupplementID,
                        TypeID = type.TypeID
                    });
                }
            }

            await _context.SaveChangesAsync();
            return NoContent();
        }

        // DELETE: api/Supplements/5
        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteSupplement(Guid id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var supplement = await _context.Supplements.FindAsync(id);
            
            if (supplement == null)
            {
                return NotFound();
            }

            // Перевіряємо права на видалення
            if (!supplement.IsGlobal && supplement.CreatorId != userId)
            {
                return Forbid();
            }

            _context.Supplements.Remove(supplement);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
} 