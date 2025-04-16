using Microsoft.EntityFrameworkCore;
namespace api.Data

{
    public class ApplicationDBContext : DbContext
    {
        public ApplicationDBContext(DbContextOptions<ApplicationDBContext> options) : base(options)
        {
        }
        public DbSet<WeatherForecast> WeatherForecasts { get; set; }
    }
}
