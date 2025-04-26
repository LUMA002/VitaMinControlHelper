using api.DTOs.IntakeLog;
using api.Models;
using Microsoft.EntityFrameworkCore;

namespace api.Mappers
{
    public static class IntakeLogMappers
    {
        public static async Task<IntakeLogDto> ToIntakeLogDtoAsync(this IntakeLog intakeLog, DbContext context)
        {
            // Завантажуємо добавку, якщо вона не завантажена
            if (intakeLog.Supplement == null)
            {
                intakeLog.Supplement = await context.Set<Supplement>()
                    .Include(s => s.TypeRelations)
                    .ThenInclude(tr => tr.Type)
                    .FirstOrDefaultAsync(s => s.SupplementID == intakeLog.SupplementID)
                    ?? throw new Exception("Supplement not found");
            }

            return new IntakeLogDto
            {
                LogID = intakeLog.LogID,
                UserID = intakeLog.UserID,
                Supplement = intakeLog.Supplement.ToSupplementDto(),
                Quantity = intakeLog.Quantity,
                Dosage = intakeLog.Dosage, // Додано поле Dosage
                Unit = intakeLog.Unit,
                TakenAt = intakeLog.TakenAt
            };
        }

        public static IntakeLog ToIntakeLogFromCreateDto(this CreateIntakeLogDto createDto, string userId)
        {
            return new IntakeLog
            {
                LogID = Guid.NewGuid(),
                UserID = userId,
                SupplementID = createDto.SupplementID,
                Quantity = createDto.Quantity,
                Dosage = createDto.Dosage, // Додано поле Dosage
                Unit = createDto.Unit,
                TakenAt = createDto.TakenAt ?? DateTime.UtcNow
            };
        }
    }
}