using System.IO;
using System.Net;
using System.Threading.Tasks;

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

namespace SampleServices.Services.UserService
{
    public class Ping
    {
        [ProducesResponseType((int)HttpStatusCode.OK)]
        [FunctionName("Ping")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "healthcheck/users")] HttpRequest req, ILogger log, ExecutionContext context)
        {
            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();

            if (string.IsNullOrEmpty(requestBody))
                return (ActionResult)new OkObjectResult("Ping...");
            else
                return (ActionResult)new OkObjectResult(requestBody);
        }
    }
}