using api.DTOs.Supplement;
using api.DTOs.SupplementType;
using api.Models;
using Microsoft.EntityFrameworkCore;

namespace api.Mappers
{
    public static class SupplementMappers
    {
        public static SupplementDto ToSupplementDto(this Supplement supplement)
        {
            return new SupplementDto
            {
                SupplementID = supplement.SupplementID,
                Name = supplement.Name,
                Description = supplement.Description,
                DeficiencySymptoms = supplement.DeficiencySymptoms,
                IsGlobal = supplement.IsGlobal,
                CreatorId = supplement.CreatorId,
                CreatedAt = supplement.CreatedAt,
                Types = supplement.TypeRelations?
                    .Select(tr => new SupplementTypeDto
                    {
                        TypeID = tr.Type.TypeID,
                        Name = tr.Type.Name
                    })
                    .ToList() ?? new List<SupplementTypeDto>()
            };
        }

        public static async Task<SupplementDto> ToSupplementDtoAsync(this Supplement supplement, DbContext context)
        {
            var result = new SupplementDto
            {
                SupplementID = supplement.SupplementID,
                Name = supplement.Name,
                Description = supplement.Description,
                DeficiencySymptoms = supplement.DeficiencySymptoms,
                IsGlobal = supplement.IsGlobal,
                CreatorId = supplement.CreatorId,
                CreatedAt = supplement.CreatedAt
            };

            // Завантажуємо типи, якщо вони не були завантажені
            if (supplement.TypeRelations == null)
            {
                result.Types = await context.Set<SupplementTypeRelation>()
                    .Where(tr => tr.SupplementID == supplement.SupplementID)
                    .Include(tr => tr.Type)
                    .Select(tr => new SupplementTypeDto
                    {
                        TypeID = tr.Type.TypeID,
                        Name = tr.Type.Name
                    })
                    .ToListAsync();
            }
            else
            {
                result.Types = supplement.TypeRelations
                    .Select(tr => new SupplementTypeDto
                    {
                        TypeID = tr.Type.TypeID,
                        Name = tr.Type.Name
                    })
                    .ToList();
            }

            return result;
        }

        public static Supplement ToSupplementFromCreateDto(this CreateSupplementDto createDto, string? creatorId = null)
        {
            return new Supplement
            {
                SupplementID = Guid.NewGuid(),
                Name = createDto.Name,
                Description = createDto.Description,
                DeficiencySymptoms = createDto.DeficiencySymptoms,
                IsGlobal = creatorId == null || createDto.IsGlobal,
                CreatorId = creatorId,
                CreatedAt = DateTime.UtcNow
            };
        }
    }
} 