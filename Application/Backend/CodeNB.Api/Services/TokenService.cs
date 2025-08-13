using CodeNB.API.Interfaces;
using CodeNB.Model;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace CodeNB.API.Services
{
    public class TokenService : ITokenService
    {
        private readonly IConfiguration _configuration;

        public TokenService(IConfiguration configuration)
        {
            _configuration = configuration;
        }
        public string CreateToken(LoginResultDto user)
        {
            string? jwtKey = _configuration["Jwt:Key"];
            if (string.IsNullOrWhiteSpace(jwtKey))
                throw new InvalidOperationException("Jwt:Key is not configured.");

            SymmetricSecurityKey key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));

            List<Claim> claims = [
                new Claim(JwtRegisteredClaimNames.Sub, user.ID.ToString()),
                new Claim("firstName", user.FirstName ?? ""),
                new Claim("lastName", user.LastName ?? ""),
                new Claim(ClaimTypes.Role, user.Role ?? ""),
            ];

            //Create new credentials for signing the token
            SigningCredentials creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            //Describe the token. What goes inside
            SecurityTokenDescriptor tokenDescriptor = new SecurityTokenDescriptor()
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.Now.AddDays(7),
                SigningCredentials = creds
            };

            //Create a new token handler
            JwtSecurityTokenHandler tokenHandler = new JwtSecurityTokenHandler();

            //Create the token
            SecurityToken token = tokenHandler.CreateToken(tokenDescriptor);

            //Write the token and return
            return tokenHandler.WriteToken(token);

        }
    }
}
