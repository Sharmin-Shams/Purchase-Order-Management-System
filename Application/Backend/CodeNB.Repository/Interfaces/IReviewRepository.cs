using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Repository
{
    public interface IReviewRepository
    {
        Task<List<ReviewDto>> GetPendingEmployeesForReview(int? id);

        Task<bool> ValidateEmployeeReviewExistsForYearAndQuarter(Review review);

        Task<Review> Create(Review review);

        Task<List<EmployeeReviewDto>> GetReviews(int id);

        Task<bool> MarkReviewAsRead(int id);

        Task<bool> ValidateHasSentReminder();

        Task<List<ReviewDto>> GetPendingReviewsForReminder();

        Task LogReminder();
    }
}
