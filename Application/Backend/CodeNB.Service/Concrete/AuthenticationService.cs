using CodeNB.Model;
using CodeNB.Repository;
using CodeNB.Types;
using static CodeNB.Model.Constants;

namespace CodeNB.Service
{
    public class AuthenticationService : IAuthenticationService
    {
        private readonly IAuthenticationRepository repo;
        public AuthenticationService(IAuthenticationRepository repo)
        {
            this.repo = repo;
        }
        public async Task<LoginResultDto?> Login(LoginDto user)
        {
            if (!int.TryParse(user.Username, out int id) || user.Username?.Trim().Length != EMPLOYEE_ID_LENGTH)
                return null;

            var salt = await repo.GetUserSalt(id);

            if (salt == null) return null;

            user.Password = PasswordUtilityService.HashToSHA256(user.Password!, salt);

            if (user.Password is null) return null;

            return await repo.Login(user);
        }

        public LoginDto ValidateCredentials(LoginDto credentials)
        {
            credentials.Errors.Clear();

            foreach (var e in credentials.Validate())
                credentials.Errors.Add(new(e.ErrorMessage!, ErrorType.Model, e.MemberNames.FirstOrDefault() ?? ""));

            return credentials;
        }
    }
}
