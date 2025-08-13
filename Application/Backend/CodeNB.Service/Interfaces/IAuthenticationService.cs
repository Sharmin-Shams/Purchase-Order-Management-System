using CodeNB.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CodeNB.Service
{
    public interface IAuthenticationService
    {
        Task<LoginResultDto?> Login(LoginDto user);
        LoginDto ValidateCredentials(LoginDto credentials);
    }
}
