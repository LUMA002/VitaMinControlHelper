using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using api.Models;

namespace api.Data
{
    public class ApplicationDBContext : IdentityDbContext<User>
    {
        public ApplicationDBContext(DbContextOptions<ApplicationDBContext> options) : base(options)
        {
        }

        public DbSet<Supplement> Supplements { get; set; }
        public DbSet<SupplementType> SupplementTypes { get; set; }
        public DbSet<SupplementTypeRelation> SupplementTypeRelations { get; set; }
       // public DbSet<UserSupplement> UserSupplements { get; set; }
        public DbSet<IntakeLog> IntakeLogs { get; set; }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Налаштування індексів
            builder.Entity<Supplement>()
                   .HasIndex(s => new { s.Name, s.CreatorId })
                   .IsUnique();

            builder.Entity<SupplementType>()
                   .HasIndex(st => st.Name)
                   .IsUnique();

            // Налаштування каскадного видалення
            builder.Entity<Supplement>()
                   .HasOne(s => s.Creator)
                   .WithMany(u => u.CreatedSupplements)
                   .HasForeignKey(s => s.CreatorId)
                   .OnDelete(DeleteBehavior.SetNull);
        }
    }
}
