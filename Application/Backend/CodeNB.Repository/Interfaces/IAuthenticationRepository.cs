using CodeNB.Model;

namespace CodeNB.Repository
{
    public interface IAuthenticationRepository
    {
        Task<byte[]?> GetUserSalt(int? id);
        Task<LoginResultDto?> Login(LoginDto user);
    }
}
