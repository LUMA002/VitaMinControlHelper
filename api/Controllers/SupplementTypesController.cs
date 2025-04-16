using api.Data;
using api.DTOs.SupplementType;
using api.Mappers;
using api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SupplementTypesController : ControllerBase
    {
        private readonly ApplicationDBContext _context;

        public SupplementTypesController(ApplicationDBContext context)
        {
            _context = context;
        }

        // GET: api/SupplementTypes
        [HttpGet]
        public async Task<ActionResult<IEnumerable<SupplementTypeDto>>> GetSupplementTypes()
        {
            var types = await _context.SupplementTypes.ToListAsync();
            return Ok(types.Select(t => t.ToSupplementTypeDto()));
        }

        // GET: api/SupplementTypes/5
        [HttpGet("{id}")]
        public async Task<ActionResult<SupplementTypeDto>> GetSupplementType(Guid id)
        {
            var supplementType = await _context.SupplementTypes.FindAsync(id);

            if (supplementType == null)
            {
                return NotFound();
            }

            return Ok(supplementType.ToSupplementTypeDto());
        }

        // POST: api/SupplementTypes
        [HttpPost]
        [Authorize]
        public async Task<ActionResult<SupplementTypeDto>> CreateSupplementType(CreateSupplementTypeDto createDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            // Перевіряємо чи існує тип з такою назвою
            if (await _context.SupplementTypes.AnyAsync(st => st.Name == createDto.Name))
            {
                return BadRequest("Тип з такою назвою вже існує");
            }

            var supplementType = createDto.ToSupplementTypeFromCreateDto();
            _context.SupplementTypes.Add(supplementType);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetSupplementType), new { id = supplementType.TypeID }, supplementType.ToSupplementTypeDto());
        }

        // PUT: api/SupplementTypes/5
        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> UpdateSupplementType(Guid id, CreateSupplementTypeDto updateDto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var supplementType = await _context.SupplementTypes.FindAsync(id);
            if (supplementType == null)
            {
                return NotFound();
            }

            // Перевіряємо чи існує інший тип з такою назвою
            if (await _context.SupplementTypes.AnyAsync(st => st.Name == updateDto.Name && st.TypeID != id))
            {
                return BadRequest("Тип з такою назвою вже існує");
            }

            supplementType.Name = updateDto.Name;
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // DELETE: api/SupplementTypes/5
        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteSupplementType(Guid id)
        {
            var supplementType = await _context.SupplementTypes.FindAsync(id);
            if (supplementType == null)
            {
                return NotFound();
            }

            // Перевіряємо чи є зв'язки з добавками
            var hasRelations = await _context.SupplementTypeRelations.AnyAsync(str => str.TypeID == id);
            if (hasRelations)
            {
                return BadRequest("Неможливо видалити тип, який використовується в добавках");
            }

            _context.SupplementTypes.Remove(supplementType);
            await _context.SaveChangesAsync();

            return NoContent();
        }
    }
} 