using CodeNB.Model;
using CodeNB.Repository;
using CodeNB.Types;
using System.Text;
using static EmailServices.EmailService;
using static CodeNB.Model.Constants;

namespace CodeNB.Service
{
    public class ReviewService : IReviewService
    {
        private readonly IReviewRepository repo;
        private readonly IEmployeeRepository empRepo;
        private readonly IEmailSender emailSender;
        private StringBuilder sb = new();
        public ReviewService(IReviewRepository repo, IEmailSender emailSender, IEmployeeRepository empRepo)
        {
            this.repo = repo;
            this.emailSender = emailSender;
            this.empRepo = empRepo;
        }

        public async Task<List<EmployeesForReviewResultDto>> GetPendingEmployeesForReview(int? id)
        {
            var pending = await repo.GetPendingEmployeesForReview(id);
            if (pending is null || pending.Count <= 0)
            {
                return [];
            }

            var groupedReviews = pending
                .GroupBy(p => new
                {
                    p.Year,
                    p.Quarter,
                    p.SupervisorID
                })
                .Select(g => new EmployeesForReviewResultDto
                {
                    Year = g.Key.Year,
                    Quarter = g.Key.Quarter,
                    Employees = [.. g
                        .Select(e => new EmployeeDto (e.EmployeeID, e.EmployeeFirstName!, e.EmployeeLastName!))
                        .OrderBy(e => e.LastName)
                        .ThenBy(e => e.FirstName)]
                })
                .OrderByDescending(x => x.Year)
                .ThenByDescending(x => x.Quarter)
                .ToList();

            return groupedReviews;
        }

        public async Task<Review> Create(Review review)
        {
            if (IsValid(review))
            {
                if (!await CanAddReview(review))
                {
                    review.Errors.Add(new(string.Format(RECORD_EXISTS, "Review"), ErrorType.Business, nameof(Review.ReviewDate)));
                }

                if (review.Errors.Count == 0)
                {
                    return await repo.Create(review);
                }

            }

            return review;
        }

        public async Task<List<EmployeeReviewDto>> GetReviews(int id)
        {
            return await repo.GetReviews(id);
        }

        public async Task<bool> MarkReviewAsRead(int id)
        {
            return await repo.MarkReviewAsRead(id);
        }

        public async Task<bool> SendReminder()
        {
            var today = DateTime.Today;
            var lastDaysOfQuarters = new[]
            {
                new DateTime(today.Year, 3, 31),  // Q1
                new DateTime(today.Year, 6, 30),  // Q2
                new DateTime(today.Year, 9, 30),  // Q3
                new DateTime(today.Year, 12, 31), // Q4
            };

            if (lastDaysOfQuarters.Any(q => q.Date == today.Date) || await IsReminderAlreadySent())
                return true;

            var reviews = await repo.GetPendingReviewsForReminder();
            if (reviews.Count == 0)
                return true;

            var nonOutstanding = reviews
                .Where(r => r.IsOutStanding.HasValue && !r.IsOutStanding.Value)
                .GroupBy(r => new
                {
                    r.SupervisorID,
                    r.SupervisorEmail,
                })
                .Select(group => new
                {
                    group.Key.SupervisorEmail,
                    Employees = group
                        .GroupBy(e => e.EmployeeID)
                        .Select(g => g.First())
                        .OrderBy(e => e.EmployeeLastName)
                        .ThenBy(e => e.EmployeeFirstName)
                        .Select(e => new
                        {
                            EmployeeName = $"{e.EmployeeLastName}, {e.EmployeeFirstName}"
                        }).ToList()
                }).ToList();


            var outstanding = reviews
                .Where(r => r.IsOutStanding.HasValue && r.IsOutStanding.Value)
                .GroupBy(r => new
                {
                    r.SupervisorID,
                    r.SupervisorEmail
                })
                .Select(group => new
                {
                    group.Key.SupervisorEmail,
                    Employees = group
                        .GroupBy(e => e.EmployeeID)
                        .Select(g => g.First())
                        .OrderBy(e => e.EmployeeLastName)
                        .ThenBy(e => e.EmployeeFirstName)
                        .Select(e => new
                        {
                            EmployeeName = $"{e.EmployeeLastName}, {e.EmployeeFirstName}"
                        }).ToList()
                }).ToList();

            if (nonOutstanding.Count == 0 && outstanding.Count == 0)
                return true;

            bool hasSentPendingEmail = false;

            foreach (var sv in nonOutstanding)
            {
                sb = new StringBuilder();
                sb.AppendLine("Dear Supervisor,");
                sb.AppendLine();
                sb.AppendLine("The following employee reviews are pending for the quarter:");
                sb.AppendLine();

                foreach (var emp in sv.Employees)
                {
                    sb.AppendLine($"- {emp.EmployeeName}");
                }

                var dto = new EmailMessageDto(
                    [sv.SupervisorEmail!],
                    "Reminder: Pending Employee Reviews",
                    sb.ToString()
                );


                emailSender.SendEmail(dto);
                hasSentPendingEmail = true;
            }

            List<string> CCs = [];
            if (outstanding.Count > 0)
            {
                var allEmp = await empRepo.GetAllEmployees(2);
                CCs = allEmp.Select(e => e.Email).ToList();
            }

            bool hasSentOutstandingEmail = false;
            foreach (var sv in outstanding)
            {
                sb = new StringBuilder();
                sb.AppendLine("Dear Supervisor,");
                sb.AppendLine();
                sb.AppendLine("The following employee reviews under your supervision remain outstanding:");
                sb.AppendLine();

                foreach (var emp in sv.Employees)
                {
                    sb.AppendLine($"- {emp.EmployeeName}");
                }

                var ccFiltered = CCs.Where(email => !sv.SupervisorEmail.IsEqualTo(email)).ToList();
                
                var dto = new EmailMessageDto(
                    [sv.SupervisorEmail!],
                    "Reminder: Outstanding Employee Reviews",
                    sb.ToString(),
                    ccFiltered
                );


                emailSender.SendEmail(dto);
                hasSentOutstandingEmail = true;
            }

            if (hasSentPendingEmail || hasSentOutstandingEmail)
                await LogReminder();

            return true;

        }

        private static bool IsValid(Review review)
        {
            review.Errors.Clear();

            foreach (var e in review.Validate())
                review.Errors.Add(new(e.ErrorMessage!, ErrorType.Model, e.MemberNames.FirstOrDefault() ?? ""));

            return review.Errors.Count == 0;
        }

        private async Task<bool> CanAddReview(Review review)
        {
            return await repo.ValidateEmployeeReviewExistsForYearAndQuarter(review);
        }

        private async Task<bool> IsReminderAlreadySent()
        {
            return await repo.ValidateHasSentReminder();
        }

        private async Task LogReminder()
        {
            await repo.LogReminder();
        }
    }
}
