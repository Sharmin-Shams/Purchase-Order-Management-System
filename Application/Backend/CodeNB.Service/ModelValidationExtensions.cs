using System.ComponentModel.DataAnnotations;
using System.Reflection;

namespace CodeNB.Service
{
    public static class ModelValidationExtensions
    {
        public static List<ValidationResult> Validate<T>(this T instance, bool validateAllProperties = true)
        {
            if (instance == null)
                throw new ArgumentNullException(nameof(instance), $"The {nameof(instance)} instance is null.");

            var results = new List<ValidationResult>();
            var context = new ValidationContext(instance);

            Validator.TryValidateObject(instance, context, results, validateAllProperties);

            return results;
        }

        public static List<ValidationResult> Validate<T>(this T instance, string propertyName)
        {
            if (instance == null)
                throw new ArgumentNullException(nameof(instance), $"The {nameof(instance)} instance is null.");

            var results = new List<ValidationResult>();
            var context = new ValidationContext(instance);
            var property = typeof(T).GetProperty(propertyName);

            if (property != null)
            {
                context.MemberName = propertyName;
                Validator.TryValidateProperty(property.GetValue(instance), context, results);
            }

            return results;
        }
        public static string GetDisplayName<T>(this T instance, string propertyName)
        {
            if (instance == null)
                throw new ArgumentNullException(nameof(instance), $"The {nameof(instance)} instance is null.");

            var property = typeof(T).GetProperty(propertyName);
            var displayAttr = property?.GetCustomAttribute<DisplayAttribute>();
            return displayAttr?.Name ?? propertyName;
        }

        public static bool IsEqualTo(this Enum _enum, string? value)
        {
            if (value == null) return false;
            return string.Equals(_enum.ToString().Trim(), value?.Trim(), StringComparison.OrdinalIgnoreCase);
        }
        public static bool IsEqualTo(this string? str, string? value)
        {
            return string.Equals(str?.Trim(), value?.Trim(), StringComparison.OrdinalIgnoreCase);
        }
    }
}
