using api.DTOs.SupplementType;
using api.Models;

namespace api.Mappers
{
    public static class SupplementTypeMappers
    {
        public static SupplementTypeDto ToSupplementTypeDto(this SupplementType supplementType)
        {
            return new SupplementTypeDto
            {
                TypeID = supplementType.TypeID,
                Name = supplementType.Name
            };
        }

        public static SupplementType ToSupplementTypeFromCreateDto(this CreateSupplementTypeDto createDto)
        {
            return new SupplementType
            {
                TypeID = Guid.NewGuid(),
                Name = createDto.Name
            };
        }
    }
} 