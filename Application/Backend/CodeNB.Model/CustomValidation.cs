using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static CodeNB.Model.Constants;

namespace CodeNB.Model
{
    internal class MinimumAgeAttribute : ValidationAttribute
    {
        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            if (value is DateTime dob)
            {
                if (CalculateAge(dob) < MINIMUM_AGE)
                    return new ValidationResult(string.Format(MIN_AGE_ERROR, MINIMUM_AGE), [validationContext.MemberName!]);

                return ValidationResult.Success;
            }

            return ValidationResult.Success;
        }

        private static int CalculateAge(DateTime dateOfBirth)
        {
            var today = DateTime.Today;
            int age = today.Year - dateOfBirth.Year;
            if (dateOfBirth > today.AddYears(-age)) age--;
            return age;
        }
    }

    internal class JobStartDateNotBeforeSeniorityDateAttribute : ValidationAttribute
    {
        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            var seniorityDate = (DateTime?)validationContext
                .ObjectType.GetProperty("SeniorityDate")!
                .GetValue(validationContext.ObjectInstance);

            if (seniorityDate == null)
                return ValidationResult.Success;

            if (value is DateTime jobStartDate && jobStartDate.Date < seniorityDate.Value.Date)
            {
                return new ValidationResult(string.Format(DATE_NOT_BEFORE_SENIORITY, validationContext.DisplayName),
                                 [validationContext.MemberName!]);
            }

            return ValidationResult.Success;
        }
    }

    internal class ConditionalQuantityValidationAttribute : ValidationAttribute
    {
        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            var item = (PurchaseOrderItem)validationContext.ObjectInstance;

            if (item.ItemDescription?.Trim().ToLower() == "no longer needed")
            {
                return ValidationResult.Success;
            }

            if (value is int quantity && quantity >= 1)
            {
                return ValidationResult.Success;
            }

            return new ValidationResult("Item quantity must be greater than zero.");
        }
    }

    internal class ConditionalPriceValidationAttribute : ValidationAttribute
    {
        protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
        {
            var item = (PurchaseOrderItem)validationContext.ObjectInstance;

            if (item.ItemDescription?.Trim().ToLower() == "no longer needed")
            {
                return ValidationResult.Success;
            }

            if (value is decimal price && price > 0.0m)
            {
                return ValidationResult.Success;
            }

            return new ValidationResult("Item price must be greater than zero.");
        }
    }

    internal class ReviewDateInRangeAttribute : ValidationAttribute
    {
        public string YearProperty { get; }
        public string QuarterProperty { get; }

        public ReviewDateInRangeAttribute(string yearProperty, string quarterProperty)
        {
            YearProperty = yearProperty;
            QuarterProperty = quarterProperty;
            ErrorMessage = "Review date is outside the valid date range for the specified year and quarter.";
        }

        protected override ValidationResult IsValid(object? value, ValidationContext validationContext)
        {
            if (value is not DateTime reviewDate)
                return ValidationResult.Success!;

            var yearProp = validationContext.ObjectType.GetProperty(YearProperty);
            var quarterProp = validationContext.ObjectType.GetProperty(QuarterProperty);

            if (yearProp == null || quarterProp == null)
                return new ValidationResult("Invalid property configuration.");

            int year = (int)yearProp.GetValue(validationContext.ObjectInstance)!;
            int quarter = (int)quarterProp.GetValue(validationContext.ObjectInstance)!;

            var start = GetQuarterStartDate(year, quarter).Date;
            var end = GetQuarterEndDate(year, quarter).Date;

            var today = DateTime.Today;
            if (year == today.Year && GetQuarter(today.Month) == quarter)
            {
                // Quarter is current → limit end date to today
                end = today;

                if (reviewDate.Date > today)
                {
                    return new ValidationResult(
                        "Review date cannot be in the future for the current quarter.",
                        [validationContext.MemberName!]
                    );
                }
            }

            if (reviewDate.Date >= start && reviewDate.Date <= end)
                return ValidationResult.Success!;

            return new ValidationResult(ErrorMessage, [validationContext.MemberName!]);
        }

        private DateTime GetQuarterStartDate(int year, int quarter) => quarter switch
        {
            1 => new DateTime(year, 1, 1),
            2 => new DateTime(year, 4, 1),
            3 => new DateTime(year, 7, 1),
            4 => new DateTime(year, 10, 1),
            _ => throw new ArgumentOutOfRangeException(nameof(quarter), "Quarter must be 1–4.")
        };

        private DateTime GetQuarterEndDate(int year, int quarter) => quarter switch
        {
            1 => new DateTime(year, 3, 31),
            2 => new DateTime(year, 6, 30),
            3 => new DateTime(year, 9, 30),
            4 => new DateTime(year, 12, 31),
            _ => throw new ArgumentOutOfRangeException(nameof(quarter), "Quarter must be 1–4.")
        };

        private int GetQuarter(int month) => (month - 1) / 3 + 1;
    }

}
