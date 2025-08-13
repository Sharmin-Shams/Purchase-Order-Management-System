using CodeNB.Model;
using CodeNB.Types;
using DAL;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace CodeNB.Repository
{
    public class ReviewRepository : IReviewRepository
    {
        private readonly IDataAccess _db;
        public ReviewRepository(IDataAccess db)
        {
            _db = db;
        }

        public async Task<List<ReviewDto>> GetPendingEmployeesForReview(int? id)
        {

            List<Parm> parms = [
                new("@SupervisorID", SqlDbType.Int, !id.HasValue ? DBNull.Value : id),
                new("@StartYear", SqlDbType.Int, 2024)
            ];


            DataTable dt = await _db.ExecuteAsync("spGetPendingEmployeeReviews", parms);

            return [.. dt
                .AsEnumerable()
                .Select(row => PopulatePendingReviewDto(row))
            ];
        }

        public async Task<bool> ValidateEmployeeReviewExistsForYearAndQuarter(Review review)
        {
            List<Parm> parms = [
                new("@EmployeeID", SqlDbType.Int, review.EmployeeID),
                new("@SupervisorID", SqlDbType.Int,  review.SupervisorID),
                new("@Year", SqlDbType.Int, review.Year),
                new("@Quarter", SqlDbType.Int, review.Quarter)
            ];

            return Convert.ToBoolean(
                  await _db.ExecuteScalarAsync("spCheckIfReviewCanBeAdded", parms)
            );
        }

        public async Task<Review> Create(Review r)
        {
            List<Parm> parms = [
                new("@ID", SqlDbType.Int, r.ID, direction: ParameterDirection.Output),
                new("@EmployeeID", SqlDbType.Int, r.EmployeeID),
                new("@SupervisorID", SqlDbType.Int, r.SupervisorID),
                new("@RatingID", SqlDbType.Int, r.RatingID),
                new("@Year", SqlDbType.Int, r.Year),
                new("@Quarter", SqlDbType.Int, r.Quarter),
                new("@Comment", SqlDbType.NVarChar, r.Comment!.Trim()),
                new("@ReviewDate", SqlDbType.Date, r.ReviewDate?.Date),
            ];

            if (await _db.ExecuteNonQueryAsync("spInsertReview", parms) <= 0)
                throw new DataException("There was an issue adding the record to the database.");

            r.ID = (int?)parms.FirstOrDefault(p => p.Name == "@ID")!.Value ?? 0;

            return r;
        }

        public async Task<List<EmployeeReviewDto>> GetReviews(int id)
        {
            List<Parm> parms = [
                new("@EmployeeID", SqlDbType.Int, id)
            ];

            DataTable dt = await _db.ExecuteAsync("spGetReviews", parms);

            return [.. dt
                .AsEnumerable()
                .Select(row => new EmployeeReviewDto {
                    ID = (int)row["ID"],
                    Year = (int)row["Year"],
                    Quarter = Convert.ToInt32(row["Quarter"]),
                    ReviewDate = (DateTime)row["ReviewDate"],
                    Comment = row["Comment"].ToString()!,
                    Rating = row["Rating"].ToString()!,
                    SupervisorName =  row["SupervisorName"].ToString()!,
                    IsRead = row["IsRead"] != DBNull.Value && (bool)row["IsRead"],
                })
            ];
        }

        public async Task<bool> MarkReviewAsRead(int id)
        {
            List<Parm> parms = [
                 new("@ID", SqlDbType.Int, id)
             ];

            if (await _db.ExecuteNonQueryAsync("spMarkReviewAsRead", parms) <= 0)
                return false;

            return true;
        }

        public async Task<bool> ValidateHasSentReminder()
        {
            return Convert.ToBoolean(
                  await _db.ExecuteScalarAsync("CheckIfReminderSentToday")
            );
        }

        public async Task<List<ReviewDto>> GetPendingReviewsForReminder()
        {
            DataTable dt = await _db.ExecuteAsync("spGetPendingReviewsForReminder");

            return [.. dt
                .AsEnumerable()
                .Select(row => {
                    var r = PopulatePendingReviewDto(row);
                    r.IsOutStanding = Convert.ToBoolean(row["IsOutStanding"]);
                    return r;
                })
            ];
        }

        public async Task LogReminder()
        {
            if (await _db.ExecuteNonQueryAsync("InsertReminderLog") <= 0)
                throw new DataException("There was an issue logging to the database.");
        }

        private static ReviewDto PopulatePendingReviewDto(DataRow row)
        {
            return new ReviewDto
            {
                Year = (int)row["Year"],
                Quarter = (int)row["Quarter"],
                SupervisorID = (int)row["SupervisorID"],
                SupervisorName = row["SupervisorName"].ToString(),
                SupervisorEmail = row["SupervisorEmail"].ToString(),
                EmployeeID = (int)row["EmployeeID"],
                EmployeeLastName = row["EmployeeLastName"].ToString(),
                EmployeeFirstName = row["EmployeeFirstName"].ToString()
            };
        }
    }
}
