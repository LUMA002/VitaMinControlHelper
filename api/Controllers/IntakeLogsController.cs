using api.Data;
using api.DTOs.IntakeLog;
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
    public class IntakeLogsController : ControllerBase
    {
        private readonly ApplicationDBContext _context;

        public IntakeLogsController(ApplicationDBContext context)
        {
            _context = context;
        }

        // GET: api/IntakeLogs
        [HttpGet]
        public async Task<ActionResult<IEnumerable<IntakeLogDto>>> GetIntakeLogs(
            [FromQuery] DateTime? from = null,
            [FromQuery] DateTime? to = null)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            IQueryable<IntakeLog> query = _context.IntakeLogs
                .Include(il => il.Supplement)
                .ThenInclude(s => s.TypeRelations)
                .ThenInclude(tr => tr.Type)
                .Where(il => il.UserID == userId);

            // Фільтрація за датою прийому
            if (from.HasValue)
            {
                query = query.Where(il => il.TakenAt >= from.Value);
            }

            if (to.HasValue)
            {
                query = query.Where(il => il.TakenAt <= to.Value);
            }

            // Сортування за датою (новіші спочатку)
            query = query.OrderByDescending(il => il.TakenAt);

            var intakeLogs = await query.ToListAsync();

            var result = new List<IntakeLogDto>();
            foreach (var log in intakeLogs)
            {
                result.Add(await log.ToIntakeLogDtoAsync(_context));
            }

            return Ok(result);
        }

        // GET: api/IntakeLogs/5
        [HttpGet("{id}")]
        public async Task<ActionResult<IntakeLogDto>> GetIntakeLog(Guid id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            var intakeLog = await _context.IntakeLogs
                .Include(il => il.Supplement)
                .ThenInclude(s => s.TypeRelations)
                .ThenInclude(tr => tr.Type)
                .FirstOrDefaultAsync(il => il.LogID == id);

            if (intakeLog == null)
            {
                return NotFound();
            }

            // Перевіряємо чи належить запис поточному користувачу
            if (intakeLog.UserID != userId)
            {
                return Forbid();
            }

            return Ok(await intakeLog.ToIntakeLogDtoAsync(_context));
        }

        // POST: api/IntakeLogs
        [HttpPost]
        public async Task<ActionResult<IntakeLogDto>> CreateIntakeLog(CreateIntakeLogDto createDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            // Перевіряємо чи існує добавка
            var supplement = await _context.Supplements
                .Include(s => s.TypeRelations)
                .ThenInclude(tr => tr.Type)
                .FirstOrDefaultAsync(s => s.SupplementID == createDto.SupplementID);

            if (supplement == null)
            {
                return NotFound("Добавка не знайдена");
            }

            // Перевіряємо чи має користувач доступ до цієї добавки
            if (!supplement.IsGlobal && supplement.CreatorId != userId)
            {
                return Forbid();
            }

            // Створюємо новий запис
            var intakeLog = createDto.ToIntakeLogFromCreateDto(userId);
            _context.IntakeLogs.Add(intakeLog);
            await _context.SaveChangesAsync();

            // Завантажуємо пов'язані дані для відповіді
            intakeLog.Supplement = supplement;

            return CreatedAtAction(nameof(GetIntakeLog), new { id = intakeLog.LogID }, 
                await intakeLog.ToIntakeLogDtoAsync(_context));
        }

        // POST: api/IntakeLogs/Batch
        [HttpPost("Batch")]
        public async Task<ActionResult<IEnumerable<IntakeLogDto>>> BatchCreateIntakeLogs(BatchCreateIntakeLogDto batchDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var result = new List<IntakeLogDto>();

            foreach (var createDto in batchDto.Logs)
            {
                // Перевіряємо чи існує добавка
                var supplement = await _context.Supplements
                    .Include(s => s.TypeRelations)
                    .ThenInclude(tr => tr.Type)
                    .FirstOrDefaultAsync(s => s.SupplementID == createDto.SupplementID);

                if (supplement == null)
                {
                    continue; // Пропускаємо невірні записи
                }

                // Перевіряємо чи має користувач доступ до цієї добавки
                if (!supplement.IsGlobal && supplement.CreatorId != userId)
                {
                    continue; // Пропускаємо записи без доступу
                }

                // Створюємо новий запис
                var intakeLog = createDto.ToIntakeLogFromCreateDto(userId);
                _context.IntakeLogs.Add(intakeLog);

                // Завантажуємо пов'язані дані для відповіді
                intakeLog.Supplement = supplement;
                result.Add(await intakeLog.ToIntakeLogDtoAsync(_context));
            }

            await _context.SaveChangesAsync();
            return Ok(result);
        }


        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteIntakeLog(Guid id)
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var intakeLog = await _context.IntakeLogs.FindAsync(id);

            if (intakeLog == null)
            {
                return NotFound();
            }

            // Перевіряємо чи належить запис поточному користувачу
            if (intakeLog.UserID != userId)
            {
                return Forbid();
            }

            _context.IntakeLogs.Remove(intakeLog);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
} 