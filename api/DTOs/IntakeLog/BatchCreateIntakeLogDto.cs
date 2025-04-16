namespace api.DTOs.IntakeLog
{
    public class BatchCreateIntakeLogDto
    {
        public List<CreateIntakeLogDto> Logs { get; set; } = new List<CreateIntakeLogDto>();
    }
} 