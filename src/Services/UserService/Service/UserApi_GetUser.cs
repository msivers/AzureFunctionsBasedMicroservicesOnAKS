using System;
using System.Linq;
using System.Net;
using System.Security.Claims;
using System.Threading.Tasks;

using AzureExtensions.FunctionToken;
using AzureExtensions.FunctionToken.FunctionBinding.Enums;
using Gremlin.Net.Driver;
using Gremlin.Net.Driver.Exceptions;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using RevolutionPlatform.RPLCommon;
using RevolutionPlatform.RPLHelpers;
using IHttpClientFactory = System.Net.Http.IHttpClientFactory;

namespace SampleServices.Services.UserService
{
    public class GetUser : UserServiceBase
    {
        public GetUser(IHttpClientFactory httpClientFactory, IGremlinClient gremlinClient, IB2CGraphClient b2cGraphClient, TelemetryConfiguration telemetryConfiguration) : base(httpClientFactory, gremlinClient, b2cGraphClient, telemetryConfiguration)
        {
            // Calls base
        }

        [ProducesResponseType((int)HttpStatusCode.OK, Type = typeof(User[]))]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [ProducesResponseType((int)HttpStatusCode.Unauthorized)]
        [ProducesResponseType((int)HttpStatusCode.Forbidden)]
        [FunctionName("GetUser")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "users/{id}")] HttpRequest req, 
            string id, 
            ILogger log, 
            [FunctionToken] FunctionTokenResult token, 
            ExecutionContext context)
        {
            log.LogInformation($"{context?.FunctionName} processed a HTTP request.");

            // IMPORTANT: Authorization!
            var authResult = AuthValidation(req, token, id);
            if (!authResult.IsAuthorized)
                return authResult.ActionResult;

            User user = null;

            try
            {
                var query = GremlinHelper.GetVertexQuery<User>(id);
                var response = new GraphResponse(await GremlinClient.SubmitAsync<dynamic>(query));

                GremlinHelper.ThrowIfResponseInvalid(response);

                if (response.Entities == null || response.Entities.Count() < 1)
                    return new NotFoundResult();

                GremlinHelper.GraphTelemetryEvent(TelemetryClient, "GraphVertexRetrieve", response, "vertex", "user");

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

            return user != null ? (ActionResult)new OkObjectResult(user) : new NotFoundResult();
        }
    }
}