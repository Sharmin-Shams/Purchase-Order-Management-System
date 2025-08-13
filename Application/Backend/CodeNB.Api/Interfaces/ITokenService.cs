using CodeNB.Model;

namespace CodeNB.API.Interfaces
{
    public interface ITokenService
    {
        string CreateToken(LoginResultDto user);
    }

}