using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using IHttpClientFactory = System.Net.Http.IHttpClientFactory;

using Gremlin.Net.Driver;
using Gremlin.Net.Driver.Exceptions;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using RevolutionPlatform.RPLCommon;
using RevolutionPlatform.RPLHelpers;

namespace SampleServices.Services.UserService
{
    public class DeleteUser : UserServiceBase
    {
        public DeleteUser(IHttpClientFactory httpClientFactory, IGremlinClient gremlinClient, IB2CGraphClient b2cGraphClient, TelemetryConfiguration telemetryConfiguration) : base(httpClientFactory, gremlinClient, b2cGraphClient, telemetryConfiguration)
        {
            // Calls base
        }

        [ProducesResponseType((int)HttpStatusCode.NoContent)]
        [ProducesResponseType((int)HttpStatusCode.NotFound)]
        [FunctionName("DeleteUser")]
        public async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "delete", Route = "users/{id}")] HttpRequest req, string id, ILogger log, ExecutionContext context)
        {
            log.LogInformation($"{context?.FunctionName} processed a HTTP request.");
            // TelemetryClient.Context.Operation.Id = context?.InvocationId.ToString(); // No longer needed?

            try
            {
                // FIND USER IN GRAPH

                var query = GremlinHelper.GetVertexQuery(id);
                var response = new GraphResponse(await GremlinClient.SubmitAsync<dynamic>(query));

                GremlinHelper.ThrowIfResponseInvalid(response);

                if (response.Entities == null || response.Entities.Count() < 1)
                    return new NotFoundResult();

                GremlinHelper.GraphTelemetryEvent(TelemetryClient, "GraphVertexRetrieve_DeleteUser", response, "vertex", "user");

                var user = response.GetEntityAsType<User>();


                // DELETE USER FROM B2C

                try
                {
                    var b2cCreatedUserResult = await B2CGraphClient.DeleteUser(user.IdentityId, log);
                }
                catch (Exception ex)
                {
                    var ignoreTask = Task.Run(() =>
                    {
                        log.LogError($"{context?.FunctionName} Delete B2C User Error: {ex.Message}");
                        TelemetryClient.TrackException(ex, new Dictionary<string, string>() { { "ExceptionType", "B2CUserDeleteError" }, { "UserName", user?.UserName }, { "EmailAddress", user?.PrimaryEmailAddress } }, null);
                    });
                }

                // DELETE USER FROM GRAPH

                query = GremlinHelper.DeleteVertexQuery(user.Id);
                response = new GraphResponse(await GremlinClient.SubmitAsync<dynamic>(query));

                GremlinHelper.ThrowIfResponseInvalid(response);

                GremlinHelper.GraphTelemetryEvent(TelemetryClient, "GraphVertexDelete", response, "vertex", "user");
            }
            catch (ResponseException ex)
            {
                GremlinHelper.HandleGraphResponseException(ex, log, context, TelemetryClient);
            }
            catch (Exception ex)
            {
                GremlinHelper.HandleGeneralException(ex, log, context, TelemetryClient);
            }

            return new StatusCodeResult(204);
        }
    }
}