/*using api.DTOs.UserSupplement;
using api.Models;
using Microsoft.EntityFrameworkCore;

namespace api.Mappers
{
    public static class UserSupplementMappers
    {
        public static async Task<UserSupplementDto> ToUserSupplementDtoAsync(this UserSupplement userSupplement, DbContext context)
        {
            // Завантажуємо добавку, якщо вона не завантажена
            if (userSupplement.Supplement == null)
            {
                userSupplement.Supplement = await context.Set<Supplement>()
                    .Include(s => s.TypeRelations)
                    .ThenInclude(tr => tr.Type)
                    .FirstOrDefaultAsync(s => s.SupplementID == userSupplement.SupplementID)
                    ?? throw new Exception("Supplement not found");
            }

            return new UserSupplementDto
            {
                UserSupplementID = userSupplement.UserSupplementID,
                UserID = userSupplement.UserID,
                Supplement = userSupplement.Supplement.ToSupplementDto(),
                DefaultDosage = userSupplement.DefaultDosage,
                DefaultUnit = userSupplement.DefaultUnit
            };
        }

        public static UserSupplement ToUserSupplementFromAddDto(this AddUserSupplementDto addDto, string userId)
        {
            return new UserSupplement
            {
                UserSupplementID = Guid.NewGuid(),
                UserID = userId,
                SupplementID = addDto.SupplementID,
                DefaultDosage = addDto.DefaultDosage,
                DefaultUnit = addDto.DefaultUnit
            };
        }
    }
} */