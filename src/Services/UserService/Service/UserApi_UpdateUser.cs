using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using IHttpClientFactory = System.Net.Http.IHttpClientFactory;

using AzureFunctions.Extensions.Swashbuckle.Attribute;
using Gremlin.Net.Driver;
using Gremlin.Net.Driver.Exceptions;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using RevolutionPlatform.RPLCommon;
using RevolutionPlatform.RPLHelpers;
using User = RevolutionPlatform.RPLCommon.User;

namespace SampleServices.Services.UserService
{
    public class UpdateUser : UserServiceBase
    {
        public UpdateUser(IHttpClientFactory httpClientFactory, IGremlinClient gremlinClient, IB2CGraphClient b2cGraphClient, TelemetryConfiguration telemetryConfiguration) : base(httpClientFactory, gremlinClient, b2cGraphClient, telemetryConfiguration)
        {
            // Calls base
        }

        [ProducesResponseType((int)HttpStatusCode.NoContent)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.BadRequest)]
        [FunctionName("UpdateUser")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "put", Route = "users/{id}")] 
            [RequestBodyType(typeof(User), "User")]
            HttpRequest req, string id, ILogger log, ExecutionContext context)
        {
            log.LogInformation($"{context?.FunctionName} processed a HTTP request.");
            // TelemetryClient.Context.Operation.Id = context?.InvocationId.ToString(); // No longer needed?

            string requestBody = new StreamReader(req.Body).ReadToEnd();
            var user = JsonConvert.DeserializeObject<User>(requestBody);

            if (user is null)
                return new BadRequestObjectResult("No User definition specified in body.");

            user.Id = user.Id ?? id;

            if (user.Id != id)
                return new BadRequestObjectResult("User Id provided in request JSON does not match the Id provided in the route.");

            try
            {
                var query = GremlinHelper.UpdateVertexQuery(id, user, log);
                var response = new GraphResponse(await GremlinClient.SubmitAsync<dynamic>(query));

                GremlinHelper.ThrowIfResponseInvalid(response);

                GremlinHelper.GraphTelemetryEvent(TelemetryClient, "GraphVertexUpdate", response, "vertex", "user");

                if (response.Entities == null || response.Entities.Count() < 1)
                    return new NotFoundResult();

                user = response.GetEntityAsType<User>();
            }
            catch (ResponseException ex)
            {
                GremlinHelper.HandleGraphResponseException(ex, log, context, TelemetryClient);
            }
            catch (Exception ex)
            {
                GremlinHelper.HandleGeneralException(ex, log, context, TelemetryClient);
            }

            return user != null ?
                new OkObjectResult(user) { StatusCode = 200 } :
                new OkObjectResult("Failed to update user.") { StatusCode = 500 };
        }
    }
}