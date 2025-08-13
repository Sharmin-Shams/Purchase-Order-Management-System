using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Service
{
    public interface IReviewService
    {
        Task<List<EmployeesForReviewResultDto>> GetPendingEmployeesForReview(int? id);
        Task<Review> Create(Review review);
        Task<List<EmployeeReviewDto>> GetReviews(int id);
        Task<bool> MarkReviewAsRead(int id);
        Task<bool> SendReminder();

    }
}
