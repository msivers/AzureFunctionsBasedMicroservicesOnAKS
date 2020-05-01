using System.Threading.Tasks;
using Microsoft.Extensions.Logging;

namespace SampleServices.Services.UserService
{
    public interface IB2CGraphClient
    {
        Task<string> GetUserByObjectId(string objectId, ILogger log);

        Task<string> GetAllUsers(string query, ILogger log);

        Task<string> CreateUser(B2CUser user, ILogger log);

        Task<string> UpdateUser(string objectId, string json, ILogger log);

        Task<string> DeleteUser(string objectId, ILogger log);
    }
}